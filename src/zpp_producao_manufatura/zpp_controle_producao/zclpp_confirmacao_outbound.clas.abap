"!<p>Classe para diaparo do IDoc MOAPS_CONFIRMOPERATIONS01.
"!Esta classe é acionada no método IF_EX_WORKORDER_GOODSMVT~COMPLETE_GOODSMOVEMENT da implementação ZPP_ENV_CONFIRMACAO da BADI WORKORDER_GOODSMVT</p>
"!<p><strong>Autor:</strong> Rafael Guares Quadros</p>
"!<p><strong>Data:</strong> 3 de ago de 2021</p>
CLASS zclpp_confirmacao_outbound DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS: lc_pp         TYPE ze_param_modulo  VALUE 'PP',
               lc_if_sap_mes TYPE ze_param_chave   VALUE 'IF_SAP_MES',
               lc_werks      TYPE ze_param_chave   VALUE 'WERKS',
               lc_auart      TYPE ze_param_chave   VALUE 'AUART'.
    CLASS-METHODS
      class_constructor.

    METHODS:
      "!Dispara o IDOC MOAPS_CONFIRMOPERATIONS01, se encontrar a configuração apropriada.
      trigger_idoc IMPORTING is_confirmation TYPE cobai_s_confirmation,

      "!Dispara a impressão de etiquetas.
      trigger_etiquetas IMPORTING is_confirmation TYPE cobai_s_confirmation .

  PRIVATE SECTION.
    CLASS-DATA:
      "!Este objeto media acessos ao banco de dados
      go_db     TYPE REF TO lcl_db,
      "!Este objeto media acessos a API standard do SAP
      go_api    TYPE REF TO lcl_api,
      "!Centro correspondente à ordem de produção
      grr_werks TYPE RANGE OF werks_d,
      "!Tipo de ordem de produção
      grr_auart TYPE RANGE OF auart.
    CLASS-METHODS:
      "!Recupera configurações na tabela de parâmetros
      set_config RAISING zcxca_tabela_parametros,
      "!Verifica se a ordem relacionada é de um tipo relevante.
      check_order_type IMPORTING iv_order_id TYPE aufnr
                       RAISING   cx_bapi_error,
      "!Verifica se a planta relacionada é relevante.
      check_plant      IMPORTING iv_plant TYPE werks_d
                       RAISING   cx_bapi_error.
ENDCLASS.



CLASS zclpp_confirmacao_outbound IMPLEMENTATION.
  METHOD class_constructor.

    go_db = NEW lcl_db( ).
    go_api = NEW lcl_api( ).
  ENDMETHOD.

  METHOD set_config.
    DATA(lr_config) = NEW zclca_tabela_parametros( ).

    TRY.
        lr_config->m_get_range(
          EXPORTING
            iv_modulo = lc_pp
            iv_chave1 = lc_if_sap_mes
            iv_chave2 = lc_werks
          IMPORTING
            et_range  = grr_werks
        ).

        lr_config->m_get_range(
          EXPORTING
            iv_modulo = lc_pp
            iv_chave1 = lc_if_sap_mes
            iv_chave2 = lc_auart
          IMPORTING
            et_range  = grr_auart
        ).
      CATCH zcxca_tabela_parametros INTO DATA(lr_error).
        RAISE EXCEPTION lr_error.
    ENDTRY.
  ENDMETHOD.

  METHOD trigger_idoc.
    DATA lt_confirmations TYPE lcl_api=>ty_confirmation_data.

    TRY.
        me->set_config( ).
        check_order_type( iv_order_id = is_confirmation-aufnr ).
        check_plant( iv_plant = is_confirmation-werks ).

        lt_confirmations = VALUE #( ( conf_number       = is_confirmation-rueck
                                      order_number      = is_confirmation-aufnr
                                      operation_counter = is_confirmation-rmzhl
                                      quantity          = is_confirmation-lmnga
                                      quantityunit      = is_confirmation-meinh ) ).

        DATA(lt_logsys) = VALUE wcb_t_logsys( (  logsys = COND #( WHEN sy-sysid CS 'D' THEN 'PID'
                         WHEN sy-sysid CS 'Q' THEN 'PIQ'
                         WHEN sy-sysid CS 'P' THEN 'PIP' ) ) ).


        go_api->ale_mosrvaps_confoprmulti(
          EXPORTING
            iv_logsys         = go_api->own_logical_system_get( )
            it_confirmations = lt_confirmations
            it_logsystems    = lt_logsys
        ).

      CATCH zcxca_tabela_parametros
            cx_bapi_error.
        RETURN.
    ENDTRY.

    "Realizar a impressão da etiqueta
    CALL FUNCTION 'ZFMPP_IMPRIMIR_ETIQUETA'
      IN BACKGROUND TASK AS SEPARATE UNIT
      EXPORTING
        iv_aufnr = is_confirmation-aufnr
        iv_rueck = is_confirmation-rueck
        iv_rmzhl = is_confirmation-rmzhl.
  ENDMETHOD.


  METHOD check_order_type.

    TRY.
        DATA(lv_tipo_ordem) = go_db->query_auart_in_aufk( iv_order_id = iv_order_id ).
      CATCH cx_sy_sql_error.
        RAISE EXCEPTION TYPE cx_bapi_error.
    ENDTRY.

    IF lv_tipo_ordem NOT IN grr_auart.
      RAISE EXCEPTION TYPE cx_bapi_error.
    ENDIF.
  ENDMETHOD.

  METHOD check_plant.

    IF iv_plant NOT IN grr_werks.
      RAISE EXCEPTION TYPE cx_bapi_error.
    ENDIF.
  ENDMETHOD.

  METHOD trigger_etiquetas.

    "Realizar a impressão da etiqueta
    CALL FUNCTION 'ZFMPP_IMPRIMIR_ETIQUETA'
      IN BACKGROUND TASK AS SEPARATE UNIT
      EXPORTING
        iv_aufnr = is_confirmation-aufnr
        iv_rueck = is_confirmation-rueck
        iv_rmzhl = is_confirmation-rmzhl.

  ENDMETHOD.

ENDCLASS.
