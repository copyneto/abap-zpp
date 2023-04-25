class ZCL_IM_PP_MD_PURREQ_CHANGE definition
  public
  final
  create public .

public section.

  interfaces IF_EX_MD_PURREQ_CHANGE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_PP_MD_PURREQ_CHANGE IMPLEMENTATION.


  METHOD if_ex_md_purreq_change~change_before_save_conv.
    RETURN.
  ENDMETHOD.


  METHOD if_ex_md_purreq_change~change_before_save_mrp.

    CONSTANTS: BEGIN OF lc_plan_mrp,
                 modulo TYPE ztca_param_par-modulo VALUE 'PP',
                 chave1 TYPE ztca_param_par-chave1 VALUE 'IF_SAP_REC',
                 chave2 TYPE ztca_param_par-chave2 VALUE 'DISPO',
               END OF lc_plan_mrp,

               BEGIN OF lc_org_comp,
                 modulo TYPE ztca_param_par-modulo VALUE 'PP',
                 chave1 TYPE ztca_param_par-chave1 VALUE 'IF_SAP_REC',
                 chave2 TYPE ztca_param_par-chave2 VALUE 'EKORG',
               END OF lc_org_comp,

               BEGIN OF lc_tp_ped,
                 modulo TYPE ztca_param_par-modulo VALUE 'PP',
                 chave1 TYPE ztca_param_par-chave1 VALUE 'IF_SAP_REC',
                 chave2 TYPE ztca_param_par-chave2 VALUE 'BSART',
               END OF lc_tp_ped.

    DATA: lt_plan_mrp TYPE range_t_dispo,
          lt_org_comp TYPE ehprct_range_ekorg.


    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = lc_plan_mrp-modulo
                                         iv_chave1 = lc_plan_mrp-chave1
                                         iv_chave2 = lc_plan_mrp-chave2
                               IMPORTING et_range  = lt_plan_mrp ).
        IF ch_eban-dispo IN lt_plan_mrp.
          TRY.
              lo_param->m_get_single( EXPORTING iv_modulo = lc_tp_ped-modulo
                                                iv_chave1 = lc_tp_ped-chave1
                                                iv_chave2 = lc_tp_ped-chave2
                                      IMPORTING ev_param  = ch_eban-bsart ).
              ch_changed = abap_true.
            CATCH zcxca_tabela_parametros.
          ENDTRY.
          TRY.
              lo_param->m_get_single( EXPORTING iv_modulo = lc_org_comp-modulo
                                                iv_chave1 = lc_org_comp-chave1
                                                iv_chave2 = lc_org_comp-chave2
                                      IMPORTING ev_param  = ch_eban-ekorg ).
              ch_changed = abap_true.
            CATCH zcxca_tabela_parametros.
          ENDTRY.
        ENDIF.
      CATCH zcxca_tabela_parametros.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
