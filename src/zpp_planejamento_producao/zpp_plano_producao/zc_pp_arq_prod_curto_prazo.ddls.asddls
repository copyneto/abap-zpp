@EndUserText.label: 'Projeção - Arquivos de Curto Prazo'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity ZC_PP_ARQ_PROD_CURTO_PRAZO
  as projection on zi_pp_arq_prod_curto_prazo as ArqCurtoPrazo
{
  key Id,
  key Line,
      PldordProfile,
      @Consumption.valueHelpDefinition: [{entity: {name: 'C_Materialvaluehelp', element: 'Material' }}]
      @ObjectModel.text.element: ['MaterialName']
      Material,
      _Material.MaterialName as MaterialName,
      @Consumption.valueHelpDefinition: [{entity: {name: 'C_Plantvaluehelp', element: 'Plant' }}]
      @ObjectModel.text.element: ['PlanPlantName']
      PlanPlant,
      _PlanPlant.PlantName   as PlanPlantName,
      @Consumption.valueHelpDefinition: [{entity: {name: 'C_Plantvaluehelp', element: 'Plant' }}]
      @ObjectModel.text.element: ['ProdPlantName']
      ProdPlant,
      _PlanPlant.PlantName   as ProdPlantName,
      TotalPlordQty,
      OrderStartDate,
      FirmingInd,
      Unit,
      Version,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _ArqCargaProducao : redirected to parent ZC_PP_ARQ_CARGA_PRODUCAO
}
