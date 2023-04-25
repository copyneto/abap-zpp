CLASS zclpp_guia_rebenef_imp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS imprime_guia
      IMPORTING
        !is_guia         TYPE zppguia_rebeneficiamento
      RETURNING
        VALUE(rt_return) TYPE bapiret2_t .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      ty_val_tab TYPE STANDARD TABLE OF api_vali .

    CONSTANTS:
      BEGIN OF gc_values,
        ygv_impurezas    TYPE atnam VALUE 'YGV_IMPUREZAS',
        ygv_fundo        TYPE atnam VALUE 'YGV_FUNDO',
        ygv_catacao      TYPE atnam VALUE 'YGV_CATACAO',
        ygv_mk10         TYPE atnam VALUE 'YGV_MK10',
        ygv_p19          TYPE atnam VALUE 'YGV_P19',
        ygv_p18          TYPE atnam VALUE 'YGV_P18',
        ygv_p17          TYPE atnam VALUE 'YGV_P17',
        ygv_p16          TYPE atnam VALUE 'YGV_P16',
        ygv_p15          TYPE atnam VALUE 'YGV_P15',
        ygv_p14          TYPE atnam VALUE 'YGV_P14',
        ygv_p13          TYPE atnam VALUE 'YGV_P13',
        ygv_p12          TYPE atnam VALUE 'YGV_P12',
        ygv_p11          TYPE atnam VALUE 'YGV_P11',
        ygv_p10          TYPE atnam VALUE 'YGV_P10',
        ygv_obs          TYPE atnam VALUE 'YGV_OBS',
      END OF gc_values .

    DATA gv_qtd_sacas TYPE menge_d.

    METHODS find_value
      IMPORTING
        !it_value       TYPE ty_val_tab
        !iv_atnam       TYPE atnam
      RETURNING
        VALUE(rv_valor) TYPE menge_d .
ENDCLASS.



CLASS ZCLPP_GUIA_REBENEF_IMP IMPLEMENTATION.


  METHOD imprime_guia.
    CONSTANTS lc_locl TYPE string VALUE 'LOCL' ##NO_TEXT.

    DATA: lv_spoolid TYPE rspoid,
          ls_guia    TYPE zppguia_rebeneficiamento.

    ls_guia = is_guia.

    FREE: rt_return.

* ----------------------------------------------------------------------
* Recupera impressora padrão do usuário
* ----------------------------------------------------------------------
    IF ls_guia-printer IS INITIAL.

      SELECT SINGLE spld
        FROM usr01
        INTO @ls_guia-printer
        WHERE bname = @sy-uname.

      IF sy-subrc NE 0 OR ls_guia-printer IS INITIAL.
        ls_guia-printer = lc_locl.
      ENDIF.

* ----------------------------------------------------------------------
* Verifica se impressora solicitada existe
* ----------------------------------------------------------------------
    ELSE.

      SELECT SINGLE padest
        FROM tsp03
        INTO @ls_guia-printer
        WHERE padest  = @ls_guia-printer.

      IF sy-subrc NE 0.

        " Impressora &1 não existe.
        rt_return[] =  VALUE #( BASE rt_return ( type       = 'E'
                                                 id         = 'ZSD_IMPRESSAO_NF'
                                                 number     = gc_msg_disp
                                                 message_v1 = ls_guia-printer ) ).
        RETURN.
      ENDIF.
    ENDIF.

* ----------------------------------------------------------------------
* Monta dados da variante - classificação
* ----------------------------------------------------------------------
    DATA: lt_val_tab        TYPE TABLE OF api_vali,
          ls_resultado_prev TYPE zppguia_rebenef_result_prev.

    LOOP AT ls_guia-despejo INTO DATA(ls_resultado). "#EC CI_LOOP_INTO_WA

      FREE lt_val_tab.

      CALL FUNCTION 'QC01_BATCH_VALUES_READ'
        EXPORTING
          i_val_matnr    = ls_resultado-material
          i_val_werks    = ls_resultado-plant
          i_val_charge   = ls_resultado-batchforedit
        TABLES
          t_val_tab      = lt_val_tab
        EXCEPTIONS
          no_class       = 1
          internal_error = 2
          no_values      = 3
          no_chars       = 4
          OTHERS         = 5.
      IF sy-subrc = 0.

        gv_qtd_sacas = ls_resultado-quantitysac.

        CLEAR ls_resultado_prev.

        ls_resultado_prev-p10      = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_p10 ).
        ls_resultado_prev-p11      = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_p11 ).
        ls_resultado_prev-p12      = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_p12 ).
        ls_resultado_prev-p13      = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_p13 ).
        ls_resultado_prev-p14      = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_p14 ).
        ls_resultado_prev-p15      = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_p15 ).
        ls_resultado_prev-p16      = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_p16 ).
        ls_resultado_prev-p17      = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_p17 ).
        ls_resultado_prev-p18      = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_p18 ).
        ls_resultado_prev-p19      = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_p19 ).
        ls_resultado_prev-mk10     = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_mk10 ).
        ls_resultado_prev-fundo    = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_fundo ).
        ls_resultado_prev-catacao  = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_catacao ).
        ls_resultado_prev-impurezas = find_value( EXPORTING it_value = lt_val_tab iv_atnam = gc_values-ygv_impurezas ).

        COLLECT ls_resultado_prev inTO ls_guia-resultado_previsto.

      ENDIF.

    ENDLOOP.

* ----------------------------------------------------------------------
* Encontra Formulário
* ----------------------------------------------------------------------
    DATA: lv_formname           TYPE tdsfname,
          lv_control_parameters TYPE ssfctrlop,
          lv_output_options     TYPE ssfcompop.
    DATA: ls_ret_guia TYPE ssfcrescl.
    DATA: lv_funcname TYPE rs38l_fnam.

    lv_formname = 'ZSFPP_GUIA_REBENEFICIAMENTO'.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = lv_formname
      IMPORTING
        fm_name            = lv_funcname
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
      rt_return[] =  VALUE #( BASE rt_return ( type       = gc_msg_error
                                               id         = gc_msg_class
                                               number     = gc_msg_form
                                               message_v1 = lv_formname ) ).
      RETURN.
    ENDIF.

* ----------------------------------------------------------------------
* Imprime Formulário
* ----------------------------------------------------------------------
    IF ls_guia-printer <> lc_locl.
      lv_output_options-tdimmed       = abap_true.
    ENDIF.
    lv_output_options-tddest        = ls_guia-printer.
    lv_control_parameters-no_dialog = abap_true.
    lv_output_options-tdnewid       = abap_true.

    CALL FUNCTION lv_funcname
      EXPORTING
        control_parameters = lv_control_parameters
        output_options     = lv_output_options
        user_settings      = space
        guia_receb         = ls_guia
      IMPORTING
        job_output_info    = ls_ret_guia
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
      rt_return[] =  VALUE #( BASE rt_return ( type       = gc_msg_warnig
                                               id         = gc_msg_class
                                               number     = gc_msg_n_gera ) ).
    ELSE.

      " Doc &1: Form. &2 impresso no spool &3.
      lv_spoolid = ls_ret_guia-spoolids[ 1 ].
      rt_return[] =  VALUE #( BASE rt_return ( type       = 'S'
                                               id         = gc_msg_class
                                               number     = gc_msg_printed
                                               message_v1 = lv_formname
                                               message_v2 = lv_spoolid ) ).

    ENDIF.

  ENDMETHOD.


  METHOD find_value.

    DATA: lv_qtde_perc TYPE atwrt,
          lv_qde       TYPE menge_d.

    DATA(lv_value) = VALUE #( it_value[ atnam = iv_atnam ]-atwrt OPTIONAL ). "#EC CI_STDSEQ
    FIND '%' IN lv_value.
    IF sy-subrc = 0.
      DATA(lv_perc) = abap_true.
    ENDIF.
    CONDENSE lv_value NO-GAPS.
    TRANSLATE lv_value USING '% '.

    IF lv_perc IS NOT INITIAL AND lv_value IS NOT INITIAL
      AND gv_qtd_sacas IS NOT INITIAL.
      lv_qtde_perc  = lv_value.
      TRANSLATE: lv_qtde_perc  USING ',.'.
      lv_qde = ( gv_qtd_sacas * lv_qtde_perc ) / 100.
      lv_value = lv_qde.
*      CONDENSE lv_value NO-GAPS.
*      TRANSLATE: lv_value USING '.,'.
    ENDIF.

    rv_valor = lv_value.

  ENDMETHOD.
ENDCLASS.
