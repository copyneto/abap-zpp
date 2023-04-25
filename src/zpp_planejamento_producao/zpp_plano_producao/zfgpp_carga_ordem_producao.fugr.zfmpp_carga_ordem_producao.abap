FUNCTION zfmpp_carga_ordem_producao.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_FILETYPE) TYPE  ZE_PRODUCAO_FILETYPE
*"     VALUE(IV_FILE_ID) TYPE  GUID
*"  EXPORTING
*"     VALUE(ET_MESSAGES) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------
  DATA(lo_carga_producao) = NEW zclpp_planejamento_producao( ).

  lo_carga_producao->setup_data(
    EXPORTING
      iv_filetype = iv_filetype
      iv_file_id  = iv_file_id ).

  lo_carga_producao->processar_arquivo( ).

  lo_carga_producao->get_messages(
    IMPORTING
      et_messages = et_messages ).
ENDFUNCTION.
