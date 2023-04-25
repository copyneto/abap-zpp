FUNCTION zfmpp_nrm_apr_graos_consumidos.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_DOC_UUID_H) TYPE  ZTPP_NRM_APR_H-DOC_UUID_H
*"     VALUE(IV_DOC_UUID_CONSUMO) TYPE
*"        ZTPP_NRM_APR_CON-DOC_UUID_CONSUMO
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------
  DATA(lo_producao) = NEW zclpp_norma_apropriacao(  ).

  lo_producao->graos_consumidos(
    EXPORTING
        iv_doc_uuid_h       = iv_doc_uuid_h
        iv_doc_uuid_consumo = iv_doc_uuid_consumo
    IMPORTING
        et_return = et_return ).

ENDFUNCTION.
