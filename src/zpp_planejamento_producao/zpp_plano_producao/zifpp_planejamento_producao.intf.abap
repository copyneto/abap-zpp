"!<p><h2>Métodos necessários à criação de ordens de produção. Utilizada na realização da carga de arquivos do SOP</h2></p>
"!<p><strong>Autor:</strong> Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong> 23 de ago de 2021</p>
INTERFACE zifpp_planejamento_producao
  PUBLIC.

  CLASS-METHODS:
    "! Utilizar para receber a instância da classe correta para tratar o arquivo
    "! @parameter ro_result | Instância da classe para tratar o retorno do arquivo
    get_instance RETURNING VALUE(ro_result) TYPE REF TO zifpp_planejamento_producao.

  METHODS:
    "! Preencher a estrutura de dados a partir do objeto de dados de entrada
    "! @parameter iv_file_id | Id do arquivo para execução de carga
    "! @parameter et_messages | Mensagens de processamento
    setup_data IMPORTING iv_file_id  TYPE guid
               EXPORTING et_messages TYPE bapiret2_t,

    "! Realizar a carga dos registros através da BAPI correspondente
    "! @parameter et_messages | Mensagens retornadas do processamento
    process EXPORTING et_messages TYPE bapiret2_t.
ENDINTERFACE.
