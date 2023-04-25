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
REPORT zppr_consumo_item.

DATA: gv_matnr TYPE matnr,
      gv_werks TYPE werks_d,
* JWSILVA - Ajuste GAP 261 - 01.12.2022 Início
*      gv_jahrper TYPE ztpp_tt_periodo.
      gv_date  TYPE i_materialdocumentitem-documentdate.
* JWSILVA - Ajuste GAP 261 - 01.12.2022 Fim

SELECT-OPTIONS: s_matnr FOR gv_matnr.
SELECT-OPTIONS: s_werks FOR gv_werks.
* JWSILVA - Ajuste GAP 261 - 01.12.2022 Início
*PARAMETERS: p_mes TYPE numc2,
*            p_ano TYPE numc4.
SELECT-OPTIONS: s_date  FOR gv_date.
* JWSILVA - Ajuste GAP 261 - 01.12.2022 Fim

START-OF-SELECTION.
  TRY.

      DATA(go_job) = NEW zclpp_interface_collab( ).

      IF go_job IS BOUND.

* JWSILVA - Ajuste GAP 261 - 01.12.2022 Início
*        SHIFT p_mes RIGHT DELETING TRAILING space.
*        OVERLAY p_mes WITH '00'.
*
*        DATA(gv_periodo) = p_ano && '0' && p_mes.
*
*        APPEND INITIAL LINE TO gv_jahrper ASSIGNING FIELD-SYMBOL(<fs_jahrper>).
*        <fs_jahrper>-sign   = 'I'.
*        <fs_jahrper>-option = 'EQ'.
*        <fs_jahrper>-low    = gv_periodo.
* JWSILVA - Ajuste GAP 261 - 01.12.2022 Fim

        go_job->execute_job_r03( EXPORTING  ir_matnr        = s_matnr[]
                                            ir_werks        = s_werks[]
* JWSILVA - Ajuste GAP 261 - 01.12.2022 Início
*                                        ir_jahrper   = gv_jahrper
                                            ir_documentdate = s_date[]
* JWSILVA - Ajuste GAP 261 - 01.12.2022 Fim
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
