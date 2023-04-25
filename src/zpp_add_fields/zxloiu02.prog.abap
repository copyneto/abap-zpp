*&---------------------------------------------------------------------*
*& Include          ZXLOIU02
*&---------------------------------------------------------------------*

CONSTANTS: lc_segnam     TYPE edilsegtyp VALUE 'E1AFKOL',
           lc_segnam_new TYPE edilsegtyp VALUE 'ZSMM_E1AFKOL'.

DATA: lv_weight TYPE char15.

IF idoc_data[ 1 ]-segnam EQ lc_segnam AND NOT line_exists( idoc_data[ segnam = lc_segnam_new ] ). "#EC CI_STDSEQ

  SELECT SINGLE MaterialNetWeight, MaterialName FROM I_Material AS i
    INNER JOIN  I_MaterialText AS t
    ON i~material = t~material
    INTO @DATA(ls_material)
    WHERE i~material EQ @f_afko-matnr_external.

  IF sy-subrc EQ 0.

    UNPACK ls_material-materialnetweight TO lv_weight.

    APPEND VALUE #( segnam = lc_segnam_new sdata = lv_weight && ls_material-materialname  ) TO  idoc_data.

  ENDIF.

ENDIF.
