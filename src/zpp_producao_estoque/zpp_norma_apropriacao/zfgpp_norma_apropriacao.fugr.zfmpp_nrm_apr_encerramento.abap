FUNCTION zfmpp_nrm_apr_encerramento.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_DOC_UUID_H) TYPE  ZTPP_NRM_APR_H-DOC_UUID_H
*"----------------------------------------------------------------------

  DATA(lo_producao) = NEW zclpp_norma_apropriacao(  ).

  lo_producao->encerramento( iv_doc_uuid_h ).

ENDFUNCTION.
