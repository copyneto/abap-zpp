CLASS lhc_ArqCargaProducao DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ArqCargaProducao RESULT result.

    METHODS processar FOR MODIFY
      IMPORTING keys FOR ACTION arqcargaproducao~processar RESULT result.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR arqcargaproducao RESULT result.

ENDCLASS.

CLASS lhc_ArqCargaProducao IMPLEMENTATION.

  METHOD get_authorizations.
    READ ENTITIES OF zi_pp_arq_carga_producao  IN LOCAL MODE
      ENTITY ArqCargaProducao
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

      IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.

        IF zclpp_auth_zppwerks=>werks_delete( <fs_data>-Plant ).
          lv_delete = if_abap_behv=>auth-allowed.
        ELSE.
          lv_delete = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      APPEND VALUE #( %tky = <fs_data>-%tky
                      %update = lv_update
                      %delete = lv_delete
                       )
             TO result.

    ENDLOOP.

  ENDMETHOD.

  METHOD processar.

    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_pp_arq_carga_producao IN LOCAL MODE
        ENTITY ArqCargaProducao
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).



    ENDLOOP.

* ---------------------------------------------------------------------------
* Recupera todas as linhas selecionadas
* ---------------------------------------------------------------------------
    READ ENTITIES OF zi_pp_arq_carga_producao IN LOCAL MODE ENTITY ArqCargaProducao
        FIELDS ( Id Type ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_producao).

* ---------------------------------------------------------------------------
* Processa arquivos selecionados
* ---------------------------------------------------------------------------
    LOOP AT lt_producao INTO DATA(ls_producao).    "#EC CI_LOOP_INTO_WA

      IF zclpp_auth_zppwerks=>werks_create( ls_producao-Plant ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-ArqCargaProducao.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-ArqCargaProducao.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create )
                        %element-plant = if_abap_behv=>mk-on )
          TO reported-ArqCargaProducao.

      ELSE.

        zclpp_planejamento_producao=>carregar_arquivo( EXPORTING iv_filetype = ls_producao-Type
                                                                 iv_file_id  = ls_producao-Id ).

        zclpp_planejamento_producao=>get_messages( IMPORTING et_messages = DATA(lt_messages) ).

* ---------------------------------------------------------------------------
* Prepara mensagens de retorno
* ---------------------------------------------------------------------------
        IF line_exists( lt_messages[ type = 'E' ] ).     "#EC CI_STDSEQ
          APPEND VALUE #(  %tky = ls_producao-%tky ) TO failed-arqcargaproducao.
        ENDIF.

        LOOP AT lt_messages INTO DATA(ls_message).       "#EC CI_NESTED

          APPEND VALUE #( %tky        = ls_producao-%tky
                          %msg        = new_message( id       = ls_message-id
                                                     number   = ls_message-number
                                                     v1       = ls_message-message_v1
                                                     v2       = ls_message-message_v2
                                                     v3       = ls_message-message_v3
                                                     v4       = ls_message-message_v4
                                                     severity = CONV #( ls_message-type ) )
                           )
            TO reported-arqcargaproducao.

        ENDLOOP.

* ---------------------------------------------------------------------------
* Atualizar campo "Status" somente em caso de sucesso
* ---------------------------------------------------------------------------
        IF NOT line_exists( lt_messages[ type = 'E' ] ). "#EC CI_STDSEQ

          MODIFY ENTITIES OF zi_pp_arq_carga_producao IN LOCAL MODE ENTITY ArqCargaProducao
              UPDATE FIELDS ( Status )
              WITH VALUE #( ( %key      = ls_producao-%key
                              Status    = 'P' ) ).

        ENDIF.

      ENDIF.

    ENDLOOP.

* ---------------------------------------------------------------------------
* Atualizar linhas processadas
* ---------------------------------------------------------------------------
    READ ENTITIES OF zi_pp_arq_carga_producao IN LOCAL MODE ENTITY ArqCargaProducao
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_producao_all).


    result = VALUE #( FOR ls_producao_all IN lt_producao_all ( %key = ls_producao_all-%key
                                                %param    = ls_producao_all ) ).

  ENDMETHOD.

  METHOD get_features.

* ---------------------------------------------------------------------------
* Recupera todas as linhas selecionadas
* ---------------------------------------------------------------------------
    READ ENTITIES OF zi_pp_arq_carga_producao IN LOCAL MODE ENTITY ArqCargaProducao
      FIELDS ( Id Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ArqCargaProducao)
      FAILED failed.

* ---------------------------------------------------------------------------
* Habilita/desabilita funcionalidades
* ---------------------------------------------------------------------------
    result = VALUE #( FOR ls_arq IN lt_ArqCargaProducao
                      LET lr_processar =   COND #( WHEN ls_arq-Status = gc_status-processado
                                                  THEN if_abap_behv=>fc-o-disabled
                                                  ELSE if_abap_behv=>fc-o-enabled  )
                      IN
                        ( %tky                 = ls_arq-%tky
                          %update              = lr_processar
                          %delete              = if_abap_behv=>fc-o-enabled
                          %action-processar    = lr_processar
                         ) ).

  ENDMETHOD.

ENDCLASS.
