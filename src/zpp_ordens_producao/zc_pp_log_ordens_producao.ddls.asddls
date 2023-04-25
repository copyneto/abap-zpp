@EndUserText.label: 'Ordens Produção Projection View'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_PP_LOG_ORDENS_PRODUCAO 
  as projection on ZI_PP_LOG_ORDENS_PRODUCAO as Log_Ordens
{
      @EndUserText.label: 'N° de Log'
  key ZLogNo,
      @EndUserText.label: 'ID.Ord.Prod'
      ManufacturingOrder,
      @EndUserText.label: 'Produto Acabado'
      Material,
      @EndUserText.label: 'Confirmação'
      Confirmacao,
      @EndUserText.label: 'Contador'
      Contador,
      ProdPlant,
      DateCr,
      CreatedAt,
      ZRecivMes,
      ZMsgMes
}
