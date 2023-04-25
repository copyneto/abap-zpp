@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Soma quantidade excedente produção'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_PP_MANUFITEM_SUM
  as select from I_MfgOrderMaterialDocumentItem
{
  key ManufacturingOrder,
      GoodsMovementType,
      BaseUnit,
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      sum( cast(QuantityInBaseUnit  as abap.dec( 13, 3 ) ) ) as QuantityInBaseUnit

}
where
     GoodsMovementType = '531'
  or GoodsMovementType = '532'
group by
  ManufacturingOrder,
  GoodsMovementType,
  BaseUnit
