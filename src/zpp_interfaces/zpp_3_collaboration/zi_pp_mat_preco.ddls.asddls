@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDs Maior Preço Material Estimativa Custo'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_PP_MAT_PRECO as 
select from ZI_PP_MAT_CUSTO as _matCusto
inner join I_CurrentMatlPriceByCostEst as _matlPrice on _matCusto.CostEstimate = _matlPrice.CostEstimate 
{
    key _matCusto.CostEstimate,
    _matCusto.Material,
    _matCusto.ValuationArea,
    _matlPrice.BaseUnit,
    @Semantics.quantity.unitOfMeasure: 'BaseUnit'
    _matlPrice.MaterialPriceUnitQty,
    _matlPrice.Currency,
    @Semantics.amount.currencyCode: 'Currency'
    _matlPrice.InventoryPrice
}
   
