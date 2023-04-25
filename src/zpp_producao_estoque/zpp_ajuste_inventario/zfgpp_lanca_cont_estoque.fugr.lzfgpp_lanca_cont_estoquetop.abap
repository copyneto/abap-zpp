FUNCTION-POOL zfgpp_lanca_cont_estoque.     "MESSAGE-ID ..

* INCLUDE LZFGPP_LANCA_CONT_ESTOQUED...      " Local class definition

*
*TYPES: BEGIN OF ty_rateio,
*         ordem     TYPE ztpp_ajust_inv_i-documentno,
*         qtd_total TYPE menge_d,
*         rateio    TYPE char3,
*         material  TYPE ztpp_ajust_inv_i-material,
*         plant     TYPE ztpp_ajust_inv_i-plant,
*         batch     TYPE ztpp_ajust_inv_i-batch,
*       END OF ty_rateio.
*
*TYPES: BEGIN OF ty_qtd_total,
*         total    TYPE menge_d,
*         material TYPE ztpp_ajust_inv_i-material,
*         plant    TYPE ztpp_ajust_inv_i-plant,
*         batch    TYPE ztpp_ajust_inv_i-batch,
*       END OF ty_qtd_total.
*
*DATA: gt_rateio    TYPE TABLE OF ty_rateio,
*      gt_qtd_total TYPE TABLE OF ty_qtd_total.
*
*DATA: gs_rateio    TYPE ty_rateio,
*      gs_qtd_total TYPE ty_qtd_total.
*
*DATA: gv_qtd_unit  TYPE menge_d.
