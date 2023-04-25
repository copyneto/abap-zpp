"!<p>Classe para gerar a impressão da etiqueta</p>
"!<p><strong>Autor:</strong>Igor Malfara</p>
"!<p><strong>Data:</strong> 16 de agosto de 2021</p>
CLASS zclpp_gerar_etiqueta DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    "! Executa toda a rotina da classe
    "! @parameter iv_aufnr  | Nº ordem
    "! @parameter iv_rueck  | Nº confirmação
    "! @parameter iv_rmzhl  | Numerador da confirmação
    "! @parameter et_return | Mensagens de retorno
    METHODS process
      IMPORTING
        !iv_aufnr  TYPE aufnr
        !iv_rueck  TYPE co_rueck
        !iv_rmzhl  TYPE co_rmzhl
      EXPORTING
        !et_return TYPE bapiret2_t.

  PROTECTED SECTION.


  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_process,
        "! Ordem para processamento
        aufnr TYPE aufnr,
        "! Confirmação para processamento
        rueck TYPE co_rueck,
        "! Numerador da confirmação para processamento
        rmzhl TYPE co_rmzhl,
      END OF ty_process .
    TYPES:
      tt_batch TYPE TABLE OF bapicharg1 .
    TYPES:
      tt_return TYPE TABLE OF bapireturn .
    TYPES:
      ty_tp_plant TYPE RANGE OF werks_d .
    TYPES:
      ty_tp_matnr TYPE RANGE OF matnr .
    TYPES:
      ty_tp_mtart TYPE RANGE OF mara-mtart .

    CONSTANTS:
      "! Valores utilizados na chamada da etiqueta
      BEGIN OF gc_etiq,
        "! Impressora padrão quando não existir configuração
        printer TYPE char4 VALUE 'LP01',
        "! Módulo para config. da impressora
        modulo  TYPE zi_ca_param_mod-modulo VALUE 'PP',
        "! Chave 1 para config. da impressora
        chave1  TYPE zi_ca_param_par-chave1 VALUE 'IF_SAP_MES',
        "! Chave 2 para config. da impressora
        chave2  TYPE zi_ca_param_par-chave2 VALUE 'PRINTER',
      END OF gc_etiq .
    "! Variável para controle de mensagens
    DATA gv_dummy TYPE string .
    "! Tabela de mensagens
    DATA gt_msg_ex TYPE bapiret2_t .
    "! Tabela com dados para impressão da etiqueta
    DATA gt_etiqueta TYPE zctgpp_controle_prod .
    "! Estrutura com dados de processamento
    DATA gs_process TYPE ty_process .
    CONSTANTS gc_modulo TYPE ze_param_modulo VALUE 'PP' ##NO_TEXT.
    DATA gc_chave1_001 TYPE ztca_param_par-chave1 VALUE 'IF_SAP_SAGA' ##NO_TEXT.
    DATA gc_chave2_001 TYPE ztca_param_par-chave2 VALUE 'PLANTA' ##NO_TEXT.
    DATA gc_chave2_002 TYPE ztca_param_par-chave2 VALUE 'MATERIAL' ##NO_TEXT.
    DATA gc_chave2_003 TYPE ztca_param_par-chave2 VALUE 'MTART' ##NO_TEXT.
    DATA gr_plant TYPE ty_tp_plant .
    DATA gr_matnr TYPE ty_tp_matnr .
    DATA gr_mtart TYPE ty_tp_mtart.

    "! Método para buscar dados
    METHODS get_data .
    "! Método para construir dados da etiqueta
    METHODS build_etiqueta .
    "! Método para verificar se há dados para processar
    "! @parameter rv_result | Verdadeiro ou falso
    METHODS check_data
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    "! Método para verificar se há dados para processar
    "! @parameter iv_material   | Material
    "! @parameter iv_lote       | Lote
    "! @parameter iv_planta     | Planta
    "! @parameter rv_expirydate | Validade
    METHODS get_expirydate
      IMPORTING
        !iv_material         TYPE zspp_controle_prod_etiq-material
        !iv_lote             TYPE zspp_controle_prod_etiq-lote
        !iv_planta           TYPE zspp_controle_prod_etiq-planta
      RETURNING
        VALUE(rv_expirydate) TYPE zspp_controle_prod_etiq-expirydate .
    "! Método para verificar se há dados para processar
    "! @parameter iv_material   | Material
    "! @parameter iv_unidade    | Unidade
    "! @parameter iv_eanum      | EAN
    "! @parameter iv_quantidade | Quantidade
    "! @parameter rv_qtdeconv   | Quantidade convertida
    METHODS get_conv_um
      IMPORTING
        !iv_material       TYPE zspp_controle_prod_etiq-material
        !iv_unidade        TYPE zspp_controle_prod_etiq-unidade
        !iv_eanum          TYPE zspp_controle_prod_etiq-eanunidade
        !iv_quantidade     TYPE zspp_controle_prod_etiq-quantidade
      RETURNING
        VALUE(rv_qtdeconv) TYPE char4 .
    "! Método para executar a impressão da etiqueta
    METHODS execute_etiqueta .
    "! Método para inserir mensagem de retorno
    METHODS append_msg .
    "! Método para buscar a config. de impressora
    "! @parameter rv_printer   | Impressora configurada
    METHODS get_printer
      RETURNING
        VALUE(rv_printer) TYPE sfpoutputparams-dest .
    "! Método para atribuir erro no formulário
    METHODS set_erro_form .
    "! Método para fazer refresh
    METHODS refresh .
    METHODS get_param .
ENDCLASS.



CLASS ZCLPP_GERAR_ETIQUETA IMPLEMENTATION.


  METHOD process.

    gs_process-aufnr = iv_aufnr.
    gs_process-rueck = iv_rueck.
    gs_process-rmzhl = iv_rmzhl.

    get_data( ).

    IF check_data( ) = abap_true.

      build_etiqueta( ).

      execute_etiqueta(  ).

    ENDIF.

    et_return = gt_msg_ex.

    refresh( ).

  ENDMETHOD.


  METHOD get_data.

* INI_ALT - Denilson Pasini Pina - META - 23/12/2021
    me->get_param( ).
* FIM_ALT - Denilson Pasini Pina - META - 23/12/2021

    SELECT  ordem,
            confirmacao,
            contador,
            dtproducao,
            material,
            planta,
            quantidade,
            unidade,
            dtlancamento,
            hrlancamento,
            confirmacaotexto,
            lote,
            descricao,
            ean,
            eanunidade,
            mtart "INI_ALT - Denilson Pasini Pina - META - 23/12/2021
  FROM zi_pp_mat_etiqueta
* INI_ALT - Denilson Pasini Pina - META - 23/12/2021
  AS a
  INNER JOIN mara AS b
  ON a~material EQ b~matnr
* FIM_ALT - Denilson Pasini Pina - META - 23/12/2021
  WHERE ordem = @gs_process-aufnr
    AND confirmacao = @gs_process-rueck
    AND contador = @gs_process-rmzhl
   AND dtproducao IS NOT INITIAL
   INTO TABLE @DATA(lt_cds)
   UP TO 1 ROWS.

    LOOP AT lt_cds ASSIGNING FIELD-SYMBOL(<fs_cds>).

* INI_ALT - Denilson Pasini Pina - META - 23/12/2021
      IF gr_mtart IS NOT INITIAL AND <fs_cds>-mtart IN gr_mtart.
        CONTINUE.
      ENDIF.
* FIM_ALT - Denilson Pasini Pina - META - 23/12/2021

      APPEND INITIAL LINE TO gt_etiqueta ASSIGNING FIELD-SYMBOL(<fs_etiq>).
      <fs_etiq> = CORRESPONDING #( <fs_cds> ).
    ENDLOOP.
  ENDMETHOD.


  METHOD check_data.

    IF lines( gt_etiqueta ) > 0.

      rv_result = abap_true.

    ELSE.

      rv_result = abap_false.

      MESSAGE e001 INTO gv_dummy.

      append_msg( ).

    ENDIF.

  ENDMETHOD.


  METHOD build_etiqueta.

    DATA: lv_char4 TYPE char4.

    LOOP AT gt_etiqueta ASSIGNING FIELD-SYMBOL(<fs_etiqueta>).

      <fs_etiqueta>-expirydate = get_expirydate(
                                    EXPORTING
                                      iv_material = <fs_etiqueta>-material
                                      iv_lote     = <fs_etiqueta>-lote
                                      iv_planta   = <fs_etiqueta>-planta
                                    ).

      <fs_etiqueta>-quantidadeconv = get_conv_um(
                                       EXPORTING
                                         iv_material   = <fs_etiqueta>-material
                                         iv_unidade    = <fs_etiqueta>-unidade
                                         iv_eanum      = <fs_etiqueta>-eanunidade
                                         iv_quantidade = <fs_etiqueta>-quantidade
                                     ).

      <fs_etiqueta>-barcode1 = <fs_etiqueta>-ean &&
                               <fs_etiqueta>-quantidadeconv &&
                               <fs_etiqueta>-expirydate &&
                               <fs_etiqueta>-lote &&
                               <fs_etiqueta>-material.

      <fs_etiqueta>-barcode2 = <fs_etiqueta>-ordem.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <fs_etiqueta>-contador
        IMPORTING
          output = lv_char4.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_char4
        IMPORTING
          output = lv_char4.

      <fs_etiqueta>-barcode3 = <fs_etiqueta>-confirmacao && lv_char4.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_expirydate.

    DATA: lt_batches TYPE STANDARD TABLE OF bapicharg1.

    CALL FUNCTION 'BAPI_MATERIAL_GETBATCHES'
      EXPORTING
        material    = CONV matnr18( iv_material )
        batchnumber = iv_lote
        plant       = iv_planta
      TABLES
        batches     = lt_batches.

    CHECK lines( lt_batches ) > 0.

    rv_expirydate = lt_batches[ 1 ]-expirydate.

  ENDMETHOD.


  METHOD get_conv_um.

    DATA: lv_menge          TYPE menge_d,
          lv_formatted_text TYPE c LENGTH 4,
          lv_unit           TYPE t006-msehi.

    CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
      EXPORTING
        i_matnr              = iv_material
        i_in_me              = iv_unidade
        i_out_me             = iv_eanum
        i_menge              = iv_quantidade
      IMPORTING
        e_menge              = lv_menge
      EXCEPTIONS
        error_in_application = 1
        error                = 2
        OTHERS               = 3.

    CHECK sy-subrc = 0.

    IF lv_menge < 1.

      lv_menge = 1.

    ENDIF.

    SELECT SINGLE msehi
       FROM t006
       WHERE decan = 0
       INTO (@lv_unit).

    IF sy-subrc = 0.

      WRITE lv_menge TO lv_formatted_text NO-GROUPING UNIT lv_unit.

      rv_qtdeconv = |{ lv_formatted_text ALPHA = IN WIDTH = 4 }|.

    ENDIF.

  ENDMETHOD.


  METHOD execute_etiqueta.

    DATA: lv_fm_name         TYPE rs38l_fnam,
          lv_matnr           TYPE mara-matnr,
          ls_fp_outputparams TYPE sfpoutputparams,
          ls_fp_docparams    TYPE sfpdocparams.


    ls_fp_outputparams-nodialog = abap_true.
    ls_fp_outputparams-reqnew   = abap_true.
    ls_fp_outputparams-reqimm   = abap_true.
    ls_fp_outputparams-dest     = get_printer( ).


    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = ls_fp_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.

    IF sy-subrc <> 0.

      set_erro_form( ).

    ELSE.

      TRY.

          CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
            EXPORTING
              i_name     = 'ZAFPP_CONTROLE_PROD'
            IMPORTING
              e_funcname = lv_fm_name.

        CATCH cx_fp_api_repository.

          set_erro_form( ).

        CATCH cx_fp_api_usage.

          set_erro_form( ).

        CATCH cx_fp_api_internal.

          set_erro_form( ).

      ENDTRY.


      ls_fp_docparams-langu   = 'P'.
      ls_fp_docparams-country = 'BR'.

* INI_ALT - Denilson Pasini Pina - META - 20/12/2021
      TRY .
          DATA(lo_envia_ordem) = NEW zclpp_co_si_enviar_ordem_produ( ).
        CATCH cx_ai_system_fault .
      ENDTRY.

*      me->get_param( ).

* FIM_ALT - Denilson Pasini Pina - META - 20/12/2021

      LOOP AT gt_etiqueta ASSIGNING FIELD-SYMBOL(<fs_etiqueta>).

        CALL FUNCTION lv_fm_name
          EXPORTING
            /1bcdwb/docparams = ls_fp_docparams
            etiqueta          = <fs_etiqueta>
*      IMPORTING
*           /1bcdwb/formoutput =
          EXCEPTIONS
            usage_error       = 1
            system_error      = 2
            internal_error    = 3
            OTHERS            = 4.

        IF sy-subrc = 0.

          MESSAGE s003 WITH <fs_etiqueta>-ordem INTO gv_dummy.
          append_msg( ).

* INI_ALT - Denilson Pasini Pina - META - 20/12/2021
*          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
*            EXPORTING
*              input  = <fs_etiqueta>-material
*            IMPORTING
*              output = lv_matnr.


          IF ( gr_plant IS NOT INITIAL AND <fs_etiqueta>-planta IN gr_plant ).
*            AND ( gr_matnr IS NOT INITIAL AND lv_matnr IN gr_matnr ).

            TRY.
                lo_envia_ordem->si_enviar_ordem_producao_out( output = VALUE zclpp_mt_ordem_producao( mt_ordem_producao-ordem            = <fs_etiqueta>-ordem
                                                                                                      mt_ordem_producao-confirmacao      = <fs_etiqueta>-confirmacao
                                                                                                      mt_ordem_producao-contador         = <fs_etiqueta>-contador
                                                                                                      mt_ordem_producao-dtproducao       = <fs_etiqueta>-dtproducao
                                                                                                      mt_ordem_producao-material         = <fs_etiqueta>-material
                                                                                                      mt_ordem_producao-planta           = <fs_etiqueta>-planta
                                                                                                      mt_ordem_producao-quantidade       = <fs_etiqueta>-quantidade
                                                                                                      mt_ordem_producao-unidade          = <fs_etiqueta>-unidade
                                                                                                      mt_ordem_producao-dtlancamento     = <fs_etiqueta>-dtlancamento
                                                                                                      mt_ordem_producao-hrlancamento     = <fs_etiqueta>-hrlancamento
                                                                                                      mt_ordem_producao-confirmacaotexto = <fs_etiqueta>-confirmacaotexto
                                                                                                      mt_ordem_producao-lote             = <fs_etiqueta>-lote
                                                                                                      mt_ordem_producao-descricao        = <fs_etiqueta>-descricao
                                                                                                      mt_ordem_producao-ean              = <fs_etiqueta>-ean
                                                                                                      mt_ordem_producao-eanunidade       = <fs_etiqueta>-eanunidade
                                                                                                      mt_ordem_producao-expirydate       = <fs_etiqueta>-expirydate
                                                                                                      mt_ordem_producao-barcode1         = <fs_etiqueta>-barcode1
                                                                                                      mt_ordem_producao-barcode2         = <fs_etiqueta>-barcode2
                                                                                                      mt_ordem_producao-barcode3         = <fs_etiqueta>-barcode3 ) ).
                COMMIT WORK.
              CATCH cx_ai_system_fault .
            ENDTRY.


          ENDIF.
* Fim_ALT - Denilson Pasini Pina - META - 20/12/2021


        ELSE.

          MESSAGE e004 WITH <fs_etiqueta>-ordem INTO gv_dummy.
          append_msg( ).

        ENDIF.
      ENDLOOP.

      CALL FUNCTION 'FP_JOB_CLOSE'
        EXCEPTIONS
          usage_error    = 1
          system_error   = 2
          internal_error = 3
          OTHERS         = 4.

      IF sy-subrc <> 0.

        set_erro_form( ).

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD append_msg.



    DATA(ls_message) = VALUE bapiret2( type         = sy-msgty
                                       id           = sy-msgid
                                       number       = sy-msgno
                                       message_v1   = sy-msgv1
                                       message_v2   = sy-msgv2
                                       message_v3   = sy-msgv3
                                       message_v4   = sy-msgv4 ).

    ls_message-message = gv_dummy.

    APPEND ls_message TO gt_msg_ex.

  ENDMETHOD.


  METHOD get_printer.

* LSCHEPP - Ajuste GAP 052 - 08.04.2022 Início
    DATA lv_planta TYPE zi_ca_param_par-chave3.
* LSCHEPP - Ajuste GAP 052 - 08.04.2022 Fim

* LSCHEPP - Ajuste GAP 052 - 21.11.2022 Início
    DATA lv_centro_trabalho TYPE zi_ca_param_par-chave2.
* LSCHEPP - Ajuste GAP 052 - 21.11.2022 Fim

    DATA lr_printer TYPE RANGE OF rspopname.

    DATA(lo_parametro) = NEW  zclca_tabela_parametros( ).

* LSCHEPP - Ajuste GAP 052 - 08.04.2022 Início
    TRY.
        lv_planta = gt_etiqueta[ 1 ]-planta.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
* LSCHEPP - Ajuste GAP 052 - 08.04.2022 Fim

* LSCHEPP - Ajuste GAP 052 - 21.11.2022 Início
    TRY.
        DATA(lv_ordem) = gt_etiqueta[ 1 ]-ordem.
        SELECT SINGLE a~workcenter
          FROM i_workcenter AS a
          INNER JOIN i_manufacturingorderoperation AS b ON a~workcenterinternalid = b~workcenterinternalid
          INTO @DATA(lv_workcenter)
          WHERE b~manufacturingorder      = @lv_ordem
            AND b~operationcontrolprofile = 'PI03'.
        IF sy-subrc EQ 0.
          lv_centro_trabalho = lv_workcenter.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
* LSCHEPP - Ajuste GAP 052 - 21.11.2022 Fim

    TRY.
        lo_parametro->m_get_range(
          EXPORTING
            iv_modulo = gc_etiq-modulo
            iv_chave1 = gc_etiq-chave1
* LSCHEPP - Ajuste GAP 052 - 21.11.2022 Início
*            iv_chave2 = gc_etiq-chave2
            iv_chave2 = lv_centro_trabalho
* LSCHEPP - Ajuste GAP 052 - 21.11.2022 Fim
* LSCHEPP - Ajuste GAP 052 - 08.04.2022 Início
            iv_chave3 = lv_planta
* LSCHEPP - Ajuste GAP 052 - 08.04.2022 Fim
          IMPORTING
            et_range  = lr_printer ).

      CATCH zcxca_tabela_parametros.


    ENDTRY.

    ASSIGN lr_printer[ 1 ] TO FIELD-SYMBOL(<fs_printer>).

    IF sy-subrc IS INITIAL.

      rv_printer = <fs_printer>-low.

    ELSE.

      rv_printer = gc_etiq-printer.

    ENDIF.

  ENDMETHOD.


  METHOD set_erro_form.

    MESSAGE e002 INTO gv_dummy.

    append_msg( ).


  ENDMETHOD.


  METHOD refresh.

    FREE: gt_etiqueta, gt_msg_ex.

  ENDMETHOD.


  METHOD get_param.

    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = me->gc_modulo
                                         iv_chave1 = me->gc_chave1_001
                                         iv_chave2 = me->gc_chave2_001
                               IMPORTING et_range  = gr_plant ).

        TRY.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.

      CATCH zcxca_tabela_parametros.
    ENDTRY.

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = me->gc_modulo
                                         iv_chave1 = me->gc_chave1_001
                                         iv_chave2 = me->gc_chave2_002
                               IMPORTING et_range  = gr_matnr ).

        TRY.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.

      CATCH zcxca_tabela_parametros.
    ENDTRY.

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = me->gc_modulo
                                         iv_chave1 = me->gc_etiq-chave1
                                         iv_chave2 = me->gc_chave2_003
                               IMPORTING et_range  = gr_mtart ).

        TRY.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.

      CATCH zcxca_tabela_parametros.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
