class ZCLPP_IM_WORKBREAKDOWN_UPDATE definition
  public
  final
  create public .

public section.

  interfaces IF_EX_WORKBREAKDOWN_UPDATE .
protected section.
private section.
ENDCLASS.



CLASS ZCLPP_IM_WORKBREAKDOWN_UPDATE IMPLEMENTATION.


  METHOD if_ex_workbreakdown_update~at_save.

    TYPES:
      BEGIN OF ty_rng_prctr,
        sign(1),
        option(2),
        low       TYPE prctr,
        high      TYPE  prctr,
      END OF ty_rng_prctr,
      BEGIN OF ty_rng_pgsbr,
        sign(1),
        option(2),
        low       TYPE ps_pgsbr,
        high      TYPE ps_pgsbr,
      END OF ty_rng_pgsbr.

    DATA: lt_rng_prctr TYPE TABLE OF ty_rng_prctr,
          lt_rng_pgsbr TYPE TABLE OF ty_rng_pgsbr.

    CHECK it_wbs_element IS NOT INITIAL.

    DATA(ls_wbs_element) = it_wbs_element[ 1 ].

    CHECK ls_wbs_element-poski(3) = 'CPX' OR ls_wbs_element-poski(3) = 'GER'.

    IF ls_wbs_element-prctr IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_wbs_element-prctr high = ls_wbs_element-prctr ) TO lt_rng_prctr.
    ENDIF.

    IF ls_wbs_element-pgsbr IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_wbs_element-pgsbr high = ls_wbs_element-pgsbr ) TO lt_rng_pgsbr.
    ENDIF.


    SELECT SINGLE kokrs, kostl
      FROM csks
      WHERE kokrs = @ls_wbs_element-fkokr
        AND kostl = @ls_wbs_element-fkstl
        AND bukrs = @ls_wbs_element-pbukr
        AND prctr IN @lt_rng_prctr
        AND gsber IN @lt_rng_pgsbr
      INTO @DATA(ls_csks).

*    CHECK ls_csks IS INITIAL.
    IF sy-subrc <> 0.
      MESSAGE e001(zps1) RAISING error_with_message.
      EXIT.
    ENDIF.
    SELECT SINGLE werks, gsber
      FROM t134g
      INTO @DATA(lv_t134g)
      WHERE werks = @ls_wbs_element-werks
        AND gsber = @ls_wbs_element-pgsbr.

    IF sy-subrc <> 0.
      MESSAGE e004(zps1) RAISING error_with_message.
    ENDIF.

  ENDMETHOD.


  method IF_EX_WORKBREAKDOWN_UPDATE~BEFORE_UPDATE.
     return.
  endmethod.
ENDCLASS.
