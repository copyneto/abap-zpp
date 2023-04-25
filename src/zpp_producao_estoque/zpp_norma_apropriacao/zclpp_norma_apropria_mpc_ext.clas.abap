class ZCLPP_NORMA_APROPRIA_MPC_EXT definition
  public
  inheriting from ZCLPP_NORMA_APROPRIA_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCLPP_NORMA_APROPRIA_MPC_EXT IMPLEMENTATION.


  method DEFINE.
    ##NO_TEXT
    CONSTANTS:
    lc_entity_name   TYPE /iwbep/med_external_name value 'excel',
    lc_property_name type /iwbep/med_external_name value 'FileName'.

    super->define( ).

    DATA:
      lo_entity   TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
      lo_property TYPE REF TO /iwbep/if_mgw_odata_property.

    lo_entity = model->get_entity_type( iv_entity_name = lc_entity_name ).

    IF lo_entity IS BOUND.
      lo_property = lo_entity->get_property( iv_property_name = lc_property_name ).
      lo_property->set_as_content_type( ).
    ENDIF.

  endmethod.
ENDCLASS.
