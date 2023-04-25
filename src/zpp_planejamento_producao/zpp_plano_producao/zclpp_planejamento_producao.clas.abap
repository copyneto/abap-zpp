"!<p><h1>Execução do planejamento de produção</h1></p>
"!<p><strong>Autor:</strong> Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong> 23 de ago de 2021</p>
CLASS zclpp_planejamento_producao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS:
      "! Carregar arquivo utilizando STARTING NEW TASK
      "! @parameter iv_filetype | Tipo do arquivo:<ul><li><strong>C</strong> - Curto prazo</li></ul><ul><li><strong>M</strong> - Médio prazo</li></ul>
      "! @parameter iv_file_id | Guid do arquivo a set processado
      carregar_arquivo IMPORTING iv_filetype TYPE ze_producao_filetype
                                 iv_file_id  TYPE guid,

      "! Ler as mensagens geradas pelo processamento
      "! @parameter p_task |Noma da task executada
      setup_messages IMPORTING p_task TYPE clike,

      "! Retorna as mensagens geradas durante o processamento
      "! @parameter et_messages | Lista de mensagens
      get_messages EXPORTING et_messages TYPE bapiret2_t,


      download_arquivo IMPORTING iv_id       TYPE any
                       EXPORTING ev_filename TYPE string
                                 ev_file     TYPE xstring
                                 ev_mimetype TYPE mimetypes-type
                                 et_return   TYPE bapiret2_t.

    METHODS:
      "! Preparar os dados recebidos do arquivo para processamento
      "! @parameter iv_filetype | Tipo do arquivo:<ul><li><strong>C</strong> - Curto prazo</li></ul><ul><li><strong>M</strong> - Médio prazo</li></ul>
      "! @parameter iv_file_id | Guid do arquivo a set processado
      setup_data IMPORTING iv_filetype TYPE ze_producao_filetype
                           iv_file_id  TYPE guid,

      "! Realizar a carga do arquivo através das BAPIs
      processar_arquivo.

  PRIVATE SECTION.

    CLASS-DATA:
      "!Armazenamento das mensagens de processamento
      gt_messages       TYPE STANDARD TABLE OF bapiret2,

      "!Instância da classe utilizada para processar o arquivo de entrada
      go_carga_producao TYPE REF TO zifpp_planejamento_producao,

      "!Flag para sincronizar o processamento da função de criação de ordens de produção
      gv_wait_async     TYPE abap_bool.
ENDCLASS.



CLASS zclpp_planejamento_producao IMPLEMENTATION.

  METHOD get_messages.

    et_messages = gt_messages.
  ENDMETHOD.


  METHOD setup_data.
    go_carga_producao = COND #( WHEN iv_filetype = 'C' THEN zclpp_plan_curto_prazo=>get_instance( )
                                WHEN iv_filetype = 'M' THEN zclpp_plan_medio_prazo=>get_instance( ) ).

    go_carga_producao->setup_data(
      EXPORTING
        iv_file_id     = iv_file_id
      IMPORTING
        et_messages = gt_messages ).
  ENDMETHOD.


  METHOD processar_arquivo.

    go_carga_producao->process(
      IMPORTING
        et_messages = gt_messages ).
  ENDMETHOD.


  METHOD carregar_arquivo.

    REFRESH gt_messages.
    gv_wait_async = abap_false.

    CALL FUNCTION 'ZFMPP_CARGA_ORDEM_PRODUCAO'
      STARTING NEW TASK 'OP_LOAD'
      CALLING setup_messages ON END OF TASK
      EXPORTING
        iv_filetype = iv_filetype
        iv_file_id  = iv_file_id.

    WAIT UNTIL gv_wait_async = abap_true.
  ENDMETHOD.


  METHOD setup_messages.

    RECEIVE RESULTS FROM FUNCTION 'ZFMPP_CARGA_ORDEM_PRODUCAO'
          IMPORTING
            et_messages = gt_messages.

    gv_wait_async = abap_true.
  ENDMETHOD.

  METHOD download_arquivo.

  TYPES:
   BEGIN OF ty_teste,
     campo1 TYPE string,
     campo2 TYPE char200,
     campo3 TYPE char100,
   END OF ty_teste,

   ty_t_teste TYPE STANDARD TABLE OF ty_teste.

    DATA: lt_curto     TYPE zctgpp_layout_arq_curto_prazo,
*    DATA: lt_curto     TYPE ty_t_teste,
          lt_medio     TYPE zctgpp_layout_arq_medio_prazo,
          lv_extension TYPE char100.

    FREE: ev_filename, ev_file, ev_mimetype, et_return.

    DATA(lv_id) = cl_soap_wsrmb_helper=>convert_uuid_hyphened_to_raw( iv_id ).

* ----------------------------------------------------------------------
* Recupera dados
* ----------------------------------------------------------------------
    SELECT SINGLE *
      FROM ztpp_arq_prod
      INTO @DATA(ls_arquivo)
      WHERE id = @lv_id. "#EC CI_ALL_FIELDS_NEEDED

    IF sy-subrc NE 0.
      FREE ls_arquivo.
    ENDIF.

    ev_filename = ls_arquivo-name.

    SELECT *
      FROM ztpp_prod_curto
      INTO CORRESPONDING FIELDS OF TABLE @lt_curto
      WHERE id = @lv_id.

    IF sy-subrc NE 0.
      FREE lt_curto.
    ENDIF.

    SELECT *
      FROM ztpp_prod_medio
      INTO CORRESPONDING FIELDS OF TABLE @lt_medio
      WHERE id = @lv_id.

    IF sy-subrc NE 0.
      FREE lt_medio.
    ENDIF.

* ----------------------------------------------------------------------
* Criar arquivo excel
* ----------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = ev_filename ).

    IF lt_curto[] IS NOT INITIAL.
      lo_excel->create_document( EXPORTING it_table  = lt_curto
                                 IMPORTING ev_file   = ev_file
                                           et_return = et_return ).
    ENDIF.

    IF lt_medio[] IS NOT INITIAL.
      lo_excel->create_document( EXPORTING it_table  = lt_medio
                                 IMPORTING ev_file   = ev_file
                                           et_return = et_return ).
    ENDIF.

* ----------------------------------------------------------------------
* Retorna nome do arquivo
* ----------------------------------------------------------------------
    SPLIT ev_filename AT '.' INTO DATA(lv_name) lv_extension.

    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = lv_extension
      IMPORTING
        mimetype  = ev_mimetype.

  ENDMETHOD.

ENDCLASS.
