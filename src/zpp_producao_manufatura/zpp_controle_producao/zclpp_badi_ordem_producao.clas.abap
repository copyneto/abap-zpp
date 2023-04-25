"!<p>Classe de implementação da BAdI <strong>WORKORDER_UPDATE</strong></p>
"!<p><strong>Autor:</strong> Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong> 30 de jul de 2021</p>
CLASS zclpp_badi_ordem_producao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_ex_workorder_update .

    "!Código do status de usuário equivalente ao sistema MES
    CONSTANTS gc_status_mes TYPE asttx VALUE 'MES' ##NO_TEXT.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLPP_BADI_ORDEM_PRODUCAO IMPLEMENTATION.


  METHOD if_ex_workorder_update~archive_objects.            "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_update~at_deletion_from_database.  "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_update~at_release.                 "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_update~at_save.                    "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_update~before_update.

    "Verificar se é necessário o envio do IDoc LOIPRO01
    IF line_exists( it_header[ 1 ] ).
      DATA(ls_header) = it_header[ 1 ].

      DATA(lo_if_ordem_producao) = NEW zclpp_ordem_prod_outbound( ).
      lo_if_ordem_producao->get_config( ).

      IF lo_if_ordem_producao->gv_falta_config = abap_false.
        IF lo_if_ordem_producao->verificar_envio( ls_header ).

          "Caso seja necessário o envio da interface, acionar método
          lo_if_ordem_producao->enviar_idoc( EXPORTING it_header    = it_header
                                                       it_operation = it_operation
                                                       it_component = it_component ).

          "Atualizar o status de usuário para 'MES'
          IF lo_if_ordem_producao->gv_erro_envio = abap_false.
            lo_if_ordem_producao->atualizar_user_status( EXPORTING it_header = it_header
                                                                   iv_status = gc_status_mes ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD if_ex_workorder_update~cmts_check.                 "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_update~initialize.                 "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_update~in_update.                  "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_update~number_switch.              "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_update~reorg_status_activate.      "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_update~reorg_status_act_check.     "#EC NEEDED

  ENDMETHOD.


  METHOD if_ex_workorder_update~reorg_status_revoke.        "#EC NEEDED

  ENDMETHOD.
ENDCLASS.
