"!<p>Classe para refugo de operação</p>
"!<p><strong>Autor:</strong> Caio Mossmann</p>
"!<p><strong>Data:</strong> 11 de ago de 2021</p>
CLASS zclpp_refugo_de_operacao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    "! Executa toda a rotina da classe
    "! @parameter iv_material   | Nº do material
    "! @parameter iv_quantidade | Quantidade na unidade de medida do registro
    "! @parameter iv_unidade    | Unidade de medida do registro
    "! @parameter iv_ordem      | Nº ordem
    METHODS
      execute
        IMPORTING
          iv_material   TYPE matnr18
          iv_quantidade TYPE erfmg
          iv_unidade    TYPE erfme
          iv_ordem      TYPE aufnr
        RAISING
          zcxpp_erro_interface_mes.

  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ty_selected_data,
             matnr TYPE mchb-matnr,
             charg TYPE mchb-charg,
             werks TYPE mchb-werks,
             lgort TYPE mchb-lgort,
             clabs TYPE mchb-clabs,
           END OF ty_selected_data .
  types:
    ty_selected_table TYPE TABLE OF ty_selected_data .
  types:
    ty_bapi_item      TYPE TABLE OF bapi2017_gm_item_create .

      "! Seleciona de dados
      "! @parameter iv_material | Nº do material
      "! @parameter iv_ordem    | Nº ordem
      "! @parameter et_table    | Tabela com os dados selecionados
  methods SELECT_DATA
    importing
      !IV_MATERIAL type MATNR18
      !IV_ORDEM type AUFNR
    exporting
      !ET_TABLE type TY_SELECTED_TABLE
    raising
      ZCXPP_ERRO_INTERFACE_MES .
      "! Preenche a tabela de itens para a Bapi
      "! @parameter iv_quantidade    | Quantidade na unidade de medida do registro
      "! @parameter iv_unidade       | Unidade de medida do registro
      "! @parameter iv_ordem         | Nº ordem
      "! @parameter it_selected_data | Tabela com os dados selecionados
      "! @parameter et_bapi_item     | Tabela de itens para a Bapi
  methods FILL_TABLE
    importing
      !IV_QUANTIDADE type ERFMG
      !IV_UNIDADE type ERFME
      !IV_ORDEM type AUFNR
      !IT_SELECTED_DATA type TY_SELECTED_TABLE
    exporting
      !ET_BAPI_ITEM type TY_BAPI_ITEM .
      "! Chama a Bapi BAPI_GOODSMVT_CREATE
      "! @parameter ct_item   | Tabela de itens para a Bapi
  methods CALL_BAPI
    importing
      !IV_QUANTIDADE type ERFMG
      !IV_UNIDADE type ERFME
      !IV_ORDEM type AUFNR
      !IV_MATERIAL type MATNR18
    changing
      !CT_ITEM type TY_BAPI_ITEM
    raising
      ZCXPP_ERRO_INTERFACE_MES .
  methods NUMBER_GET_NEXT
    returning
      value(RV_PROX_NUM) type /PTLGPN/ED086
    raising
      ZCXPP_ERRO_INTERFACE_MES .
ENDCLASS.



CLASS ZCLPP_REFUGO_DE_OPERACAO IMPLEMENTATION.


  METHOD execute.

    select_data(
      EXPORTING
        iv_material = iv_material
        iv_ordem    = |{ iv_ordem ALPHA = IN }|
      IMPORTING
        et_table    = DATA(lt_selected_data) ).

    fill_table(
      EXPORTING
        it_selected_data = lt_selected_data
        iv_ordem         = |{ iv_ordem ALPHA = IN }|
        iv_quantidade    = iv_quantidade
        iv_unidade       = iv_unidade
      IMPORTING
        et_bapi_item     = DATA(lt_bapi_item) ).

    call_bapi(
      EXPORTING
        iv_quantidade    = iv_quantidade
        iv_unidade       = iv_unidade
        iv_ordem         = |{ iv_ordem ALPHA = IN }|
        iv_material      = iv_material
      CHANGING
        ct_item = lt_bapi_item
    ).

  ENDMETHOD.


  METHOD select_data.

    CONSTANTS:
      lc_clabs TYPE mchb-clabs VALUE '0',

      BEGIN OF lc_exception,
        id TYPE symsgid VALUE 'ZPP_INTERFACES_MES',
        n1 TYPE symsgno VALUE '001',
        n2 TYPE symsgno VALUE '002',
        n3 TYPE symsgno VALUE '003',
      END OF lc_exception.


    SELECT SINGLE
        productionplant
        FROM i_manufacturingorder
        INTO @DATA(lv_planta)
        WHERE manufacturingorder EQ @iv_ordem.

    IF sy-subrc IS NOT INITIAL.

      RAISE EXCEPTION TYPE zcxpp_erro_interface_mes
        EXPORTING
          is_textid = VALUE #( msgid = lc_exception-id
                               msgno = lc_exception-n1
                               attr1 = iv_ordem ).

    ENDIF.

    SELECT SINGLE
        lgpro
        FROM marc
        INTO @DATA(lv_deposito)
        WHERE matnr EQ @iv_material
        AND   werks EQ @lv_planta.

    IF sy-subrc IS NOT INITIAL.

      RAISE EXCEPTION TYPE zcxpp_erro_interface_mes
        EXPORTING
          is_textid = VALUE #( msgid = lc_exception-id
                               msgno = lc_exception-n2
                               attr1 = iv_ordem
                               attr2 = iv_material
                               attr3 = lv_planta ).

    ENDIF.

    SELECT
        matnr
        charg
        werks
        lgort
        clabs
       FROM mchb
       INTO TABLE et_table
       WHERE matnr EQ iv_material
       AND   werks EQ lv_planta
       AND   lgort EQ lv_deposito
       AND   clabs NE lc_clabs.

    IF sy-subrc IS NOT INITIAL.

      RAISE EXCEPTION TYPE zcxpp_erro_interface_mes
        EXPORTING
          is_textid = VALUE #( msgid = lc_exception-id
                               msgno = lc_exception-n3
                               attr1 = iv_ordem
                               attr2 = iv_material
                               attr3 = lv_planta ).

    ENDIF.

    SORT et_table BY charg.

  ENDMETHOD.


  METHOD fill_table.

    CONSTANTS:

      BEGIN OF lc_parametro,
        modulo TYPE zi_ca_param_mod-modulo VALUE 'PP',
        chave1 TYPE zi_ca_param_par-chave1 VALUE 'IF_SAP_MES',
        chave2 TYPE zi_ca_param_par-chave2 VALUE 'MOVE_TYPE_REFUGO',
      END OF lc_parametro.

    DATA: lv_qtde_aux  LIKE iv_quantidade,
          ls_bapi_item LIKE LINE OF et_bapi_item,
          lr_move_type TYPE RANGE OF bwart.

    lv_qtde_aux = iv_quantidade.

    DATA(lo_parametro) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_parametro->m_get_range(
          EXPORTING
            iv_modulo = lc_parametro-modulo
            iv_chave1 = lc_parametro-chave1
            iv_chave2 = lc_parametro-chave2
          IMPORTING
            et_range  = lr_move_type ).
      CATCH zcxca_tabela_parametros.

    ENDTRY.

    READ TABLE lr_move_type INTO DATA(ls_move_type) INDEX 1.
    IF sy-subrc IS INITIAL.

      DATA(lv_move_type) = ls_move_type-low.

    ENDIF.

    LOOP AT it_selected_data ASSIGNING FIELD-SYMBOL(<fs_selected>).

      lv_qtde_aux = lv_qtde_aux - <fs_selected>-clabs.

      ls_bapi_item-material = <fs_selected>-matnr.
      ls_bapi_item-plant    = <fs_selected>-werks.
      ls_bapi_item-stge_loc = <fs_selected>-lgort.
      ls_bapi_item-batch    = <fs_selected>-charg.
      ls_bapi_item-move_type = lv_move_type.
      ls_bapi_item-entry_uom = iv_unidade.
      ls_bapi_item-orderid   = iv_ordem.

      IF lv_qtde_aux GT 0.

        ls_bapi_item-entry_qnt = <fs_selected>-clabs.
        APPEND ls_bapi_item TO et_bapi_item.

      ELSEIF lv_qtde_aux EQ 0.

        ls_bapi_item-entry_qnt = <fs_selected>-clabs.
        APPEND ls_bapi_item TO et_bapi_item.
        EXIT.

      ELSE.

        ls_bapi_item-entry_qnt = <fs_selected>-clabs + lv_qtde_aux.
        APPEND ls_bapi_item TO et_bapi_item.
        EXIT.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD call_bapi.

    CONSTANTS lc_gm_code TYPE bapi2017_gm_code-gm_code VALUE '03'.

    DATA: ls_goodsmvt_code   TYPE bapi2017_gm_code,
          ls_goodsmvt_header TYPE bapi2017_gm_head_01,
          lt_return          TYPE bapiret2_t,
          ls_log_mes         TYPE ztpp_log_mes,
          lv_check           TYPE c.

    ls_goodsmvt_code-gm_code      = lc_gm_code.
    ls_goodsmvt_header-pstng_date = sy-datum.

    DATA: lv_materialdocument TYPE bapi2017_gm_head_ret-mat_doc.
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_code    = ls_goodsmvt_code
        goodsmvt_header  = ls_goodsmvt_header
      IMPORTING
        materialdocument = lv_materialdocument
      TABLES
        goodsmvt_item    = ct_item
        return           = lt_return.

*    DATA: lv_seqnr TYPE i.
*    SELECT MAX( z_log_no )
*        INTO @DATA(lv_log_mes)
*        FROM ztpp_log_mes
*      WHERE z_log_no <> ''.
*    IF sy-subrc = 0.
*      lv_seqnr = lv_log_mes.
*      lv_seqnr = lv_seqnr + 1.
*    ELSE.
*      lv_seqnr = 1.
*    ENDIF.

*    ls_log_mes-z_log_no           = lv_seqnr.

    "Recupera intervalo de numeração - ZPP_LOGMES
    ls_log_mes-z_log_no           = me->number_get_next( ).
    ls_log_mes-manufacturingorder = iv_ordem.

    SELECT SINGLE material,
                  manufacturingorder,
                  productionplant
    INTO @DATA(ls_manufacturingorderitem)
    FROM i_manufacturingorderitem
    WHERE manufacturingorder = @iv_ordem.
    IF sy-subrc = 0.
      ls_log_mes-material           = ls_manufacturingorderitem-material.
      ls_log_mes-prodplant          = ls_manufacturingorderitem-productionplant.
    ENDIF.

    ls_log_mes-confirmacao        = lv_materialdocument.
    ls_log_mes-date_cr            = sy-datum.
    ls_log_mes-created_at         = sy-uzeit.

    DATA lv_qtde(10) TYPE c.
    lv_qtde = iv_quantidade.
    CONCATENATE iv_material lv_qtde iv_unidade iv_ordem INTO ls_log_mes-z_reciv_mes SEPARATED BY space.

    SORT lt_return BY type.
    READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_ret>) INDEX 1.
*                         WITH KEY type = 'E'
*                         BINARY SEARCH.
    IF sy-subrc = 0.
      ls_log_mes-z_msg_mes          = <fs_ret>-message.
      lv_check = 'E'.
    ELSE.
      lv_check = ''.
    ENDIF.

    MODIFY ztpp_log_mes FROM ls_log_mes.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.

    IF lv_check = 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      RAISE EXCEPTION TYPE zcxpp_erro_interface_mes
        EXPORTING
          is_textid = VALUE #( msgid = <fs_ret>-id
                               msgno = <fs_ret>-number
                               attr1 = <fs_ret>-message_v1
                               attr2 = <fs_ret>-message_v2
                               attr3 = <fs_ret>-message_v3
                               attr4 = <fs_ret>-message_v4 ).

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

    ENDIF.
  ENDMETHOD.


  METHOD number_get_next.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZPP_LOGMES'
        subobject               = ''
      IMPORTING
        number                  = rv_prox_num
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        internal_overflow       = 6
        OTHERS                  = 7.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
