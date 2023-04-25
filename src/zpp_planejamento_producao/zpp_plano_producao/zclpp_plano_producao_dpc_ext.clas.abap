CLASS zclpp_plano_producao_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zclpp_plano_producao_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /iwbep/if_mgw_appl_srv_runtime~create_stream
        REDEFINITION.

    METHODS /iwbep/if_mgw_appl_srv_runtime~get_stream
        REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclpp_plano_producao_dpc_ext IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.

    DATA: lo_message   TYPE REF TO /iwbep/if_message_container,
          lo_exception TYPE REF TO /iwbep/cx_mgw_busi_exception,
          lt_curto TYPE TABLE OF zspp_layout_arq_curto_prazo,
          lt_medio TYPE TABLE OF zspp_layout_arq_medio_prazo.

    DATA: ls_entity TYPE zspp_gateway_upload.

    DATA(lo_preenche_tabelas) = NEW zclpp_preenche_tabelas( ).

*    DATA: ls_file TYPE ypoc_excel.

    DATA: lv_filetype TYPE ze_producao_filetype,
          lv_nome_arq TYPE rsfilenm,
          lv_guid     TYPE guid_16.

    DATA lv_mime_type TYPE char100 VALUE 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.

    IF is_media_resource-mime_type = lv_mime_type.

      SPLIT iv_slug AT ';' INTO lv_nome_arq lv_filetype.

      TRY.
          lv_guid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.

      CASE lv_filetype.
        WHEN 'C'.
          lo_preenche_tabelas->converte_xstring_para_it(
            EXPORTING
              iv_xstring  = is_media_resource-value
              iv_nome_arq = lv_nome_arq
            CHANGING
              ct_tabela   = lt_curto
          ).

          IF lt_curto IS NOT INITIAL.
            lo_preenche_tabelas->insert_ztpp_prod_curto( EXPORTING iv_guid   = lv_guid
                                                                   it_tabela = lt_curto
                                                         IMPORTING et_return = DATA(lt_return) ).
          ENDIF.

        WHEN 'M'.
          lo_preenche_tabelas->converte_xstring_para_it(
            EXPORTING
              iv_xstring  = is_media_resource-value
              iv_nome_arq = lv_nome_arq
            CHANGING
              ct_tabela   = lt_medio
          ).

          IF lt_medio IS NOT INITIAL.
            lo_preenche_tabelas->insert_ztpp_prod_medio( EXPORTING iv_guid   = lv_guid
                                                                   it_tabela = lt_medio
                                                         IMPORTING et_return = lt_return ).
          ENDIF.
      ENDCASE.

      IF lt_return IS INITIAL AND ( lt_curto IS NOT INITIAL OR lt_medio IS NOT INITIAL ).

        TRY.
            DATA(lv_plant) = COND #( WHEN lt_curto[] IS NOT INITIAL THEN lt_curto[ 1 ]-plan_plant
                                     WHEN lt_medio[] IS NOT INITIAL THEN lt_medio[ 1 ]-plant
                                     ELSE space ).
          CATCH cx_root.
        ENDTRY.

        lo_preenche_tabelas->insert_ztpp_arq_prod( iv_guid     = lv_guid
                                                   iv_nome_arq = lv_nome_arq
                                                   iv_type     = lv_filetype
                                                   iv_plant    = lv_plant ).
      ENDIF.

      ls_entity-filename     = lv_nome_arq.
      ls_entity-mimetype     = is_media_resource-mime_type.
      ls_entity-type_message = 'S'.

    ELSE.

      ls_entity-filename     = lv_nome_arq.
      ls_entity-mimetype     = is_media_resource-mime_type.
      ls_entity-type_message = 'E'.

    ENDIF.

    copy_data_to_ref( EXPORTING is_data = ls_entity
                      CHANGING  cr_data = er_entity ).

* ----------------------------------------------------------------------
* Ativa exceção em casos de erro
* ----------------------------------------------------------------------
    IF lt_return[] IS NOT INITIAL.
      lo_message = mo_context->get_message_container( ).
      lo_message->add_messages_from_bapi( it_bapi_messages = lt_return ).
      CREATE OBJECT lo_exception EXPORTING message_container = lo_message.
      RAISE EXCEPTION lo_exception.
    ENDIF.

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.

    DATA: lo_message   TYPE REF TO /iwbep/if_message_container,
          lo_exception TYPE REF TO /iwbep/cx_mgw_busi_exception,
          ls_stream    TYPE ty_s_media_resource,
          ls_lheader   TYPE ihttpnvp,
          lv_extension TYPE char40.

    CASE iv_entity_name.

* ===========================================================================
* Gerencia Botão do aplicativo "Download"
* ===========================================================================
      WHEN gc_entity-download.

        TRY.
            DATA(lv_id) = it_key_tab[ name = gc_fields-id ]-value. "#EC CI_STDSEQ
          CATCH cx_root.
        ENDTRY.

* ----------------------------------------------------------------------
* Recupera arquivo de layout
* ----------------------------------------------------------------------
        zclpp_planejamento_producao=>download_arquivo( EXPORTING iv_id       = lv_id
                                                       IMPORTING ev_filename = DATA(lv_filename)
                                                                 ev_file     = DATA(lv_file)
                                                                 ev_mimetype = DATA(lv_mimetype)
                                                                 et_return   = DATA(lt_return) ).

      WHEN OTHERS.
        RETURN.

    ENDCASE.

* ----------------------------------------------------------------------
* Retorna binário do arquivo
* ----------------------------------------------------------------------
    ls_stream-mime_type = lv_mimetype.
    ls_stream-value     = lv_file.

    copy_data_to_ref( EXPORTING is_data = ls_stream
                      CHANGING  cr_data = er_stream ).

* ----------------------------------------------------------------------
* Muda nome do arquivo
* ----------------------------------------------------------------------
* Tipo comportamento:
* - inline : Não fará download automático
* - outline: Download automático
* ----------------------------------------------------------------------
    ls_lheader-name  = |Content-Disposition| ##NO_TEXT.
    ls_lheader-value = |outline; filename="{ lv_filename }";| ##NO_TEXT.

    set_header( is_header = ls_lheader ).

* ----------------------------------------------------------------------
* Ativa exceção em casos de erro
* ----------------------------------------------------------------------
    IF lt_return[] IS NOT INITIAL.
      lo_message = mo_context->get_message_container( ).
      lo_message->add_messages_from_bapi( it_bapi_messages = lt_return ).
      CREATE OBJECT lo_exception EXPORTING message_container = lo_message.
      RAISE EXCEPTION lo_exception.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
