CLASS zclpp_lanca_cont_estoque DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA:
        "! Tabela Ajuste de Inventário - Cabeçalho
      gt_ajust_inv_header TYPE SORTED TABLE OF ztpp_ajust_inv_h WITH NON-UNIQUE KEY documentouuid .
    "! Tabela Ajuste de Inventário - Item
    DATA gt_ajust_inv_item TYPE zctgpp_ajust_inv_i .

    "! Executa a chamada de todos os processos
    "! @parameter it_ajust_inv_header  | Tabela Ajuste de Inventário - Cabeçalho
    "! @parameter it_ajust_inv_item    | Tabela Ajuste de Inventário - Item
    "! @parameter et_ajust_inv_message | Tabela Ajuste de Inventário - Mensagem
    METHODS main
      IMPORTING
        !it_ajust_inv_header  TYPE zctgpp_ajust_inv_h
        !it_ajust_inv_item    TYPE zctgpp_ajust_inv_i
      EXPORTING
        !et_ajust_inv_message TYPE zctgpp_ajust_inv_m .
  PROTECTED SECTION.
  PRIVATE SECTION.

    "! Constante para tipo mensagem Erro.
    CONSTANTS lc_erro   TYPE char1 VALUE 'E'.
    "! Constante para tipo mensagem aviso
    CONSTANTS lc_aviso  TYPE char1 VALUE 'W'.
    "! Constante para tipo mensagem sucesso.
    CONSTANTS lc_ok     TYPE char1 VALUE 'S'.
    "! Constante para tipo movimento Y01 SM Rateio de Produção (Copia 261).
    CONSTANTS lc_y01    TYPE char3 VALUE 'Y01'.
    "! Constante para tipo movimento Z01 SM Rateio de Produção - estorno (Copia 262).
    CONSTANTS lc_z01    TYPE char3 VALUE 'Z01'.
    "! Constante para Tipo de ordem PI01.
    CONSTANTS lc_pi01   TYPE char4 VALUE 'PI01'.
    "! Constante para range.
    CONSTANTS lc_i      TYPE char1 VALUE 'I'.
    "! Constante para range.
    CONSTANTS lc_eq     TYPE char2 VALUE 'EQ'.
    "! Constante para range.
    CONSTANTS lc_bt     TYPE char2 VALUE 'BT'.
    "! Constante para seleção na tabela parametros.
    CONSTANTS lc_mod    TYPE ztca_param_par-modulo VALUE 'PP'.
    "! Constante para seleção na tabela parametros.
    CONSTANTS lc_chave1 TYPE ztca_param_par-chave1 VALUE 'TIPO_MOVIMENTO'.
    "! Constante para seleção na tabela parametros.
    CONSTANTS lc_chave2 TYPE ztca_param_par-chave2 VALUE 'MOVIMENTO_SALDO'.
    CONSTANTS:
      "! Constante para Status.
      BEGIN OF gc_status,
        pendente         TYPE ze_status_cont VALUE ' ',
        em_processamento TYPE ze_status_cont VALUE '1',
        erro             TYPE ze_status_cont VALUE '2',
        completo         TYPE ze_status_cont VALUE '3',
        encerrado        TYPE ze_status_cont VALUE '4',
        advertencia      TYPE ze_status_cont VALUE '5',
      END OF gc_status.

    TYPES:
      "! Types para filtro de seleção.
      BEGIN OF ty_doc,
        documentno TYPE i_mfgordermaterialdocumentitem-manufacturingorder,
        material   TYPE ztpp_ajust_inv_i-material,
        plant      TYPE ztpp_ajust_inv_i-plant,
        batch      TYPE ztpp_ajust_inv_i-batch,
        datestart  TYPE ztpp_ajust_inv_h-datestart,
        dateend    TYPE ztpp_ajust_inv_h-dateend,
      END OF ty_doc.

    TYPES:
      "! Types Item de documento de material de pedido de manufatura.
      BEGIN OF ty_mat_doc_item,
        manufacturingorder        TYPE i_mfgordermaterialdocumentitem-manufacturingorder,
        material                  TYPE i_mfgordermaterialdocumentitem-material,
        plant                     TYPE i_mfgordermaterialdocumentitem-plant,
        batch                     TYPE i_mfgordermaterialdocumentitem-batch,
        goodsmovementtype         TYPE i_mfgordermaterialdocumentitem-goodsmovementtype,
        quantityinbaseunit        TYPE i_mfgordermaterialdocumentitem-quantityinbaseunit,
        mfgorderconfirmedyieldqty TYPE i_manufacturingorder-mfgorderconfirmedyieldqty,
      END OF ty_mat_doc_item.

    TYPES:
      "! Types dados Orders.
      BEGIN OF ty_orders,
        ordem     TYPE i_mfgordermaterialdocumentitem-manufacturingorder,
        material  TYPE ztpp_ajust_inv_i-material,
        plant     TYPE ztpp_ajust_inv_i-plant,
        batch     TYPE ztpp_ajust_inv_i-batch,
        qtd_total TYPE menge_d,
      END OF ty_orders.

    TYPES:
      "! Types dados quantidade total.
      BEGIN OF ty_qtd_total,
        material TYPE ztpp_ajust_inv_i-material,
        plant    TYPE ztpp_ajust_inv_i-plant,
        batch    TYPE ztpp_ajust_inv_i-batch,
        total    TYPE menge_d,
      END OF ty_qtd_total.

    "! Estrutura dados rateio.
    DATA gs_rateio    TYPE ty_orders.
    "! Estrutura dados quantidade total.
    DATA gs_qtd_total TYPE ty_qtd_total.
    "! Estrutura header BAPI.
    DATA gs_header_bp TYPE bapi2017_gm_head_01.
    "! Estrutura Item BAPI.
    DATA gs_item      TYPE bapi2017_gm_item_create.
    "! Estrutura Code BAPI.
    DATA gs_code      TYPE bapi2017_gm_code.
    "! Estrutura Ajuste de Inventário - Mensagens.
    DATA gs_message   TYPE ztpp_ajust_inv_m.

    "! Tabela Item de documento de material de pedido de manufatura.
    DATA gt_mat_doc_item TYPE SORTED TABLE OF ty_mat_doc_item WITH NON-UNIQUE KEY manufacturingorder
                                                                                  material
                                                                                  plant
                                                                                  batch.
    "! Tabela dados quantidade total.
    DATA gt_qtd_total    TYPE SORTED TABLE OF ty_qtd_total WITH NON-UNIQUE KEY material
                                                                               plant
                                                                               batch.
    "! Tabela dados rateio.
    DATA gt_orders       TYPE SORTED TABLE OF ty_orders WITH NON-UNIQUE KEY ordem
                                                                            material
                                                                            plant
                                                                            batch.
    "! Tabela Item BAPI.
    DATA gt_item         TYPE TABLE OF bapi2017_gm_item_create.
    "! Tabela return BAPI.
    DATA gt_return       TYPE TABLE OF bapiret2.
    "! Tabela para filtro de seleção.
    DATA gt_doc          TYPE TABLE OF ty_doc.
    "! Tabela Ajuste de Inventário - Mensagens.
    DATA gt_message      TYPE TABLE OF ztpp_ajust_inv_m.

    "! Tabela range Data de lançamento no documento.
    DATA gs_postingdate TYPE RANGE OF ztpp_ajust_inv_h-datestart.
    "! Tabela range tipo de movimento.
    DATA gs_move        TYPE RANGE OF i_mfgordermaterialdocumentitem-goodsmovementtype.
    "! Estrutura range Data de lançamento no documento.
    DATA gs_datum       LIKE LINE OF  gs_postingdate.
    "! Estrutura range tipo de movimento.
    DATA gs_move_type   LIKE LINE OF  gs_move.

    "! Realiza a seleção das Ordens e quantidades
    METHODS select.

    "! Reliza o processo de calculo e lançamento das ordens
    METHODS process.

    "!Calcula quantidade total das ordens
    METHODS get_total_qty.

    "! Calcula total de todas as ordens
    "! @parameter is_doc_item | Estrutura Item do documento do material de ordem de produção
    METHODS get_total_all_orders
      IMPORTING
        is_doc_item TYPE zclpp_lanca_cont_estoque=>ty_mat_doc_item.

    "! Calcula total de cada ordem
    "! @parameter is_doc_item |Estrutura Item do documento do material de ordem de produção
    METHODS get_total_orders
      IMPORTING
        is_doc_item TYPE zclpp_lanca_cont_estoque=>ty_mat_doc_item.

    "! Realiza as verificações para lançar a ordem.
    METHODS post_order.

    "! Calcula saldo apontamento
    "! @parameter iv_order  | Ordem
    "! @parameter is_item   | Estrutura Ajuste de Inventário - Item
    "! @parameter rv_result | Saldo apontamento
    METHODS get_qty_unit
      IMPORTING iv_order         TYPE aufnr
                is_item          TYPE ztpp_ajust_inv_i
      RETURNING VALUE(rv_result) TYPE menge_d.

    "! Realiza chamada da BAPI
    "! @parameter cs_item   | Estrutura Ajuste de Inventário - Item
    METHODS call_bapi
      CHANGING cs_item TYPE ztpp_ajust_inv_i.

    "! Preenche estruturas da BAPI
    "! @parameter is_header | Estrutura Ajuste de Inventário - Cabeçalho
    "! @parameter is_item   | Estrutura Ajuste de Inventário - Item
    "! @parameter is_rateio | Estrutura com rateio de ordens
    METHODS fill_bapi
      IMPORTING is_header TYPE ztpp_ajust_inv_h
                is_item   TYPE ztpp_ajust_inv_i
                is_rateio TYPE mill_oc_quant.

    "! Gravas logs na tabela interna de mensagens
    "! @parameter is_item    | Estrutura Ajuste de Inventário - Item
    "! @parameter is_msg     | Mensagens BAPI
    METHODS set_message
      IMPORTING
        is_item TYPE ztpp_ajust_inv_i
        is_msg  TYPE bapiret2.

    "! Atualiza status nas tabelas do banco
    METHODS commit_status.

    "! Filtra dados para seleção
    METHODS get_selection.

    "! Commit BAPI
    METHODS commit_bapi.

    "! Busaca o movimento contido na tabela de parametros
    "! @parameter iv_chave2 | Chave do Parâmetro
    METHODS get_move
      IMPORTING
        iv_chave2 TYPE ztca_param_par-chave2 OPTIONAL.

    "! Atualiza Status
    "! @parameter iv_status |  Status
    METHODS update_status IMPORTING iv_status TYPE ze_status_cont OPTIONAL.

    "! Atualiza status
    METHODS set_process_status.

    "! Executa Rollback
    METHODS rollback_bapi.

    "! Check order quantity
    METHODS orders_found_by_item
      IMPORTING
        is_item           TYPE ztpp_ajust_inv_i
      RETURNING
        VALUE(rv_boolean) TYPE abap_bool.

ENDCLASS.



CLASS zclpp_lanca_cont_estoque IMPLEMENTATION.


  METHOD main.

    gt_ajust_inv_header = it_ajust_inv_header.
    gt_ajust_inv_item   = it_ajust_inv_item.

    set_process_status( ).
    select( ).

    IF gt_mat_doc_item IS NOT INITIAL.
      process( ).
    ENDIF.

    update_status( ).
    commit_status( ).

  ENDMETHOD.


  METHOD select.

    get_selection(  ).

    IF gt_doc IS NOT INITIAL.

      get_move( iv_chave2 = lc_chave2 ).

      SELECT DISTINCT
             i_mfgordermaterialdocumentitem~manufacturingorder,
             i_mfgordermaterialdocumentitem~material,
             i_mfgordermaterialdocumentitem~plant,
             i_mfgordermaterialdocumentitem~batch,
             i_mfgordermaterialdocumentitem~goodsmovementtype,
             i_mfgordermaterialdocumentitem~quantityinbaseunit,
             i_manufacturingorder~mfgorderconfirmedyieldqty
        INTO TABLE @gt_mat_doc_item
        FROM i_mfgordermaterialdocumentitem
        INNER JOIN i_manufacturingorder
        ON i_mfgordermaterialdocumentitem~manufacturingorder EQ i_manufacturingorder~manufacturingorder
        FOR ALL ENTRIES IN @gt_doc
        WHERE "i_mfgordermaterialdocumentitem~manufacturingorder     EQ @gt_doc-documentno
              i_mfgordermaterialdocumentitem~postingdate            IN @gs_postingdate
          AND i_mfgordermaterialdocumentitem~material               EQ @gt_doc-material
          AND i_mfgordermaterialdocumentitem~plant                  EQ @gt_doc-plant
          AND i_mfgordermaterialdocumentitem~batch                  EQ @gt_doc-batch
          AND i_mfgordermaterialdocumentitem~manufacturingordertype EQ @lc_pi01
          AND i_mfgordermaterialdocumentitem~goodsmovementtype      IN @gs_move.

    ENDIF.

  ENDMETHOD.


  METHOD process.

    get_total_qty(  ).
    post_order(  ).

  ENDMETHOD.


  METHOD get_total_qty.

    get_move( ).

    LOOP AT gt_mat_doc_item ASSIGNING FIELD-SYMBOL(<fs_doc_item>) .

      IF ( NOT <fs_doc_item>-goodsmovementtype IN gs_move ).
        CONTINUE.
      ENDIF.

      "Lógica para calcular todas as quantidades de ordens com o mesmo material+centro+lote
*      READ TABLE gt_mft_order ASSIGNING FIELD-SYMBOL(<fs_mft_order>) WITH KEY manufacturingorder  = <fs_doc_item>-manufacturingorder
*                                                                              material            = <fs_doc_item>-material
*                                                                              batch               = <fs_doc_item>-batch BINARY SEARCH.
*
*      CHECK sy-subrc = 0.
      get_total_all_orders( is_doc_item = <fs_doc_item> ).
      get_total_orders( is_doc_item = <fs_doc_item> ).

    ENDLOOP.

  ENDMETHOD.


  METHOD post_order.

    DATA: lv_balance TYPE menge_d,
          lv_rateio  TYPE ru_lmnga.

    SORT gt_ajust_inv_item BY material plant batch.

    LOOP AT gt_ajust_inv_item ASSIGNING FIELD-SYMBOL(<fs_item>)
      WHERE status = gc_status-em_processamento.

      LOOP AT gt_orders ASSIGNING FIELD-SYMBOL(<fs_orders_key>)
        WHERE ( material = <fs_item>-material AND plant = <Fs_item>-plant AND batch = <fs_item>-batch )
        GROUP BY ( material = <fs_orders_key>-material
                   plant    = <fs_orders_key>-plant
                   batch    = <fs_orders_key>-batch )
        ASSIGNING FIELD-SYMBOL(<fs_group_orders>). "#EC CI_SORTSEQ

        READ TABLE gt_ajust_inv_header ASSIGNING FIELD-SYMBOL(<fs_header>)
          WITH KEY  documentouuid = <fs_item>-documentouuid BINARY SEARCH.

        CHECK sy-subrc = 0.

        READ TABLE gt_qtd_total ASSIGNING FIELD-SYMBOL(<fs_qtd_total>)
          WITH KEY material = <fs_group_orders>-material
                   plant    = <fs_group_orders>-plant
                   batch    = <fs_group_orders>-batch BINARY SEARCH.

        CHECK sy-subrc EQ 0.

        FREE: gs_header_bp,
              gt_item,
              lv_balance.

        lv_balance = <fs_item>-quantity - <fs_item>-counting.

        gs_header_bp = VALUE #( pstng_date = <fs_header>-dateend
                                doc_date   = <fs_header>-dateend ).

        LOOP AT GROUP <fs_group_orders> ASSIGNING FIELD-SYMBOL(<fs_orders>).

          TRY.
              lv_rateio = ( <fs_orders>-qtd_total * 100 ) / <fs_qtd_total>-total.
              DATA(lv_entry_qnt) = CONV erfmg( abs( ( lv_rateio / 100 ) * lv_balance ) ).
            CATCH cx_sy_zerodivide INTO DATA(lo_exception).
          ENDTRY.

          IF lv_balance LT 0.
            DATA(lv_qtd_unit) = get_qty_unit( iv_order = <fs_orders>-ordem is_item = <fs_item> ).

            IF lv_entry_qnt GT lv_qtd_unit.

              <fs_item>-status = gc_status-erro.

              DATA(ls_return) = VALUE bapiret2( type = lc_erro id = 'ZPP_INVENTARIO_PROD' number = '004' ).
              set_message( is_item = <fs_item> is_msg = ls_return ).
              CONTINUE.

            ENDIF.
          ENDIF.

          APPEND VALUE #( move_type = COND #( WHEN lv_balance GT 0 THEN lc_y01 ELSE lc_z01 )
                          orderid   = <fs_orders>-ordem
                          material  = <fs_item>-material
                          plant     = <fs_item>-plant
                          stge_loc  = <fs_item>-storagelocation
                          batch     = <fs_item>-batch
                          entry_qnt = lv_entry_qnt
                          entry_uom = <fs_item>-unit ) TO gt_item.

          FREE: lv_rateio,
                lv_qtd_unit,
                lv_entry_qnt.

        ENDLOOP.

        call_bapi( CHANGING cs_item = <fs_item> ).

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_qty_unit.

    READ TABLE gt_mat_doc_item
         WITH KEY manufacturingorder = iv_order
                  material           = is_item-material
                  plant              = is_item-plant
                  batch              = is_item-batch
         TRANSPORTING NO FIELDS
         BINARY SEARCH.

    IF sy-subrc = 0.

      LOOP AT gt_mat_doc_item ASSIGNING FIELD-SYMBOL(<fs_mat_doc_item>) FROM sy-tabix.

        IF <fs_mat_doc_item>-material   <> is_item-material
           OR <fs_mat_doc_item>-plant   <> is_item-plant
           OR <fs_mat_doc_item>-batch   <> is_item-batch
           OR <fs_mat_doc_item>-manufacturingorder <> iv_order.
          EXIT.
        ELSE.

          IF <fs_mat_doc_item>-goodsmovementtype IN gs_move.
            rv_result = rv_result + <fs_mat_doc_item>-quantityinbaseunit.
          ELSE.
            rv_result = rv_result - <fs_mat_doc_item>-quantityinbaseunit.
          ENDIF.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD call_bapi.
    IF gt_item IS INITIAL.
      RETURN.
    ENDIF.

    gs_code-gm_code = '03'.

    DATA(ls_goodsmvt_headret) = VALUE bapi2017_gm_head_ret( ).

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = gs_header_bp
        goodsmvt_code    = gs_code
      IMPORTING
        goodsmvt_headret = ls_goodsmvt_headret
      TABLES
        goodsmvt_item    = gt_item
        return           = gt_return.         "#EC CI_SEL_NESTED

    IF ls_goodsmvt_headret IS NOT INITIAL.

      set_message( is_item = cs_item
                   is_msg  = VALUE #( type       = lc_ok
                                      id         = 'QTASK'
                                      number     = '155'
                                      message_v1 = ls_goodsmvt_headret-mat_doc
                                      message_v2 = ls_goodsmvt_headret-doc_year ) ).

      commit_bapi(  ).
      cs_item-status = COND #( WHEN cs_item-status = gc_status-erro THEN gc_status-advertencia ELSE gc_status-completo ).

    ELSE.

      rollback_bapi( ).
      cs_item-status = gc_status-erro.

      LOOP AT gt_return ASSIGNING FIELD-SYMBOL(<fs_return>).
        set_message( is_item = cs_item is_msg = <fs_return> ).
      ENDLOOP.
      IF sy-subrc NE 0.

        set_message( is_item = cs_item
                     is_msg  = VALUE #( type = lc_erro
                     id      = 'M7'
                     number  = '130' ) ).
      ENDIF.

    ENDIF.

    FREE: gt_return, gt_item.

  ENDMETHOD.


  METHOD fill_bapi.

    gs_header_bp-pstng_date = is_header-dateend.
    gs_header_bp-doc_date   = is_header-dateend.

    gs_item-orderid         = is_rateio-aufnr.
    gs_item-material        = is_item-material.
    gs_item-plant           = is_item-plant.
    gs_item-stge_loc        = is_item-storagelocation.
    gs_item-batch           = is_item-batch.
    gs_item-entry_uom       = is_item-unit.

    APPEND gs_item TO gt_item.

  ENDMETHOD.


  METHOD set_message.

    gs_message-documentouuid     = is_item-documentouuid.
    gs_message-documentoitemuuid = is_item-documentoitemuuid.

    gs_message-msgty             = is_msg-type.
    gs_message-msgid             = is_msg-id.
    gs_message-msgno             = is_msg-number.
    gs_message-msgv1             = is_msg-message_v1.
    gs_message-msgv2             = is_msg-message_v2.
    gs_message-msgv3             = is_msg-message_v3.
    gs_message-msgv4             = is_msg-message_v4.

    MESSAGE ID gs_message-msgid TYPE gs_message-msgty NUMBER gs_message-msgno
      WITH gs_message-msgv1 gs_message-msgv2 gs_message-msgv3 gs_message-msgv4
      INTO gs_message-message.

    APPEND gs_message TO gt_message.

  ENDMETHOD.


  METHOD commit_status.

    UPDATE ztpp_ajust_inv_h FROM TABLE @( gt_ajust_inv_header ).
    UPDATE ztpp_ajust_inv_i FROM TABLE @( gt_ajust_inv_item ).

    SORT gt_message BY documentouuid documentoitemuuid.
    LOOP AT gt_message ASSIGNING FIELD-SYMBOL(<fs_message_key>)
      GROUP BY ( documentouuid     = <fs_message_key>-documentouuid
                 documentoitemuuid = <fs_message_key>-documentoitemuuid )
      ASSIGNING FIELD-SYMBOL(<fs_group_message>).

      DATA(lv_seqnr) = CONV seqnr( 0 ).
      LOOP AT GROUP <fs_group_message> ASSIGNING FIELD-SYMBOL(<fs_message>).
        ADD 1 TO lv_seqnr.
        <fs_message>-seqnr = lv_seqnr.
      ENDLOOP.
    ENDLOOP.

    DELETE ztpp_ajust_inv_m FROM TABLE @( VALUE #(
      FOR <fs_item_key> IN gt_ajust_inv_item
        ( documentouuid     = <fs_item_key>-documentouuid
          documentoitemuuid = <fs_item_key>-documentoitemuuid ) ) ).

    MODIFY ztpp_ajust_inv_m FROM TABLE @( gt_message ).
    COMMIT WORK.

  ENDMETHOD.


  METHOD get_total_all_orders.
    "Total de quantidades de ordens com o mesmo material+centro+lote
    READ TABLE gt_qtd_total ASSIGNING FIELD-SYMBOL(<fs_qtd_total>)  WITH KEY material = is_doc_item-material
                                                                             plant    = is_doc_item-plant
                                                                             batch    = is_doc_item-batch BINARY SEARCH.
    IF <fs_qtd_total>  IS ASSIGNED.
      <fs_qtd_total>-total = <fs_qtd_total>-total + is_doc_item-mfgorderconfirmedyieldqty.
    ELSE.
      DATA(lv_tabix) = sy-tabix.
      gs_qtd_total-material = is_doc_item-material.
      gs_qtd_total-plant    = is_doc_item-plant.
      gs_qtd_total-batch    = is_doc_item-batch.
      gs_qtd_total-total    = gs_qtd_total-total + is_doc_item-mfgorderconfirmedyieldqty.

      INSERT gs_qtd_total INTO gt_qtd_total INDEX lv_tabix.
      CLEAR gs_qtd_total.
    ENDIF.
  ENDMETHOD.


  METHOD get_total_orders.

    READ TABLE gt_orders ASSIGNING FIELD-SYMBOL(<fs_orders>) WITH KEY ordem    = is_doc_item-manufacturingorder
                                                                      material = is_doc_item-material
                                                                      plant    = is_doc_item-plant
                                                                      batch    = is_doc_item-batch BINARY SEARCH.

    IF <fs_orders> IS NOT ASSIGNED.
      DATA(lv_tabix) = sy-tabix.
      gs_rateio-ordem     = is_doc_item-manufacturingorder.
      gs_rateio-material  = is_doc_item-material.
      gs_rateio-plant     = is_doc_item-plant.
      gs_rateio-batch     = is_doc_item-batch.
      gs_rateio-qtd_total = gs_rateio-qtd_total + is_doc_item-mfgorderconfirmedyieldqty.

      INSERT gs_rateio INTO gt_orders INDEX lv_tabix.
      CLEAR gs_rateio.

    ELSE.
      "Verfica se o calculo para mesma ordem.
      <fs_orders>-qtd_total =  <fs_orders>-qtd_total + is_doc_item-mfgorderconfirmedyieldqty.
    ENDIF.


  ENDMETHOD.


  METHOD get_selection.

    DATA lv_documentno TYPE aufnr.

    LOOP AT gt_ajust_inv_item ASSIGNING FIELD-SYMBOL(<fs_item>).

      DATA(lv_tabix) = sy-tabix.

      IF  NOT <fs_item>-counting IS INITIAL         " Tem contagem
      AND <fs_item>-quantity NE <fs_item>-counting. " Saldo diferente de zero

        READ TABLE gt_ajust_inv_header ASSIGNING FIELD-SYMBOL(<fs_header>) WITH KEY documentouuid = <fs_item>-documentouuid BINARY SEARCH.
        IF sy-subrc = 0.

          lv_documentno = <fs_header>-documentno.
          UNPACK lv_documentno TO lv_documentno.

          APPEND VALUE #( documentno = lv_documentno
                          material   = <fs_item>-material
                          plant      = <fs_item>-plant
                          batch      = <fs_item>-batch ) TO gt_doc.

          gs_datum-sign   = lc_i.
          gs_datum-option = lc_bt.
          gs_datum-low    = <fs_header>-datestart.
          gs_datum-high   = <fs_header>-dateend.
          APPEND gs_datum TO gs_postingdate .
          CLEAR: gs_datum, lv_documentno.


        ENDIF.

      ELSE.
*        DELETE gt_ajust_inv_item INDEX lv_tabix.
        <fs_item>-status = gc_status-pendente.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD rollback_bapi.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.


  METHOD commit_bapi.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

  ENDMETHOD.


  METHOD get_move.

    DATA(lo_tabela_parametros) = NEW  zclca_tabela_parametros( ).

    CLEAR gs_move.

    TRY.
        lo_tabela_parametros->m_get_range(
          EXPORTING
            iv_modulo = lc_mod
            iv_chave1 = lc_chave1
            iv_chave2 = iv_chave2
          IMPORTING
            et_range  = gs_move
        ).

      CATCH zcxca_tabela_parametros.

    ENDTRY.

  ENDMETHOD.


  METHOD update_status.

    CASE iv_status.
      WHEN gc_status-em_processamento.

        DATA(ls_ajust_inv_header) = VALUE ztpp_ajust_inv_h( status = gc_status-em_processamento ).
        LOOP AT gt_ajust_inv_header ASSIGNING FIELD-SYMBOL(<fs_ajust_inv_header>).
          <fs_ajust_inv_header>-status = ls_ajust_inv_header-status.
        ENDLOOP.

        LOOP AT gt_ajust_inv_item ASSIGNING FIELD-SYMBOL(<fs_item>).
          CHECK <fs_item>-status NE gc_status-em_processamento
            AND <fs_item>-status NE gc_status-completo
            AND <fs_item>-status NE gc_status-encerrado
            AND <fs_item>-status NE gc_status-advertencia.
          <fs_item>-status = gc_status-em_processamento.
        ENDLOOP.


      WHEN OTHERS.

        LOOP AT gt_ajust_inv_item ASSIGNING <fs_item>.

          CHECK <fs_item>-status EQ gc_status-em_processamento.
          <fs_item>-status = gc_status-pendente.

          IF <fs_item>-status = gc_status-erro.
            DATA(lv_erro) = abap_true.
          ENDIF.

          IF <fs_item>-status = gc_status-advertencia.
            DATA(lv_advertencia) = abap_true.
          ENDIF.

          IF me->orders_found_by_item( <fs_item> ) = abap_false.
            me->set_message(
              is_item  = <fs_item>
              is_msg   = VALUE #(
                type   = lc_aviso
                id     = 'ZPP_INVENTARIO_PROD'
                number = '005'
              )
            ).
          ENDIF.
        ENDLOOP.

        IF lv_erro EQ abap_true.
          ls_ajust_inv_header = VALUE ztpp_ajust_inv_h( status = gc_status-erro ).

        ELSEIF lv_advertencia EQ abap_true.
          ls_ajust_inv_header = VALUE ztpp_ajust_inv_h( status = gc_status-advertencia ).

        ELSE.
          ls_ajust_inv_header = VALUE ztpp_ajust_inv_h( status = gc_status-completo ).

          LOOP AT gt_ajust_inv_item ASSIGNING <fs_item>.
            CHECK <fs_item>-status EQ gc_status-pendente.
            CHECK <fs_item>-quantity - <fs_item>-counting NE 0.
            ls_ajust_inv_header = VALUE ztpp_ajust_inv_h( status = gc_status-pendente ).
            EXIT.
          ENDLOOP.
        ENDIF.

        LOOP AT gt_ajust_inv_header ASSIGNING <fs_ajust_inv_header>.
          <fs_ajust_inv_header>-status = ls_ajust_inv_header-status.
        ENDLOOP.

    ENDCASE.

  ENDMETHOD.


  METHOD set_process_status.
    update_status( gc_status-em_processamento ).
    commit_status( ).
  ENDMETHOD.

  METHOD orders_found_by_item.
    READ TABLE gt_qtd_total TRANSPORTING NO FIELDS
      WITH KEY
        material = is_item-material
        plant    = is_item-plant
        batch    = is_item-batch
      BINARY SEARCH.

    IF sy-subrc IS INITIAL.
      rv_boolean = abap_true.
    ELSE.
      rv_boolean = abap_False.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
