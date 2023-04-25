  @EndUserText.label: 'Projection view Ajuste Inventário-Item'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true

define view entity ZC_PP_AJUSTE_INVENTARIO_ITEM
  as projection on ZI_PP_AJUSTE_INVENTARIO_ITEM
{
          @EndUserText.label: 'Guid Item'
  key     DocumentoItemUUID,
          @EndUserText.label: 'Guid Documento'
          DocumentoUUID,
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.90
          @ObjectModel.text.element: ['MaterialName']
          @EndUserText.label: 'Material'
          Material,
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.90
          @EndUserText.label: 'Nome Material'
          MaterialName,
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.90
          @EndUserText.label: 'Centro'
          Plant,
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.90
          @EndUserText.label: 'Depósito'
          StorageLocation,
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.90
          @EndUserText.label: 'Lote'
          Batch,
          @Semantics.amount.currencyCode: 'Currency'
          @EndUserText.label: 'Preço Unitário'
          Price,
          @Semantics.currencyCode: true
          @EndUserText.label: 'Moeda'
          Currency,
          @Semantics.quantity.unitOfMeasure: 'Unit'
          @EndUserText.label: 'Quantidade'
          Quantity,
          @Semantics.unitOfMeasure: true
          @EndUserText.label: 'Unidade'
          Unit,
          @Semantics.amount.currencyCode: 'Currency'
          @EndUserText.label: 'Valor Estoque'
          TotalQuantity,
          @Semantics.quantity.unitOfMeasure: 'Unit'
          @EndUserText.label: 'Contagem'
          Counting,
          @EndUserText.label: 'Valor Contagem'
          @Semantics.amount.currencyCode: 'Currency'
          TotalCounting,
          @Semantics.quantity.unitOfMeasure: 'Unit'
          @EndUserText.label: 'Saldo'
          Balance,
          @Semantics.amount.currencyCode: 'Currency'
          @EndUserText.label: 'Valor Saldo'
          TotalBalance,
//          @Semantics.unitOfMeasure: true
          @EndUserText.label: 'Percentual'
          Percentage,
          //          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCLPP_AJUSTE_INV_VIRTUAL_DATA'
          //          @EndUserText.label: 'Acuracidade'
          //          @Semantics.quantity.unitOfMeasure: 'Percentage'
          //  virtual Accuracy      : perct,
          @EndUserText.label: 'Acuracidade'
          @Semantics.quantity.unitOfMeasure: 'Percentage'
          Accuracy,
          @ObjectModel.text.element: ['StatusText']
          @EndUserText.label: 'Status'
          Status,
          _ItemStatus.StatusText                   as StatusText,
          StatusCriticality,
          CreatedBy,
          CreatedAt,
          LastChangedBy,
          LastChangedAt,
          LocalLastChangedAt,
          /* Associations */
          _Header : redirected to parent ZC_PP_AJUSTE_INVENTARIO_HEADER,
          //      _Material,
          //      _MaterialText,
          //      _MRPController,
          //      _Plant,
          //      _StorageLocation,
          _ItemStatus
}
