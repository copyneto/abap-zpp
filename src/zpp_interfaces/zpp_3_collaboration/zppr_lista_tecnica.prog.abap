***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Interface com 3 Collaboration                          *
*** AUTOR : Heitor Alves - META                                       *
*** FUNCIONAL: Antonio Lopes - META                                   *
*** DATA : 11.01.2022                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 11.01.2022 | Heitor Alves       | Desenvolvimento inicial         *
***********************************************************************
REPORT zppr_lista_tecnica.

DATA: gv_matnr TYPE matnr,
      gv_werks TYPE werks_d,
      gv_stalt TYPE stalt,
      gv_datuv TYPE datuv,
      gv_datub TYPE datub.

SELECT-OPTIONS: s_matnr FOR gv_matnr.
SELECT-OPTIONS: s_werks FOR gv_werks.
SELECT-OPTIONS: s_stalt FOR gv_stalt.
SELECT-OPTIONS: s_datuv FOR gv_datuv.
SELECT-OPTIONS: s_datub FOR gv_datub.

START-OF-SELECTION.
  TRY.

      DATA(go_job) = NEW zclpp_interface_collab( ).

      IF go_job IS BOUND.

        go_job->execute_job( EXPORTING  ir_matnr = s_matnr[]
                                        ir_werks = s_werks[]
                                        ir_stalt = s_stalt[]
                                        ir_datuv = s_datuv[]
                                        ir_datub = s_datub[] ).

* ECOSTA - Ajuste GAP 261 - 21.03.2022 Início
     MESSAGE text-s01 TYPE 'S'.
* ECOSTA - Ajuste GAP 261 - 21.03.2022 Fim
      ENDIF.
    CATCH zcxca_erro_interface INTO DATA(lo_erro).
      DATA: gv_erro(1) TYPE c     VALUE 'E',
            gv_msgno   TYPE numc3 VALUE '001'.

      DATA: gs_erro_msg TYPE bal_s_msg.

      gs_erro_msg-msgv1 = lo_erro->textid.
      gs_erro_msg-msgty = gv_erro.
      gs_erro_msg-msgid = sy-msgid.
      gs_erro_msg-msgno = gv_msgno.

      go_job->message_save( is_msg = gs_erro_msg  ).
  ENDTRY.
