"!<p>Classe para envio do IDoc LOIPRO01 para o sistema MES.
"!Esta classe é utilizada sempre ao gravar a ordem de produção</p>
"!<p><strong>Autor:</strong> Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong> 2 de ago de 2021</p>
CLASS zclpp_ordem_prod_outbound DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      "!Status de ordem para envio ao sistema MES
      gc_status_ordem TYPE sttxt VALUE 'LIB',
      "!Status de usuário inválido para envio ao sistema MES
      gc_status_user  TYPE asttx VALUE 'MES'.

    DATA:
      "!Indicador de falta de configuração na tabela de parâmetros
      gv_falta_config TYPE abap_bool VALUE abap_false READ-ONLY,
      "!Indicador de erro ao enviar interface
      gv_erro_envio   TYPE abap_bool VALUE abap_false READ-ONLY.

    METHODS:
      "!Ler configuração da tabela de parâmetros
      get_config,

      "!Verificar se é necessário o envio do IDoc para o sistema MES
      "!@parameter is_header |Cabeçalho da ordem de produção
      "! @parameter rv_result |Resultado da verificação (<strong>ABAP_TRUE</strong> significa que interface deve ser ativada)
      verificar_envio IMPORTING is_header        TYPE cobai_s_header
                      RETURNING VALUE(rv_result) TYPE abap_bool,

      "!Enviar IDoc com as informações da ordem de produção ao sistema MES
      "!@parameter it_header |Cabeçalho da ordem de produção
      "! @parameter it_operation |Tabela com as operações de uma ordem de produção
      "! @parameter it_component |Tabela com as reservas de materiais para a ordem
      enviar_idoc IMPORTING it_header    TYPE cobai_t_header
                            it_operation TYPE cobai_t_operation
                            it_component TYPE cobai_t_component,

      "!Atualizar o user status da ordem através de qRFC
      "!@parameter it_header |Cabeçalho da ordem de produção
      "! @parameter iv_status |Novo status de usuário a ser inserido na ordem de produção
      atualizar_user_status IMPORTING it_header TYPE cobai_t_header
                                      iv_status TYPE asttx.

  PRIVATE SECTION.

    DATA:
      "!Centro correspondente à ordem de produção
      gr_werks TYPE RANGE OF werks_d,
      "!Tipo de ordem de produção
      gr_auart TYPE RANGE OF auart,
      "!Tipo de material para ordem de produção
      gr_mtart TYPE RANGE OF mtart.
ENDCLASS.



CLASS ZCLPP_ORDEM_PROD_OUTBOUND IMPLEMENTATION.


  METHOD get_config.

    "Obter as configurações de envio do IDoc
    DATA(lo_config) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_config->m_get_range(
          EXPORTING
            iv_modulo = 'PP'
            iv_chave1 = 'IF_SAP_MES'
            iv_chave2 = 'WERKS'
          IMPORTING
            et_range  = gr_werks ).

        lo_config->m_get_range(
          EXPORTING
            iv_modulo = 'PP'
            iv_chave1 = 'IF_SAP_MES'
            iv_chave2 = 'AUART'
          IMPORTING
            et_range  = gr_auart ).

        lo_config->m_get_range(
          EXPORTING
            iv_modulo = 'PP'
            iv_chave1 = 'IF_SAP_MES'
            iv_chave2 = 'MTART'
            IMPORTING
            et_range  = gr_mtart ).

      CATCH zcxca_tabela_parametros.
        gv_falta_config = abap_true.
    ENDTRY.
  ENDMETHOD.


  METHOD verificar_envio.

    rv_result = abap_false.

    SELECT SINGLE material,
                  materialtype
        INTO @DATA(ls_material)
        FROM i_material
        WHERE material = @is_header-plnbez.
    IF sy-subrc = 0.

      IF sy-ucomm EQ space.
        "Verificar se é necessário o envio do IDoc para o sistema MES
        IF is_header-asttx          NS gc_status_user  AND
           is_header-werks          IN gr_werks        AND
           is_header-auart          IN gr_auart        AND
           ls_material-materialtype NOT IN gr_mtart.

          "Enviar o IDoc através de função bgRFC para aguardar atualização do BD
          rv_result = abap_true.
        ENDIF.
      ELSEIF sy-ucomm EQ 'BU' OR sy-ucomm EQ 'YES'.
        "Verificar se é necessário o envio do IDoc para o sistema MES
        IF is_header-sttxt          CS gc_status_ordem AND
           is_header-asttx          NS gc_status_user  AND
           is_header-werks          IN gr_werks        AND
           is_header-auart          IN gr_auart        AND
           ls_material-materialtype NOT IN gr_mtart.

          "Enviar o IDoc através de função bgRFC para aguardar atualização do BD
          rv_result = abap_true.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD atualizar_user_status.

    IF line_exists( it_header[ 1 ] ).

      DATA(ls_header) = it_header[ 1 ].

      "Selecionar status equivalente (Código interno)
      SELECT estat FROM tj30t
          INTO @DATA(lv_status)
          UP TO 1 ROWS
          WHERE stsma = @ls_header-stats AND
                txt04 = @iv_status.
      ENDSELECT.
      IF sy-subrc = 0.
        "Chamar função para atualizar o status do usuário via bgRFC
        CALL FUNCTION 'ZFMPP_ATUALIZAR_USER_STATUS'
          IN BACKGROUND TASK AS SEPARATE UNIT
          EXPORTING
            iv_object = ls_header-objnr
            iv_status = lv_status.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD enviar_idoc.

    DATA: lt_order_data TYPE cloi_afko_tab,
          lv_logsys     TYPE tbdlst-logsys.

    "Determinar sistema lógico de destino
    lv_logsys = COND #( WHEN sy-sysid CS 'D' THEN 'PID'
                        WHEN sy-sysid CS 'Q' THEN 'PIQ'
                        WHEN sy-sysid CS 'P' THEN 'PIP' ).

    "Preparar dados para envio
    IF line_exists( it_header[ 1 ] )    AND
       line_exists( it_component[ 1 ] ) AND
       line_exists( it_operation[ 1 ] ).

      "Cabeçalho da ordem
      APPEND INITIAL LINE TO lt_order_data ASSIGNING FIELD-SYMBOL(<fs_idoc_header>).
      <fs_idoc_header> = CORRESPONDING #( it_header[ 1 ] MAPPING matnr_external = matnr ).

      APPEND INITIAL LINE TO <fs_idoc_header>-t_affl ASSIGNING FIELD-SYMBOL(<fs_affl>).
      <fs_affl> = CORRESPONDING #( it_operation[ 1 ] ).

      "Preencher operações
      <fs_affl>-t_afvo = CORRESPONDING #( it_operation ).

      "Preencher reservas
      IF lines( <fs_affl>-t_afvo ) > 0.
        <fs_affl>-t_afvo[ 1 ]-t_resb = CORRESPONDING #( it_component MAPPING matnr_external = matnr ).
      ENDIF.

      "Enviar interface (IDoc)
      CALL FUNCTION 'CLOI_MASTERIDOC_CREATE_LOIPRO'
        EXPORTING
          opt_sys      = lv_logsys
          message_type = 'LOIPRO'
          no_commit    = 'X'
        TABLES
          order_data   = lt_order_data.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
