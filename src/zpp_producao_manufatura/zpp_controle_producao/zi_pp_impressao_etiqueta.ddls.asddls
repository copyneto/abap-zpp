@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Impressão da etiqueta de confirmação'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_PP_IMPRESSAO_ETIQUETA
  as select from zi_pp_Confirmacoes_cubo as Mfg
{
      @EndUserText.label: 'Confirmação'
  key MfgOrderConfirmation      as Confirmation,
      @EndUserText.label: 'Contador'
  key MfgOrderConfirmationCount as ConfirmationCount,
      @EndUserText.label: 'Ordem de Processo'
      ManufacturingOrder        as MOrder,
      @EndUserText.label: 'Planta'
      Plant,
      @EndUserText.label: 'Material'
      Material,
      @EndUserText.label: 'Data de Confirmação'
      PostingDate

}
