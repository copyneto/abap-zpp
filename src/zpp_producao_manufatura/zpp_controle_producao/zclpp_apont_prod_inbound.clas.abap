"!<p>Apontamento de ordem de produção originário do sistema MES.
"! Esta classe é utilizada pela classe de proxy ZCLPP_APONT_PROD_MES_INB</p>
"!<p><strong>Autor:</strong> Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong> 6 de ago de 2021</p>
CLASS zclpp_apont_prod_inbound DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS:
      "! Método utilizado para efetivar a confirmação de apontamento pelo sistema MES
      "! @parameter iv_orderid |Número da ordem enviado pelo MES
      "! @parameter iv_quantidade |Quantidade boa a ser confirmada
      "! @parameter iv_conf_text |Texto de confirmação
      "! @raising zcxpp_erro_interface_mes |Erro no processamento da interface
      efetuar_apontamento IMPORTING iv_orderid          TYPE aufnr
                                    iv_quantidade       TYPE ru_lmnga
                                    iv_conf_text        TYPE co_rtext
                          EXPORTING
                                    es_apontamento_resp TYPE zclpp_mt_apontamento_resp
                          RAISING   zcxpp_erro_interface_mes.
private section.

  constants GC_ERRO type C value 'E' ##NO_TEXT.

  methods RETURN_MESSAGE
    importing
      !IS_RETURN_1 type BAPIRET1
      !IS_RETURN_2 type BAPI_CORU_RETURN
    changing
      !CS_APONTAMENTO_RESP type ZCLPP_MT_APONTAMENTO_RESP .
  methods NUMBER_GET_NEXT
    returning
      value(RV_PROX_NUM) type /PTLGPN/ED086
    raising
      ZCXPP_ERRO_INTERFACE_MES .
ENDCLASS.



CLASS ZCLPP_APONT_PROD_INBOUND IMPLEMENTATION.


  METHOD efetuar_apontamento.

    DATA: lt_levels  TYPE STANDARD TABLE OF bapi_pi_hdrlevel,
          ls_return  TYPE bapiret1,
          lt_return  TYPE STANDARD TABLE OF bapi_coru_return,
          ls_log_mes TYPE ztpp_log_mes.

    APPEND INITIAL LINE TO lt_levels ASSIGNING FIELD-SYMBOL(<fs_level>).
    <fs_level>-orderid    = |{ iv_orderid ALPHA = IN }|.    "Nº ordem = <Numero da ordem enviado pelo MES>
    <fs_level>-fin_conf   = '1'.           "Confirmação parcial/final = '1'
    <fs_level>-clear_res  = abap_true.     "Dar baixa de reservas pendentes = 'X'
    <fs_level>-postg_date = sy-datum.      "Data de lançamento = ‘data atual’
    <fs_level>-yield      = iv_quantidade. "Quantidade boa a ser confirmada = <quantidade boa, enviada pelo mes>
    <fs_level>-conf_text  = iv_conf_text.  "Texto de confirmação = <texto enviado pelo mes>

    CALL FUNCTION 'BAPI_PROCORDCONF_CREATE_HDR'
      IMPORTING
        return        = ls_return
      TABLES
        athdrlevels   = lt_levels
        detail_return = lt_return.

    READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_return>) INDEX 1.

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
*
*    ls_log_mes-z_log_no           = lv_seqnr.

    "Recupera intervalo de numeração - ZPP_LOGMES
    ls_log_mes-z_log_no           = me->number_get_next( ).
    ls_log_mes-manufacturingorder = iv_orderid.

    UNPACK ls_log_mes-manufacturingorder TO ls_log_mes-manufacturingorder.

    SELECT SINGLE material,
                  manufacturingorder,
                  productionplant
    INTO @DATA(ls_manufacturingorderitem)
    FROM i_manufacturingorderitem
    WHERE manufacturingorder = @ls_log_mes-manufacturingorder.
    IF sy-subrc = 0.
      ls_log_mes-material           = ls_manufacturingorderitem-material.
      ls_log_mes-prodplant          = ls_manufacturingorderitem-productionplant.
    ENDIF.

*    CONCATENATE <fs_return>-conf_no <fs_return>-conf_cnt INTO ls_log_mes-confirmacao SEPARATED BY space.
    ls_log_mes-confirmacao = <fs_return>-conf_no.
    ls_log_mes-contador    = <fs_return>-conf_cnt.

    ls_log_mes-date_cr            = sy-datum.
    ls_log_mes-created_at         = sy-uzeit.

    DATA lv_qtde(10) TYPE c.
    lv_qtde = iv_quantidade.
    CONCATENATE iv_orderid lv_qtde iv_conf_text INTO ls_log_mes-z_reciv_mes SEPARATED BY space.
    ls_log_mes-z_msg_mes          = ls_return-message.

    MODIFY ztpp_log_mes FROM ls_log_mes.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.

    IF ls_return-type = 'E'.
      "Retornar erro
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      SORT lt_return BY type.
      READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_ret>)
                           WITH KEY type = 'E'
                           BINARY SEARCH.
      IF sy-subrc = 0.
        ls_return = CORRESPONDING #( <fs_ret> ).

        me->return_message(
            EXPORTING
                is_return_1 = ls_return
                is_return_2 = <fs_return>
            CHANGING
                cs_apontamento_resp = es_apontamento_resp
         ).

      ENDIF.

    ELSE.
      "Efetivar mudanças
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

      READ TABLE lt_levels ASSIGNING FIELD-SYMBOL(<fs_levels>) INDEX 1.
      IF sy-subrc = 0.

        es_apontamento_resp-mt_apontamento_resp-manufacturing_order = <fs_levels>-orderid.

        SELECT SINGLE plant,
                      material,
                      confirmationunit,
                      confirmationyieldquantity,
                      mfgorderconfirmation,
                      mfgorderconfirmationcount,
                      manufacturingorder
            INTO @DATA(ls_confirmacoes_cubo)
            FROM zi_pp_confirmacoes_cubo
            WHERE mfgorderconfirmation      = @<fs_return>-conf_no
            AND   mfgorderconfirmationcount = @<fs_return>-conf_cnt
            AND   manufacturingorder        = @<fs_levels>-orderid.

        es_apontamento_resp-mt_apontamento_resp-plant                        = ls_confirmacoes_cubo-plant.
        es_apontamento_resp-mt_apontamento_resp-material                     = ls_confirmacoes_cubo-material.
        es_apontamento_resp-mt_apontamento_resp-confirmation_unit            = ls_confirmacoes_cubo-confirmationunit.
        es_apontamento_resp-mt_apontamento_resp-confirmation_yield_quantity  = ls_confirmacoes_cubo-confirmationyieldquantity.

        me->return_message(
            EXPORTING
                is_return_1 = ls_return
                is_return_2 = <fs_return>
            CHANGING
                cs_apontamento_resp = es_apontamento_resp
         ).

      ENDIF.

    ENDIF.
  ENDMETHOD.


  METHOD return_message.

    cs_apontamento_resp-mt_apontamento_resp-type       = is_return_1-type.
    cs_apontamento_resp-mt_apontamento_resp-id         = is_return_1-id.
    cs_apontamento_resp-mt_apontamento_resp-number     = is_return_1-number.
    cs_apontamento_resp-mt_apontamento_resp-message    = is_return_1-message.
    cs_apontamento_resp-mt_apontamento_resp-log_no     = is_return_1-log_no.
    cs_apontamento_resp-mt_apontamento_resp-log_msg_no = is_return_1-log_msg_no.
    cs_apontamento_resp-mt_apontamento_resp-message_v1 = is_return_1-message_v1.
    cs_apontamento_resp-mt_apontamento_resp-message_v2 = is_return_1-message_v2.
    cs_apontamento_resp-mt_apontamento_resp-message_v3 = is_return_1-message_v3.
    cs_apontamento_resp-mt_apontamento_resp-message_v4 = is_return_1-message_v4.
    cs_apontamento_resp-mt_apontamento_resp-message_status = COND #( WHEN is_return_1-type NE gc_erro THEN TEXT-001 ELSE is_return_1-message ).
    cs_apontamento_resp-mt_apontamento_resp-parameter  = is_return_2-parameter.
    cs_apontamento_resp-mt_apontamento_resp-row        = is_return_2-row.
    cs_apontamento_resp-mt_apontamento_resp-field      = is_return_2-field.
    cs_apontamento_resp-mt_apontamento_resp-system     = is_return_2-system.
    cs_apontamento_resp-mt_apontamento_resp-flg_locked = is_return_2-flg_locked.
    cs_apontamento_resp-mt_apontamento_resp-conf_no    = is_return_2-conf_no.
    cs_apontamento_resp-mt_apontamento_resp-conf_cnt   = is_return_2-conf_cnt.

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
