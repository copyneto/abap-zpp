***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: PP - Carga receita mestre                              *
*** AUTOR    : Luís Gustavo Schepp - META                             *
*** FUNCIONAL: Antonio Lopes da Silva Neto - META                     *
*** DATA     : 04.04.2022                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 01.04.2022 | Luís Gustavo Schepp   | Desenvolvimento inicial      *
***********************************************************************
REPORT zppc_carga_receita_mestre1.

************************************************************************
* Declarações
************************************************************************

*-Tipos-----------------------------------------------------------*
TYPES: BEGIN OF ty_header,
         mat_num(18)    TYPE c,
         plant(4)       TYPE c,
         prod_versn(4)  TYPE c,
         profile(7)     TYPE c,
         valid_fr(10)   TYPE c,
         status(3)      TYPE c,
         usage(3)       TYPE c,
         base_qty(7)    TYPE c,
         base_uom(3)    TYPE c,
         old_mat_ref(1) TYPE c,
       END OF ty_header,

       BEGIN OF ty_item,
         mat_num(18)       TYPE c,
         plant(4)          TYPE c,
         prod_versn(4)     TYPE c,
         op_ctr(4)         TYPE c,
         phase_ind(1)      TYPE c,
         sup_op(4)         TYPE c,
         ctrl_recp_dest(2) TYPE c,
         resource(8)       TYPE c,
         ctrl_key(4)       TYPE c,
         op_desc(40)       TYPE c,
         base_qty(17)      TYPE c,
         base_uom(3)       TYPE c,
         durn_qty_1(11)    TYPE c,
         durn_uom_1(3)     TYPE c,
         activity_1(6)     TYPE c,
         durn_qty_2(11)    TYPE c,
         durn_uom_2(3)     TYPE c,
         activity_2(6)     TYPE c,
         durn_qty_3(11)    TYPE c,
         durn_uom_3(3)     TYPE c,
         activity_3(6)     TYPE c,
         durn_qty_4(11)    TYPE c,
         durn_uom_4(3)     TYPE c,
         activity_4(6)     TYPE c,
         durn_qty_5(11)    TYPE c,
         durn_uom_5(3)     TYPE c,
         activity_5(6)     TYPE c,
       END OF ty_item,

       BEGIN OF ty_log,
         registro(10),
         tipo_msg(1),
         msg(100),
       END OF ty_log.

*-Tabelas internas------------------------------------------------------*
DATA: gt_bdc    TYPE tab_bdcdata,
      gt_msg    TYPE tab_bdcmsgcoll,
      gt_header TYPE TABLE OF ty_header,
      gt_item   TYPE TABLE OF ty_item,
      gt_log    TYPE TABLE OF ty_log.

*-Estruturas------------------------------------------------------*
DATA gs_options TYPE ctu_params.

*-Constantes------------------------------------------------------*
CONSTANTS gc_c201 TYPE tcode VALUE 'C201'.

*-----------------------------------------------------------------------*
* Classe do Report
*-----------------------------------------------------------------------*
CLASS lcl_report DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS:
      busca_arquivo CHANGING cv_arquivo TYPE string,
      executar,
      mostra_log.

  PRIVATE SECTION.

    CLASS-METHODS:
      carrega_dados,
      processa_dados,
      bdc_dynpro IMPORTING iv_program  TYPE bdc_prog
                           iv_dynpro   TYPE bdc_dynr
                           iv_dynbegin TYPE bdc_start OPTIONAL,
      bdc_fieldvalue IMPORTING iv_fnam TYPE fnam_____4
                               iv_fval TYPE bdc_fval.

ENDCLASS.

*-Screen parameters----------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_cabec TYPE string OBLIGATORY,
              p_item  TYPE string OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS p_mode TYPE ctu_params-dismode DEFAULT 'N'.
SELECTION-SCREEN END OF BLOCK b2.

*----------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_cabec.
  lcl_report=>busca_arquivo(
                   CHANGING
                    cv_arquivo = p_cabec ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_item.
  lcl_report=>busca_arquivo(
                   CHANGING
                    cv_arquivo = p_item ).
*----------------------------------------------------------------------*
*START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  lcl_report=>executar( ).

*-----------------------------------------------------------------------*
* Classe do report
*-----------------------------------------------------------------------*
CLASS lcl_report IMPLEMENTATION.

  METHOD busca_arquivo.

    DATA lt_file_table TYPE filetable.

    DATA lv_rc TYPE i.

    cl_gui_frontend_services=>file_open_dialog(
      EXPORTING
        file_filter             = CONV #( TEXT-t01 ) "'Pasta de Trabalho do Excel (*.xlsx, *.XLSX)|*.XLSX|'
        window_title            = CONV #( TEXT-t02 ) "'Selecione um arquivo'
      CHANGING
        file_table              = lt_file_table
        rc                      = lv_rc
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5 ).
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      TRY.
          cv_arquivo = lt_file_table[ 1 ]-filename.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDIF.

  ENDMETHOD.

  METHOD executar.

    carrega_dados( ).

    processa_dados( ).

    mostra_log( ).

  ENDMETHOD.

  METHOD carrega_dados.

    FIELD-SYMBOLS: <fs_datat> TYPE STANDARD TABLE,
                   <fs_field> TYPE any.

    DATA lt_records TYPE solix_tab.

    DATA: lv_filename      TYPE string,
          lv_headerxstring TYPE xstring,
          lv_filelength    TYPE i.


    IF NOT p_cabec IS INITIAL.

      lv_filename = p_cabec.

      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          filename                = lv_filename
          filetype                = 'BIN'
        IMPORTING
          filelength              = lv_filelength
          header                  = lv_headerxstring
        TABLES
          data_tab                = lt_records
        EXCEPTIONS
          file_open_error         = 1
          file_read_error         = 2
          no_batch                = 3
          gui_refuse_filetransfer = 4
          invalid_type            = 5
          no_authority            = 6
          unknown_error           = 7
          bad_data_format         = 8
          header_not_allowed      = 9
          separator_not_allowed   = 10
          header_too_long         = 11
          unknown_dp_error        = 12
          access_denied           = 13
          dp_out_of_memory        = 14
          disk_full               = 15
          dp_timeout              = 16
          OTHERS                  = 17.
      IF sy-subrc NE 0.
        MESSAGE TEXT-e01 TYPE 'S' DISPLAY LIKE 'E'.
      ELSE.

        CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
          EXPORTING
            input_length = lv_filelength
          IMPORTING
            buffer       = lv_headerxstring
          TABLES
            binary_tab   = lt_records
          EXCEPTIONS
            failed       = 1
            OTHERS       = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        TRY.
            DATA(lo_excel_ref) = NEW cl_fdt_xl_spreadsheet( document_name = lv_filename
                                                            xdocument     = lv_headerxstring ) .
          CATCH cx_fdt_excel_core INTO DATA(lv_error).
            DATA(lv_message) = lv_error->get_text( ).
            MESSAGE lv_message TYPE 'S' DISPLAY LIKE 'E'.
        ENDTRY.

        lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
                                                       IMPORTING
                                                         worksheet_names = DATA(lt_worksheets) ).

        TRY.
            DATA(ls_worksheets) = lt_worksheets[ 1 ].
            DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet( ls_worksheets ).
            ASSIGN lo_data_ref->* TO <fs_datat>.

            LOOP AT <fs_datat> ASSIGNING FIELD-SYMBOL(<fs_data>).
              IF sy-tabix > 1.
                DO 10 TIMES.
                  ASSIGN COMPONENT sy-index OF STRUCTURE <fs_data> TO <fs_field> .
                  IF <fs_field> IS ASSIGNED.
                    CASE sy-index .
                      WHEN 1.
                        APPEND INITIAL LINE TO gt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
                        <fs_header>-mat_num = |{ CONV matnr18( <fs_field> ) ALPHA = IN }|.
                      WHEN 2.
                        <fs_header>-plant = <fs_field>.
                      WHEN 3.
                        <fs_header>-prod_versn = <fs_field>.
                      WHEN 4.
                        <fs_header>-profile = <fs_field>.
                      WHEN 5.
                        <fs_header>-valid_fr = |{ <fs_field>+8(2) }.{ <fs_field>+5(2) }.{ <fs_field>(4) }|.
                      WHEN 6.
                        <fs_header>-status = <fs_field>.
                      WHEN 7.
                        <fs_header>-usage = <fs_field>.
                      WHEN 8.
                        <fs_header>-base_qty = <fs_field>.
                      WHEN 9.
                        <fs_header>-base_uom = <fs_field>.
                      WHEN 10.
                        <fs_header>-old_mat_ref = <fs_field>.
                    ENDCASE .
                    UNASSIGN <fs_field>.
                  ENDIF.
                ENDDO.
              ENDIF.
              UNASSIGN <fs_header>.
            ENDLOOP.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.
      ENDIF.
    ENDIF.

    IF NOT p_item IS INITIAL.

      CLEAR: lv_filename,
             lv_filelength,
             lv_headerxstring.

      REFRESH lt_records.

      lv_filename = p_item.

      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          filename                = lv_filename
          filetype                = 'BIN'
        IMPORTING
          filelength              = lv_filelength
          header                  = lv_headerxstring
        TABLES
          data_tab                = lt_records
        EXCEPTIONS
          file_open_error         = 1
          file_read_error         = 2
          no_batch                = 3
          gui_refuse_filetransfer = 4
          invalid_type            = 5
          no_authority            = 6
          unknown_error           = 7
          bad_data_format         = 8
          header_not_allowed      = 9
          separator_not_allowed   = 10
          header_too_long         = 11
          unknown_dp_error        = 12
          access_denied           = 13
          dp_out_of_memory        = 14
          disk_full               = 15
          dp_timeout              = 16
          OTHERS                  = 17.
      IF sy-subrc NE 0.
        MESSAGE TEXT-e01 TYPE 'S' DISPLAY LIKE 'E'.
      ELSE.

        CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
          EXPORTING
            input_length = lv_filelength
          IMPORTING
            buffer       = lv_headerxstring
          TABLES
            binary_tab   = lt_records
          EXCEPTIONS
            failed       = 1
            OTHERS       = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        TRY.
            DATA(lo_excel_ref1) = NEW cl_fdt_xl_spreadsheet( document_name = lv_filename
                                                             xdocument     = lv_headerxstring ) .
          CATCH cx_fdt_excel_core INTO DATA(lv_error1).
            DATA(lv_message1) = lv_error1->get_text( ).
            MESSAGE lv_message1 TYPE 'S' DISPLAY LIKE 'E'.
        ENDTRY.

        lo_excel_ref1->if_fdt_doc_spreadsheet~get_worksheet_names(
                                                       IMPORTING
                                                         worksheet_names = DATA(lt_worksheets1) ).

        TRY.
            UNASSIGN: <fs_datat>,
                      <fs_data>.
            DATA(ls_worksheets1) = lt_worksheets1[ 1 ].
            DATA(lo_data_ref1) = lo_excel_ref1->if_fdt_doc_spreadsheet~get_itab_from_worksheet( ls_worksheets1 ).
            ASSIGN lo_data_ref1->* TO <fs_datat>.

            LOOP AT <fs_datat> ASSIGNING <fs_data>.
              IF sy-tabix > 1.
                DO 27 TIMES.
                  ASSIGN COMPONENT sy-index OF STRUCTURE <fs_data> TO <fs_field> .
                  IF <fs_field> IS ASSIGNED.
                    CASE sy-index .
                      WHEN 1.
                        APPEND INITIAL LINE TO gt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
                        <fs_item>-mat_num = |{ CONV matnr18( <fs_field> ) ALPHA = IN }|.
                      WHEN 2.
                        <fs_item>-plant = <fs_field>.
                      WHEN 3.
                        <fs_item>-prod_versn = <fs_field>.
                      WHEN 4.
                        <fs_item>-op_ctr = <fs_field>.
                      WHEN 5.
                        <fs_item>-phase_ind = <fs_field>.
                      WHEN 6.
                        <fs_item>-sup_op = <fs_field>.
                      WHEN 7.
                        <fs_item>-ctrl_recp_dest = <fs_field>.
                      WHEN 8.
                        <fs_item>-resource = <fs_field>.
                      WHEN 9.
                        <fs_item>-ctrl_key = <fs_field>.
                      WHEN 10.
                        <fs_item>-op_desc = <fs_field>.
                      WHEN 11.
                        <fs_item>-base_qty = <fs_field>.
                      WHEN 12.
                        <fs_item>-base_uom = <fs_field>.
                      WHEN 13.
                        <fs_item>-durn_qty_1 = <fs_field>.
                      WHEN 14.
                        <fs_item>-durn_uom_1 = <fs_field>.
                      WHEN 15.
                        <fs_item>-activity_1 = <fs_field>.
                      WHEN 16.
                        <fs_item>-durn_qty_2 = <fs_field>.
                      WHEN 17.
                        <fs_item>-durn_uom_2 = <fs_field>.
                      WHEN 18.
                        <fs_item>-activity_2 = <fs_field>.
                      WHEN 19.
                        <fs_item>-durn_qty_3 = <fs_field>.
                      WHEN 20.
                        <fs_item>-durn_uom_3 = <fs_field>.
                      WHEN 21.
                        <fs_item>-activity_3 = <fs_field>.
                      WHEN 22.
                        <fs_item>-durn_qty_4 = <fs_field>.
                      WHEN 23.
                        <fs_item>-durn_uom_4 = <fs_field>.
                      WHEN 24.
                        <fs_item>-activity_4 = <fs_field>.
                      WHEN 25.
                        <fs_item>-durn_qty_5 = <fs_field>.
                      WHEN 26.
                        <fs_item>-durn_uom_5 = <fs_field>.
                      WHEN 27.
                        <fs_item>-activity_5 = <fs_field>.
                    ENDCASE .
                    UNASSIGN <fs_field>.
                  ENDIF.
                ENDDO.
              ENDIF.
              UNASSIGN <fs_item>.
            ENDLOOP.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD processa_dados.

    DATA: lv_message TYPE char200,
          lv_tot_lin TYPE char02.


    gs_options-dismode = p_mode.
    gs_options-updmode = 'S'.

    SORT gt_header BY mat_num plant prod_versn.
    SORT gt_item BY mat_num plant prod_versn op_ctr.

    LOOP AT gt_header ASSIGNING FIELD-SYMBOL(<fs_header>).

      REFRESH: gt_bdc,
               gt_msg.

      DATA(lv_tabix_header) = sy-tabix.

      bdc_dynpro( EXPORTING iv_program = 'SAPLCPDI'                        iv_dynpro = '4000'  iv_dynbegin = abap_true ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_CURSOR'                     iv_fval = 'RC27M-VERID' ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_OKCODE'                     iv_fval = '/00' ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'RC27M-MATNR'                    iv_fval = CONV #( <fs_header>-mat_num ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'RC27M-WERKS'                    iv_fval = CONV #( <fs_header>-plant ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'RC27M-VERID'                    iv_fval = CONV #( <fs_header>-prod_versn ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'RC271-PLNNR'                    iv_fval = space ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'RC271-PLNAL'                    iv_fval = '2' ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'RC271-PROFIDNETZ'               iv_fval = CONV #( <fs_header>-profile ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'RC271-STTAG'                    iv_fval = CONV #( <fs_header>-valid_fr ) ).

      bdc_dynpro( EXPORTING iv_program = 'SAPLCPDA'                        iv_dynpro = '4210'  iv_dynbegin = abap_true ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_CURSOR'                     iv_fval = 'PLKOD-BMSCH' ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_OKCODE'                     iv_fval = '/00' ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLKOD-WERKS'                    iv_fval = CONV #( <fs_header>-plant ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLKOD-PLNAL'                    iv_fval = '2').
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLKOD-VERWE'                    iv_fval = CONV #( <fs_header>-usage ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLKOD-STATU'                    iv_fval = CONV #( <fs_header>-status ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLKOD-BMSCH'                    iv_fval = CONV #( <fs_header>-base_qty ) ).
      IF NOT <fs_header>-base_uom IS INITIAL.
        bdc_fieldvalue( EXPORTING iv_fnam = 'PLKOD-PLNME'                  iv_fval = CONV #( <fs_header>-base_uom ) ).
      ENDIF.
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_SUBSCR'                     iv_fval = 'SAPLCPDA                                4215CHANGE_RULE' ).

      bdc_dynpro( EXPORTING iv_program = 'SAPLCPDA'                        iv_dynpro = '4210'  iv_dynbegin = abap_true ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_CURSOR'                     iv_fval = 'PLKOD-WERKS' ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_OKCODE'                     iv_fval = '=VOUE' ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLKOD-WERKS'                    iv_fval = CONV #( <fs_header>-plant ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLKOD-PLNAL'                    iv_fval = '2').
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLKOD-VERWE'                    iv_fval = CONV #( <fs_header>-usage ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLKOD-STATU'                    iv_fval = CONV #( <fs_header>-status ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLKOD-BMSCH'                    iv_fval = CONV #( <fs_header>-base_qty ) ).
      IF NOT <fs_header>-base_uom IS INITIAL.
        bdc_fieldvalue( EXPORTING iv_fnam = 'PLKOD-PLNME'                  iv_fval = CONV #( <fs_header>-base_uom ) ).
      ENDIF.
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_SUBSCR'                     iv_fval = 'SAPLCPDA                                4215CHANGE_RULE' ).

      DATA(lt_item) = gt_item.
      DELETE lt_item WHERE mat_num NE <fs_header>-mat_num.
      DELETE lt_item WHERE plant NE <fs_header>-plant.
      DELETE lt_item WHERE prod_versn NE <fs_header>-prod_versn.
      DESCRIBE TABLE lt_item LINES lv_tot_lin.
      IF lv_tot_lin < 10.
        lv_tot_lin = |0{ lv_tot_lin }|.
      ENDIF.

      bdc_dynpro( EXPORTING iv_program = 'SAPLCPDI'                        iv_dynpro = '4400'  iv_dynbegin = abap_true ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_CURSOR'                     iv_fval = |PLPOD-LTXA1({ lv_tot_lin })| ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_OKCODE'                     iv_fval = '=ENT1' ).


      LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>).

        IF sy-tabix < 10.
          DATA(lv_tabix) = |0{ sy-tabix }|.
        ELSE.
          lv_tabix = sy-tabix.
        ENDIF.

        bdc_fieldvalue( EXPORTING iv_fnam = |PLPOD-LTXA1({ lv_tabix })|     iv_fval = CONV #( <fs_item>-op_desc ) ).

        IF lv_tabix EQ lv_tot_lin.
          bdc_fieldvalue( EXPORTING iv_fnam = |PLPOD-PHFLG({ lv_tabix })|   iv_fval = CONV #( <fs_item>-phase_ind ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = |PLPOD-PVZNR({ lv_tabix })|   iv_fval = CONV #( <fs_item>-sup_op ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = |PLPOD-PHSEQ({ lv_tabix })|   iv_fval = CONV #( <fs_item>-ctrl_recp_dest ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = |PLPOD-STEUS({ lv_tot_lin })| iv_fval = CONV #( <fs_item>-ctrl_key ) ).

          bdc_dynpro( EXPORTING iv_program = 'SAPLCPDO'                     iv_dynpro = '4410'  iv_dynbegin = abap_true ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_CURSOR'                  iv_fval = 'PLPOD-VORNR'  ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_OKCODE'                  iv_fval = '=BACK' ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VORNR'                 iv_fval = CONV #( <fs_item>-op_ctr ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-STEUS'                 iv_fval = CONV #( <fs_item>-ctrl_key ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-CKSELKZ'               iv_fval = CONV #( <fs_item>-phase_ind ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-LTXA1'                 iv_fval = CONV #( <fs_item>-op_desc ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-BMSCH'                 iv_fval = CONV #( <fs_item>-base_qty ) ).
          IF NOT <fs_item>-base_uom IS INITIAL.
            bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-MEINH'               iv_fval = CONV #( <fs_item>-base_uom ) ).
          ENDIF.
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW01'                 iv_fval = CONV #( <fs_item>-durn_qty_1 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE01'                 iv_fval = CONV #( <fs_item>-durn_uom_1 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW02'                 iv_fval = CONV #( <fs_item>-durn_qty_2 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE02'                 iv_fval = CONV #( <fs_item>-durn_uom_2 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW03'                 iv_fval = CONV #( <fs_item>-durn_qty_3 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE03'                 iv_fval = CONV #( <fs_item>-durn_uom_3 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW04'                 iv_fval = CONV #( <fs_item>-durn_qty_4 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE04'                 iv_fval = CONV #( <fs_item>-durn_uom_4 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW05'                 iv_fval = CONV #( <fs_item>-durn_qty_5 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE05'                 iv_fval = CONV #( <fs_item>-durn_uom_5 ) ).

          DATA(ls_last_item) = <fs_item>.
          EXIT.
        ENDIF.

        IF lv_tabix MOD 2 EQ 0.
          bdc_fieldvalue( EXPORTING iv_fnam = |PLPOD-PHFLG({ lv_tabix })|   iv_fval = CONV #( <fs_item>-phase_ind ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = |PLPOD-PVZNR({ lv_tabix })|   iv_fval = CONV #( <fs_item>-sup_op ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = |PLPOD-PHSEQ({ lv_tabix })|   iv_fval = CONV #( <fs_item>-ctrl_recp_dest ) ).
        ELSE.
          bdc_fieldvalue( EXPORTING iv_fnam = |PLPOD-ARBPL({ lv_tabix })|   iv_fval = CONV #( <fs_item>-resource ) ).
        ENDIF.

      ENDLOOP.

      LOOP AT lt_item ASSIGNING <fs_item>.

        IF sy-tabix MOD 2 EQ 0.

          IF sy-tabix < 10.
            lv_tabix = |0{ sy-tabix }|.
          ELSE.
            lv_tabix = sy-tabix.
          ENDIF.

          bdc_dynpro( EXPORTING iv_program = 'SAPLCPDI'                     iv_dynpro = '4400'  iv_dynbegin = abap_true ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_CURSOR'                  iv_fval = |PLPOD-VORNR({ lv_tabix })| ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_OKCODE'                  iv_fval = '=PICK' ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'RC27X-ENTRY_ACT'             iv_fval = '1' ).

          bdc_dynpro( EXPORTING iv_program = 'SAPLCPDO'                     iv_dynpro = '4410'  iv_dynbegin = abap_true ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_CURSOR'                  iv_fval = 'PLPOD-VGW05'  ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_OKCODE'                  iv_fval = '/00' ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VORNR'                 iv_fval = CONV #( <fs_item>-op_ctr ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-STEUS'                 iv_fval = CONV #( <fs_item>-ctrl_key ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-CKSELKZ'               iv_fval = CONV #( <fs_item>-phase_ind ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-LTXA1'                 iv_fval = CONV #( <fs_item>-op_desc ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-BMSCH'                 iv_fval = CONV #( <fs_item>-base_qty ) ).
          IF NOT <fs_item>-base_uom IS INITIAL.
            bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-MEINH'               iv_fval = CONV #( <fs_item>-base_uom ) ).
          ENDIF.
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW01'                 iv_fval = CONV #( <fs_item>-durn_qty_1 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE01'                 iv_fval = CONV #( <fs_item>-durn_uom_1 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW02'                 iv_fval = CONV #( <fs_item>-durn_qty_2 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE02'                 iv_fval = CONV #( <fs_item>-durn_uom_2 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW03'                 iv_fval = CONV #( <fs_item>-durn_qty_3 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE03'                 iv_fval = CONV #( <fs_item>-durn_uom_3 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW04'                 iv_fval = CONV #( <fs_item>-durn_qty_4 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE04'                 iv_fval = CONV #( <fs_item>-durn_uom_4 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW05'                 iv_fval = CONV #( <fs_item>-durn_qty_5 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE05'                 iv_fval = CONV #( <fs_item>-durn_uom_5 ) ).

          bdc_dynpro( EXPORTING iv_program = 'SAPLCPDO'                     iv_dynpro = '4410'  iv_dynbegin = abap_true ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_CURSOR'                  iv_fval = 'PLPOD-VORNR'  ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_OKCODE'                  iv_fval = '/00' ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VORNR'                 iv_fval = CONV #( <fs_item>-op_ctr ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-STEUS'                 iv_fval = CONV #( <fs_item>-ctrl_key ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-CKSELKZ'               iv_fval = CONV #( <fs_item>-phase_ind ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-LTXA1'                 iv_fval = CONV #( <fs_item>-op_desc ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-BMSCH'                 iv_fval = CONV #( <fs_item>-base_qty ) ).
          IF NOT <fs_item>-base_uom IS INITIAL.
            bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-MEINH'               iv_fval = CONV #( <fs_item>-base_uom ) ).
          ENDIF.
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW01'                 iv_fval = CONV #( <fs_item>-durn_qty_1 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE01'                 iv_fval = CONV #( <fs_item>-durn_uom_1 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW02'                 iv_fval = CONV #( <fs_item>-durn_qty_2 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE02'                 iv_fval = CONV #( <fs_item>-durn_uom_2 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW03'                 iv_fval = CONV #( <fs_item>-durn_qty_3 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE03'                 iv_fval = CONV #( <fs_item>-durn_uom_3 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW04'                 iv_fval = CONV #( <fs_item>-durn_qty_4 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE04'                 iv_fval = CONV #( <fs_item>-durn_uom_4 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW05'                 iv_fval = CONV #( <fs_item>-durn_qty_5 ) ).
          bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE05'                 iv_fval = CONV #( <fs_item>-durn_uom_5 ) ).
        ENDIF.
      ENDLOOP.

      bdc_dynpro( EXPORTING iv_program = 'SAPLCPDI'                         iv_dynpro = '4400'  iv_dynbegin = abap_true ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_CURSOR'                      iv_fval = |PLPOD-VORNR({ lv_tot_lin })| ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_OKCODE'                      iv_fval = '=PICK' ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'RC27X-ENTRY_ACT'                 iv_fval = '1' ).

      bdc_dynpro( EXPORTING iv_program = 'SAPLCPDO'                         iv_dynpro = '4410'  iv_dynbegin = abap_true ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_CURSOR'                      iv_fval = 'PLPOD-VGW05'  ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_OKCODE'                      iv_fval = '/00' ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VORNR'                     iv_fval = CONV #( ls_last_item-op_ctr ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-STEUS'                     iv_fval = CONV #( ls_last_item-ctrl_key ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-CKSELKZ'                   iv_fval = CONV #( ls_last_item-phase_ind ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-LTXA1'                     iv_fval = CONV #( ls_last_item-op_desc ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-BMSCH'                     iv_fval = CONV #( ls_last_item-base_qty ) ).
      IF NOT <fs_item>-base_uom IS INITIAL.
        bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-MEINH'                   iv_fval = CONV #( ls_last_item-base_uom ) ).
      ENDIF.
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW01'                     iv_fval = CONV #( ls_last_item-durn_qty_1 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE01'                     iv_fval = CONV #( ls_last_item-durn_uom_1 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW02'                     iv_fval = CONV #( ls_last_item-durn_qty_2 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE02'                     iv_fval = CONV #( ls_last_item-durn_uom_2 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW03'                     iv_fval = CONV #( ls_last_item-durn_qty_3 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE03'                     iv_fval = CONV #( ls_last_item-durn_uom_3 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW04'                     iv_fval = CONV #( ls_last_item-durn_qty_4 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE04'                     iv_fval = CONV #( ls_last_item-durn_uom_4 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW05'                     iv_fval = CONV #( ls_last_item-durn_qty_5 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE05'                     iv_fval = CONV #( ls_last_item-durn_uom_5 ) ).

      bdc_dynpro( EXPORTING iv_program = 'SAPLCPDO'                         iv_dynpro = '4410'  iv_dynbegin = abap_true ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_CURSOR'                      iv_fval = 'PLPOD-VORNR'  ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'BDC_OKCODE'                      iv_fval = '=BU' ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VORNR'                     iv_fval = CONV #( ls_last_item-op_ctr ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-STEUS'                     iv_fval = CONV #( ls_last_item-ctrl_key ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-CKSELKZ'                   iv_fval = CONV #( ls_last_item-phase_ind ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-LTXA1'                     iv_fval = CONV #( ls_last_item-op_desc ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-BMSCH'                     iv_fval = CONV #( ls_last_item-base_qty ) ).
      IF NOT <fs_item>-base_uom IS INITIAL.
        bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-MEINH'                   iv_fval = CONV #( ls_last_item-base_uom ) ).
      ENDIF.
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW01'                     iv_fval = CONV #( ls_last_item-durn_qty_1 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE01'                     iv_fval = CONV #( ls_last_item-durn_uom_1 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW02'                     iv_fval = CONV #( ls_last_item-durn_qty_2 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE02'                     iv_fval = CONV #( ls_last_item-durn_uom_2 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW03'                     iv_fval = CONV #( ls_last_item-durn_qty_3 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE03'                     iv_fval = CONV #( ls_last_item-durn_uom_3 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW04'                     iv_fval = CONV #( ls_last_item-durn_qty_4 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE04'                     iv_fval = CONV #( ls_last_item-durn_uom_4 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGW05'                     iv_fval = CONV #( ls_last_item-durn_qty_5 ) ).
      bdc_fieldvalue( EXPORTING iv_fnam = 'PLPOD-VGE05'                     iv_fval = CONV #( ls_last_item-durn_uom_5 ) ).


      CALL TRANSACTION gc_c201
                 USING gt_bdc
          OPTIONS FROM gs_options
         MESSAGES INTO gt_msg.

      LOOP AT gt_msg INTO DATA(ls_msg).

        IF ls_msg-msgid EQ 'CP' AND
           ls_msg-msgnr EQ '603'.
          CONTINUE.
        ENDIF.

        IF ls_msg-msgid EQ 'C5' AND
           ls_msg-msgnr EQ '636'.
          CONTINUE.
        ENDIF.

        IF ls_msg-msgid = 'C5' AND
           ls_msg-msgnr = '657'.
          CONTINUE.
        ENDIF.

        CLEAR lv_message.
        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            msgid               = ls_msg-msgid
            msgnr               = ls_msg-msgnr
            msgv1               = ls_msg-msgv1
            msgv2               = ls_msg-msgv2
            msgv3               = ls_msg-msgv3
            msgv4               = ls_msg-msgv4
          IMPORTING
            message_text_output = lv_message.

        APPEND VALUE #(
          registro = ls_msg-msgv1
          tipo_msg = ls_msg-msgtyp
          msg      = lv_message
                      ) TO gt_log.
      ENDLOOP.

      TRY.
          DATA(ls_log) = gt_log[ lv_tabix_header ].
          "Busca último Numerador de grupos criado
          SELECT MAX( plnal )
            FROM mapl
            INTO @DATA(lv_plnal)
            WHERE matnr = @<fs_header>-mat_num
              AND werks = @<fs_header>-plant
              AND plnty = '2'
              AND plnnr = @ls_log-registro.
          IF sy-subrc NE 0.
            lv_plnal = 0.
          ENDIF.
          SELECT *
            FROM mkal
            INTO TABLE @DATA(lt_mkal)
            WHERE matnr = @<fs_header>-mat_num
              AND werks = @<fs_header>-plant
              AND verid = @<fs_header>-prod_versn.

          IF sy-subrc EQ 0.
            LOOP AT lt_mkal ASSIGNING FIELD-SYMBOL(<fs_mkal>).
              <fs_mkal>-plnty = '2'.
              <fs_mkal>-plnnr = ls_log-registro.
              <fs_mkal>-alnal = lv_plnal.
            ENDLOOP.
            CALL FUNCTION 'MDIA_UPDATE_MKAL_INTERN'
              TABLES
                it_mkal_i = lt_mkal.
            CALL FUNCTION 'DB_COMMIT'.
          ENDIF.

        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

  METHOD bdc_dynpro.

    APPEND VALUE #(
      program  = iv_program
      dynpro   = iv_dynpro
      dynbegin = iv_dynbegin
                  ) TO gt_bdc.

  ENDMETHOD.

  METHOD bdc_fieldvalue.

    APPEND VALUE #(
      fnam = iv_fnam
      fval = iv_fval
                  ) TO gt_bdc.

  ENDMETHOD.

  METHOD mostra_log.

    DATA: lo_log       TYPE REF TO cl_salv_table,
          lo_functions TYPE REF TO cl_salv_functions,
          lo_columns   TYPE REF TO cl_salv_columns_table,
          lo_column    TYPE REF TO cl_salv_column,
          lo_display   TYPE REF TO cl_salv_display_settings.


    IF NOT gt_log IS INITIAL.

      TRY.
          cl_salv_table=>factory(
            EXPORTING
              list_display = if_salv_c_bool_sap=>false
            IMPORTING
              r_salv_table = lo_log
            CHANGING
              t_table      = gt_log ).

          lo_columns = lo_log->get_columns( ).
          lo_columns->set_optimize( ).
          lo_column = lo_columns->get_column( columnname = 'REGISTRO' ).
          lo_column->set_medium_text( value = CONV #( TEXT-t03 ) ).
          lo_column->set_alignment( if_salv_c_alignment=>centered ).
          lo_column = lo_columns->get_column( columnname = 'TIPO_MSG' ).
          lo_column->set_short_text( value = CONV #( TEXT-t04 ) ).
          lo_column->set_alignment( if_salv_c_alignment=>centered ).
          lo_column = lo_columns->get_column( columnname = 'MSG' ).
          lo_column->set_short_text( value = CONV #( TEXT-t05 ) ).
        CATCH cx_salv_msg.
        CATCH cx_salv_not_found.
      ENDTRY.

      lo_display = lo_log->get_display_settings( ).
      lo_display->set_striped_pattern( cl_salv_display_settings=>true ).

      lo_functions = lo_log->get_functions( ).
      lo_functions->set_all( abap_true ).
      lo_log->display( ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.
