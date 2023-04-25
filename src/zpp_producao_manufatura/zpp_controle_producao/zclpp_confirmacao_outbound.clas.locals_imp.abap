*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_db IMPLEMENTATION.
  METHOD query_auart_in_aufk.

    CLEAR rv_order_type.
    SELECT auart
      FROM aufk
     WHERE aufnr = @iv_order_id
     ORDER BY PRIMARY KEY
      INTO @rv_order_type
        UP TO 1 ROWS.
    ENDSELECT.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_sql_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_api IMPLEMENTATION.
  METHOD ale_mosrvaps_confoprmulti.

    CALL FUNCTION 'ALE_MOSRVAPS_CONFOPRMULTI'
      EXPORTING
        logicalsystem         = iv_logsys
*       commitcontrol         = 'E'
*       obj_type              = 'BUS10503'
*       serial_id             = '0'
      TABLES
        operationconfirmation = it_confirmations
        receivers             = it_logsystems
*       communication_documents =
*       application_objects   =
      EXCEPTIONS
        error_creating_idocs  = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
      MESSAGE
           ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
         INTO DATA(lv_message).
      RAISE EXCEPTION TYPE cx_bapi_error
        EXPORTING
          status = VALUE #( ( id = sy-msgid
                            type = sy-msgty
                            number = sy-msgno
                            message = lv_message
                            message_v1 = sy-msgv1
                            message_v2 = sy-msgv2
                            message_v3 = sy-msgv3
                            message_v4 = sy-msgv4 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD own_logical_system_get.

    CLEAR rv_log_syst.
    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
      IMPORTING
        own_logical_system             = rv_log_syst
      EXCEPTIONS
        own_logical_system_not_defined = 1
        OTHERS                         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        INTO DATA(lv_message).
      RAISE EXCEPTION TYPE cx_bapi_error
        EXPORTING
          status = VALUE #( ( id = sy-msgid
                            type = sy-msgty
                            number = sy-msgno
                            message = lv_message
                            message_v1 = sy-msgv1
                            message_v2 = sy-msgv2
                            message_v3 = sy-msgv3
                            message_v4 = sy-msgv4 ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
