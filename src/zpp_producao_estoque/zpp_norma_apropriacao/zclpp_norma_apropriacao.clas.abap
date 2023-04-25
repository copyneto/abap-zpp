"!<p>Essa classe é utilizada para a lógica de negócio do APP de Norma de Apropriação <strong>Grãos Verdes</strong>
"!<p><strong>Autor:</strong> Carlos Galoro - Meta</p>
"!<p><strong>Data:</strong> 29/09/2021</p>
CLASS zclpp_norma_apropriacao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      tt_return    TYPE TABLE OF bapiret2 .
    TYPES:
      tt_coru_ret  TYPE TABLE OF bapi_coru_return .
    TYPES:
      tt_order_ret TYPE TABLE OF bapi_order_return .

    DATA:
      BEGIN OF gs_status,
        pendente   TYPE ztpp_nrm_apr_h-status VALUE 0,
        erro       TYPE ztpp_nrm_apr_h-status VALUE 1,
        processado TYPE ztpp_nrm_apr_h-status VALUE 2,
        encerrado  TYPE ztpp_nrm_apr_h-status VALUE 3,
      END OF gs_status .
    DATA:
      BEGIN OF gs_log,
        prd_graos  TYPE bal_s_log-extnumber VALUE 'PRD_GRAOS',
        graos_cons TYPE bal_s_log-extnumber VALUE 'GRAOS_CONS',
        encerra    TYPE bal_s_log-extnumber VALUE 'ENCERRA',
      END OF gs_log .
    CONSTANTS:
      gc_e TYPE c LENGTH 1 VALUE 'E' ##NO_TEXT.
    CONSTANTS:
      gc_x TYPE c LENGTH 1 VALUE 'X' ##NO_TEXT.

    "! Método para executar as regras de negócio da produção de grãos
    "! @parameter iv_doc_uuid_h  | Identificação UUID da tabela ZTPP_NRM_APR_H
    METHODS producao_graos
      IMPORTING
        !iv_doc_uuid_h TYPE ztpp_nrm_apr_h-doc_uuid_h .
    "! Método para executar as regras de negócio de grãos consumidos
    "! @parameter iv_doc_uuid_h       | Identificação UUID da tabela ZTPP_NRM_APR_H
    "! @parameter iv_doc_uuid_consumo | Identificação UUID da tabela ZTPP_NRM_APR_CON
    "! @parameter et_return           | Tabela com as mensagens de retorno da BAPI
    METHODS graos_consumidos
      IMPORTING
        !iv_doc_uuid_h       TYPE ztpp_nrm_apr_h-doc_uuid_h
        !iv_doc_uuid_consumo TYPE ztpp_nrm_apr_con-doc_uuid_consumo OPTIONAL
      EXPORTING
        !et_return           TYPE tt_return .
    "! Método para executar o encerramento das ordens de apropriação
    "! @parameter iv_doc_uuid_h  | Identificação UUID da tabela ZTPP_NRM_APR_H
    METHODS encerramento
      IMPORTING
        !iv_doc_uuid_h TYPE ztpp_nrm_apr_h-doc_uuid_h .
    METHODS check_quantidade
      IMPORTING
        !iv_doc_uuid_h TYPE ztpp_nrm_apr_h-doc_uuid_h
      EXPORTING
        !et_return     TYPE bapiret2_t .
  PROTECTED SECTION.

  PRIVATE SECTION.

    TYPES:
      "===========INICIO PRODUÇÃO DE GRÃOS===========
      BEGIN OF ty_montante,
        doc_uuid_ordem TYPE ztpp_nrm_apr_ord-doc_uuid_ordem,
        order_number   TYPE ztpp_nrm_apr_ord-order_number,
        material       TYPE ztpp_nrm_apr_ord-material,
        montante       TYPE konp-kbetr,
        rateio         TYPE n LENGTH 3,
      END OF ty_montante .
    TYPES:
      tt_ordem    TYPE TABLE OF ztpp_nrm_apr_ord .
    TYPES:
      tt_montante TYPE TABLE OF ty_montante .

    DATA gv_log_handle TYPE balloghndl .

    "! Método para criar as ordens que serão usadas nas normas de apropriação
    "! @parameter iv_docno | Número da ordem criada
    "! @parameter ct_ordem | Tabela de ordens que terá status atualizado
    METHODS criar_ordem
      IMPORTING
        !iv_docno TYPE ztpp_nrm_apr_h-documentno
      CHANGING
        !ct_ordem TYPE tt_ordem .
    "! Método para liberar as ordens criadas nas normas de apropriação
    "! @parameter iv_docno | Número do documento para gravação de log
    "! @parameter ct_ordem | Tabela de ordens que terá status atualizado
    METHODS liberar_ordem
      IMPORTING
        !iv_docno TYPE ztpp_nrm_apr_h-documentno
      CHANGING
        !ct_ordem TYPE tt_ordem .
    "! Método para confirmar as ordens criadas nas normas de apropriação
    "! @parameter iv_docno | Número do documento para gravação de log
    "! @parameter ct_ordem | Tabela de ordens que terá status atualizado
    METHODS confirmar_ordem
      IMPORTING
        !iv_docno TYPE ztpp_nrm_apr_h-documentno
      CHANGING
        !ct_ordem TYPE tt_ordem .
    "! Método para calcular o rateio nas normas de apropriação
    "! @parameter  iv_doc_uuid_h | Chave cabeçalho
    "! @parameter  iv_docno      | Número do documento para gravação de log
    "! @parameter  iv_material   | Código material de consumo
    "! @parameter  et_rateio     | Tabela com cáculo do rateio
    "! @parameter  cv_erro       | Retorno da execução do cálculo
    METHODS calcular_rateio
      IMPORTING
        !iv_doc_uuid_h TYPE ztpp_nrm_apr_h-doc_uuid_h
        !iv_docno      TYPE ztpp_nrm_apr_h-documentno
        !iv_material   TYPE ztpp_nrm_apr_ord-material
      EXPORTING
        !et_rateio     TYPE tt_montante
      CHANGING
        !cv_erro       TYPE flag .
    "===========FIM PRODUÇÃO DE GRÃOS===========
    "! Método para inicializar a função de gravação de logs
    "! @parameter iv_obj  | Objeto para a gravação de logs
    "! @parameter iv_sub  | Subobjeto para a gravação de logs
    "! @parameter iv_nome | Nome do objeto usado para a gravação de logs
    METHODS initialize_log
      IMPORTING
        !iv_obj  TYPE bal_s_log-object DEFAULT 'ZNRM_APR'
        !iv_sub  TYPE bal_s_log-subobject DEFAULT 'PRD_GRAOS'
        !iv_nome TYPE bal_s_log-extnumber .
    "! Método para executar a gravação de logs
    "! @parameter is_msg      | Estrutura com a mensagem de log
    "! @parameter iv_ndoc     | Número do documento para a gravação do log
    "! @parameter iv_material | Código do material para a gravação do log
    METHODS save_log
      IMPORTING
        !is_msg      TYPE bapiret2
        !iv_ndoc     TYPE ztpp_nrm_apr_h-documentno
        !iv_material TYPE ztpp_nrm_apr_con-material .
    "! Método para passar as mensagens de return da BAPI de Confirmar ordem
    "! @parameter it_msgs     | Tabela com as mensagens do return
    "! @parameter iv_ndoc     | Número do documento para a gravação do log
    "! @parameter iv_material | Código do material para a gravação do log
    METHODS mensagens_confirmar
      IMPORTING
        !it_msgs     TYPE tt_coru_ret
        !iv_ndoc     TYPE ztpp_nrm_apr_h-documentno
        !iv_material TYPE ztpp_nrm_apr_con-material .
    "! Método para passar as mensagens de return da BAPI de Grãos Consumidos
    "! @parameter it_msgs     | Tabela com as mensagens do return
    "! @parameter iv_ndoc     | Número do documento para a gravação do log
    "! @parameter iv_material | Código do material para a gravação do log
    "! @parameter et_return   | Tabela com as mensagens de retorno da BAPI
    "! @parameter cv_erro     | Campo que indica se tem mensagens de erro
    METHODS mensagens_graos
      IMPORTING
        !it_msgs     TYPE tt_return
        !iv_ndoc     TYPE ztpp_nrm_apr_h-documentno
        !iv_material TYPE ztpp_nrm_apr_con-material
      EXPORTING
        !et_return   TYPE tt_return
      CHANGING
        !cv_erro     TYPE c .
    "! Método para passar as mensagens de return da BAPI de Encerramento
    "! @parameter it_msgs     | Tabela com as mensagens do return
    "! @parameter iv_ndoc     | Número do documento para a gravação do log
    "! @parameter iv_material | Código do material para a gravação do log
    "! @parameter cv_erro     | Campo que indica se tem mensagens de erro
    METHODS mensagens_encerra
      IMPORTING
        !it_msgs     TYPE tt_order_ret
        !iv_ndoc     TYPE ztpp_nrm_apr_h-documentno
        !iv_material TYPE ztpp_nrm_apr_ord-material
      CHANGING
        !cv_erro     TYPE c .
    "! Método para executar a BAPI_GOODSMVT_CREATE para cada ordem
    "! @parameter iv_doc_uuid_h | Identificação UUID da tabela ZTPP_NRM_APR_H
    "! @parameter is_consumo    | Registro da tabela ztpp_nrm_apr_con
    "! @parameter iv_ndoc       | Número do documento para a gravação do log
    "! @parameter iv_material   | Código do material para a gravação do log
    "! @parameter it_rateio     | Tabelas de rateios
    "! @parameter cv_erro       | Campo que indica se tem mensagens de erro
    "! @parameter ct_return     | Tabela com as mensagens de retorno da BAPI
    METHODS exec_goodsmvt
      IMPORTING
        !iv_doc_uuid_h TYPE ztpp_nrm_apr_h-doc_uuid_h
        !is_consumo    TYPE ztpp_nrm_apr_con
        !iv_ndoc       TYPE ztpp_nrm_apr_h-documentno
        !iv_material   TYPE ztpp_nrm_apr_ord-material
        !it_rateio     TYPE tt_montante
      CHANGING
        !cv_erro       TYPE c
        !ct_return     TYPE tt_return .
ENDCLASS.



CLASS zclpp_norma_apropriacao IMPLEMENTATION.


  METHOD producao_graos.

    DATA: lv_status_h TYPE ze_status_nrm_apr.

    SELECT SINGLE documentno
      FROM ztpp_nrm_apr_h
     WHERE doc_uuid_h EQ @iv_doc_uuid_h
      INTO @DATA(lv_docno).

    SELECT *
      FROM ztpp_nrm_apr_ord
     WHERE doc_uuid_h EQ @iv_doc_uuid_h
       AND status     NE @gs_status-processado
     INTO TABLE @DATA(lt_ordem).

    IF sy-subrc EQ 0.

      initialize_log( iv_nome = gs_log-prd_graos ).

      criar_ordem(
        EXPORTING
          iv_docno = lv_docno
        CHANGING
          ct_ordem = lt_ordem ).

      liberar_ordem(
        EXPORTING
          iv_docno = lv_docno
        CHANGING
          ct_ordem = lt_ordem ).

*      confirmar_ordem(
*        EXPORTING
*          iv_docno = lv_docno
*        CHANGING
*          ct_ordem = lt_ordem ).
*
*      calcular_rateio(
*        EXPORTING
*          iv_doc_uuid_h = iv_doc_uuid_h
*          iv_docno      = lv_docno
*        CHANGING
*          ct_ordem = lt_ordem ).

* Atualiza o status na tabela de cabeçalho
      SELECT SINGLE order_number
        FROM ztpp_nrm_apr_ord
       WHERE doc_uuid_h EQ @iv_doc_uuid_h
         AND status = @gs_status-erro
        INTO @DATA(lv_ordem).

      IF sy-subrc EQ 0.
        lv_status_h = gs_status-erro.
      ELSE.
        lv_status_h = gs_status-pendente.
      ENDIF.

      GET TIME STAMP FIELD DATA(lv_tsh).

      UPDATE ztpp_nrm_apr_h SET status                = lv_status_h
                                last_changed_by       = sy-uname
                                local_last_changed_at = lv_tsh
                          WHERE doc_uuid_h            = iv_doc_uuid_h.
      COMMIT WORK.

    ENDIF.
  ENDMETHOD.


  METHOD criar_ordem.

    DATA: ls_orderdata    TYPE bapi_pi_order_create,
          ls_return       TYPE bapiret2,
          lv_order_number TYPE bapi_order_key-order_number,
          lv_order_type   TYPE bapi_order_copy-order_type,
          lv_wait         TYPE boolean.

*    CLEAR: lv_wait.
*    "Apenas uma ordem para processamento
*    IF lines( ct_ordem ) = 1.
*      lv_wait = abap_true.
*    ENDIF.

    LOOP AT ct_ordem ASSIGNING FIELD-SYMBOL(<fs_cria>).

      CLEAR: ls_orderdata,
             ls_return,
             lv_order_number,
             lv_order_type.

      ls_orderdata-material         = <fs_cria>-material.
      ls_orderdata-plant            = <fs_cria>-plant.
      ls_orderdata-order_type       = <fs_cria>-order_type.
      ls_orderdata-basic_start_date = <fs_cria>-basic_start_date.
      ls_orderdata-quantity         = <fs_cria>-quantity.
      ls_orderdata-prod_version     = <fs_cria>-prod_version.

      CLEAR lv_order_number.
      CALL FUNCTION 'BAPI_PROCORD_CREATE'
        EXPORTING
          orderdata    = ls_orderdata
        IMPORTING
          return       = ls_return
          order_number = lv_order_number
          order_type   = lv_order_type.

      IF ls_return-type <> gc_e.

        <fs_cria>-status = gs_status-pendente.

        IF NOT lv_order_number IS INITIAL.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = abap_true.

          <fs_cria>-order_number = lv_order_number.

*          IF  lv_wait = abap_true.
*            WAIT UP TO 5 SECONDS.
*          ENDIF.

          DO 20 TIMES.
            SELECT SINGLE manufacturingorder
              FROM i_manufacturingorder
             WHERE manufacturingorder = @lv_order_number
              INTO @DATA(lv_ord_prod).

            IF sy-subrc IS INITIAL.
              EXIT.
            ELSE.
              WAIT UP TO '0.5' SECONDS.
            ENDIF.
          ENDDO.

        ELSE.
          <fs_cria>-status = gs_status-erro.
        ENDIF.
      ELSE.
        <fs_cria>-status = gs_status-erro.
      ENDIF.

      <fs_cria>-last_changed_by = sy-uname.

      GET TIME STAMP FIELD DATA(lv_ts).
      <fs_cria>-local_last_changed_at = lv_ts.

      IF ls_return IS NOT INITIAL.
        save_log(
          EXPORTING
            is_msg      = ls_return
            iv_ndoc     = iv_docno
            iv_material = <fs_cria>-material ).
      ENDIF.

    ENDLOOP.

    MODIFY ztpp_nrm_apr_ord FROM TABLE ct_ordem.
    COMMIT WORK.

  ENDMETHOD.


  METHOD liberar_ordem.

    DATA: ls_return TYPE bapiret2,
          lt_orders TYPE TABLE OF bapi_order_key,
          lt_detail TYPE TABLE OF bapi_order_return,
          lt_log    TYPE TABLE OF bapi_order_application_log,
          lv_wait   TYPE boolean.

    CLEAR: lv_wait.
    "Apenas uma ordem para processamento
    IF lines( ct_ordem ) = 1.
      lv_wait = abap_true.
    ENDIF.

    LOOP AT ct_ordem ASSIGNING FIELD-SYMBOL(<fs_libera>).

      IF <fs_libera>-order_number IS NOT INITIAL.

        CLEAR: ls_return.
        REFRESH: lt_orders,
                 lt_detail,
                 lt_log.

        APPEND INITIAL LINE TO lt_orders ASSIGNING FIELD-SYMBOL(<fs_order>).
        <fs_order>-order_number = <fs_libera>-order_number.

        CALL FUNCTION 'BAPI_PROCORD_RELEASE'
          IMPORTING
            return          = ls_return
          TABLES
            orders          = lt_orders
            detail_return   = lt_detail
            application_log = lt_log.


        IF NOT line_exists( lt_detail[ type = gc_e ] ).  "#EC CI_STDSEQ
          <fs_libera>-status = gs_status-processado.

          IF lv_wait = abap_true.
            WAIT UP TO 2 SECONDS.
          ENDIF.

        ELSE.
          <fs_libera>-status = gs_status-erro.
        ENDIF.

        <fs_libera>-last_changed_by = sy-uname.

        GET TIME STAMP FIELD DATA(lv_ts).
        <fs_libera>-local_last_changed_at = lv_ts.

        IF ls_return IS NOT INITIAL.
          save_log(
            EXPORTING
              is_msg      = ls_return
              iv_ndoc     = iv_docno
              iv_material = <fs_libera>-material ).
        ENDIF.
      ENDIF.
    ENDLOOP.

    MODIFY ztpp_nrm_apr_ord FROM TABLE ct_ordem.
    COMMIT WORK.

  ENDMETHOD.


  METHOD confirmar_ordem.

    CONSTANTS: lc_1 TYPE c LENGTH 1 VALUE '1'.

    DATA: ls_return  TYPE bapiret1,
          lt_levels  TYPE TABLE OF bapi_pi_hdrlevel,
          lt_goods   TYPE TABLE OF bapi2017_gm_item_create,
          lt_conf    TYPE TABLE OF bapi_link_conf_goodsmov,
          lt_batch   TYPE TABLE OF bapi_char_batch,
          lt_link    TYPE TABLE OF bapi_link_gm_char_batch,
          lt_detail  TYPE TABLE OF bapi_coru_return,
          ls_return2 TYPE bapiret2.


    LOOP AT ct_ordem ASSIGNING FIELD-SYMBOL(<fs_confirma>).

      IF <fs_confirma>-order_number IS NOT INITIAL.

        CLEAR: ls_return.
        REFRESH: lt_levels,
                 lt_goods,
                 lt_conf,
                 lt_batch,
                 lt_link,
                 lt_detail.

        APPEND INITIAL LINE TO lt_levels ASSIGNING FIELD-SYMBOL(<fs_levels>).
        <fs_levels>-orderid    = <fs_confirma>-order_number.
        <fs_levels>-fin_conf   = lc_1.
        <fs_levels>-clear_res  = gc_x.
        <fs_levels>-postg_date = <fs_confirma>-basic_start_date.
        <fs_levels>-yield      = <fs_confirma>-quantity.

        CALL FUNCTION 'BAPI_PROCORDCONF_CREATE_HDR'
          IMPORTING
            return                = ls_return
          TABLES
            athdrlevels           = lt_levels
            goodsmovements        = lt_goods
            link_conf_goodsmov    = lt_conf
            characteristics_batch = lt_batch
            link_gm_char_batch    = lt_link
            detail_return         = lt_detail.

        IF line_exists( lt_detail[ type = gc_e ] ).      "#EC CI_STDSEQ
          <fs_confirma>-status = gs_status-erro.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = abap_true.
          <fs_confirma>-status = gs_status-processado.
        ENDIF.


        <fs_confirma>-last_changed_by = sy-uname.

        GET TIME STAMP FIELD DATA(lv_ts).
        <fs_confirma>-local_last_changed_at = lv_ts.

        IF lt_detail[] IS NOT INITIAL.
          mensagens_confirmar(
            EXPORTING
              it_msgs     = lt_detail
              iv_ndoc     = iv_docno
              iv_material = <fs_confirma>-material ).

        ENDIF.
      ENDIF.
    ENDLOOP.

    MODIFY ztpp_nrm_apr_ord FROM TABLE ct_ordem.
    COMMIT WORK.

  ENDMETHOD.


  METHOD calcular_rateio.

    DATA: lv_total        TYPE p LENGTH 15 DECIMALS 2,
          lv_total_rateio TYPE n LENGTH 3,
          lv_falta        TYPE n LENGTH 2,
          lv_valor_ok     TYPE flag,
          lt_ordem        TYPE tt_ordem,
          lt_detail       TYPE TABLE OF bapi_order_return,
          lt_montante     TYPE TABLE OF ty_montante.
    DATA: lr_status TYPE RANGE OF ztpp_nrm_apr_ord-status.

* LSCHEPP - Ajuste tab. registro condição - 29.06.2022 Início
    CONSTANTS: BEGIN OF lc_canal_dist,
                 modulo TYPE ztca_param_par-modulo VALUE 'PP',
                 chave1 TYPE ztca_param_par-chave1 VALUE 'MATERIALTYPE',
               END OF lc_canal_dist.

    DATA: lt_canal_dist     TYPE gds_selrange_vtweg_tab,
          lt_canal_dist_aux TYPE gds_selrange_vtweg_tab.
* LSCHEPP - Ajuste tab. registro condição - 29.06.2022 Fim

    lr_status = VALUE #( sign = 'I'
                         option = 'EQ'
                         ( low = gs_status-erro )
                         ( low = gs_status-processado ) ).

    SELECT *
    FROM ztpp_nrm_apr_ord
    INTO TABLE lt_ordem
    WHERE doc_uuid_h EQ iv_doc_uuid_h
      AND material   NE iv_material.

    DELETE lt_ordem WHERE status NOT IN lr_status.       "#EC CI_STDSEQ
    IF lt_ordem[] IS INITIAL.
      lt_detail = VALUE #( ( type   = gc_e
                             id     = 'ZPP_APROPRIACAO'
                             number = '005' ) ).
      mensagens_encerra(
        EXPORTING
          it_msgs     = lt_detail
          iv_ndoc     = iv_docno
          iv_material = ''
        CHANGING
          cv_erro     = cv_erro ).
      RETURN.
    ENDIF.

    IF ( 0 < lines( lt_ordem[] ) ).
* LSCHEPP - Ajuste tab. registro condição - 29.06.2022 Início
*      SELECT matnr , knumh
*        FROM a603
*         FOR ALL ENTRIES IN @lt_ordem
*       WHERE matnr = @lt_ordem-material
*        INTO TABLE @DATA(lt_knumh).
      SELECT material, materialtype
        FROM i_material
        INTO TABLE @DATA(lt_i_material)
        FOR ALL ENTRIES IN @lt_ordem
        WHERE material EQ @lt_ordem-material.
      IF sy-subrc EQ 0.

        SORT lt_i_material BY material.

        DATA(lo_param) = NEW zclca_tabela_parametros( ).

        TRY.
            DATA(lv_materialtype) = lt_i_material[ 1 ]-materialtype.
            SELECT SINGLE chave3
              FROM ztca_param_par
              INTO @DATA(lv_plant)
              WHERE modulo = @lc_canal_dist-modulo
                AND chave1 = @lc_canal_dist-chave1
                AND chave2 = @lv_materialtype.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.

        LOOP AT lt_i_material ASSIGNING FIELD-SYMBOL(<fs_i_material>).

          REFRESH lt_canal_dist_aux.
          TRY.
              lo_param->m_get_range( EXPORTING iv_modulo = lc_canal_dist-modulo
                                               iv_chave1 = lc_canal_dist-chave1
                                               iv_chave2 = CONV #( <fs_i_material>-materialtype )
                                               iv_chave3 = lv_plant
                                     IMPORTING et_range  = lt_canal_dist_aux ).
              APPEND LINES OF lt_canal_dist_aux TO lt_canal_dist.
            CATCH zcxca_tabela_parametros.
          ENDTRY.
        ENDLOOP.

*        SORT lt_materialtype BY matnr.
        SORT lt_canal_dist.
        DELETE ADJACENT DUPLICATES FROM lt_canal_dist COMPARING ALL FIELDS.

        SELECT matnr, vkorg, vtweg, mvgr2
          FROM mvke
          INTO TABLE @DATA(lt_mvke)
          FOR ALL ENTRIES IN @lt_ordem
          WHERE matnr EQ @lt_ordem-material
            AND vkorg EQ @lv_plant
            AND vtweg IN @lt_canal_dist.
        IF sy-subrc EQ 0.
          SORT lt_mvke BY matnr.
          SELECT vtweg, mvgr2, datab, knumh
            FROM a621
            INTO TABLE @DATA(lt_knumh)
            FOR ALL ENTRIES IN @lt_mvke
            WHERE vtweg EQ @lt_mvke-vtweg
              AND mvgr2 EQ @lt_mvke-mvgr2.
        ENDIF.
      ENDIF.
* LSCHEPP - Ajuste tab. registro condição - 29.06.2022 Fim
    ENDIF.

    IF lt_knumh[] IS NOT INITIAL.

* LSCHEPP - Ajuste tab. registro condição - 29.06.2022 Início
*      SORT lt_knumh BY matnr ASCENDING.
      SORT lt_knumh BY vtweg mvgr2 datab DESCENDING.
* LSCHEPP - Ajuste tab. registro condição - 29.06.2022 Fim

      SELECT knumh , kbetr, kpein
        FROM konp
         FOR ALL ENTRIES IN @lt_knumh
       WHERE knumh = @lt_knumh-knumh
         AND kznep <> @abap_true
        INTO TABLE @DATA(lt_kbetr).

      SORT lt_kbetr BY knumh ASCENDING.

    ENDIF.

    SELECT  docuuidh,
            docuuidordem,
            quantityconfirmed
    FROM zi_pp_nrm_apr_ord
    FOR ALL ENTRIES IN @lt_ordem
    WHERE docuuidh = @lt_ordem-doc_uuid_h
      AND docuuidordem = @lt_ordem-doc_uuid_ordem
    INTO TABLE @DATA(lt_apr_ord).
    IF sy-subrc = 0.
      SORT lt_apr_ord BY docuuidh docuuidordem.
    ENDIF.

*   Determinar a quantidade total
    CLEAR: lv_valor_ok.
    LOOP AT lt_ordem ASSIGNING FIELD-SYMBOL(<fs_total>).
      IF <fs_total>-order_number IS NOT INITIAL.
        READ TABLE lt_apr_ord
        ASSIGNING FIELD-SYMBOL(<fs_apr_ord>)
          WITH KEY docuuidh     = <fs_total>-doc_uuid_h
                   docuuidordem = <fs_total>-doc_uuid_ordem
          BINARY SEARCH.
        IF sy-subrc = 0.
          DATA(lv_qtyconf) = <fs_apr_ord>-quantityconfirmed.
        ELSE.
          CLEAR: lv_qtyconf.
        ENDIF.

* LSCHEPP - Ajuste tab. registro condição - 29.06.2022 Início
*        READ TABLE lt_knumh WITH KEY matnr = <fs_total>-material
        READ TABLE lt_mvke WITH KEY matnr = <fs_total>-material
                           ASSIGNING FIELD-SYMBOL(<fs_mvke>)
                           BINARY SEARCH.
        IF sy-subrc EQ 0.
          READ TABLE lt_knumh WITH KEY vtweg = <fs_mvke>-vtweg
                                       mvgr2 = <fs_mvke>-mvgr2
                              ASSIGNING FIELD-SYMBOL(<fs_knumh>)
                              BINARY SEARCH.
* LSCHEPP - Ajuste tab. registro condição - 29.06.2022 Fim
          IF sy-subrc = 0.
            READ TABLE lt_kbetr WITH KEY knumh = <fs_knumh>-knumh
                                ASSIGNING FIELD-SYMBOL(<fs_kbetr>)
                                BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_kbetr) = <fs_kbetr>-kbetr.
              DATA(lv_kpein) = <fs_kbetr>-kpein.
            ELSE.
              CLEAR: lv_kbetr,
                     lv_kpein.
            ENDIF.
          ELSE.
            CLEAR: lv_kbetr,
                   lv_kpein.
          ENDIF.
* LSCHEPP - Ajuste tab. registro condição - 29.06.2022 Início
        ENDIF.
* LSCHEPP - Ajuste tab. registro condição - 29.06.2022 Fim

        IF lv_kpein NE 0.
          DATA(lv_montante) =  CONV kbetr_kond( ( lv_qtyconf * lv_kbetr ) / lv_kpein ).
        ELSE.
          lv_montante =  CONV kbetr_kond( lv_qtyconf  ).
        ENDIF.

        IF lv_montante <> 0.
          lv_valor_ok = gc_x.
          APPEND INITIAL LINE TO et_rateio ASSIGNING FIELD-SYMBOL(<fs_rateio>).
          <fs_rateio>-doc_uuid_ordem = <fs_total>-doc_uuid_ordem.
          <fs_rateio>-order_number   = <fs_total>-order_number.
          <fs_rateio>-material       = <fs_total>-material.
          <fs_rateio>-montante       = lv_montante.
          lv_total = lv_total + <fs_rateio>-montante.
        ENDIF.

      ENDIF.
    ENDLOOP.

    IF et_rateio[] IS NOT INITIAL.

      SORT et_rateio BY montante ASCENDING.

* Calcular porcentagem
      LOOP AT et_rateio ASSIGNING FIELD-SYMBOL(<fs_calc>).
        <fs_calc>-rateio = ( <fs_calc>-montante * 100 ) / lv_total.
        lv_total_rateio = lv_total_rateio + <fs_calc>-rateio.
        AT LAST.
          IF lv_total_rateio LT 100.
            lv_falta = 100 - lv_total_rateio.
            <fs_calc>-rateio = <fs_calc>-rateio + lv_falta.
          ENDIF.
        ENDAT.
      ENDLOOP.

      GET TIME STAMP FIELD DATA(lv_ts).

    ELSE.
      IF lv_valor_ok IS INITIAL.
        lt_detail = VALUE #( ( type   = gc_e
                               id     = 'ZPP_APROPRIACAO'
                               number = '005' ) ).
      ENDIF.
      mensagens_encerra(
        EXPORTING
          it_msgs     = lt_detail
          iv_ndoc     = iv_docno
          iv_material = ''
        CHANGING
          cv_erro     = cv_erro ).
    ENDIF.

  ENDMETHOD.


  METHOD graos_consumidos.

    DATA: ls_header     TYPE bapi2017_gm_head_01,
          lt_return     TYPE TABLE OF bapiret2,
          lt_return_met TYPE tt_return,
          lt_rateio     TYPE tt_montante.

    DATA: lv_status_h  TYPE ze_status_nrm_apr,
          ls_gmvt_code TYPE bapi2017_gm_code.

    DATA: lv_erro       TYPE c,
          lv_doc_uuid_h TYPE ztpp_nrm_apr_h-doc_uuid_h.

    DATA: lr_status TYPE RANGE OF ztpp_nrm_apr_con-status.

    lr_status = VALUE #( sign = 'I'
                         option = 'EQ'
                         ( low = gs_status-erro )
                         ( low = gs_status-pendente ) ).

    SELECT SINGLE documentno
      FROM ztpp_nrm_apr_h
     WHERE doc_uuid_h EQ @iv_doc_uuid_h
      INTO @DATA(lv_docno).

    lv_doc_uuid_h = iv_doc_uuid_h.

    SELECT *
    FROM ztpp_nrm_apr_con
    WHERE doc_uuid_h       EQ @iv_doc_uuid_h
      AND status          IN  @lr_status
    INTO TABLE @DATA(lt_consumo).

    initialize_log( iv_nome = gs_log-graos_cons ).

    LOOP AT lt_consumo ASSIGNING FIELD-SYMBOL(<fs_consumo>).
      CLEAR: lt_rateio[], lv_erro, lt_return_met[].

      calcular_rateio(
          EXPORTING
            iv_doc_uuid_h = iv_doc_uuid_h
            iv_docno      = lv_docno
            iv_material   = <fs_consumo>-material
          IMPORTING
            et_rateio     = lt_rateio
          CHANGING
            cv_erro = lv_erro ).
      IF lv_erro IS INITIAL.
        exec_goodsmvt(
        EXPORTING
          iv_doc_uuid_h = lv_doc_uuid_h
          is_consumo    = <fs_consumo>
          iv_ndoc       = lv_docno
          iv_material   = <fs_consumo>-material
          it_rateio     = lt_rateio
        CHANGING
          cv_erro       = lv_erro
          ct_return     = lt_return_met ).

        APPEND LINES OF lt_return_met TO et_return.
*     Atualiza o status na tabela de grãos consumidos
        IF line_exists( lt_return_met[ type = gc_e ] ).  "#EC CI_STDSEQ
          <fs_consumo>-status = gs_status-erro.
        ELSE.
          <fs_consumo>-status = gs_status-processado.
        ENDIF.
      ELSE.
        <fs_consumo>-status = gs_status-erro.
      ENDIF.
    ENDLOOP.

    <fs_consumo>-last_changed_by = sy-uname.

    GET TIME STAMP FIELD DATA(lv_tsp).
    <fs_consumo>-local_last_changed_at = lv_tsp.

    MODIFY ztpp_nrm_apr_con FROM TABLE lt_consumo.

    COMMIT WORK.

* Atualiza o status na tabela de cabeçalho

    SELECT doc_uuid_h , status
    FROM ztpp_nrm_apr_con
    WHERE doc_uuid_h EQ @iv_doc_uuid_h
    INTO TABLE @DATA(lt_status_con).

    SORT: lt_status_con BY doc_uuid_h status.

    READ TABLE lt_status_con WITH KEY doc_uuid_h = <fs_consumo>-doc_uuid_h
                                      status = gs_status-erro
                                      TRANSPORTING NO FIELDS
                                      BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_status_h = gs_status-erro.
    ELSE.

      READ TABLE lt_status_con WITH KEY doc_uuid_h = <fs_consumo>-doc_uuid_h
                                        status = gs_status-pendente
                                        TRANSPORTING NO FIELDS
                                        BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_status_h = gs_status-pendente.
      ELSE.
        lv_status_h = gs_status-processado.
      ENDIF.

    ENDIF.

    GET TIME STAMP FIELD DATA(lv_tsh).

    UPDATE ztpp_nrm_apr_h SET status                = lv_status_h
                              last_changed_by       = sy-uname
                              local_last_changed_at = lv_tsh
                        WHERE doc_uuid_h            = iv_doc_uuid_h.
    COMMIT WORK.

  ENDMETHOD.


  METHOD encerramento.

    DATA: ls_return TYPE bapiret2,
          lt_orders TYPE TABLE OF bapi_order_key,
          lt_detail TYPE TABLE OF bapi_order_return,
          lt_return TYPE tt_return,
          lt_log    TYPE TABLE OF bapi_order_application_log.

    DATA: lv_status_h TYPE ze_status_nrm_apr,
          lv_erro     TYPE c,
          lv_stat     TYPE ztpp_nrm_apr_h-status.

    DATA: lr_status TYPE RANGE OF ztpp_nrm_apr_con-status.

    lr_status = VALUE #( sign = 'I'
                         option = 'EQ'
                         ( low = gs_status-processado ) ).

    initialize_log( iv_nome = gs_log-encerra ).

    SELECT SINGLE documentno
      FROM ztpp_nrm_apr_h
     WHERE doc_uuid_h EQ @iv_doc_uuid_h
      INTO @DATA(lv_docno).

    SELECT doc_uuid_h , doc_uuid_ordem , order_number , material
      FROM ztpp_nrm_apr_ord
     WHERE doc_uuid_h EQ @iv_doc_uuid_h
      INTO TABLE @DATA(lt_ordem).

    CHECK sy-subrc EQ 0.

    graos_consumidos(
      EXPORTING
        iv_doc_uuid_h = iv_doc_uuid_h
      IMPORTING
        et_return     = lt_return ).

    SELECT doc_uuid_h , doc_uuid_consumo , material
      FROM ztpp_nrm_apr_con
     WHERE doc_uuid_h EQ @iv_doc_uuid_h
       AND status  NOT IN @lr_status
      INTO TABLE @DATA(lt_consu).
    IF sy-subrc EQ 0.
      LOOP AT lt_consu ASSIGNING FIELD-SYMBOL(<fs_consu>).
        lt_detail = VALUE #( ( type   = gc_e
                       id     = 'ZPP_APROPRIACAO'
                       number = '007' ) ).

        mensagens_encerra(
          EXPORTING
            it_msgs     = lt_detail
            iv_ndoc     = lv_docno
            iv_material = <fs_consu>-material
          CHANGING
            cv_erro     = lv_erro ).

      ENDLOOP.

    ENDIF.

    CHECK lv_erro IS INITIAL.

    LOOP AT lt_ordem ASSIGNING FIELD-SYMBOL(<fs_encerra>).

      IF NOT <fs_encerra>-order_number IS INITIAL.

        CLEAR: ls_return,
               lv_erro.
        REFRESH: lt_orders,
                 lt_detail,
                 lt_log.

        APPEND INITIAL LINE TO lt_orders ASSIGNING FIELD-SYMBOL(<fs_order>).
        <fs_order>-order_number = <fs_encerra>-order_number.

*            CALL FUNCTION 'BAPI_PROCORD_COMPLETE_TECH'
*              IMPORTING
*                return          = ls_return
*              TABLES
*                orders          = lt_orders
*                detail_return   = lt_detail
*                application_log = lt_log.
*
*
*            IF NOT lt_detail[] IS INITIAL.
*
*              mensagens_encerra(
*                EXPORTING
*                  it_msgs     = lt_detail
*                  iv_ndoc     = lv_docno
*                  iv_material = <fs_encerra>-material
*                CHANGING
*                  cv_erro     = lv_erro ).
*
*            ENDIF.

        IF lv_erro IS INITIAL.
          lv_stat = gs_status-encerrado.
        ELSE.
          lv_stat = gs_status-erro.
        ENDIF.

        GET TIME STAMP FIELD DATA(lv_ts).
* Atualiza o status na tabela de ordens
        UPDATE ztpp_nrm_apr_ord SET status                 = lv_stat
                                    last_changed_by        = sy-uname
                                    local_last_changed_at  = lv_ts
                              WHERE doc_uuid_h             = <fs_encerra>-doc_uuid_h
                                AND doc_uuid_ordem         = <fs_encerra>-doc_uuid_ordem.
        COMMIT WORK.
      ENDIF.
    ENDLOOP.

* Atualiza o status na tabela de cabeçalho
    SELECT SINGLE order_number
      FROM ztpp_nrm_apr_ord
     WHERE doc_uuid_h EQ @iv_doc_uuid_h
       AND status EQ @gs_status-erro
      INTO @DATA(lv_ordem).

    IF sy-subrc EQ 0.
      lv_status_h = gs_status-erro.
    ELSE.
      lv_status_h = gs_status-encerrado.
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_tsh).

    UPDATE ztpp_nrm_apr_h SET status                = lv_status_h
                              last_changed_by       = sy-uname
                              local_last_changed_at = lv_tsh
                        WHERE doc_uuid_h            = iv_doc_uuid_h.
    COMMIT WORK.

  ENDMETHOD.


  METHOD initialize_log.

    DATA: ls_msg        TYPE bal_s_msg,
          lt_log_handle TYPE bal_t_logh,
          ls_log        TYPE bal_s_log.

    APPEND gv_log_handle TO lt_log_handle.

    DATA: lv_erro TYPE c.

    ls_log-extnumber = iv_nome.
    ls_log-aluser    = sy-uname.
    ls_log-alprog    = sy-repid.
    ls_log-object    = iv_obj.
    ls_log-subobject = iv_sub.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log      = ls_log
      IMPORTING
        e_log_handle = gv_log_handle
      EXCEPTIONS
        OTHERS       = 1.

    IF sy-subrc NE 0.
      lv_erro = 'X'.
    ENDIF.

  ENDMETHOD.


  METHOD save_log.

    DATA: ls_msg        TYPE bal_s_msg,
          lt_log_handle TYPE bal_t_logh,
          ls_context    TYPE zspp_nrm_apr.

    APPEND gv_log_handle TO lt_log_handle.

    DATA: lv_erro TYPE c.

    ls_msg-msgty     = is_msg-type.
    ls_msg-msgid     = is_msg-id.
    ls_msg-msgno     = is_msg-number.
    ls_msg-msgv1     = is_msg-message_v1.
    ls_msg-msgv2     = is_msg-message_v2.
    ls_msg-msgv3     = is_msg-message_v3.
    ls_msg-msgv4     = is_msg-message_v4.
    ls_msg-probclass = '1'.

    ls_context-documentno = iv_ndoc.
    ls_context-material   = iv_material.

    ls_msg-context-tabname = 'ZSPP_NRM_APR'.
    ls_msg-context-value   = ls_context.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = gv_log_handle
        i_s_msg          = ls_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.

    IF sy-subrc NE 0.
      lv_erro = 'X'.
    ENDIF.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle = lt_log_handle
      EXCEPTIONS
        OTHERS         = 4.

    IF sy-subrc NE 0.
      lv_erro = 'X'.
    ENDIF.

  ENDMETHOD.


  METHOD mensagens_confirmar.

    DATA: ls_return  TYPE bapiret2.

* Confirmar ordem
    LOOP AT it_msgs ASSIGNING FIELD-SYMBOL(<fs_msgs>).
      MOVE-CORRESPONDING <fs_msgs> TO ls_return.
      save_log(
        EXPORTING
          is_msg      = ls_return
          iv_ndoc     = iv_ndoc
          iv_material = iv_material ).
    ENDLOOP.

  ENDMETHOD.


  METHOD mensagens_graos.

    DATA: ls_return  TYPE bapiret2.

* Grãos Consumidos
    LOOP AT it_msgs ASSIGNING FIELD-SYMBOL(<fs_msgs>).

* Preenche tabela com todas as linhas de retorno da BAPI
      APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<fs_bapiret>).
      <fs_bapiret> = <fs_msgs>.

      IF <fs_msgs>-type EQ gc_e.
        cv_erro = gc_x.
      ENDIF.

      save_log(
        EXPORTING
          is_msg      = <fs_msgs>
          iv_ndoc     = iv_ndoc
          iv_material = iv_material ).

    ENDLOOP.

  ENDMETHOD.


  METHOD mensagens_encerra.

    DATA: ls_return  TYPE bapiret2.

* Encerramento
    LOOP AT it_msgs ASSIGNING FIELD-SYMBOL(<fs_msgs>).
      IF <fs_msgs>-type EQ gc_e.
        cv_erro = gc_x.
      ENDIF.
      MOVE-CORRESPONDING <fs_msgs> TO ls_return.
      save_log(
        EXPORTING
          is_msg      = ls_return
          iv_ndoc     = iv_ndoc
          iv_material = iv_material ).
    ENDLOOP.

  ENDMETHOD.


  METHOD exec_goodsmvt.

    DATA: ls_header  TYPE bapi2017_gm_head_01,
          lt_item    TYPE TABLE OF bapi2017_gm_item_create,
          ls_headret TYPE bapi2017_gm_head_ret,
          lv_docum   TYPE bapi2017_gm_head_ret-mat_doc,
          lv_year    TYPE bapi2017_gm_head_ret-doc_year,
          lt_return  TYPE TABLE OF bapiret2.

    DATA: lv_status_h  TYPE ze_status_nrm_apr,
          ls_gmvt_code TYPE bapi2017_gm_code.

* Calcular_quantidade para cada ordem
    LOOP AT it_rateio ASSIGNING FIELD-SYMBOL(<fs_rateio>).

      CLEAR: ls_header,
             ls_headret,
             lv_docum,
             lv_year.

      REFRESH: lt_item,
               lt_return.

      ls_header-pstng_date = sy-datum.

      ls_gmvt_code-gm_code = '03'.

      APPEND INITIAL LINE TO lt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
      <fs_item>-material  = is_consumo-material.
      <fs_item>-plant     = is_consumo-plant.
      <fs_item>-stge_loc  = is_consumo-stge_loc.
      <fs_item>-batch     = is_consumo-batch.
      <fs_item>-move_type = '261'.
      <fs_item>-entry_qnt = ( is_consumo-entry_qnt * <fs_rateio>-rateio ) / 100.
      <fs_item>-entry_uom = is_consumo-entry_uom.
      <fs_item>-orderid   = <fs_rateio>-order_number.

* Executar o lancamento
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = ls_header
          goodsmvt_code    = ls_gmvt_code
        IMPORTING
          goodsmvt_headret = ls_headret
          materialdocument = lv_docum
          matdocumentyear  = lv_year
        TABLES
          goodsmvt_item    = lt_item
          return           = lt_return.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

      mensagens_graos(
        EXPORTING
          it_msgs     = lt_return
          iv_ndoc     = iv_ndoc
          iv_material = is_consumo-material
        IMPORTING
          et_return   = ct_return
        CHANGING
          cv_erro     = cv_erro ).

      IF lv_docum IS NOT INITIAL.

        MESSAGE s003(zpp_apropriacao) WITH lv_docum INTO DATA(lv_message).

        APPEND INITIAL LINE TO ct_return ASSIGNING FIELD-SYMBOL(<fs_doc>).
        <fs_doc>-type       = 'S'.
        <fs_doc>-id         = 'ZPP_APROPRIACAO'.
        <fs_doc>-number     = '003'.
        <fs_doc>-message    = lv_message.
        <fs_doc>-message_v1 = lv_docum.

        save_log(
         EXPORTING
           is_msg      = <fs_doc>
           iv_ndoc     = iv_ndoc
           iv_material = is_consumo-material ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD check_quantidade.

    SELECT docuuidh,
       SUM( entryqnt ) AS entryqnt
      FROM zi_pp_nrm_apr_con
     WHERE docuuidh = @iv_doc_uuid_h
     GROUP BY docuuidh
      INTO @DATA(ls_entrada)
        UP TO 1 ROWS.
    ENDSELECT.

    IF sy-subrc IS NOT INITIAL.
      et_return = VALUE #( BASE et_return ( id     = 'ZPP_APROPRIACAO'
                                            type   = 'E'
                                            number = 009 ) ).
    ENDIF.

    SELECT docuuidh,
       SUM( quantitytotal ) AS quantitytotal
      FROM zi_pp_nrm_apr_ord
     WHERE docuuidh = @iv_doc_uuid_h
     GROUP BY docuuidh
      INTO @DATA(ls_produzido)
        UP TO 1 ROWS.
    ENDSELECT.

    IF sy-subrc IS NOT INITIAL.
      et_return = VALUE #( BASE et_return ( id     = 'ZPP_APROPRIACAO'
                                            type   = 'E'
                                            number = 010 ) ).
    ENDIF.

    CHECK et_return IS INITIAL.

    IF ls_entrada-entryqnt NE ls_produzido-quantitytotal.
      et_return = VALUE #( BASE et_return ( id     = 'ZPP_APROPRIACAO'
                                            type   = 'E'
                                            number = 011 ) ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
