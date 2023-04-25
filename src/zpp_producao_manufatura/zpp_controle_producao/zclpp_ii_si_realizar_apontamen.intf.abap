interface ZCLPP_II_SI_REALIZAR_APONTAMEN
  public .


  methods SI_REALIZAR_APONTAMENTO_IN
    importing
      !INPUT type ZCLPP_MT_APONTAMENTO
    raising
      ZCLPP_CX_FMT_APONTAMENTO .
endinterface.
