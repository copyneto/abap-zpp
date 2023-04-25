FUNCTION zfmpp_imprimir_etiqueta.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_WAIT) TYPE  CHAR1 DEFAULT ABAP_TRUE
*"     VALUE(IV_AUFNR) TYPE  AFRU-AUFNR
*"     VALUE(IV_RUECK) TYPE  AFRU-RUECK
*"     VALUE(IV_RMZHL) TYPE  AFRU-RMZHL
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------
  IF iv_wait = abap_true.
    "Aguardar a atualização no Banco de Dados
    WAIT UP TO 7 SECONDS.
  ENDIF.

  NEW zclpp_gerar_etiqueta( )->process(
    EXPORTING
      iv_aufnr = iv_aufnr
      iv_rueck = iv_rueck
      iv_rmzhl = iv_rmzhl
    IMPORTING
      et_return = et_return ).

*    NEW zclpp_gerar_etiqueta( )->process(
*      EXPORTING
*        iv_aufnr = iv_aufnr
*        iv_rueck = iv_rueck
*        iv_rmzhl = iv_rmzhl ).

ENDFUNCTION.
