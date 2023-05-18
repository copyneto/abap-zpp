@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDs Maior Estimativa Custo Material'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_PP_MAT_CUSTO as select from I_CurrentMatlPriceByCostEst {
    key max(CostEstimate) as CostEstimate,
    Material,
    ValuationArea    
}
group by
    Material,
    ValuationArea
