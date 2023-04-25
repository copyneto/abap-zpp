@EndUserText.label: 'Norma de Apropriação Grãos Consumidos'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_PP_NRM_APR_CON
  as projection on ZI_PP_NRM_APR_CON
{
  key DocUuidH,
  key DocUuidConsumo,
      Material,
      @ObjectModel.text.element: ['PlantName']
      Plant,
      PlantName,
      StgeLoc,
      Batch,
      EntryQnt,
      EntryUom,
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
      /* Associations */
      _H : redirected to parent ZC_PP_NRM_APR_H
}
