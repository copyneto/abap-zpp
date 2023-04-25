@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection view Ajuste Inventário-Header'
//@Search.searchable: true
@ObjectModel.semanticKey: ['DocumentNo']
define root view entity ZC_PP_AJUSTE_INVENTARIO_HEADER
  as projection on ZI_PP_AJUSTE_INVENTARIO_HEADER
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key DocumentoUUID,
      @EndUserText.label: 'Nº Documento'
      @ObjectModel.text.element: ['DocName']
      DocumentNo,
      @EndUserText.label: 'Id Contagem'
      IdContagem,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_PlantStdVH', element: 'Plant' } } ]
      @EndUserText.label: 'Centro'
      Plant,
      @Consumption.filter: { selectionType: #INTERVAL }
      @EndUserText.label: 'Período Inicial'
      DateStart,
      @Consumption.filter: { selectionType: #INTERVAL }
      @EndUserText.label: 'Período Final'
      DateEnd,
      @EndUserText.label: 'Descrição'
      DocName,
      @EndUserText.label: ''
      Description,
      @EndUserText.label: 'Status'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_PP_AJUSTE_INVENTARIO_STATUS', element: 'StatusId' } }]
      @ObjectModel.text.element: ['StatusText']
      Status,
      _InventStatus.StatusText as StatusText,
      StatusCriticality,
      @EndUserText.label: 'Criado Por'
      @ObjectModel.text.element: ['UserName']
      CreatedBy,
      _User.UserDescription    as UserName,
      @EndUserText.label: 'Criado Em'
      CreatedAt,
      @EndUserText.label: 'Modificado Por'
      LastChangedBy,
      @EndUserText.label: 'Modificado Em'
      LastChangedAt,
      @EndUserText.label: 'Última Modif.'
      LocalLastChangedAt,
      /* Associations */
      _Item : redirected to composition child ZC_PP_AJUSTE_INVENTARIO_ITEM,
      _Totals,
      _InventStatus,
      _User
}
