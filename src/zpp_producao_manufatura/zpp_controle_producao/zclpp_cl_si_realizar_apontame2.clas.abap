"!<p>Proxy de inbound do apontamento de refugo do sistema MES</p>
"!<p><strong>Autor:</strong> Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong> 16 de ago de 2021</p>
CLASS zclpp_cl_si_realizar_apontame2 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zclpp_ii_si_realizar_apontame2 .

ENDCLASS.



CLASS zclpp_cl_si_realizar_apontame2 IMPLEMENTATION.


  METHOD zclpp_ii_si_realizar_apontame2~si_realizar_apontamento_refugo.


    DATA(lo_refugo) = NEW zclpp_refugo_de_operacao( ).

    TRY.
        lo_refugo->execute(
          EXPORTING
            iv_material   = input-mt_refugo-material
            iv_quantidade = input-mt_refugo-entry_qnt
            iv_unidade    = input-mt_refugo-entry_uom
            iv_ordem      = input-mt_refugo-orderid ).

      CATCH zcxpp_erro_interface_mes INTO DATA(lo_erro).

        DATA(ls_erro) = VALUE zclpp_exchange_fault_data1( fault_text = lo_erro->get_text( ) ).

        RAISE EXCEPTION TYPE zclpp_cx_fmt_refugo
          EXPORTING
            standard = ls_erro.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
