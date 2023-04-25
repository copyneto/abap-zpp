"!<p>Proxy de inbound do apontamento de produção do sistema MES
"!<strong>http://trescoracoes.com.br/chaodefabrica/producao</strong></p>
"!<p><strong>Autor:</strong> Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong> 12 de ago de 2021</p>
CLASS zclpp_cl_si_realizar_apontame1 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zclpp_ii_si_realizar_apontame1 .
ENDCLASS.



CLASS ZCLPP_CL_SI_REALIZAR_APONTAME1 IMPLEMENTATION.


  METHOD zclpp_ii_si_realizar_apontame1~si_realizar_apontamento_in.

    DATA(lo_apontamento) = NEW zclpp_apont_prod_inbound( ).

    TRY.
        lo_apontamento->efetuar_apontamento(
          EXPORTING
            iv_orderid    = input-mt_apontamento-orderid
            iv_quantidade = input-mt_apontamento-yield
            iv_conf_text  = input-mt_apontamento-conf_text
          IMPORTING
            es_apontamento_resp = output ).

      CATCH zcxpp_erro_interface_mes INTO DATA(lo_erro).

        DATA(ls_erro) = VALUE zclpp_exchange_fault_data( fault_text = lo_erro->get_text( ) ).

        RAISE EXCEPTION TYPE zclpp_cx_fmt_apontamento1
          EXPORTING
            standard = ls_erro ##ENH_OK.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
