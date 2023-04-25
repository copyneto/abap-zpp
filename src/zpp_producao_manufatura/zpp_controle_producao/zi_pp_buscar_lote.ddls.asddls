@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'View para dados do lote'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_PP_BUSCAR_LOTE
  as select from afru as Confirmacao
    inner join   aufm as _Aufm on _Aufm.aufnr = Confirmacao.aufnr

  association [0..1] to I_MfgOrderMaterialDocumentItem as _DocItem on $projection.docmaterial = _DocItem.MaterialDocument

{
  key Confirmacao.rueck           as confirmacao,
  key Confirmacao.rmzhl           as contador,
      _Aufm.mblnr                 as docmaterial,
      _DocItem.ManufacturingOrder as ordem,
      _DocItem._Batch.Batch       as lote,

      _DocItem
}
where
  _DocItem.GoodsMovementType = '101'
