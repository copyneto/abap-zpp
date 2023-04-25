CLASS lcl_ajusteinventariohdr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS: BEGIN OF gc_status,
                 pendente         TYPE ze_status_cont VALUE ' ',
                 em_processamento TYPE ze_status_cont VALUE '1',
                 erro             TYPE ze_status_cont VALUE '2',
                 completo         TYPE ze_status_cont VALUE '3',
                 encerrado        TYPE ze_status_cont VALUE '4',
                 advertencia      TYPE ze_status_cont VALUE '5',
               END OF gc_status.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ajusteinventariohdr RESULT result.

    METHODS get_authorizationsItem FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR AjusteInventarioItem RESULT result.

    METHODS finish FOR MODIFY
      IMPORTING keys FOR ACTION ajusteinventariohdr~finish RESULT result.

    METHODS execute FOR MODIFY
      IMPORTING keys FOR ACTION ajusteinventariohdr~execute RESULT result.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR ajusteinventariohdr RESULT result.

ENDCLASS.

CLASS lcl_ajusteinventariohdr IMPLEMENTATION.

  METHOD finish.

    MODIFY ENTITIES OF zi_pp_ajuste_inventario_header IN LOCAL MODE
      ENTITY ajusteinventariohdr
         UPDATE FIELDS ( status )
           WITH VALUE #( FOR ls_key IN keys
                           ( %tky   = ls_key-%tky
                             status = gc_status-encerrado ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zi_pp_ajuste_inventario_header IN LOCAL MODE
      ENTITY ajusteinventariohdr
        FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header)
      FAILED failed.

    result = VALUE #( FOR ls_int IN lt_header
                       ( %tky   = ls_int-%tky
                         %param = ls_int ) ).
  ENDMETHOD.

  METHOD execute.

    " Lê os dados de cabeçalho
    READ ENTITIES OF zi_pp_ajuste_inventario_header IN LOCAL MODE
      ENTITY ajusteinventariohdr
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header_entity)
      FAILED failed.

    READ TABLE lt_header_entity ASSIGNING FIELD-SYMBOL(<fs_header_entity>) INDEX 1.
    IF <fs_header_entity> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    " Lê os itens associados
    READ ENTITIES OF zi_pp_ajuste_inventario_header
      ENTITY  ajusteinventariohdr BY \_item
        ALL FIELDS WITH VALUE #( ( documentouuid = <fs_header_entity>-documentouuid ) )
      RESULT DATA(lt_item_entity)
      FAILED failed.

    DATA(lt_header) = VALUE zctgpp_ajust_inv_h( ).
    LOOP AT lt_header_entity ASSIGNING <fs_header_entity>.
      DATA(ls_header) = CORRESPONDING ztpp_ajust_inv_h( <fs_header_entity> ).
      ls_header-created_by            = <fs_header_entity>-createdby.
      ls_header-created_at            = <fs_header_entity>-createdat.
      ls_header-last_changed_by       = <fs_header_entity>-lastchangedby.
      ls_header-last_changed_at       = <fs_header_entity>-lastchangedat.
      ls_header-local_last_changed_at = <fs_header_entity>-locallastchangedat.
      APPEND ls_header TO lt_header.
    ENDLOOP.

    DATA(lt_item) = VALUE zctgpp_ajust_inv_i( ).
    LOOP AT lt_item_entity ASSIGNING FIELD-SYMBOL(<fs_item_entity>).
      DATA(ls_item) = CORRESPONDING ztpp_ajust_inv_i( <fs_item_entity> ).
      ls_item-created_by            = <fs_item_entity>-createdby.
      ls_item-created_at            = <fs_item_entity>-createdat.
      ls_item-last_changed_by       = <fs_item_entity>-lastchangedby.
      ls_item-last_changed_at       = <fs_item_entity>-lastchangedat.
      ls_item-local_last_changed_at = <fs_item_entity>-locallastchangedat.
      APPEND ls_item TO lt_item.
    ENDLOOP.

    CALL FUNCTION 'ZFMPP_LANCA_CONT_ESTOQUE'
      STARTING NEW TASK 'BACKGROUND'
      EXPORTING
        it_ajust_inv_header = lt_header "CORRESPONDING zctgpp_ajust_inv_h( lt_header_entity )
        it_ajust_inv_item   = lt_item. "CORRESPONDING ZCTGPP_AJUST_INV_I( lt_item_entity ).

    READ ENTITIES OF zi_pp_ajuste_inventario_header IN LOCAL MODE
      ENTITY ajusteinventariohdr
        FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result)
      FAILED failed.

    result = VALUE #( FOR ls_int IN lt_result
                       ( %tky   = ls_int-%tky
                         %param = ls_int ) ).
  ENDMETHOD.

  METHOD get_features.

    READ ENTITIES OF zi_pp_ajuste_inventario_header IN LOCAL MODE
      ENTITY ajusteinventariohdr
        FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_entity)
      FAILED failed.

    result = VALUE #( FOR ls_entity IN lt_entity
                       ( %key = ls_entity-%key
                         %features = VALUE #(
                           %update = COND #( WHEN ls_entity-status = gc_status-em_processamento
                                               OR ls_entity-status = gc_status-completo
                                               OR ls_entity-status = gc_status-encerrado
                                             THEN if_abap_behv=>fc-o-disabled
                                             ELSE if_abap_behv=>fc-o-enabled )

                           %action = VALUE #(
                             finish  = COND #( WHEN ls_entity-status = gc_status-encerrado
                                                 OR ls_entity-status = gc_status-em_processamento
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )

                             execute = COND #( WHEN ls_entity-status = gc_status-em_processamento
                                                 OR ls_entity-status = gc_status-completo
                                                 OR ls_entity-status = gc_status-encerrado
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled ) ) ) ) ).
  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_pp_ajuste_inventario_header IN LOCAL MODE
          ENTITY ajusteinventariohdr
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_data)
          FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    DATA: lv_update TYPE if_abap_behv=>t_xflag,
          lv_delete TYPE if_abap_behv=>t_xflag.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclpp_auth_zppwerks=>werks_update( <fs_data>-Plant ).
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      APPEND VALUE #( %tky    = <fs_data>-%tky
                      %update = lv_update )
         TO result.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_authorizationsitem.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_ajusteinventarioitem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS: BEGIN OF gc_status,
                 pendente         TYPE ze_status_cont VALUE ' ',
                 em_processamento TYPE ze_status_cont VALUE '1',
                 erro             TYPE ze_status_cont VALUE '2',
                 completo         TYPE ze_status_cont VALUE '3',
                 encerrado        TYPE ze_status_cont VALUE '4',
                 advertencia      TYPE ze_status_cont VALUE '5',
               END OF gc_status.

    METHODS message FOR MODIFY
      IMPORTING keys FOR ACTION ajusteinventarioitem~message RESULT result.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR ajusteinventarioitem RESULT result.

ENDCLASS.

CLASS lcl_ajusteinventarioitem IMPLEMENTATION.

  METHOD message.

    IF lines( keys ) GT 0.
      SELECT documentoitemuuid,
             sequence,
             messageid,
             messageno,
             messagetype,
             messagev1,
             messagev2,
             messagev3,
             messagev4,
             messagetext
        FROM zi_pp_ajuste_inventario_msg
        FOR ALL ENTRIES IN @keys
        WHERE documentoitemuuid = @keys-documentoitemuuid
        INTO TABLE @DATA(lt_mensagens).
    ENDIF.

    LOOP AT lt_mensagens INTO DATA(ls_mensagens).  "#EC CI_LOOP_INTO_WA

      APPEND VALUE #( %tky-documentoitemuuid = ls_mensagens-documentoitemuuid ) TO failed-ajusteinventarioitem.

      APPEND VALUE #( %tky = VALUE #( documentoitemuuid = ls_mensagens-documentoitemuuid )
                      %msg =  new_message( id       = ls_mensagens-messageid
                                           number   = CONV #( ls_mensagens-messageno )
                                           severity = CONV #( ls_mensagens-messagetype )
                                           v1       = ls_mensagens-messagev1
                                           v2       = ls_mensagens-messagev2
                                           v3       = ls_mensagens-messagev3
                                           v4       = ls_mensagens-messagev4 ) ) TO reported-ajusteinventarioitem.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_features.

    READ ENTITY zi_pp_ajuste_inventario_item
      FROM VALUE #( FOR ls_keyval IN keys ( %key            = ls_keyval-%key
                                            %control-status = if_abap_behv=>mk-on ) )
      RESULT DATA(lt_entity)
      FAILED failed.

    result = VALUE #( FOR ls_entity IN lt_entity
                       ( %key = ls_entity-%key
                         %features = VALUE #(
                           %action-message = COND #( WHEN ls_entity-status = gc_status-erro
                                                       OR ls_entity-status = gc_status-completo
                                                       OR ls_entity-status = gc_status-advertencia
                                                       or ls_entity-status = gc_status-pendente
                                                     THEN if_abap_behv=>fc-o-enabled
                                                     ELSE if_abap_behv=>fc-o-disabled )

                           %field-counting = COND #( WHEN ls_entity-status = gc_status-em_processamento
                                                       OR ls_entity-status = gc_status-completo
                                                       OR ls_entity-status = gc_status-encerrado
                                                       OR ls_entity-status = gc_status-advertencia
                                                     THEN if_abap_behv=>fc-f-read_only ) ) ) ).
  ENDMETHOD.

ENDCLASS.
