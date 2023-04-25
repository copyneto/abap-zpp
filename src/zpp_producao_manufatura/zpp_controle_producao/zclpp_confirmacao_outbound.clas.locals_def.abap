*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
CLASS lcl_db DEFINITION.
  PUBLIC SECTION.
    METHODS
      query_auart_in_aufk IMPORTING iv_order_id          TYPE aufnr
                          RETURNING VALUE(rv_order_type) TYPE aufart
                          RAISING   cx_sy_sql_error.
ENDCLASS.


CLASS lcl_api DEFINITION.
  PUBLIC SECTION.
    TYPES  ty_confirmation_data TYPE STANDARD TABLE OF bapi10503oprconfin.
    METHODS:
      ale_mosrvaps_confoprmulti IMPORTING iv_logsys        TYPE bapiapologsys
                                          it_confirmations TYPE ty_confirmation_data
                                          it_logsystems    TYPE wcb_t_logsys
                                RAISING   cx_bapi_error,
      own_logical_system_get    RETURNING VALUE(rv_log_syst) TYPE  logsys
                                RAISING   cx_bapi_error.
ENDCLASS.
