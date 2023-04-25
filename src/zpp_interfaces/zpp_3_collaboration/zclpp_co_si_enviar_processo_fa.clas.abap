class ZCLPP_CO_SI_ENVIAR_PROCESSO_FA definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods SI_ENVIAR_PROCESSO_FABRICACAO
    importing
      !OUTPUT type ZCLPP_MT_PROCESSO_FABRICACAO
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZCLPP_CO_SI_ENVIAR_PROCESSO_FA IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZCLPP_CO_SI_ENVIAR_PROCESSO_FA'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method SI_ENVIAR_PROCESSO_FABRICACAO.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'OUTPUT' kind = '0' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'SI_ENVIAR_PROCESSO_FABRICACAO'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
