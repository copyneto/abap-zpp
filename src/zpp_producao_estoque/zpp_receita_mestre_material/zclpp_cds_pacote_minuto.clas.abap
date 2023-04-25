CLASS zclpp_cds_pacote_minuto DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS zclpp_cds_pacote_minuto IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    APPEND 'VALOR02' TO et_requested_orig_elements.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA lt_original_data TYPE STANDARD TABLE OF zi_pp_receita_mestre WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF <fs_data>-Valor02 IS NOT INITIAL.

        <fs_data>-PacotesPorMinuto = <fs_data>-Quantidade / <fs_data>-Valor02.

      ENDIF.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).

  ENDMETHOD.

ENDCLASS.
