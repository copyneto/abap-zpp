@EndUserText.label: 'Norma de Apropriação Cabeçalho'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define root view entity ZC_PP_NRM_APR_H
  as projection on ZI_PP_NRM_APR_H
 association [0..1] to ZI_CA_VH_PADEST as _Printer on _Printer.Printer = $projection.Printer
{
  key DocUuidH,
      Documentno,
      @EndUserText.label: 'Instrução'
      Docname,
      @ObjectModel.text.element: ['PlantName']
      Plant,
      PlantName,
      @ObjectModel.text.element: ['OrderTypeName']
      OrderType,
      OrderTypeName,
      BasicStartDate,
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
      @EndUserText.label: 'Impressora'
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_PADEST', element: 'Printer' }}]
      Printer,

      /* Associations */
      _Consumo : redirected to composition child ZC_PP_NRM_APR_CON,
      _Ordens  : redirected to composition child ZC_PP_NRM_APR_ORD,
      _Printer
}
