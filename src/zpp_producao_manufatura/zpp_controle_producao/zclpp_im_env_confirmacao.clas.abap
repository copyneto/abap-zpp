"! <p class="shorttext synchronized" lang="PT">Usage of ABAP Doc</p>
"! Classe associada a implementação ZPP_ENVIAR_CONFIRMACAO da BADI
"! WORKORDER_CONFIRM
"! No método IF_EX_WORKORDER_CONFIRM~AT_SAVE o IDOC
"! MOAPS_CONFIRMOPERATIONS01 é disparado.
CLASS zclpp_im_env_confirmacao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_ex_workorder_confirm .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclpp_im_env_confirmacao IMPLEMENTATION.


  METHOD if_ex_workorder_confirm~at_cancel_check.           "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_confirm~at_save.                   "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_confirm~before_update.             "#EC NEEDED

*    TRY.
*        NEW zclpp_confirmacao_outbound( )->trigger_idoc( is_confirmation = it_confirmation[ 1 ] ).
*      CATCH cx_sy_itab_line_not_found ##NO_HANDLER.
*    ENDTRY.

**    Realiza a impressão de etiquetas.
    TRY.
        NEW zclpp_confirmacao_outbound( )->trigger_etiquetas( is_confirmation = it_confirmation[ 1 ] ).
      CATCH cx_sy_itab_line_not_found ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD if_ex_workorder_confirm~individual_capacity.       "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_confirm~in_update.                 "#EC NEEDED

  ENDMETHOD.
ENDCLASS.
