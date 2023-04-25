@EndUserText.label: 'Impressão da etiqueta de confirmação'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_PP_IMPRESSAO_ETIQUETA
  as projection on ZI_PP_IMPRESSAO_ETIQUETA
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key Confirmation,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key ConfirmationCount,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      MOrder,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Plant,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Material,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      PostingDate
}
