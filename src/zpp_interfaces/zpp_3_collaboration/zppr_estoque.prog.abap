***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Interface com 3 Collaboration                          *
*** AUTOR : Heitor Alves - META                                       *
*** FUNCIONAL: Antonio Lopes - META                                   *
*** DATA : 27.01.2022                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 27.01.2022 | Heitor Alves       | Desenvolvimento inicial         *
***********************************************************************
REPORT zppr_estoque.

DATA: gv_matnr TYPE matnr,
      gv_werks TYPE werks_d,
* LSCHEPP - Ajustes GAP 058 - 15.08.2022 Início
      gv_lgort TYPE lgort_d,
      gv_mtart TYPE mtart,
      gv_matkl TYPE matkl.
* LSCHEPP - Ajustes GAP 058 - 15.08.2022 Fim

SELECT-OPTIONS: s_matnr FOR gv_matnr,
                s_werks FOR gv_werks,
* LSCHEPP - Ajustes GAP 058 - 15.08.2022 Início
                s_lgort FOR gv_lgort,
                s_mtart FOR gv_mtart,
                s_matkl FOR gv_matkl.
* LSCHEPP - Ajustes GAP 058 - 15.08.2022 Fim

START-OF-SELECTION.
  TRY.

      DATA(go_job) = NEW zclpp_interface_collab( ).

      IF go_job IS BOUND.

        go_job->execute_job_r04( EXPORTING  ir_matnr = s_matnr[]
                                            ir_werks = s_werks[]
* LSCHEPP - Ajustes GAP 058 - 15.08.2022 Início
                                            ir_lgort = s_lgort[]
                                            ir_mtart = s_mtart[]
                                            ir_matkl = s_matkl[]
* LSCHEPP - Ajustes GAP 058 - 15.08.2022 Fim
                                ).
* LSCHEPP - Ajuste GAP 261 - 12.04.2022 Início
        MESSAGE TEXT-s01 TYPE 'S'.
* LSCHEPP - Ajuste GAP 261 - 12.04.2022 Fim
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
