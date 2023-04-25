class ZCLPP_NORMA_APROPRIA_DPC_EXT definition
  public
  inheriting from ZCLPP_NORMA_APROPRIA_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCLPP_NORMA_APROPRIA_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.
    DATA: lo_message    TYPE REF TO /iwbep/if_message_container,
          lo_exception  TYPE REF TO /iwbep/cx_mgw_busi_exception,
          lt_norma_apro TYPE TABLE OF zspp_layout_arq_norma_apro.

    DATA: ls_entity TYPE zspp_gateway_upload.

    DATA(lo_preenche_tabelas) = NEW zclpp_preenche_tabelas_nor_ap( ).

*    DATA: ls_file TYPE ypoc_excel.

    DATA: lv_nome_arq TYPE rsfilenm,
          lv_guid_str TYPE string,
          lv_guid     TYPE guid_16.

    ##NO_TEXT
    DATA lv_mime_type TYPE char100 VALUE 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.

     IF is_media_resource-mime_type = lv_mime_type.

      SPLIT iv_slug AT ';' INTO lv_guid_str lv_nome_arq.

      lv_guid_str = to_upper( lv_guid_str ).
      TRANSLATE lv_guid_str USING '- '.
      CONDENSE lv_guid_str NO-GAPS .

      lv_guid   = lv_guid_str.

      lo_preenche_tabelas->converte_xstring_para_it(
       EXPORTING
         iv_xstring  = is_media_resource-value
         iv_nome_arq = lv_nome_arq
       CHANGING
         ct_tabela   = lt_norma_apro
      ).

      IF lt_norma_apro IS NOT INITIAL.
        lo_preenche_tabelas->insert_ztpp_nrm_apr_con( EXPORTING iv_guid   = lv_guid
                                                                it_tabela = lt_norma_apro
                                                      IMPORTING et_return = DATA(lt_return) ).
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
ENDCLASS.
