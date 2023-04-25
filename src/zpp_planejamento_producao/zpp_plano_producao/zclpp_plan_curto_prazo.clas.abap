"!<p><h2>Efetua a criação de ordens de produção de curto prazo</h2></p>
"!<p><strong>Autor:</strong> Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong> 26 de ago de 2021</p>
CLASS zclpp_plan_curto_prazo DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    INTERFACES:
      zifpp_planejamento_producao,
      if_amdp_marker_hdb.

    ALIASES: get_instance FOR zifpp_planejamento_producao~get_instance,
             setup_data   FOR zifpp_planejamento_producao~setup_data,
             processar    FOR zifpp_planejamento_producao~process.

    TYPES:
      "! Tipo de tabela para a lista de componentes na criação da ordem de produção
      ty_components TYPE STANDARD TABLE OF bapi_pldordcomp_e1.

  PRIVATE SECTION.
    CLASS-DATA:
      "! Instância da classe de carga de curto prazo
      go_instance TYPE REF TO zclpp_plan_curto_prazo.

    DATA:
      "! Dados do arquivo a serem processados
      gt_dados TYPE zctgpp_layout_arq_curto_prazo.

    METHODS:
      "! Realizar a criação da ordem de produção a partir dos dados lidos do arquivo Excel/Tabela BD
      "! @parameter is_dados_ordem | Dados para a criação da ordem de produção
      "! @parameter iv_profile | Perfil da ordem de produção
      "! @parameter ct_mensagens | Mensagens com o resultado da execução da BAPI
      criar_ordem IMPORTING is_dados_ordem TYPE bapiplaf_i1
                            iv_profile     TYPE pasch
                  CHANGING  ct_mensagens   TYPE bapiret2_t,

      "! Verificar quais componentes devem ter ordens de produção criados
      "! @parameter ct_components | Lista com os componentes
      verificar_componentes CHANGING ct_components TYPE ty_components,


      "! Stored procedure para realizar a filtragem dos registros de semi-acabados
      "! @parameter it_components | Lista de componentes necessários na ordem de produção
      "! @parameter et_semi_acabados | Lista de semi-acabados a serem produzidos para atender a ordem
      amdp_obter_semi_acabados IMPORTING VALUE(it_components)    TYPE ty_components
                               EXPORTING VALUE(et_semi_acabados) TYPE ty_components.
ENDCLASS.



CLASS zclpp_plan_curto_prazo IMPLEMENTATION.

  METHOD get_instance.

    IF go_instance IS NOT BOUND.
      go_instance = NEW zclpp_plan_curto_prazo( ).
    ENDIF.

    ro_result = go_instance.
  ENDMETHOD.


  METHOD setup_data.

    SELECT FROM zi_pp_arq_prod_curto_prazo
       FIELDS pldordprofile, material, planplant, prodplant, totalplordqty,
              orderstartdate, firmingind, unit, Version
       WHERE id = @iv_file_id
       ORDER BY line
       INTO TABLE @gt_dados.

    IF lines( gt_dados ) = 0.
      MESSAGE e002(zpp_plano_producao) INTO DATA(lv_message).
      et_messages = VALUE #( ( id = 'ZPP_PLANO_PRODUCAO' type = 'E' number = '002' message = lv_message ) ).
    ENDIF.
  ENDMETHOD.


  METHOD processar.

    DATA lv_material TYPE matnr18.

    "Preparar dados para o formato da BAPI
    LOOP AT gt_dados ASSIGNING FIELD-SYMBOL(<fs_ordem>).
      lv_material = |{ <fs_ordem>-material ALPHA = IN }|.
      DATA(ls_ordem_producao) = VALUE bapiplaf_i1( pldord_profile   = <fs_ordem>-pldord_profile
                                                   material         = lv_material
                                                   plan_plant       = <fs_ordem>-plan_plant
                                                   prod_plant       = <fs_ordem>-prod_plant
                                                   total_plord_qty  = <fs_ordem>-total_plord_qty
                                                   order_start_date = <fs_ordem>-order_start_date
                                                   firming_ind      = <fs_ordem>-firming_ind
                                                   version          = <fs_ordem>-version ).

      "Executar Criação das ordens de produção
      me->criar_ordem( EXPORTING is_dados_ordem = ls_ordem_producao
                                 iv_profile     = <fs_ordem>-pldord_profile
                       CHANGING  ct_mensagens   = et_messages ).
    ENDLOOP.
  ENDMETHOD.


  METHOD criar_ordem.

    DATA: ls_return     TYPE bapireturn1,
          lt_components TYPE ty_components.

    "Execução da BAPI
    CALL FUNCTION 'BAPI_PLANNEDORDER_CREATE'
      EXPORTING
        headerdata            = is_dados_ordem
      IMPORTING
        return                = ls_return
      TABLES
        createdcomponentsdata = lt_components.

    "Coletar as mensagens
    IF ls_return IS NOT INITIAL.
      ct_mensagens = VALUE #( BASE ct_mensagens ( CORRESPONDING #( ls_return ) ) ).
    ENDIF.

    IF ls_return-type = 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      RETURN.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ENDIF.

    "Verificar nos componentes quais devem ter ordens criadas
    me->verificar_componentes( CHANGING ct_components = lt_components ).

    "Criar ordens para sub-componentes
    LOOP AT lt_components ASSIGNING FIELD-SYMBOL(<fs_component>).
      DATA(ls_ordem_producao) = VALUE bapiplaf_i1( pldord_profile  = iv_profile
                                                   material        = <fs_component>-material
                                                   plan_plant      = <fs_component>-plant
                                                   prod_plant      = <fs_component>-plant
                                                   total_plord_qty = <fs_component>-req_quan
                                                   order_fin_date  = <fs_component>-req_date
                                                   firming_ind     = abap_true ).
      "Executar Criação das ordens de produção
      me->criar_ordem( EXPORTING is_dados_ordem = ls_ordem_producao
                                 iv_profile     = iv_profile
                       CHANGING  ct_mensagens   = ct_mensagens ).
    ENDLOOP.
  ENDMETHOD.


  METHOD verificar_componentes.

    "Obter lista de materiais semi acabados
    me->amdp_obter_semi_acabados(
      EXPORTING
        it_components    = ct_components
      IMPORTING
        et_semi_acabados = ct_components ).
  ENDMETHOD.


  METHOD amdp_obter_semi_acabados BY DATABASE PROCEDURE FOR HDB
                                  LANGUAGE SQLSCRIPT USING mara mast mkal mapl.

    et_semi_acabados = select distinct a.*  from :it_components as a
                            inner join mara as b on b.matnr = a.material
                            inner join mast as c on c.matnr = a.material and
                                                    c.werks = a.plant
                            inner join mkal as d on d.matnr = a.material and
                                                    d.werks = a.plant
                            inner join mapl as e on e.matnr = a.material and
                                                    e.werks = a.plant
                            where b.mandt = SESSION_CONTEXT('CLIENT')          and
                                  b.mtart = 'HALB'                             and
                                  c.mandt = SESSION_CONTEXT('CLIENT')          and
                                  c.stlan = '1'                                and
                                  d.mandt = SESSION_CONTEXT('CLIENT')          and
                                  d.bdatu > SESSION_CONTEXT('SAP_SYSTEM_DATE') and
                                  e.mandt = SESSION_CONTEXT('CLIENT')          and
                                  e.plnty = '2';
  ENDMETHOD.
ENDCLASS.
