CLASS lhc_header DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.
    METHODS calculardocumentno FOR DETERMINE ON MODIFY
      IMPORTING keys FOR header~calculardocumentno.

    METHODS encerrar FOR MODIFY
      IMPORTING keys FOR ACTION header~encerrar RESULT result.

    METHODS imprimir FOR MODIFY
      IMPORTING keys FOR ACTION header~imprimir.

    METHODS buscaproximoid
      RETURNING
        VALUE(rv_number) TYPE ze_nr_nrm_aprop.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR header RESULT result.

    METHODS authoritycreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR header~authoritycreate.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR header RESULT result.

    METHODS atualizaentidade FOR DETERMINE ON SAVE
      IMPORTING keys FOR header~atualizaentidade.

    DATA gv_wait_async     TYPE abap_bool.

ENDCLASS.

CLASS lhc_header IMPLEMENTATION.

  METHOD get_authorizations.

    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
        ENTITY header
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data)
        FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    DATA: lv_update TYPE if_abap_behv=>t_xflag,
          lv_delete TYPE if_abap_behv=>t_xflag.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclpp_auth_zppwerks=>werks_update( <fs_data>-plant ).
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.

        IF zclpp_auth_zppwerks=>werks_delete( <fs_data>-plant ).
          lv_delete = if_abap_behv=>auth-allowed.
        ELSE.
          lv_delete = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      APPEND VALUE #( %tky = <fs_data>-%tky
                      %update = lv_update
                      %delete = lv_delete
                      %assoc-_consumo = lv_update
                      %assoc-_ordens  = lv_update )
             TO result.

    ENDLOOP.

  ENDMETHOD.

  METHOD authoritycreate.

    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
        ENTITY header
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclpp_auth_zppwerks=>werks_create( <fs_data>-plant ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-header.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-header.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create )
                        %element-plant = if_abap_behv=>mk-on )
          TO reported-header.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD calculardocumentno.

    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY header
    FIELDS ( documentno )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    IF NOT line_exists( lt_header[ documentno  = '' ] ). "#EC CI_STDSEQ
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY header
    UPDATE FIELDS ( documentno status )
    WITH VALUE #( FOR ls_header IN lt_header WHERE ( documentno IS INITIAL ) ( "#EC CI_STDSEQ
                       %key      =  ls_header-%key
                        documentno   = buscaproximoid( )
                        status = '0'
                       ) )
    REPORTED DATA(lt_reported).

  ENDMETHOD.


  METHOD buscaproximoid.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZPPNRMAPR'
      IMPORTING
        number                  = rv_number
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD encerrar.

    gv_wait_async = abap_false.

    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
        ENTITY header
          FIELDS ( status ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header)
        FAILED failed.

    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
    IF sy-subrc = 0.

      DATA(lo_object) = NEW zclpp_norma_apropriacao( ).

      lo_object->check_quantidade( EXPORTING iv_doc_uuid_h = <fs_header>-docuuidh
                                   IMPORTING et_return     = DATA(lt_validado) ).

      LOOP AT lt_validado ASSIGNING FIELD-SYMBOL(<fs_validado>).

        APPEND VALUE #( %msg = new_message( id       = <fs_validado>-id
                                            number   = <fs_validado>-number
                                            v1       = <fs_validado>-message_v1
                                            v2       = <fs_validado>-message_v2
                                            v3       = <fs_validado>-message_v3
                                            v4       = <fs_validado>-message_v4
                                            severity = CONV #( <fs_validado>-type ) )
                         ) TO reported-header.

      ENDLOOP.

      CHECK lt_validado IS INITIAL.

      CALL FUNCTION 'ZFMPP_NRM_APR_ENCERRAMENTO'
        STARTING NEW TASK 'PRODENC'
        CALLING setup_messages ON END OF TASK
        EXPORTING
          iv_doc_uuid_h = <fs_header>-docuuidh.

      WAIT UNTIL gv_wait_async = abap_true.

    ENDIF.

    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
      ENTITY header
        FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_return)
      FAILED failed.

    result = VALUE #( FOR ls_header IN lt_return
                       ( %tky   = ls_header-%tky
                         %param = ls_header ) ).

  ENDMETHOD.

  METHOD imprimir.

    DATA: lt_return_all   TYPE bapiret2_t,
          ls_guia         TYPE zppguia_rebeneficiamento,
          ls_despejo      TYPE zppguia_rebenef_despejo,
          ls_resultado    TYPE zppguia_rebenef_resultado,
          ls_res_obtido   TYPE zppguia_rebenef_res_obtido,
          ls_res_material TYPE zppguia_rebenef_res_material.

* ---------------------------------------------------------------------------
* Recupera dados das linhas selecionadas
* ---------------------------------------------------------------------------
    "Header
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY header
    FIELDS ( documentno docname plant plantname ordertype basicstartdate
             locallastchangedat )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    "Comsumo
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY header BY \_consumo
    FIELDS ( plant )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_consumo).

    "Ordem
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY header BY \_ordens
    FIELDS ( quantity quantityuom material materialname plant processorder )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_ordem).

    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
    IF  sy-subrc = 0.

      ls_guia-printer      = keys[ 1 ]-%param.
      ls_guia = CORRESPONDING #( <fs_header> ).

      " Converter para data
      CONVERT TIME STAMP <fs_header>-locallastchangedat TIME ZONE gc_zone
              INTO DATE DATA(lv_data).
      ls_guia-finaldate = lv_data.

      " Soma as quantidades das Ordens
      IF lt_ordem[] IS NOT INITIAL.
        DATA(lt_sumqtd) = VALUE ty_data_tab(
            FOR GROUPS lt_group OF ls_input_line IN lt_ordem
                GROUP BY ( quantityuom = ls_input_line-quantityuom )
                (   quantityuom = lt_group-quantityuom
                    quantity    = REDUCE #(
                        INIT lv_subtotal = 0
                        FOR ls_group_line IN GROUP lt_group
                        NEXT lv_subtotal  = lv_subtotal  + ls_group_line-quantity
                    )
                )
        ).
        ls_guia-total_quantity = |{ lt_sumqtd[ 1 ]-quantity } { lt_sumqtd[ 1 ]-quantityuom }|.
      ENDIF.

* ---------------------------------------------------------------------------
* Despejo / Resultado
* ---------------------------------------------------------------------------
      IF lt_ordem[] IS NOT INITIAL.

        SELECT materialdocument, processorder, plant, material, materialname, goodsmovementtype,
               batchforedit, baseunit, quantityinbaseunit
        INTO TABLE @DATA(lt_procord)
        FROM i_procordmgmtgoodsmovement
        FOR ALL ENTRIES IN @lt_ordem
        WHERE plant        = @lt_ordem-plant
          "AND material     = @lt_ordem-material
          AND processorder = @lt_ordem-processorder
          AND goodsmovementtype IN ( @gc_despejo, @gc_despejo262, @gc_resultado, @gc_resultado102, @gc_resultado531, @gc_resultado532 ).

        IF sy-subrc  EQ 0.

          LOOP AT lt_procord INTO DATA(ls_procord). "#EC CI_LOOP_INTO_WA

            CLEAR: ls_despejo, ls_resultado, ls_res_material.

            IF ls_procord-goodsmovementtype  EQ gc_despejo OR ls_procord-goodsmovementtype  EQ gc_despejo262.

              ls_despejo = CORRESPONDING #( ls_procord ).
              " Converter para SAC
              CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                EXPORTING
                  i_matnr              = ls_procord-material
                  i_in_me              = ls_procord-baseunit
                  i_out_me             = gc_sac
                  i_menge              = ls_procord-quantityinbaseunit
                IMPORTING
                  e_menge              = ls_despejo-quantitysac
                EXCEPTIONS
                  error_in_application = 1
                  error                = 2
                  OTHERS               = 3.
              IF sy-subrc EQ 0.
                IF ls_procord-goodsmovementtype = gc_despejo262.
                  ls_despejo-quantityinbaseunit = ls_despejo-quantityinbaseunit * -1.
                  ls_despejo-quantitysac        = ls_despejo-quantitysac * -1.
                ENDIF.
                COLLECT ls_despejo INTO ls_guia-despejo.
              ENDIF.

            ELSE.

              ls_resultado = CORRESPONDING #( ls_procord ).
              ls_res_material = CORRESPONDING #( ls_procord ).

              " Converter para SAC
              CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                EXPORTING
                  i_matnr              = ls_procord-material
                  i_in_me              = ls_procord-baseunit
                  i_out_me             = gc_sac
                  i_menge              = ls_procord-quantityinbaseunit
                IMPORTING
                  e_menge              = ls_resultado-quantitysac
                EXCEPTIONS
                  error_in_application = 1
                  error                = 2
                  OTHERS               = 3.
              IF sy-subrc EQ 0.


                IF ls_procord-goodsmovementtype = gc_resultado102 OR ls_procord-goodsmovementtype = gc_resultado532.
                  ls_resultado-quantityinbaseunit = ls_resultado-quantityinbaseunit * -1.
                  ls_resultado-quantitysac        = ls_resultado-quantitysac * -1.
                ENDIF.

                COLLECT ls_resultado INTO ls_guia-resultado.

                ls_res_material-quantitysac = ls_resultado-quantitysac.
                COLLECT ls_res_material INTO ls_guia-resultado_material.

              ENDIF.

            ENDIF.

          ENDLOOP.




          DELETE ls_guia-despejo WHERE quantityinbaseunit <= 0. "#EC CI_STDSEQ
          DELETE ls_guia-resultado WHERE quantityinbaseunit <= 0. "#EC CI_STDSEQ

        ENDIF.

      ENDIF.

* ---------------------------------------------------------------------------
* Resultado Obtido
* ---------------------------------------------------------------------------
      LOOP AT lt_ordem INTO DATA(ls_ordem).        "#EC CI_LOOP_INTO_WA

        CLEAR ls_res_obtido.

        ls_res_obtido = CORRESPONDING #( ls_ordem ).

        COLLECT ls_res_obtido INTO ls_guia-resultado_obtido.

      ENDLOOP.

* ---------------------------------------------------------------------------
* Imprime Guia
* ---------------------------------------------------------------------------
      DATA(lo_impressao) = NEW zclpp_guia_rebenef_imp( ).
      DATA(lt_return) = lo_impressao->imprime_guia( EXPORTING is_guia = ls_guia   ).

      INSERT LINES OF lt_return[] INTO TABLE lt_return_all[].

* ---------------------------------------------------------------------------
*Retorna mensagens de erro
* ---------------------------------------------------------------------------
      LOOP AT lt_return_all INTO DATA(ls_return_all).

        APPEND VALUE #( %msg = new_message( id       = ls_return_all-id
                                            number   = ls_return_all-number
                                            v1       = ls_return_all-message_v1
                                            v2       = ls_return_all-message_v2
                                            v3       = ls_return_all-message_v3
                                            v4       = ls_return_all-message_v4
                                            severity = CONV #( ls_return_all-type ) )
                         )
          TO reported-header.


      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD get_features.

    DATA: lv_edit TYPE x LENGTH 1.
*    DATA: lv_ordem TYPE x LENGTH 1.
    DATA: lr_status TYPE RANGE OF ze_status_nrm_apr.

    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
      ENTITY header
        FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header)
      FAILED failed.


    lr_status = VALUE #( sign = 'I'
                         option = 'EQ'
                         ( low = '0' )
                         ( low = '1' )
                         ( low = '2' )
                         ( low = '3' )  ).

    "Somente editar com status pendente
    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
    IF sy-subrc = 0.
      IF <fs_header>-status IN lr_status.
        lv_edit = if_abap_behv=>fc-o-disabled.
      ELSE.
        lv_edit =  if_abap_behv=>fc-o-enabled.
      ENDIF.
    ENDIF.

    result =
    VALUE #(
    FOR ls_header IN lt_header
      LET lv_encerrar =   COND #( WHEN ls_header-status = '3'
                                  THEN if_abap_behv=>fc-o-disabled
                                  ELSE if_abap_behv=>fc-o-enabled  )

      IN
        ( %tky              = ls_header-%tky
          %action-encerrar  = lv_encerrar
          %delete           = lv_edit
          %update           = lv_edit
         ) ).



  ENDMETHOD.


  METHOD setup_messages.
    gv_wait_async = abap_true.
  ENDMETHOD.


  METHOD atualizaentidade.

    "Header
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY header
    FIELDS ( plant ordertype basicstartdate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    "Comsumo
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY header BY \_consumo
    FIELDS ( plant )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_consumo).

    "Ordem
    READ ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
    ENTITY header BY \_ordens
    FIELDS ( plant basicstartdate ordertype )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_ordem).


    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
    IF  sy-subrc = 0.

      MODIFY ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
      ENTITY consumo
      UPDATE FIELDS ( plant )
      WITH VALUE #( FOR ls_consumo IN lt_consumo WHERE ( status = '0') ( "#EC CI_STDSEQ
                         %key      =  ls_consumo-%key
                          plant = <fs_header>-plant
                         ) )

      REPORTED DATA(lt_reported).

      MODIFY ENTITIES OF zi_pp_nrm_apr_h IN LOCAL MODE
      ENTITY ordem
      UPDATE FIELDS ( plant basicstartdate ordertype )
      WITH VALUE #( FOR ls_ordem IN lt_ordem WHERE ( status = '0') ( "#EC CI_STDSEQ
                         %key      =  ls_ordem-%key
                          plant = <fs_header>-plant
                          ordertype = <fs_header>-ordertype
                          basicstartdate = <fs_header>-basicstartdate
                         ) )

      REPORTED DATA(lt_reported2).

    ENDIF.


  ENDMETHOD.


ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
