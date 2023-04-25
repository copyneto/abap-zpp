@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'View para dados da tabela MEAN'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_pp_mean as select from mean as Ean {
   key matnr as material,
   key meinh as unidade,
   ean11 as ean
}
where eantp = 'UC'
