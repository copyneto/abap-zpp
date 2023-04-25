@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Estoque Invent Prod - itens documento'
@Metadata.allowExtensions: true
view entity ZC_PP_INVENT_PROD_DOC_ITEM
  with parameters
    p_datade  : abap.dats,
    p_dataate : abap.dats
  as select from I_MfgOrderMaterialDocumentItem as I_MfgOrderMatDocItem
{
  key Material,
  key Plant,
  key Batch
}
where
       I_MfgOrderMatDocItem.PostingDate       between $parameters.p_datade and $parameters.p_dataate
  and(
       I_MfgOrderMatDocItem.GoodsMovementType = '261'
    or I_MfgOrderMatDocItem.GoodsMovementType = '262'
    or I_MfgOrderMatDocItem.GoodsMovementType = 'Y02'
    or I_MfgOrderMatDocItem.GoodsMovementType = 'Z02'
  )
group by
  Material,
  Plant,
  Batch
