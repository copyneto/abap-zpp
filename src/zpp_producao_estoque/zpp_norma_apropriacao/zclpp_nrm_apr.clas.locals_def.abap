*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

CONSTANTS: gc_sac          TYPE meins_d VALUE 'BAG',
           gc_zone         TYPE char3 VALUE 'UTC',
           gc_despejo      TYPE bwart VALUE '261',
           gc_despejo262   TYPE bwart VALUE '262',
           gc_resultado    TYPE bwart VALUE '101',
           gc_resultado102 TYPE bwart VALUE '102',
           gc_resultado531 TYPE bwart VALUE '531',
           gc_resultado532 TYPE bwart VALUE '532'.



TYPES:
  BEGIN OF ty_data_struct,
    quantityuom TYPE co_gmein,
    quantity    TYPE gamng,
  END OF ty_data_struct,
  ty_data_tab TYPE STANDARD TABLE OF ty_data_struct WITH EMPTY KEY.
