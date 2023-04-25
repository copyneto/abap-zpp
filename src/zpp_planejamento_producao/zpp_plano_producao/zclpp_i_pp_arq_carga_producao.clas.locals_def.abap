*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

* ======================================================================
* Global Types
* ======================================================================


* ======================================================================
* Global variables
* ======================================================================

CONSTANTS:
  BEGIN OF gc_status,
    carregado  TYPE ztpp_arq_prod-status VALUE 'L',
    processado TYPE ztpp_arq_prod-status VALUE 'P',
  END OF gc_status.
