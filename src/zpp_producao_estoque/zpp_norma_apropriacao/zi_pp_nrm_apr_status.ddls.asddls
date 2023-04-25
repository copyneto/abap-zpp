@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Status Norma de Apropriação'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_PP_NRM_APR_STATUS
  as select from dd07t as InventStatus
{
      @ObjectModel.text.element: [ 'StatusText' ]
  key domvalue_l as StatusId,
      ddlanguage as Language,
      ddtext     as StatusText
}
where
      domname  = 'ZD_STATUS_NRM_APR'
  and as4local = 'A'
