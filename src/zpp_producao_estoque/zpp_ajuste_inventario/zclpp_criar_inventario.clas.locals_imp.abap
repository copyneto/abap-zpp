CLASS lcl_criarinventariohdr DEFINITION INHERITING FROM cl_abap_behavior_handler .

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF gc_sem_lanc_perio_planta,
        id     TYPE symsgid VALUE 'ZPP_INVENTARIO_PROD',
        number TYPE symsgno VALUE '001',
      END OF gc_sem_lanc_perio_planta,

      BEGIN OF gc_data_inicial_maior_final,
        id     TYPE symsgid VALUE 'ZPP_INVENTARIO_PROD',
        number TYPE symsgno VALUE '002',
      END OF gc_data_inicial_maior_final,

      BEGIN OF gc_existe_documento_perio,
        id     TYPE symsgid VALUE 'ZPP_INVENTARIO_PROD',
        number TYPE symsgno VALUE '003',
      END OF gc_existe_documento_perio.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR CriarInventarioHdr RESULT result.

    METHODS get_authorizationsItem FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR CriarInventarioItem RESULT result.

    METHODS validardatas FOR VALIDATE ON SAVE
      IMPORTING keys FOR criarinventariohdr~validardatas.

    METHODS calculardocumentno FOR DETERMINE ON MODIFY
      IMPORTING keys FOR criarinventariohdr~calculardocumentno.

    METHODS dadosdeselecao FOR VALIDATE ON SAVE
      IMPORTING keys FOR criarinventariohdr~dadosdeselecao.

    METHODS verificadocumento FOR VALIDATE ON SAVE
      IMPORTING keys FOR criarinventariohdr~verificadocumento.

    METHODS buscaproximoid
      RETURNING VALUE(rv_number) TYPE ze_nr_ajust_inv .

    METHODS feature_ctrl_method FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR criarinventariohdr RESULT result.

    METHODS feature_ctrl_method_item FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR criarinventarioitem RESULT result.
    METHODS mensagens FOR MODIFY
      IMPORTING keys FOR ACTION criarinventarioitem~mensagens RESULT result.

    METHODS authoritycreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR criarinventariohdr~authoritycreate.

ENDCLASS.

CLASS lcl_criarinventariohdr IMPLEMENTATION.

  METHOD dadosdeselecao.

    READ ENTITIES OF zi_pp_criar_inventario_header IN LOCAL MODE
        ENTITY criarinventariohdr
            FIELDS ( datestart dateend ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_criar_inventarios) FAILED DATA(ls_erros).

    LOOP AT lt_criar_inventarios INTO DATA(ls_criar_inventarios). "#EC CI_LOOP_INTO_WA
      SELECT COUNT( * ) FROM zc_pp_inventario_producao( "#EC CI_SEL_NESTED
        p_datade  = @ls_criar_inventarios-datestart,
        p_dataate = @ls_criar_inventarios-dateend )
      WHERE plant = @ls_criar_inventarios-plant.
      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = ls_criar_inventarios-%tky ) TO failed-criarinventariohdr.

        APPEND VALUE #(
          %tky        = ls_criar_inventarios-%tky
          %msg        =  new_message(
            id       = gc_sem_lanc_perio_planta-id
            number   = gc_sem_lanc_perio_planta-number
            severity = if_abap_behv_message=>severity-error
          )
          %element-plant     = if_abap_behv=>mk-on
          %element-datestart = if_abap_behv=>mk-on
          %element-dateend   = if_abap_behv=>mk-on
        ) TO reported-criarinventariohdr.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validardatas.

    READ ENTITIES OF zi_pp_criar_inventario_header IN LOCAL MODE
        ENTITY criarinventariohdr
            FIELDS ( datestart dateend ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_criar_inventarios) FAILED DATA(ls_erros).

    LOOP AT lt_criar_inventarios INTO DATA(ls_criar_inventarios). "#EC CI_LOOP_INTO_WA

      IF ls_criar_inventarios-dateend < ls_criar_inventarios-datestart.
        APPEND VALUE #( %tky = ls_criar_inventarios-%tky ) TO failed-criarinventariohdr.

        APPEND VALUE #(
          %tky        = ls_criar_inventarios-%tky
          %msg        =  new_message(
            id       = gc_data_inicial_maior_final-id
            number   = gc_data_inicial_maior_final-number
            severity = if_abap_behv_message=>severity-error
          )
          %element-datestart = if_abap_behv=>mk-on
          %element-dateend = if_abap_behv=>mk-on
        ) TO reported-criarinventariohdr.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.



  METHOD verificadocumento.

    READ ENTITIES OF zi_pp_criar_inventario_header IN LOCAL MODE
      ENTITY criarinventariohdr
        FIELDS ( plant datestart dateend ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_criar_inventarios) FAILED DATA(ls_erros).

    LOOP AT lt_criar_inventarios INTO DATA(ls_criar_inventarios). "#EC CI_LOOP_INTO_WA

      APPEND VALUE #(
        %tky        = ls_criar_inventarios-%tky
        %state_area = 'VALIDATE_DOCUMENTO' )
      TO reported-criarinventariohdr.


      SELECT documentno                              "#EC CI_SEL_NESTED
        FROM ztpp_ajust_inv_h
        WHERE plant     = @ls_criar_inventarios-plant
          AND datestart = @ls_criar_inventarios-datestart
          AND dateend   = @ls_criar_inventarios-dateend
          AND status    <> '4'
          INTO @DATA(ls_documentno) UP TO 1 ROWS.
      ENDSELECT.

      IF sy-subrc = 0.

        APPEND VALUE #( %tky = ls_criar_inventarios-%tky ) TO failed-criarinventariohdr.

        APPEND VALUE #(
          %tky        = ls_criar_inventarios-%tky
          %state_area = 'VALIDATE_DOCUMENTO'
          %msg        =  new_message(
            id       = gc_existe_documento_perio-id
            number   = gc_existe_documento_perio-number
            severity = if_abap_behv_message=>severity-error
            v1       = |{ ls_documentno ALPHA = OUT }|
          )
          %element-plant = if_abap_behv=>mk-on
          %element-datestart = if_abap_behv=>mk-on
          %element-dateend = if_abap_behv=>mk-on
        ) TO reported-criarinventariohdr.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD buscaproximoid.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZPPCONTAG'
      IMPORTING
        number                  = rv_number
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD feature_ctrl_method.
    " read data required
    READ ENTITY zi_pp_criar_inventario_header
         FIELDS ( status )
           WITH VALUE #( FOR ls_key IN keys ( %key = ls_key-%key ) )
         RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result
             ( %key                          = ls_result-%key
               %features-%delete             = COND #( WHEN ls_result-status IS INITIAL
                                                       THEN if_abap_behv=>fc-o-enabled
                                                       ELSE if_abap_behv=>fc-o-disabled   )
              ) ).

  ENDMETHOD.

  METHOD feature_ctrl_method_item.
    READ ENTITY zi_pp_criar_inventario_item
         FIELDS ( status   )
           WITH VALUE #( FOR ls_key IN keys ( %key = ls_key-%key ) )
         RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result
            ( %key                          = ls_result-%key
              %field-counting                 =
               COND #( WHEN ls_result-status = '1' THEN if_abap_behv=>fc-f-read_only
                       WHEN ls_result-status = '3' THEN if_abap_behv=>fc-f-read_only
                       WHEN ls_result-status = '4' THEN if_abap_behv=>fc-f-read_only )
              %features-%action-mensagens =
               COND #( WHEN ls_result-status = '2' THEN if_abap_behv=>fc-o-enabled
                       WHEN ls_result-status = '1' THEN if_abap_behv=>fc-o-enabled
               ELSE if_abap_behv=>fc-o-disabled )
             ) ).
  ENDMETHOD.

  METHOD calculardocumentno.
    READ ENTITIES OF zi_pp_criar_inventario_header IN LOCAL MODE
      ENTITY criarinventariohdr
      FIELDS ( documentno )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_inventario_hdr).

    IF NOT line_exists( lt_inventario_hdr[ documentno  = '' ] ). "#EC CI_STDSEQ
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zi_pp_criar_inventario_header IN LOCAL MODE
      ENTITY criarinventariohdr
        UPDATE FIELDS ( documentno )
        WITH VALUE #( FOR ls_inventario_hdr IN lt_inventario_hdr WHERE ( documentno IS INITIAL ) ( "#EC CI_STDSEQ
                           %key      =  ls_inventario_hdr-%key
                            documentno   = buscaproximoid( )
                           ) )
    REPORTED DATA(lt_reported).


    READ ENTITIES OF zi_pp_criar_inventario_header IN LOCAL MODE
        ENTITY criarinventariohdr
          FIELDS ( documentno datestart dateend plant )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_inventario_header).

    LOOP AT lt_inventario_header INTO DATA(ls_inventario_header). "#EC CI_LOOP_INTO_WA
      SELECT material, plant, storagelocation, batch, matlwrhsstkqtyinmatlbaseunit, "#EC CI_SEL_NESTED
             materialbaseunit, priceunit, currency
        FROM zc_pp_inventario_producao(
        p_datade  = @ls_inventario_header-datestart,
        p_dataate = @ls_inventario_header-dateend )
      WHERE plant = @ls_inventario_header-plant
      INTO TABLE @DATA(lt_inventario_producao).

      MODIFY ENTITIES OF zi_pp_criar_inventario_header  IN LOCAL MODE
        ENTITY criarinventariohdr
          CREATE BY \_item
          FIELDS ( material plant storagelocation batch quantity unit counting price currency )
          WITH  VALUE #(
           (
             %key-documentouuid = ls_inventario_header-documentouuid
             %target = VALUE #( FOR ls_inventario_producao IN lt_inventario_producao
                   (
                   documentouuid   = ls_inventario_header-documentouuid
                    material        = ls_inventario_producao-material
                    plant           = ls_inventario_producao-plant
                    storagelocation = ls_inventario_producao-storagelocation
                    batch           = ls_inventario_producao-batch
                    quantity        = ls_inventario_producao-matlwrhsstkqtyinmatlbaseunit
                    counting        = ls_inventario_producao-matlwrhsstkqtyinmatlbaseunit
                    unit            = ls_inventario_producao-materialbaseunit
                    price           = ls_inventario_producao-priceunit
                    currency        = ls_inventario_producao-currency
                    ) ) ) )
    MAPPED DATA(ls_mapped1)
    REPORTED DATA(ls_reported1)
    FAILED DATA(ls_failed1).

    ENDLOOP.

  ENDMETHOD.

  METHOD mensagens.

    SELECT * FROM zi_pp_ajuste_inventario_msg "#EC CI_FAE_LINES_ENSURED
    FOR ALL ENTRIES IN @keys
    WHERE documentoitemuuid = @keys-documentoitemuuid
    INTO TABLE @DATA(lt_mensagens).

    LOOP AT lt_mensagens INTO DATA(ls_mensagens).  "#EC CI_LOOP_INTO_WA

      APPEND VALUE #( %tky-documentoitemuuid = ls_mensagens-documentoitemuuid ) TO failed-criarinventarioitem.

      APPEND VALUE #(
        %tky        = VALUE #( documentoitemuuid = ls_mensagens-documentoitemuuid )
        %msg        =  new_message(
          id       = ls_mensagens-messageid
          number   = CONV #( ls_mensagens-messageno )
          severity = CONV #( ls_mensagens-messagetype )
          v1       = ls_mensagens-messagev1
          v2       = ls_mensagens-messagev2
          v3       = ls_mensagens-messagev3
          v4       = ls_mensagens-messagev4
        )
      ) TO reported-criarinventarioitem.
    ENDLOOP.
  ENDMETHOD.

  METHOD authorityCreate.

    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_pp_criar_inventario_header IN LOCAL MODE
        ENTITY CriarInventarioHdr
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclpp_auth_zppwerks=>werks_create( <fs_data>-Plant ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-criarinventariohdr.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-criarinventariohdr.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create )
                        %element-plant = if_abap_behv=>mk-on )
          TO reported-criarinventariohdr.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_pp_criar_inventario_header IN LOCAL MODE
        ENTITY CriarInventarioHdr
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data)
        FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    DATA: lv_update TYPE if_abap_behv=>t_xflag,
          lv_delete TYPE if_abap_behv=>t_xflag.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclpp_auth_zppwerks=>werks_update( <fs_data>-Plant ).
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.

        IF zclpp_auth_zppwerks=>werks_delete( <fs_data>-Plant ).
          lv_delete = if_abap_behv=>auth-allowed.
        ELSE.
          lv_delete = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      APPEND VALUE #( %tky = <fs_data>-%tky
                      %update = lv_update
                      %delete = lv_delete )
             TO result.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_authorizationsitem.

  ENDMETHOD.

ENDCLASS.
