CLASS lhc__consumo DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

    CONSTANTS gc_msgid TYPE msgid VALUE 'ZPP_APROPRIACAO'.
    CONSTANTS gc_e TYPE char1 VALUE 'E'.

    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.
*    METHODS executar FOR MODIFY
*      IMPORTING keys FOR ACTION consumo~executar RESULT result.

    METHODS oncreatecons FOR DETERMINE ON MODIFY
      IMPORTING keys FOR consumo~oncreatecons.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR consumo RESULT result.

    METHODS verificastatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR consumo~verificastatus.

*    METHODS authorization FOR AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR Consumo RESULT result.

    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.
    DATA gv_wait_async     TYPE abap_bool.

ENDCLASS.

CLASS lhc__consumo IMPLEMENTATION.


*  METHOD executar.
*
*    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
*      ENTITY consumo
*        FIELDS ( docuuidh docuuidconsumo ) WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_consumo)
*      FAILED failed.
*
*    READ TABLE lt_consumo ASSIGNING FIELD-SYMBOL(<fs_consumo>) INDEX 1.
*    IF sy-subrc = 0.
*
*      CALL FUNCTION 'ZFMPP_NRM_APR_GRAOS_CONSUMIDOS'
*        STARTING NEW TASK 'PRODCONS'
*        CALLING setup_messages ON END OF TASK
*        EXPORTING
*          iv_doc_uuid_h       = <fs_consumo>-docuuidh
*          iv_doc_uuid_consumo = <fs_consumo>-docuuidconsumo.
*
*      WAIT UNTIL gv_wait_async = abap_true.
*
*
*      IF line_exists( gt_messages[ type = 'E' ] ).       "#EC CI_STDSEQ
*        APPEND VALUE #(  %tky = <fs_consumo>-%tky ) TO failed-consumo.
*      ENDIF.
*
*      LOOP AT gt_messages INTO DATA(ls_message).         "#EC CI_NESTED
*
*        APPEND VALUE #( %tky        = <fs_consumo>-%tky
*                        %msg        = new_message( id       = ls_message-id
*                                                   number   = ls_message-number
*                                                   v1       = ls_message-message_v1
*                                                   v2       = ls_message-message_v2
*                                                   v3       = ls_message-message_v3
*                                                   v4       = ls_message-message_v4
*                                                   severity = CONV #( ls_message-type ) )
*                         )
*          TO reported-consumo.
*
*      ENDLOOP.
*
*    ENDIF.
*
*
*    "Atualiza as informações
*    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
*      ENTITY consumo
*        ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_all)
*      FAILED failed.
*
*    result = VALUE #( FOR ls_all IN lt_all ( %key = ls_all-%key
*                                              %param    = ls_all ) ).
*
*
*
*  ENDMETHOD.

  METHOD setup_messages.

    RECEIVE RESULTS FROM FUNCTION 'ZFMPP_NRM_APR_GRAOS_CONSUMIDOS'
          IMPORTING
            et_return = gt_messages.

    gv_wait_async = abap_true.
  ENDMETHOD.

  METHOD oncreatecons.

    "Header
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY header
    FIELDS ( documentno plant ordertype basicstartdate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    "Comsumo
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY consumo
    FIELDS ( plant )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_consumo).


    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.

    MODIFY ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY consumo
    UPDATE FIELDS ( plant )
    WITH VALUE #( FOR ls_consumo IN lt_consumo (         "#EC CI_STDSEQ
                       %key      =  ls_consumo-%key
                        status = '0'
                        plant = <fs_header>-plant
                       ) )

    REPORTED DATA(lt_reported).


  ENDMETHOD.

  METHOD get_features.

    DATA: lv_ordem TYPE x LENGTH 1.
    DATA: lr_status TYPE RANGE OF ze_status_nrm_apr.

    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
          ENTITY header BY \_ordens
          FIELDS ( status ) WITH CORRESPONDING #( keys )
          RESULT DATA(lt_ordem)
          FAILED failed.

    lr_status = VALUE #( sign = 'I'
                     option = 'EQ'
                     ( low = '0' )
                     ( low = '1' ) ).

    "Verificar se todas as ordens estão processadas
    lv_ordem = if_abap_behv=>fc-o-enabled.
    LOOP AT lt_ordem ASSIGNING FIELD-SYMBOL(<fs_ordem>).
      IF <fs_ordem>-status IN lr_status.
        lv_ordem = if_abap_behv=>fc-o-disabled.
        EXIT.
      ENDIF.
    ENDLOOP.

    "Verifica se o Consumo esta pendente para permitir editar
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
        ENTITY consumo "header BY \_ordens
        FIELDS ( status ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_consumo)
        FAILED failed.

    result =
    VALUE #(
    FOR ls_consumo IN lt_consumo
      LET lv_edit =   COND #( WHEN ls_consumo-status = '2'
                                  THEN if_abap_behv=>fc-o-disabled
                                  ELSE if_abap_behv=>fc-o-enabled  )
      IN
        ( %tky              = ls_consumo-%tky
*          %action-executar  = COND #( WHEN ls_consumo-status = '2'
*                                THEN if_abap_behv=>fc-o-disabled
*                                ELSE lv_ordem )
          %delete           = lv_edit
          %update           = lv_edit
         ) ).

  ENDMETHOD.


  METHOD verificastatus.


    "Verifica se todas linhas estão como pendente para poder inserir novas linhas
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
        ENTITY header
        FIELDS ( status ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header)
        FAILED  DATA(lv_failed1).

    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
    IF sy-subrc = 0.

      IF <fs_header>-status = '3'.
        "Não é possivel inserir novas linhas, documento encerrado
        APPEND VALUE #( %tky        = <fs_header>-%tky
                        %msg        = new_message( id       = gc_msgid
                                                   number   = '004'
                                                   severity = CONV #( gc_e ) )
                         )
          TO reported-ordem.

        RETURN.
      ENDIF.

    ENDIF.


  ENDMETHOD.

*  METHOD authorization.
*    return.
*  ENDMETHOD.

ENDCLASS.
