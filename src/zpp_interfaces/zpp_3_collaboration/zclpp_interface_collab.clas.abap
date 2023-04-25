***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Interface com 3 Collaboration                          *
*** AUTOR : Heitor Alves - META                                       *
*** FUNCIONAL: Antonio Lopes - META                                   *
*** DATA : 11.01.2022                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 11.01.2022 | Heitor Alves       | Desenvolvimento inicial         *
***********************************************************************
class ZCLPP_INTERFACE_COLLAB definition
  public
  final
  create public .

public section.

      "! Pega parâmetros do Job e envia dados via Proxy
      "! @parameter ir_matnr | Range de Materiais
      "! @parameter ir_werks | Range de Centros
      "! @parameter ir_stalt | Range de Listas Técnicas
      "! @parameter ir_datuv | Range de Datas Iniciais
      "! @parameter ir_datub | Range de Datas Finais
      "! @raising zcxca_erro_interface | Erro Genérico
  methods EXECUTE_JOB
    importing
      !IR_MATNR type TBL_MAT_RANGE
      !IR_WERKS type RANGE_T_WERKS_D
      !IR_STALT type TRG_CHAR2
      !IR_DATUV type RANGE_T_DATS
      !IR_DATUB type RANGE_T_DATS
    raising
      ZCXCA_ERRO_INTERFACE .
      "! Pega parâmetros do Job e envia dados via Proxy
      "! @parameter ir_matnr | Range de Materiais
      "! @parameter ir_werks | Range de Centros
      "! @parameter ir_documentdate | Range de Data
      "! @raising zcxca_erro_interface | Erro Genérico
  methods EXECUTE_JOB_R03
    importing
      !IR_MATNR type TBL_MAT_RANGE
      !IR_WERKS type RANGE_T_WERKS_D
      !IR_DOCUMENTDATE type RANGE_T_DATS
    raising
      ZCXCA_ERRO_INTERFACE .
      "! Pega parâmetros do Job e envia dados via Proxy
      "! @parameter ir_matnr | Range de Materiais
      "! @parameter ir_werks | Range de Centros
      "! @raising zcxca_erro_interface | Erro Genérico
  methods EXECUTE_JOB_R04
    importing
      !IR_MATNR type TBL_MAT_RANGE
      !IR_WERKS type RANGE_T_WERKS_D
      !IR_LGORT type SHP_LGORT_RANGE_T
      !IR_MTART type FIP_T_MTART_RANGE
      !IR_MATKL type SHP_MATKL_RANGE_T
    raising
      ZCXCA_ERRO_INTERFACE .
  methods MESSAGE_SAVE
    importing
      !IS_MSG type BAL_S_MSG .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: gv_log_handle TYPE balloghndl.

    CONSTANTS: BEGIN OF gc_erros,
                 envio  TYPE string VALUE 'Erro no envio das informações'                                       ##NO_TEXT,
*                 reprovado2 TYPE string VALUE 'Não foi encontrado o registro da Ordem da solicitação'            ##NO_TEXT,
*                 reprovado3 TYPE string VALUE 'Não foi encontrado o registro de Ativo da solicitação'            ##NO_TEXT,
*                 reprovado4 TYPE string VALUE 'Não foi encontrado o registro de Centro de Custo da solicitação'  ##NO_TEXT,
*                 reprovado5 TYPE string VALUE 'Não foi encontrado o registro de PEP da solicitação'              ##NO_TEXT,
*                 reprovado6 TYPE string VALUE 'Solicitação de Viagem já existe no S/4HANA'                       ##NO_TEXT,
*                 reprovado7 TYPE string VALUE 'Solicitação de Viagem não encontrada no S/4HANA.'                 ##NO_TEXT,
                 classe TYPE string VALUE 'ZCA_ERROS_MSG'                                                  ##NO_TEXT,
*                 argo       TYPE string VALUE 'Aguardando Liberação ARGO'                                        ##NO_TEXT,
*                 b01        TYPE string VALUE 'B01'                                                              ##NO_TEXT,
*                 pep        TYPE ps_posid_edit    VALUE 'PEP'                   ##NO_TEXT,
*                 modulo     TYPE ze_param_modulo  VALUE 'MM'                    ##NO_TEXT,
*                 chave1     TYPE ze_param_chave   VALUE 'ARGO'                  ##NO_TEXT,
*                 chave2     TYPE ze_param_chave   VALUE 'APROVADOR'             ##NO_TEXT,
*                 chave3     TYPE ze_param_chave_3 VALUE 'S/4HANA'               ##NO_TEXT,
*                 chave1_a   TYPE ze_param_chave   VALUE 'ARGO'                  ##NO_TEXT,
*                 chave2_a   TYPE ze_param_chave   VALUE 'BAPI_PR_CREATE'        ##NO_TEXT,
*                 chave3_a   TYPE ze_param_chave_3 VALUE 'PR_TYPE'               ##NO_TEXT,
*                 chave1_o   TYPE ze_param_chave   VALUE 'ARGO'                  ##NO_TEXT,
*                 chave2_o   TYPE ze_param_chave   VALUE 'ORG_COMPRAS'           ##NO_TEXT,
*                 chave3_o   TYPE ze_param_chave_3 VALUE 'PREQ'                  ##NO_TEXT,
*                 chave1_m   TYPE ze_param_chave   VALUE 'ME'                    ##NO_TEXT,
*                 chave2_m   TYPE ze_param_chave   VALUE 'CANCELITEM'            ##NO_TEXT,
*                 chave3_m   TYPE ze_param_chave_3 VALUE 'MENSAGEM'              ##NO_TEXT,
*                 string1    TYPE string VALUE 'Sol. Passagem | Solicitação: '   ##NO_TEXT,
*                 string2    TYPE string VALUE '| Passageiro: '                  ##NO_TEXT,
*                 string3    TYPE string VALUE 'Trecho - Origem: '               ##NO_TEXT,
*                 string4    TYPE string VALUE 'Destino: '                       ##NO_TEXT,
*                 string5    TYPE string VALUE 'Data da Viagem: '                ##NO_TEXT,
*                 string6    TYPE string VALUE 'Solicitante: '                   ##NO_TEXT,
*                 string7    TYPE string VALUE 'Sol. Hospedagem | Solicitação'   ##NO_TEXT,
*                 string8    TYPE string VALUE '| Hospede: '                     ##NO_TEXT,
*                 string9    TYPE string VALUE 'Hotel: '                         ##NO_TEXT,
*                 string10   TYPE string VALUE 'Localidade: '                    ##NO_TEXT,
*                 string11   TYPE string VALUE 'Check-In: '                      ##NO_TEXT,
*                 string12   TYPE string VALUE 'Check-Out: '                     ##NO_TEXT,
*                 string13   TYPE string VALUE 'Último Aprovador: '              ##NO_TEXT,
               END OF gc_erros.


    METHODS:

      "! Raise
      "! @parameter is_ret | Parametro
      "! @raising zcxca_erro_interface | Erro
      erro_raise
        IMPORTING
          is_ret TYPE scx_t100key
        RAISING
          zcxca_erro_interface,

      create_log.



ENDCLASS.



CLASS ZCLPP_INTERFACE_COLLAB IMPLEMENTATION.


  METHOD create_log.

    CONSTANTS: lc_obj TYPE c LENGTH 20 VALUE 'ZPP_INTERFACE_COLLAB',
               lc_sub TYPE c LENGTH 10 VALUE 'JOB'.

    DATA: ls_log        TYPE bal_s_log.

    ls_log-aluser    = sy-uname.
    ls_log-alprog    = sy-repid.
    ls_log-object    = lc_obj.
    ls_log-subobject = lc_sub.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log      = ls_log
      IMPORTING
        e_log_handle = gv_log_handle
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    IF NOT sy-batch IS INITIAL.

      CALL FUNCTION 'BP_ADD_APPL_LOG_HANDLE'
        EXPORTING
          loghandle = gv_log_handle
        EXCEPTIONS
          OTHERS    = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD execute_job.
    DATA: lt_list     TYPE TABLE OF zc_pp_materialbom,
*          ls_list     TYPE zc_pp_materialbom,
          ls_list_tec TYPE zclpp_dt_lista_tecnica,
          lt_techlist TYPE zclpp_mt_lista_tecnica.

    TRY.

        SELECT *                              "#EC CI_ALL_FIELDS_NEEDED
        FROM zc_pp_materialbom
        WHERE   material                IN @ir_matnr
        AND     plant                   IN @ir_werks
        AND     billofmaterialvariant   IN @ir_stalt
        AND     validitystartdate       IN @ir_datuv
        AND     validityenddate         IN @ir_datub
        INTO CORRESPONDING FIELDS OF TABLE @lt_list.

        IF sy-subrc = 0.

          LOOP AT lt_list ASSIGNING FIELD-SYMBOL(<fs_list>).

            ls_list_tec-bill_of_material               = <fs_list>-billofmaterial+4(4).
            ls_list_tec-bill_of_material_component     = <fs_list>-billofmaterialcomponent+11(7).
            ls_list_tec-bill_of_material_item_node_num = <fs_list>-billofmaterialitemnodenumber.
            ls_list_tec-bill_of_material_item_number   = <fs_list>-billofmaterialitemnumber.
*            ls_list_tec-bill_of_material_item_quantity = <fs_list>-bomheaderquantityinbaseunit.
            ls_list_tec-bill_of_material_item_quantity = COND #( WHEN <fs_list>-billofmaterialitemquantity < 0 THEN |-{ abs( <fs_list>-billofmaterialitemquantity ) }|
                                                                 ELSE <fs_list>-billofmaterialitemquantity ).

            ls_list_tec-bill_of_material_item_unit     = <fs_list>-billofmaterialitemunit.
            ls_list_tec-bill_of_material_status        = <fs_list>-billofmaterialstatus.
            ls_list_tec-bill_of_material_variant       = <fs_list>-billofmaterialvariant.
            ls_list_tec-bill_of_material_variant_usage = <fs_list>-billofmaterialvariantusage.
            ls_list_tec-bomalternative_text            = <fs_list>-bomalternativetext.
            ls_list_tec-bomheader_base_unit            = <fs_list>-bomheaderbaseunit.
            ls_list_tec-bomheader_quantity_in_base_uni = <fs_list>-bomheaderquantityinbaseunit.
            ls_list_tec-bomheader_text                 = <fs_list>-bomheadertext.
            ls_list_tec-bomitem_internal_change_count  = <fs_list>-bomiteminternalchangecount.
            ls_list_tec-is_net_scrap                   = <fs_list>-isnetscrap.

*            ls_list_tec-language                       = <fs_list>-language.

            CALL FUNCTION 'CONVERSION_EXIT_ISOLA_OUTPUT'
              EXPORTING
                input  = <fs_list>-language
              IMPORTING
                output = ls_list_tec-language.

            ls_list_tec-material                       = <fs_list>-material+10(8).
            ls_list_tec-operation_scrap_in_percent     = <fs_list>-operationscrapinpercent.
            ls_list_tec-plant                          = <fs_list>-plant.
            ls_list_tec-z_component_name               = <fs_list>-z_productname.
            ls_list_tec-z_product_name                 = <fs_list>-z_componentname.

            lt_techlist-mt_lista_tecnica = ls_list_tec.

*          lt_techlist-mt_lista_tecnica = corresponding #( lt_list mapping
*                                                                          bill_of_material                 = billofmaterial
*                                                                         bill_of_material_component       = BillOfMaterialComponent
*                                                                         bill_of_material_item_node_num   = BillOfMaterialItemNodeNumber
*                                                                         bill_of_material_item_number     = BillOfMaterialItemNumber
*                                                                         bill_of_material_item_quantity   = BOMHeaderQuantityInBaseUnit
*                                                                         bill_of_material_item_unit       = BillOfMaterialItemUnit
*                                                                         bill_of_material_status          = BillOfMaterialStatus
*                                                                         bill_of_material_variant         = BillOfMaterialVariant
*                                                                         bill_of_material_variant_usage   = BillOfMaterialVariantUsage
*                                                                         bomalternative_text              = BOMAlternativeText
*                                                                         bomheader_base_unit              = BOMHeaderBaseUnit
*                                                                         bomheader_quantity_in_base_uni   = BOMHeaderQuantityInBaseUnit
*                                                                         bomheader_text                   = BOMHeaderText
*                                                                         bomitem_internal_change_count    = BOMItemInternalChangeCount
*                                                                         is_net_scrap                     = IsNetScrap
*                                                                         language                         = Language
*                                                                         material                         = Material
*                                                                         operation_scrap_in_percent       = OperationScrapInPercent
*                                                                         plant                            = Plant
*                                                                         z_component_name                 = Z_ComponentName
*                                                                         z_product_name                   = Z_ProductName ).

            IF ls_list_tec-bill_of_material_component IS NOT INITIAL.  "card 4378
              DATA(lo_tech_list_out) = NEW zclpp_co_si_enviar_lista_tecni( ).

              lo_tech_list_out->si_enviar_lista_tecnica_out( output = lt_techlist ).

              COMMIT WORK.
            ENDIF.
            CLEAR: <fs_list>, ls_list_tec, lt_techlist-mt_lista_tecnica.

          ENDLOOP.

        ENDIF.

      CATCH zcxmm_erro_interface_mes.
        me->erro_raise( is_ret = VALUE #(  msgid = gc_erros-classe attr1 = gc_erros-envio  msgno = '000' ) ).
      CATCH cx_ai_system_fault.
        me->erro_raise( is_ret = VALUE #(  msgid = gc_erros-classe attr1 = gc_erros-envio  msgno = '000' ) ).
    ENDTRY.

  ENDMETHOD.


  METHOD erro_raise.

    RAISE EXCEPTION TYPE zcxca_erro_interface
      EXPORTING
        textid = VALUE #( msgid = is_ret-msgid
                          msgno = is_ret-msgno
                          attr1 = is_ret-attr1
                          ).
  ENDMETHOD.


  METHOD message_save.

    DATA: ls_msg        TYPE bal_s_msg,
          lt_log_handle TYPE bal_t_logh,
          lv_mensagem   TYPE symsgv.

    APPEND gv_log_handle TO lt_log_handle.

    ls_msg = is_msg.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = gv_log_handle
        i_s_msg          = ls_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_client       = sy-mandt
        i_save_all     = abap_true
        i_t_log_handle = lt_log_handle
      EXCEPTIONS
        OTHERS         = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.


  METHOD execute_job_r03.

    DATA: lt_itemconsumption TYPE zclpp_mt_processo_fabricacao1.

    TRY.

        SELECT  m~materialdocument,
                m~materialdocumentitem,
                m~material,
                t~materialname,
                m~plant,
                m~storagelocation,
                m~goodsmovementtype,
                m~quantityinentryunit,
                m~entryunit,
                m~documentdate
        FROM i_materialdocumentitem AS m
        INNER JOIN i_materialtext AS t ON t~material  = m~material
                                       AND t~language = @sy-langu
        WHERE   m~material                IN @ir_matnr
        AND     m~plant                   IN @ir_werks
* JWSILVA - Ajuste GAP 261 - 01.12.2022 Início
*        AND     m~fiscalyearperiod   IN @ir_jahrper
        AND     m~DocumentDate            IN @ir_documentdate
* JWSILVA - Ajuste GAP 261 - 01.12.2022 Fim
        INTO TABLE @DATA(lt_list).

        IF sy-subrc = 0.

          LOOP AT lt_list ASSIGNING FIELD-SYMBOL(<fs_list>).

            lt_itemconsumption-mt_processo_fabricacao-lines-material_document      = <fs_list>-materialdocument.
            lt_itemconsumption-mt_processo_fabricacao-lines-material_document_item = <fs_list>-materialdocumentitem.
            lt_itemconsumption-mt_processo_fabricacao-lines-plant                  = <fs_list>-plant.
            lt_itemconsumption-mt_processo_fabricacao-lines-material               = <fs_list>-material.
            lt_itemconsumption-mt_processo_fabricacao-lines-material_name          = <fs_list>-materialname.
            lt_itemconsumption-mt_processo_fabricacao-lines-entry_unit             = <fs_list>-entryunit.
            lt_itemconsumption-mt_processo_fabricacao-lines-goods_movement_type    = <fs_list>-goodsmovementtype.
            lt_itemconsumption-mt_processo_fabricacao-lines-storage_location       = <fs_list>-storagelocation.
            lt_itemconsumption-mt_processo_fabricacao-lines-posting_date           = <fs_list>-documentdate.
            lt_itemconsumption-mt_processo_fabricacao-lines-quantity_in_entry_unit = <fs_list>-quantityinentryunit.

            DATA(lo_item_comsuption_out) = NEW zclpp_co_si_enviar_processo_f1( ).

            lo_item_comsuption_out->si_enviar_processo_fabricacao( output = lt_itemconsumption ).

            COMMIT WORK.

            CLEAR: lt_itemconsumption-mt_processo_fabricacao-lines.

          ENDLOOP.

        ENDIF.

      CATCH zcxmm_erro_interface_mes.
        me->erro_raise( is_ret = VALUE #(  msgid = gc_erros-classe attr1 = gc_erros-envio  msgno = '000' ) ).
      CATCH cx_ai_system_fault.
        me->erro_raise( is_ret = VALUE #(  msgid = gc_erros-classe attr1 = gc_erros-envio  msgno = '000' ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD execute_job_r04.

    DATA: lt_estoque TYPE zclpp_mt_estoque_saldo.
    DATA: ls_estoque TYPE zclpp_mt_estoque_saldo.

    TRY.

        SELECT  m~matnr,
                m~werks,
                m~lgort,
                t~materialname,
                m~labst,
                mat~materialbaseunit,
                m~umlme,
                m~insme,
                m~speme,
                m~retme,
                m~einme,
                c~materialpriceunitqty,
                c~inventoryprice,
                c~inventoryprice AS zpricelivre,
                c~inventoryprice AS zpricetrans,
                c~inventoryprice AS zpricerestri,
                c~inventoryprice AS zpricebloq,
                c~inventoryprice AS zpricedevol,
                ' '              AS sobkz,
                '          '     AS kunnr,
                '          '     AS lifnr

        FROM mard AS m
        INNER JOIN i_materialtext AS t ON  t~material  = m~matnr
                                       AND t~language  = @sy-langu
        INNER JOIN i_material AS mat   ON  mat~material = m~matnr
        INNER JOIN i_currentmatlpricebycostest AS c ON  c~material      = m~matnr
                                                    AND c~valuationarea = m~werks
        WHERE   m~matnr     IN @ir_matnr
        AND     m~werks     IN @ir_werks
* LSCHEPP - Ajustes GAP 058 - 15.08.2022 Início
        AND     m~lgort           IN @ir_lgort
        AND     mat~materialtype  IN @ir_mtart
        AND     mat~materialgroup IN @ir_matkl
* LSCHEPP - Ajustes GAP 058 - 15.08.2022 Fim
        AND    (   m~labst     <> 0
            OR     m~umlme     <> 0
            OR     m~insme     <> 0
            OR     m~speme     <> 0
            OR     m~retme     <> 0
            OR     m~einme     <> 0 )

        INTO TABLE @DATA(lt_list).

        SELECT m~matnr,
                       m~werks,
                       '    ' AS lgort,
                       SUM( m~kulab ) AS labst,
                       t~materialname,
                       mat~materialbaseunit,
                       c~materialpriceunitqty,
                       c~inventoryprice,
                       c~inventoryprice AS zpricelivre,
                       c~inventoryprice AS zpricetrans,
                       c~inventoryprice AS zpricerestri,
                       c~inventoryprice AS zpricebloq,
                       c~inventoryprice AS zpricedevol,
                      m~sobkz              AS sobkz,
                      m~kunnr    AS kunnr,
                      '         '     AS lifnr
                  FROM msku AS m
                INNER JOIN i_materialtext AS t ON  t~material  = m~matnr
                                               AND t~language  = @sy-langu
                INNER JOIN i_material AS mat   ON  mat~material = m~matnr
                INNER JOIN i_currentmatlpricebycostest AS c ON  c~material      = m~matnr
                                                            AND c~valuationarea = m~werks
                WHERE   m~matnr     IN @ir_matnr
                AND     m~werks     IN @ir_werks
                AND     mat~materialtype  IN @ir_mtart
                AND     mat~materialgroup IN @ir_matkl
                  GROUP BY m~matnr,
                       m~werks,
                       m~sobkz,
                       t~materialname,
                       mat~materialbaseunit,
                       c~materialpriceunitqty,
                       c~inventoryprice,
                       m~kunnr
                APPENDING CORRESPONDING FIELDS OF TABLE @lt_list.


        SELECT m~matnr,
               m~werks,
               '    '  AS lgort,
               SUM( m~sllab )  AS labst,
               t~materialname,
               mat~materialbaseunit,
               c~materialpriceunitqty,
               c~inventoryprice,
               c~inventoryprice AS zpricelivre,
               c~inventoryprice AS zpricetrans,
               c~inventoryprice AS zpricerestri,
               c~inventoryprice AS zpricebloq,
               c~inventoryprice AS zpricedevol,
                      m~sobkz              AS sobkz,
                      '          '     AS kunnr,
                      m~lifnr     AS lifnr
          FROM mssl AS m
        INNER JOIN i_materialtext AS t ON  t~material  = m~matnr
                                       AND t~language  = @sy-langu
        INNER JOIN i_material AS mat   ON  mat~material = m~matnr
        INNER JOIN i_currentmatlpricebycostest AS c ON  c~material      = m~matnr
                                                    AND c~valuationarea = m~werks
        WHERE   m~matnr     IN @ir_matnr
        AND     m~werks     IN @ir_werks
        AND     mat~materialtype  IN @ir_mtart
        AND     mat~materialgroup IN @ir_matkl
          GROUP BY m~matnr,
               m~werks,
               m~sobkz,
               t~materialname,
               mat~materialbaseunit,
               c~materialpriceunitqty,
               c~inventoryprice,
               m~lifnr
        APPENDING CORRESPONDING FIELDS OF TABLE @lt_list.

        IF lt_list IS NOT INITIAL.

          SORT lt_list BY matnr werks lgort.
*          DELETE ADJACENT DUPLICATES FROM lt_list COMPARING matnr werks lgort.

          LOOP AT lt_list ASSIGNING FIELD-SYMBOL(<fs_list>).

            IF <fs_list>-materialpriceunitqty > 0.
* LSCHEPP - Ajuste GAP 261 - 12.04.2022 Início
*              <fs_list>-zpricelivre     = ( <fs_list>-inventoryprice / <fs_list>-materialpriceunitqty ) * <fs_list>-labst.
              DATA(lv_zpricelivre) = CONV ptr_two_dec( ( <fs_list>-inventoryprice / <fs_list>-materialpriceunitqty ) * <fs_list>-labst ).
* LSCHEPP - Ajuste GAP 261 - 12.04.2022 Fim
              <fs_list>-zpricetrans     = ( <fs_list>-inventoryprice / <fs_list>-materialpriceunitqty ) * <fs_list>-umlme.
              <fs_list>-zpricerestri    = ( <fs_list>-inventoryprice / <fs_list>-materialpriceunitqty ) * <fs_list>-einme.
              <fs_list>-zpricebloq      = ( <fs_list>-inventoryprice / <fs_list>-materialpriceunitqty ) * <fs_list>-speme.
              <fs_list>-zpricedevol     = ( <fs_list>-inventoryprice / <fs_list>-materialpriceunitqty ) * <fs_list>-retme.
            ENDIF.

            ls_estoque-mt_estoque_saldo-lines-einme              = <fs_list>-einme.
            ls_estoque-mt_estoque_saldo-lines-insme              = <fs_list>-insme.
            ls_estoque-mt_estoque_saldo-lines-labst              = <fs_list>-labst.
            ls_estoque-mt_estoque_saldo-lines-lgort              = <fs_list>-lgort.
* BCOSTA - Ajuste GAP 261 - 29.12.2022 Início
            IF ls_estoque-mt_estoque_saldo-lines-lgort IS INITIAL.
              ls_estoque-mt_estoque_saldo-lines-lgort = '0'.
            ENDIF.
* BCOSTA - Ajuste GAP 261 - 29.12.2022 Fim
            ls_estoque-mt_estoque_saldo-lines-material_base_unit = <fs_list>-materialbaseunit.
            ls_estoque-mt_estoque_saldo-lines-material_name      = <fs_list>-materialname.
            ls_estoque-mt_estoque_saldo-lines-matnr              = <fs_list>-matnr.
            ls_estoque-mt_estoque_saldo-lines-retme              = <fs_list>-retme.
            ls_estoque-mt_estoque_saldo-lines-speme              = <fs_list>-speme.
            ls_estoque-mt_estoque_saldo-lines-umlme              = <fs_list>-umlme.
            ls_estoque-mt_estoque_saldo-lines-werks              = <fs_list>-werks.
            ls_estoque-mt_estoque_saldo-lines-zprice_bloq        = <fs_list>-zpricebloq.
            ls_estoque-mt_estoque_saldo-lines-zprice_devol       = <fs_list>-zpricedevol.
* LSCHEPP - Ajuste GAP 261 - 12.04.2022 Início
*            ls_estoque-mt_estoque_saldo-lines-zprice_livre       = <fs_list>-zpricelivre.
            ls_estoque-mt_estoque_saldo-lines-zprice_livre       = lv_zpricelivre.
* LSCHEPP - Ajuste GAP 261 - 12.04.2022 Fim
            ls_estoque-mt_estoque_saldo-lines-zprice_restri      = <fs_list>-zpricerestri.
            ls_estoque-mt_estoque_saldo-lines-zprice_trans       = <fs_list>-zpricetrans.
            ls_estoque-mt_estoque_saldo-lines-kunnr       = <fs_list>-kunnr.
            ls_estoque-mt_estoque_saldo-lines-lifnr       = <fs_list>-lifnr.
            ls_estoque-mt_estoque_saldo-lines-sobkz       = <fs_list>-sobkz.
*
**          ENDLOOP.
*
*            lt_estoque-mt_estoque_saldo-lines  = CORRESPONDING  #( lt_list MAPPING
*                                                                      einme               = einme
*                                                                      insme               = insme
*                                                                      labst               = labst
*                                                                      lgort               = lgort
*                                                                      material_base_unit  = materialbaseunit
*                                                                      material_name       = materialname
*                                                                      matnr               = matnr
*                                                                      retme               = retme
*                                                                      speme               = speme
*                                                                      umlme               = umlme
*                                                                      werks               = werks
*                                                                      zprice_bloq         = zpricebloq
*                                                                      zprice_devol        = zpricedevol
*                                                                      zprice_livre        = zpricelivre
*                                                                      zprice_restri       = zpricerestri
*                                                                      zprice_trans        = zpricetrans
*                                                          ).

            DATA(lo_estoque_out) = NEW zclpp_co_si_enviar_estoque_sal( ).

*            lo_estoque_out->si_enviar_estoque_saldo_out( output = lt_estoque ).
            lo_estoque_out->si_enviar_estoque_saldo_out( output = ls_estoque ).

            COMMIT WORK.

            CLEAR: ls_estoque.

          ENDLOOP.

        ENDIF.

      CATCH zcxmm_erro_interface_mes.
        me->erro_raise( is_ret = VALUE #(  msgid = gc_erros-classe attr1 = gc_erros-envio  msgno = '000' ) ).
      CATCH cx_ai_system_fault.
        me->erro_raise( is_ret = VALUE #(  msgid = gc_erros-classe attr1 = gc_erros-envio  msgno = '000' ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
