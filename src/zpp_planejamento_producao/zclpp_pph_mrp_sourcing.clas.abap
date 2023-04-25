CLASS zclpp_pph_mrp_sourcing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_pph_mrp_sourcing_badi .
    INTERFACES if_amdp_marker_hdb .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclpp_pph_mrp_sourcing IMPLEMENTATION.


  METHOD if_pph_mrp_sourcing_badi~sos_det_adjust
       BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
       OPTIONS READ-ONLY.

    ct_newlot_sos_f = SELECT :ct_newlot_sos_f.the_index,
                             :ct_newlot_sos_f.beskz,
                             :ct_newlot_sos_f.sobes,
                             :ct_newlot_sos_f.lgort,
                             :ct_newlot_sos_f.webaz,
                             :ct_newlot_sos_f.werks_from,
                             :ct_newlot_sos_f.reslo,
                             :ct_newlot_sos_f.qunum,
                             :ct_newlot_sos_f.qupos,
                             :ct_newlot_sos_f.lifnr,
                             :ct_newlot_sos_f.verid,
                             :ct_newlot_sos_f.plifz,
                             :ct_newlot_sos_f.zeord,
                             :ct_newlot_sos_f.ebeln,
                             :ct_newlot_sos_f.ebelp,
                             :ct_newlot_sos_f.infnr,
                             :ct_newlot_sos_f.ematn,
                             :ct_newlot_sos_f.ekorg,
                             :ct_newlot_sos_f.ekgrp,
                             :ct_newlot_sos_f.matkl,
                             :ct_newlot_sos_f.vrtyp,
                             :ct_newlot_sos_f.autet,

                        CASE WHEN :ct_newlot_sos_f.delkz = 'PA'
                             THEN :ct_newlot_sos_f.delkz
                             ELSE 'PA'
                        END AS delkz,

                             :ct_newlot_sos_f.srm_contract_id,
                             :ct_newlot_sos_f.srm_contract_itm,
                             :ct_newlot_sos_f.sgt_rcat,
                             :ct_newlot_sos_f.sgt_scat
                        FROM :ct_newlot_sos_f;

  ENDMETHOD.
ENDCLASS.
