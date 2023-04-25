CLASS lhc_Impressao DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    METHODS setup_messages
      IMPORTING
        !p_task TYPE clike .

  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ Impressao RESULT result.

    METHODS Imprimir FOR MODIFY
      IMPORTING keys FOR ACTION Impressao~Imprimir RESULT result.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR Impressao RESULT result.

    DATA gt_return TYPE bapiret2_t.
    DATA gv_wait_async TYPE abap_bool .
ENDCLASS.

CLASS lhc_Impressao IMPLEMENTATION.

  METHOD read.

    SELECT Confirmation,
           ConfirmationCount,
           MOrder
        FROM zi_pp_impressao_etiqueta
        INTO TABLE @DATA(LT_result)
        FOR ALL ENTRIES IN @keys
        WHERE Confirmation EQ @keys-Confirmation
        AND   ConfirmationCount EQ @keys-ConfirmationCount.
    IF sy-subrc IS INITIAL.

      MOVE-CORRESPONDING lt_result TO result.

    ENDIF.


  ENDMETHOD.

  METHOD Imprimir.

*    DATA(lo_etiqueta) = NEW zclpp_gerar_etiqueta( ).

    READ ENTITIES OF zi_pp_impressao_etiqueta
      ENTITY Impressao
        FIELDS ( Confirmation ConfirmationCount MOrder ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_etiquetas)
      FAILED failed.

    READ TABLE lt_etiquetas INTO DATA(ls_etiqueta) INDEX 1.
    IF sy-subrc IS INITIAL.

      CALL FUNCTION 'ZFMPP_IMPRIMIR_ETIQUETA'
        STARTING NEW TASK 'PRINT_ETIQUETA'
        CALLING setup_messages ON END OF TASK
        EXPORTING
          iv_wait  = abap_false
          iv_aufnr = ls_etiqueta-MOrder
          iv_rueck = ls_etiqueta-Confirmation
          iv_rmzhl = ls_etiqueta-ConfirmationCount.

      WAIT UNTIL gv_wait_async = abap_true.
      DATA(lt_return) = gt_return.

*      lo_etiqueta->process(
*        EXPORTING
*          iv_aufnr  = ls_etiqueta-MOrder
*          iv_rueck  = ls_etiqueta-Confirmation
*          iv_rmzhl  = ls_etiqueta-ConfirmationCount
*        IMPORTING
*          et_return = DATA(lt_return)
*      ).

      LOOP AT lt_return INTO DATA(ls_return).

        APPEND VALUE #(
          %tky       = ls_etiqueta-%tky
          %msg       = new_message(
            id       = ls_return-id
            number   = ls_return-number
            v1       = ls_return-message_v1
            v2       = ls_return-message_v2
            v3       = ls_return-message_v3
            v4       = ls_return-message_v4
            severity = CONV #( ls_return-type ) ) ) TO reported-impressao.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD get_features.
  ENDMETHOD.

  METHOD setup_messages.
    CASE p_task.
      WHEN 'PRINT_ETIQUETA'.

        RECEIVE RESULTS FROM FUNCTION 'ZFMPP_IMPRIMIR_ETIQUETA'
         IMPORTING
           et_return = me->gt_return.

        me->gv_wait_async = abap_true.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_PP_IMPRESSAO_ETIQUETA DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_PP_IMPRESSAO_ETIQUETA IMPLEMENTATION.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

ENDCLASS.
