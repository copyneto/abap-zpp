"!<p><h2>Classe para converter Xstring (Excel) para internal table</h2></p>
"!<p><strong>Autor:</strong> Marcos Rubik</p>
"!<p><strong>Data:</strong> 17 de Junho de 2022</p>
class ZCLPP_PREENCHE_TABELAS_NOR_AP definition
  public
  final
  create public .

PUBLIC SECTION.
  TYPES: tt_string TYPE TABLE OF string.

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
  METHODS insert_ztpp_nrm_apr_con
    IMPORTING
      !it_tabela TYPE STANDARD TABLE
      !iv_guid   TYPE guid_16
    EXPORTING
      !et_return TYPE bapiret2_t .
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



CLASS ZCLPP_PREENCHE_TABELAS_NOR_AP IMPLEMENTATION.


  METHOD CONVERTE_XSTRING_PARA_IT.
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


  METHOD insert_ztpp_nrm_apr_con.
    DATA: lv_guid      TYPE guid_16,
          lv_timestamp TYPE timestamp.

    DATA: ls_norma_apro TYPE ztpp_nrm_apr_con.

    DATA: lt_norma_apro TYPE TABLE OF ztpp_nrm_apr_con.

    DATA: lr_range     TYPE RANGE OF mara-meins,
          lr_range_aux TYPE RANGE OF mara-meins.

    FREE: et_return.

    GET TIME STAMP FIELD lv_timestamp.

    SELECT SINGLE plant, status
       FROM ztpp_nrm_apr_h
       INTO @DATA(ls_nrm_apr_h)
      WHERE doc_uuid_h = @iv_guid.
    IF sy-subrc EQ 0.
      IF ls_nrm_apr_h-status EQ '3'.
        et_return = VALUE #( ( type   = 'E'
                               id     = 'ZPP_APROPRIACAO'
                               number = '008' ) ).
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT it_tabela ASSIGNING FIELD-SYMBOL(<fs_norma_apro>).
      MOVE-CORRESPONDING <fs_norma_apro> TO ls_norma_apro.

      CHECK ls_norma_apro-material is NOT INITIAL.

      TRY.
          lv_guid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.

      ls_norma_apro-material         = |{ ls_norma_apro-material WIDTH = 18 ALIGN = RIGHT PAD = '0' }|.
      ls_norma_apro-plant            = ls_nrm_apr_h-plant.
      ls_norma_apro-doc_uuid_h       = iv_guid.
      ls_norma_apro-doc_uuid_consumo = lv_guid.
      ls_norma_apro-created_by       = sy-uname.
      ls_norma_apro-created_at       = lv_timestamp.

      APPEND ls_norma_apro TO lt_norma_apro.
    ENDLOOP.

    lr_range = VALUE #( FOR ls_norma_apro_aux IN lt_norma_apro ( sign = 'I' option = 'EQ' low = ls_norma_apro_aux-entry_uom ) ).

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

    LOOP AT lt_norma_apro ASSIGNING FIELD-SYMBOL(<fs_curto_aux>).
      READ TABLE lr_range_aux ASSIGNING FIELD-SYMBOL(<fs_range>) INDEX sy-tabix.
      IF sy-subrc = 0.
        <fs_curto_aux>-entry_uom = <fs_range>-low.
      ENDIF.
    ENDLOOP.

*    DATA(lt_norma_apro_key) = lt_norma_apro[].
*    SORT lt_norma_apro_key BY plan_plant.
*    DELETE ADJACENT DUPLICATES FROM lt_norma_apro_key COMPARING plan_plant.
*
*    IF lines( lt_norma_apro_key ) > 1.
*      " Mais de um centro encontrado no arquivo, favor corrigir.
*      et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZPP_PLANO_PRODUCAO' number = '003' ) ).
*      RETURN.
*    ENDIF.

    MODIFY ztpp_nrm_apr_con FROM TABLE lt_norma_apro.

  ENDMETHOD.


  METHOD PREENCHE_TABELA_COMPONENTES.
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
