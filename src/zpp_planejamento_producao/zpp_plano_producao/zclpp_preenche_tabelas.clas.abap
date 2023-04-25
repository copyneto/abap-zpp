"!<p><h2>Classe para converter Xstring (Excel) para internal table</h2></p>
"!<p><strong>Autor:</strong> Thiago da Graça</p>
"!<p><strong>Data:</strong> 30 de ago de 2021</p>
CLASS zclpp_preenche_tabelas DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    "! Converte xstring para tabela interna
    "! @parameter iv_xstring | Arquivo Xstring
    "! @parameter iv_nome_arq | Nome do arquivo
    "! @parameter ct_tabela | Tabela tipificada
    METHODS converte_xstring_para_it
      IMPORTING
        !iv_xstring  TYPE xstring
        !iv_nome_arq TYPE rsfilenm
      CHANGING
        !ct_tabela   TYPE STANDARD TABLE .
    "! Insere dados na tabela ztpp_arq_prod
    "! @parameter iv_nome_arq | Nome do arquivo
    "! @parameter iv_type | Tipo de arquivo de planejamento de produção
    "! @parameter iv_guid | GUID em formato 'RAW'
    "! @parameter iv_plant | Centro
    METHODS insert_ztpp_arq_prod
      IMPORTING
        !iv_nome_arq TYPE rsfilenm
        !iv_type     TYPE ze_producao_filetype
        !iv_guid     TYPE guid_16
        !iv_plant    TYPE werks_d.
    "! Insere dados na tabela ztpp_prod_medio
    "! @parameter it_tabela | Tabela tipificada
    "! @parameter iv_guid | GUID em formato 'RAW'
    "! @parameter et_return | Mensagens de retorno
    METHODS insert_ztpp_prod_curto
      IMPORTING
        !it_tabela TYPE STANDARD TABLE
        !iv_guid   TYPE guid_16
      EXPORTING
        et_return  TYPE bapiret2_t.

    "! Insere dados na tabela ztpp_prod_medio
    "! @parameter it_tabela | Tabela tipificada
    "! @parameter iv_guid | GUID em formato 'RAW'
    "! @parameter et_return | Mensagens de retorno
    METHODS insert_ztpp_prod_medio
      IMPORTING
        !it_tabela TYPE STANDARD TABLE
        !iv_guid   TYPE guid_16
      EXPORTING
        et_return  TYPE bapiret2_t.


    "! Preenche tabela dos componentes
    "! @parameter is_line | Linha da tabela
    "! @parameter ct_tabela | Tabela tipificada
    METHODS preenche_tabela_componentes
      IMPORTING
        !is_line   TYPE any
      CHANGING
        !ct_tabela TYPE STANDARD TABLE .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclpp_preenche_tabelas IMPLEMENTATION.

  METHOD converte_xstring_para_it.
    DATA: lo_ref_descr TYPE REF TO cl_abap_structdescr,
          lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet.

    DATA: lt_detail TYPE abap_compdescr_tab.

    FIELD-SYMBOLS : <fs_data>      TYPE STANDARD TABLE.

    TRY .
        lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
                                document_name = CONV #( iv_nome_arq )
                                xdocument     = iv_xstring ) .
      CATCH cx_fdt_excel_core.
        "Implement suitable error handling here
    ENDTRY .

    "Get List of Worksheets
    lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
      IMPORTING
        worksheet_names = DATA(lt_worksheets) ).

    IF NOT lt_worksheets IS INITIAL.
      READ TABLE lt_worksheets INTO DATA(lv_woksheetname) INDEX 1.

      DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
                                               lv_woksheetname ).
      "now you have excel work sheet data in dyanmic internal table
      ASSIGN lo_data_ref->* TO <fs_data>.

      LOOP AT <fs_data> ASSIGNING FIELD-SYMBOL(<fs_line>) FROM 2. "Ignorar linha do cabeçalho
        me->preenche_tabela_componentes( EXPORTING is_line = <fs_line> CHANGING ct_tabela = ct_tabela ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD insert_ztpp_arq_prod.

    DATA ls_prod TYPE ztpp_arq_prod.

    ls_prod-id          = iv_guid.
    ls_prod-name        = iv_nome_arq.
    ls_prod-userid      = sy-uname.
    ls_prod-import_date = sy-datum.
    ls_prod-import_time = sy-uzeit.
    ls_prod-type        = iv_type.
    ls_prod-status      = 'L'.
    ls_prod-plant       = iv_plant.

    MODIFY ztpp_arq_prod FROM ls_prod.

  ENDMETHOD.


  METHOD insert_ztpp_prod_curto.

    DATA: ls_curto TYPE ztpp_prod_curto.

    DATA: lt_curto TYPE TABLE OF ztpp_prod_curto.

    DATA: lr_range     TYPE RANGE OF mara-meins,
          lr_range_aux TYPE RANGE OF mara-meins.

    FREE: et_return.

    LOOP AT it_tabela ASSIGNING FIELD-SYMBOL(<fs_curto>).
      MOVE-CORRESPONDING <fs_curto> TO ls_curto.

      ls_curto-id    = iv_guid.
      ls_curto-line  = ls_curto-line + 1.

      APPEND ls_curto TO lt_curto.
    ENDLOOP.

    DELETE lt_curto WHERE pldord_profile = ''.           "#EC CI_STDSEQ

    lr_range = VALUE #( FOR ls_curto_aux IN lt_curto ( sign = 'I' option = 'EQ' low = ls_curto_aux-unit ) ).

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_RANGE_I'
      EXPORTING
        input          = sy-repid
        language       = sy-langu
      TABLES
        range_int      = lr_range_aux
        range_ext      = lr_range
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_curto ASSIGNING FIELD-SYMBOL(<fs_curto_aux>).
      READ TABLE lr_range_aux ASSIGNING FIELD-SYMBOL(<fs_range>) INDEX sy-tabix.
      IF sy-subrc = 0.
        <fs_curto_aux>-unit = <fs_range>-low.
      ENDIF.
    ENDLOOP.

    DATA(lt_curto_key) = lt_curto[].
    SORT lt_curto_key BY plan_plant.
    DELETE ADJACENT DUPLICATES FROM lt_curto_key COMPARING plan_plant.

    IF lines( lt_curto_key ) > 1.
      " Mais de um centro encontrado no arquivo, favor corrigir.
      et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZPP_PLANO_PRODUCAO' number = '003' ) ).
      RETURN.
    ENDIF.

    MODIFY ztpp_prod_curto FROM TABLE lt_curto.

  ENDMETHOD.


  METHOD insert_ztpp_prod_medio.

    DATA: ls_medio TYPE ztpp_prod_medio.

    DATA: lt_medio TYPE TABLE OF ztpp_prod_medio.

    DATA: lr_range     TYPE RANGE OF mara-meins,
          lr_range_aux TYPE RANGE OF mara-meins.

    FREE: et_return.

    LOOP AT it_tabela ASSIGNING FIELD-SYMBOL(<fs_medio>).
      MOVE-CORRESPONDING <fs_medio> TO ls_medio.

      ls_medio-id    = iv_guid.
      ls_medio-line  = ls_medio-line + 1.

      APPEND ls_medio TO lt_medio.
    ENDLOOP.

    DELETE lt_medio WHERE material = ''.                 "#EC CI_STDSEQ

    lr_range = VALUE #( FOR ls_medio_aux IN lt_medio ( sign = 'I' option = 'EQ' low = ls_medio_aux-unit ) ).

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_RANGE_I'
      EXPORTING
        input          = sy-repid
        language       = sy-langu
      TABLES
        range_int      = lr_range_aux
        range_ext      = lr_range
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_medio ASSIGNING FIELD-SYMBOL(<fs_medio_aux>).
      READ TABLE lr_range_aux ASSIGNING FIELD-SYMBOL(<fs_range>) INDEX sy-tabix.
      IF sy-subrc = 0.
        <fs_medio_aux>-unit = <fs_range>-low.
      ENDIF.
    ENDLOOP.

    DATA(lt_medio_key) = lt_medio[].
    SORT lt_medio_key BY plant.
    DELETE ADJACENT DUPLICATES FROM lt_medio_key COMPARING plant.

    IF lines( lt_medio_key ) > 1.
      " Mais de um centro encontrado no arquivo, favor corrigir.
      et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZPP_PLANO_PRODUCAO' number = '003' ) ).
      RETURN.
    ENDIF.

    MODIFY ztpp_prod_medio FROM TABLE lt_medio.

  ENDMETHOD.


  METHOD preenche_tabela_componentes.
    DATA: lo_ref_descr TYPE REF TO cl_abap_structdescr.

    DATA: lt_detail TYPE abap_compdescr_tab.

    DATA: lv_value TYPE bapi_current_sales_price,
          lv_qty   TYPE char13,
          lv_data  TYPE char10,
          lv_guid  TYPE char16.

    ASSIGN is_line TO FIELD-SYMBOL(<fs_line>).

    APPEND INITIAL LINE TO ct_tabela ASSIGNING FIELD-SYMBOL(<fs_return>).

    lo_ref_descr ?= cl_abap_typedescr=>describe_by_data( <fs_return> ).
    lt_detail[] = lo_ref_descr->components.

    LOOP AT lt_detail ASSIGNING FIELD-SYMBOL(<fs_detail>).

      ASSIGN COMPONENT <fs_detail>-name OF STRUCTURE <fs_return> TO FIELD-SYMBOL(<fs_ref>).
      ASSIGN COMPONENT sy-tabix         OF STRUCTURE <fs_line>   TO FIELD-SYMBOL(<fs_line_value>).

      IF <fs_ref> IS ASSIGNED AND <fs_line_value> IS ASSIGNED.
        CASE <fs_detail>-type_kind.
          WHEN 'D'.
            IF <fs_line_value> IS NOT INITIAL.
              lv_data = <fs_line_value>.
              TRANSLATE lv_data USING '/ . '.
              CONDENSE lv_data NO-GAPS.
              lv_data = |{ lv_data+4(4) }{ lv_data+2(2) }{ lv_data(2) }|.
              ASSIGN lv_data TO <fs_line_value>.
            ENDIF.

          WHEN 'P'.
            lv_qty = <fs_line_value>.
            CONDENSE lv_qty NO-GAPS.

            FIND ALL OCCURRENCES OF REGEX '[,.]' IN lv_qty RESULTS DATA(lt_result).

            IF sy-subrc EQ 0.
              " Recupera último registro
              DATA(ls_result) = lt_result[ lines( lt_result ) ].

              CASE lv_qty+ls_result-offset(ls_result-length).
                WHEN ','.
                  TRANSLATE lv_qty USING '. '.
                  TRANSLATE lv_qty USING ',.'.
                  CONDENSE  lv_qty NO-GAPS.
                WHEN '.'.
                  TRANSLATE lv_qty USING ', '.
                  CONDENSE  lv_qty NO-GAPS.
              ENDCASE.
            ENDIF.

            ASSIGN lv_qty TO <fs_line_value>.


          WHEN 'X'.
            lv_guid = <fs_line_value>.
            lv_guid = to_upper( lv_guid ).
            TRANSLATE lv_guid USING '- '.
            CONDENSE lv_guid NO-GAPS .
            ASSIGN lv_guid TO <fs_line_value>.
        ENDCASE.

        TRY .
            <fs_ref> = <fs_line_value>.
          CATCH cx_root.
        ENDTRY.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
