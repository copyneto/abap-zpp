FUNCTION zfmpp_lanca_cont_estoque.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IT_AJUST_INV_HEADER) TYPE  ZCTGPP_AJUST_INV_H
*"     VALUE(IT_AJUST_INV_ITEM) TYPE  ZCTGPP_AJUST_INV_I
*"  EXPORTING
*"     VALUE(ET_AJUST_INV_MESSAGE) TYPE  ZCTGPP_AJUST_INV_M
*"----------------------------------------------------------------------
***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: EXECUTA RATEIO E LANÇA CONTAGEM DE ESTOQUE             *
*** AUTOR    : FLÁVIA LEITE –[META]                                   *
*** FUNCIONAL: ANTONIO LOPES – META                                   *
*** DATA     : 26.07.2021                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA      | AUTOR        | DESCRIÇÃO                              *
***-------------------------------------------------------------------*
***           |              |                                        *
***********************************************************************

  DATA(lo_lanca_cont_estoque) = NEW zclpp_lanca_cont_estoque( ).

  lo_lanca_cont_estoque->main( EXPORTING
                                it_ajust_inv_header = it_ajust_inv_header
                                it_ajust_inv_item = it_ajust_inv_item
                               IMPORTING
                                et_ajust_inv_message =  et_ajust_inv_message ).

ENDFUNCTION.
