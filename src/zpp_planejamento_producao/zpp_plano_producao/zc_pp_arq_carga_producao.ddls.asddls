@EndUserText.label: 'Projeção - Arquivos de Carga de Produção'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define root view entity ZC_PP_ARQ_CARGA_PRODUCAO
  as projection on zi_pp_arq_carga_producao as ArqCargaProducao
{
  key Id,
      Name,
      @Consumption.valueHelpDefinition: [{entity: {name: 'P_USER_ADDR', element: 'bname' }}]
      @ObjectModel.text.element: ['UserName']
      @EndUserText.label: 'Responsável'
      Userid,
      @EndUserText.label: 'Responsável'
      _User.NAME_TEXTC as UserName,
      @EndUserText.label: 'Data Importação'
      ImportDate,
      @EndUserText.label: 'Hora Importação'
      ImportTime,
      @EndUserText.label: 'Tipo'
      Type,
      @EndUserText.label: 'Tipo'
      TypeName,
      @Consumption.valueHelpDefinition: [{entity: {name: 'C_Plantvaluehelp', element: 'Plant' }}]
      @ObjectModel.text.element: ['PlantName']
      @EndUserText.label: 'Centro'
      Plant, 
      @EndUserText.label: 'Centro'
      _Plant.PlantName   as PlantName,
      @EndUserText.label: 'Status'
      Status,
      @EndUserText.label: 'Status'
      StatusName,
      @EndUserText.label: 'Status'
      StatusCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _ArqCurtoPrazo : redirected to composition child ZC_PP_ARQ_PROD_CURTO_PRAZO,
      _ArqMedioPrazo : redirected to composition child ZC_PP_ARQ_PROD_MEDIO_PRAZO,
      _User

}
 