@EndUserText.label: 'Projec view p/ Criação Inventário-Item'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
define view entity ZC_PP_CRIAR_INVENTARIO_ITEM
  as projection on ZI_PP_CRIAR_INVENTARIO_ITEM
{

  key documentoItemUuid,
      documentoUuid,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      @ObjectModel.text.element: ['MaterialName']
      Material,
      Plant,
      StorageLocation,
      Batch,
      Quantity,
      Unit,
      Counting,
      Balance,
      @ObjectModel.text.element: ['StatusText']
      Status,
      _ItemStatus.StatusText as StatusText,
      StatusCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      MaterialName,
      /* Associations */
      _Header : redirected to parent ZC_PP_CRIAR_INVENTARIO_HEADER
}
