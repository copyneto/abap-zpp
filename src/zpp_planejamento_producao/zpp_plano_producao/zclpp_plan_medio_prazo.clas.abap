"!<p><h1>Efetua carga de necessidades de médio prazo</h1></p>
"!<p><strong>Autor:</strong> Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong> 26 de ago de 2021</p>
CLASS zclpp_plan_medio_prazo DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    INTERFACES zifpp_planejamento_producao.

    ALIASES: get_instance FOR zifpp_planejamento_producao~get_instance,
             setup_data   FOR zifpp_planejamento_producao~setup_data,
             processar    FOR zifpp_planejamento_producao~process.

  PRIVATE SECTION.
    CLASS-DATA:
      "! Instância da classe de carga de médio prazo
      go_instance TYPE REF TO zclpp_plan_medio_prazo.

    METHODS:
      "! Preencher as estruturas/tabelas utilizadas pela BAPI
      "! @parameter is_excel | Registro de dados de entrada, lidos da tabela do Excel
      "! @parameter es_item_struct | Estrutura de ítens da BAPI
      "! @parameter et_sched_table | Tabela com o planejamento das datas de produção
      fill_structure IMPORTING is_excel       TYPE zspp_layout_arq_medio_prazo
                     EXPORTING es_item_struct TYPE bapisitemr
                               et_sched_table TYPE fsh_bapisshdin_t,

      "! Execução da BAPI para criação de necessidades
      "! @parameter is_item_struct | Estrutura de ítens da BAPI
      "! @parameter it_sched_table | Tabela com o planejamento das datas de produção
      "! @parameter et_messages | Retorno de mensagens geradas pela BAPI
      criar_necessidade IMPORTING is_item_struct TYPE bapisitemr
                                  it_sched_table TYPE fsh_bapisshdin_t
                        EXPORTING et_messages    TYPE bapiret2_t.

    DATA:
      "! Dados do arquivo a serem processados
      gt_dados    TYPE zctgpp_layout_arq_medio_prazo,

      "! Chave de material de cabeçalho
      gv_material TYPE matnr18,

      "! Chave de planta de produção
      gv_planta   TYPE werks_d,

      "! Chave de versão de produção
      gv_versao   TYPE versb.
ENDCLASS.



CLASS zclpp_plan_medio_prazo IMPLEMENTATION.

  METHOD get_instance.

    IF go_instance IS NOT BOUND.
      go_instance = NEW zclpp_plan_medio_prazo( ).
    ENDIF.

    ro_result = go_instance.
  ENDMETHOD.


  METHOD setup_data.

    SELECT FROM zi_pp_arq_prod_medio_prazo
       FIELDS material, plant, version, versactiv, datetype, reqdate,
              reqqty, unit, bomexpl, prodves
       WHERE id = @iv_file_id
       ORDER BY material, plant, version,  line
       INTO TABLE @gt_dados.

    IF lines( gt_dados ) = 0.
      MESSAGE e002(zpp_plano_producao) INTO DATA(lv_message).
      et_messages = VALUE #( ( id = 'ZPP_PLANO_PRODUCAO' type = 'E' number = '002' message = lv_message ) ).
    ENDIF.
  ENDMETHOD.


  METHOD processar.

    LOOP AT gt_dados ASSIGNING FIELD-SYMBOL(<fs_necessidade>).

      "Preparar dados para a BAPI
      me->fill_structure(
        EXPORTING
          is_excel       = <fs_necessidade>
        IMPORTING
          es_item_struct = DATA(ls_bapi_item)
          et_sched_table = DATA(lt_schedules) ).

      "Criar ou alterar necessidade
      me->criar_necessidade(
        EXPORTING
          is_item_struct = ls_bapi_item
          it_sched_table = lt_schedules
        IMPORTING
          et_messages    = DATA(lt_messages) ).

      "Atualizar mensagens de retorno
      et_messages = VALUE #( BASE et_messages FOR ls_message IN lt_messages ( CORRESPONDING #( ls_message ) ) ).
    ENDLOOP.
  ENDMETHOD.


  METHOD fill_structure.

    DATA lv_material TYPE matnr18.

    lv_material = |{ is_excel-material ALPHA = IN }|.

    IF gv_material <> lv_material     OR
       gv_planta   <> is_excel-plant  OR
       gv_versao   <> is_excel-version.

      REFRESH et_sched_table.
      gv_material = lv_material.
      gv_planta   = is_excel-plant.
      gv_versao   = is_excel-version.
    ENDIF.

    MOVE-CORRESPONDING is_excel TO es_item_struct.
    es_item_struct-material = lv_material.
    APPEND INITIAL LINE TO et_sched_table ASSIGNING FIELD-SYMBOL(<fs_schedule>).
    MOVE-CORRESPONDING is_excel TO <fs_schedule>.
    <fs_schedule>-date_type = COND #( WHEN <fs_schedule>-date_type = 'D' THEN '1'
                                      WHEN <fs_schedule>-date_type = 'W' THEN '2'
                                      WHEN <fs_schedule>-date_type = 'M' THEN '3'
                                      ELSE '3' ).
  ENDMETHOD.


  METHOD criar_necessidade.

    DATA lt_return TYPE STANDARD TABLE OF bapireturn1.

    "Realizar a criação da necessidade
    CALL FUNCTION 'BAPI_REQUIREMENTS_CREATE'
      EXPORTING
        requirements_item        = is_item_struct
        do_commit                = abap_false
      TABLES
        requirements_schedule_in = it_sched_table
        return                   = lt_return.

    "Verificar se a necessidade já existe
    IF line_exists( lt_return[ id = '6P' number = '011' ] ). "#EC CI_STDSEQ
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      "Em caso afirmativo, executar a alteração da necessidade
      REFRESH lt_return.
      CALL FUNCTION 'BAPI_REQUIREMENTS_CHANGE'
        EXPORTING
          material                 = is_item_struct-material
          plant                    = is_item_struct-plant
          requirementstype         = is_item_struct-requ_type
          version                  = is_item_struct-version
          reqmtsplannumber         = is_item_struct-req_number
          vers_activ               = is_item_struct-vers_activ
          do_commit                = abap_false
          delete_old               = 'X'
        TABLES
          requirements_schedule_in = it_sched_table
          return                   = lt_return.
    ENDIF.

    et_messages = CORRESPONDING #( lt_return ).
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
  ENDMETHOD.
ENDCLASS.
