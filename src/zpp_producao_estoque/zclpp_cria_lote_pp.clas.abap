"!<p>Essa classe é utilizada como implementação da BADI WORKORDER_GOODSMVT
"!<p><strong>Autor:</strong> Anderson Macedo - Meta</p>
"!<p><strong>Data:</strong> 30/07/2021</p>
CLASS zclpp_cria_lote_pp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_ex_workorder_goodsmvt .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclpp_cria_lote_pp IMPLEMENTATION.


  METHOD if_ex_workorder_goodsmvt~backflush.
    RETURN.
  ENDMETHOD.


  METHOD if_ex_workorder_goodsmvt~cogi_authority_check.
    RETURN.
  ENDMETHOD.


  METHOD if_ex_workorder_goodsmvt~cogi_post.
    RETURN.
  ENDMETHOD.


  METHOD if_ex_workorder_goodsmvt~complete_goodsmovement.
    RETURN.
  ENDMETHOD.


  METHOD if_ex_workorder_goodsmvt~gm_screen_line_check.
    RETURN.
  ENDMETHOD.


  METHOD if_ex_workorder_goodsmvt~gm_screen_okcode_check.
    RETURN.
  ENDMETHOD.


  METHOD if_ex_workorder_goodsmvt~gm_wipbatch_check.
    RETURN.
  ENDMETHOD.


  METHOD if_ex_workorder_goodsmvt~gm_wipbatch_propose.
    RETURN.
  ENDMETHOD.


  METHOD if_ex_workorder_goodsmvt~goods_receipt.

    CONSTANTS: lc_first TYPE char4 VALUE '0101',
               lc_time  TYPE uzeit VALUE '010000'.

    DATA: lv_first   TYPE sy-datum,
          lv_juliano TYPE i.

    DATA(lt_comp) = ct_goods_receipt.
    SORT lt_comp BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_comp COMPARING matnr.

    lv_first = sy-datum(4) && lc_first.

    IF lt_comp IS NOT INITIAL.

      SELECT
        material,
        isbatchmanagementrequired
        FROM i_material
        INTO TABLE @DATA(lt_mat)
        FOR ALL ENTRIES IN @lt_comp
        WHERE material = @lt_comp-matnr.

    ENDIF.

    LOOP AT ct_goods_receipt ASSIGNING FIELD-SYMBOL(<fs_comp>).

      READ TABLE lt_mat ASSIGNING FIELD-SYMBOL(<fs_mat>) WITH KEY material = <fs_comp>-matnr
                                                         BINARY SEARCH.

      IF <fs_mat> IS ASSIGNED.

        IF <fs_mat>-isbatchmanagementrequired EQ abap_true.

          IF <fs_comp>-hsdat IS INITIAL.
            <fs_comp>-hsdat = sy-datum.
          ENDIF.

***          CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
***            EXPORTING
***              date1            = lv_first
***              time1            = lc_time
***              date2            = <fs_comp>-hsdat
***              time2            = lc_time
***            IMPORTING
***              datediff         = lv_juliano
***            EXCEPTIONS
***              invalid_datetime = 1
***              OTHERS           = 2.
***
***          IF sy-subrc = 0.
***
***            <fs_comp>-charg = <fs_comp>-werks && <fs_comp>-hsdat+2(2) && lv_juliano.
***
***          ENDIF.

*          CALL FUNCTION 'HR_ES_CALC_YRS_MTHS_DAYS'
*            EXPORTING
*              beg_da        = lv_first
*              end_da        = <fs_comp>-hsdat
*            IMPORTING
*              no_day        = lv_juliano
*            EXCEPTIONS
*              dateint_error = 1
*              OTHERS        = 2.
*          IF sy-subrc EQ 0.
*            <fs_comp>-charg = <fs_comp>-werks && <fs_comp>-hsdat+2(2) && lv_juliano.
*          ENDIF.

          <fs_comp>-charg = <fs_comp>-aufnr+2(10).

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD if_ex_workorder_goodsmvt~im_called.
    RETURN.
  ENDMETHOD.


  METHOD if_ex_workorder_goodsmvt~manual_goods_receipt.
    RETURN.
  ENDMETHOD.


  METHOD if_ex_workorder_goodsmvt~picklist.
    RETURN.
  ENDMETHOD.
ENDCLASS.
