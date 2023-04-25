CLASS lhc_ordem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.

    CONSTANTS gc_msgid TYPE msgid VALUE 'ZPP_APROPRIACAO'.
    CONSTANTS gc_e TYPE char1 VALUE 'E'.


    METHODS oncreateorder FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ordem~oncreateorder.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR ordem RESULT result.
    METHODS verificamaterial FOR VALIDATE ON SAVE
      IMPORTING keys FOR ordem~verificamaterial.
    METHODS verificastatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR ordem~verificastatus.
    METHODS ordens FOR MODIFY
      IMPORTING keys FOR ACTION ordem~ordens RESULT result.

    METHODS authorization FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ordem RESULT result.

    DATA gv_wait_async     TYPE abap_bool.

ENDCLASS.

CLASS lhc_ordem IMPLEMENTATION.

  METHOD oncreateorder.

    "Header
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY header
    FIELDS ( documentno plant ordertype basicstartdate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    "Ordens
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY ordem
    FIELDS ( plant ordertype basicstartdate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_ordens).


    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.

    MODIFY ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY ordem
    UPDATE FIELDS ( status plant ordertype basicstartdate )
    WITH VALUE #( FOR ls_ordem IN lt_ordens (            "#EC CI_STDSEQ
                       %key      =  ls_ordem-%key
                        status = '0'
                        plant = <fs_header>-plant
                        ordertype = <fs_header>-ordertype
                        basicstartdate = <fs_header>-basicstartdate
                       ) )

    REPORTED DATA(lt_reported).

  ENDMETHOD.



  METHOD get_features.

    DATA: lv_ordem TYPE x LENGTH 1.
    DATA: lr_status TYPE RANGE OF ze_status_nrm_apr.


    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
      ENTITY ordem "header BY \_ordens
      FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ordem)
      FAILED failed.

    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
      ENTITY header BY \_ordens
        FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_all)
      FAILED failed.

    " Veririca se tem linhas pendente/erro para processar
    lr_status = VALUE #( sign   = 'I'
                         option = 'EQ'
                        ( low   = '0' )   "0  Pendente
                        ( low   = '1' )   "1  Erro
                        ( low   = '2' ) )."2  Processado

    lv_ordem = if_abap_behv=>fc-o-disabled.
    LOOP AT lt_all ASSIGNING FIELD-SYMBOL(<fs_all>).
      IF <fs_all>-status IN lr_status.
        lv_ordem = if_abap_behv=>fc-o-enabled.
        EXIT.
      ENDIF.
    ENDLOOP.

    result = VALUE #( FOR ls_ordem IN lt_ordem LET lv_edit = COND #( WHEN ls_ordem-status = '0'
                                                                       OR ls_ordem-status = '1'
                                                                          THEN if_abap_behv=>fc-o-enabled
                                                                          ELSE if_abap_behv=>fc-o-disabled  )
      IN ( %tky           = ls_ordem-%tky
           %delete        = lv_edit
           %update        = lv_edit
           %action-ordens = lv_ordem
         ) ).

  ENDMETHOD.

  METHOD verificamaterial.

    "Verifica se o Consumo esta pendente para permitir editar
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
        ENTITY ordem "header BY \_ordens
        FIELDS ( material status ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_ordem)
        FAILED DATA(lv_failed).

    "Verifica se o Consumo esta pendente para permitir editar
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
        ENTITY header BY \_ordens
        FIELDS ( material status ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_all)
        FAILED  lv_failed.


    READ TABLE lt_ordem ASSIGNING FIELD-SYMBOL(<fs_ordem>) INDEX 1.
    IF sy-subrc = 0.

      DELETE lt_all WHERE docuuidordem = <fs_ordem>-docuuidordem. "#EC CI_STDSEQ

      "Verifica se material ja utilizado
      READ TABLE lt_all TRANSPORTING NO FIELDS WITH KEY material = <fs_ordem>-material . "#EC CI_STDSEQ
      IF sy-subrc = 0.

        APPEND VALUE #( %tky        = <fs_ordem>-%tky
                        %msg        = new_message( id       = gc_msgid
                                                   number   = '001'
                                                   v1       = <fs_ordem>-material
                                                   severity = CONV #( gc_e ) )
                         )
          TO reported-ordem.

      ENDIF.

    ENDIF.


  ENDMETHOD.

  METHOD verificastatus.

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

*    "Verifica se todas linhas estão como pendente para poder inserir novas linhas
*    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
*        ENTITY header BY \_ordens
*        FIELDS ( status ) WITH CORRESPONDING #( keys )
*        RESULT DATA(lt_all)
*        FAILED  DATA(lv_failed).
*
*
*    LOOP AT lt_all ASSIGNING FIELD-SYMBOL(<fs_all>).
*
*      IF <fs_all>-status <> '0'. "pendente
*
*        "Não é possivel inserir novas linhas, processamento iniciado
*        APPEND VALUE #( %tky        = <fs_all>-%tky
*                        %msg        = new_message( id       = gc_msgid
*                                                   number   = '002'
*                                                   v1       = <fs_all>-material
*                                                   severity = CONV #( gc_e ) )
*                         )
*          TO reported-ordem.
*
*        EXIT.
*
*      ENDIF.
*
*    ENDLOOP.


  ENDMETHOD.

  METHOD ordens.

    gv_wait_async = abap_false.

    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
        ENTITY header
          FIELDS ( status ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header)
        FAILED failed.

    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
    IF sy-subrc = 0.

      CALL FUNCTION 'ZFMPP_NRM_APR_PRODUCAO_GRAOS'
        STARTING NEW TASK 'PROD_GRAOS'
        CALLING setup_messages ON END OF TASK
        EXPORTING
          iv_doc_uuid_h = <fs_header>-docuuidh.

      WAIT UNTIL gv_wait_async = abap_true.

    ENDIF.


    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
      ENTITY ordem
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_return)
      FAILED failed.

    result = VALUE #( FOR ls_return IN lt_return
                       ( %tky   = ls_return-%tky ) ).


  ENDMETHOD.

  METHOD setup_messages.
    gv_wait_async = abap_true.
  ENDMETHOD.


  METHOD authorization.
    RETURN.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
