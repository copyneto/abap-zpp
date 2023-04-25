interface ZCLPP_II_SI_REALIZAR_APONTAME1
  public .


  methods SI_REALIZAR_APONTAMENTO_IN
    importing
      !INPUT type ZCLPP_MT_APONTAMENTO1
    exporting
      !OUTPUT type ZCLPP_MT_APONTAMENTO_RESP
    raising
      ZCLPP_CX_FMT_APONTAMENTO1 .
endinterface.
