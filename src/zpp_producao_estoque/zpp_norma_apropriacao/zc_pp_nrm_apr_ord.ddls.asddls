@EndUserText.label: 'Norma de Apropriação - Ordens'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_PP_NRM_APR_ORD
  as projection on ZI_PP_NRM_APR_ORD
{
  key DocUuidH,
  key DocUuidOrdem,
      ProcessOrder,
      @ObjectModel.text.element: ['MaterialName']
      Material,
      MaterialName,
      @ObjectModel.text.element: ['PlantName']
      Plant,
      PlantName,
      @ObjectModel.text.element: ['OrderTypeName']
      OrderType,
      OrderTypeName,
      BasicStartDate,
      Quantity,
      QuantityConfirmed,
      QuantityRefugo,
      QuantityTotal,
      QuantityUom,
      Percentage,
      Total,
      CriticalPerc,
      @ObjectModel.text.element: ['StatusTxt']
      Status,
      StatusTxt,
      StatusCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      LogObjectId,
      LogObjectSubId,
      ProdVersion,
      /* Associations */
      _H : redirected to parent ZC_PP_NRM_APR_H
}
