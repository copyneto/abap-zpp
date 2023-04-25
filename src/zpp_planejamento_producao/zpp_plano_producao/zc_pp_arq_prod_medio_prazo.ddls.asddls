@EndUserText.label: 'Projeção - Arquivos de Médio Prazo'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity ZC_PP_ARQ_PROD_MEDIO_PRAZO
  as projection on zi_pp_arq_prod_medio_prazo as ArqMedioPrazo
{
  key Id,
  key Line,
      @Consumption.valueHelpDefinition: [{entity: {name: 'C_Materialvaluehelp', element: 'Material' }}]
      @ObjectModel.text.element: ['MaterialName']
      Material,
      _Material.MaterialName as MaterialName,
      @Consumption.valueHelpDefinition: [{entity: {name: 'C_Plantvaluehelp', element: 'Plant' }}]
      @ObjectModel.text.element: ['PlantName']
      Plant,
      _Plant.PlantName   as PlantName,
      Version,
      VersActiv,
      VersActivName,
      DateType,
      ReqDate,
      ReqQty,
      Unit,
      BomExpl,
      ProdVes,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _ArqCargaProducao : redirected to parent ZC_PP_ARQ_CARGA_PRODUCAO
}
