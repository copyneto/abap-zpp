@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'ZC Material BOM'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_PP_MaterialBOM
  as select from ZI_PP_MaterialBOM
  association [0..1] to I_MaterialText as _TextMaterial on  _TextMaterial.Material = $projection.BillOfMaterialComponent
                                                        and _TextMaterial.Language = $session.system_language

{
  key BillOfMaterial,
  key BillOfMaterialVariant,
  key Material,
  key Plant,
  key BillOfMaterialVariantUsage,
      BillOfMaterialCategory,
      IsConfiguredMaterial,
      MaterialBOMObjectID,
      CreatedByUser,
      LastChangedByUser,
      BOMHeaderText,
      BOMAlternativeText,
      BOMHeaderBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BOMHeaderBaseUnit'
      BOMHeaderQuantityInBaseUnit,
      BOMExplosionApplication,
      BillOfMaterialStatus,
      BillOfMaterialItemNumber,
      BillOfMaterialItemUnit,
      @Semantics.quantity.unitOfMeasure: 'BillOfMaterialItemUnit'
      BillOfMaterialItemQuantity,
      BillOfMaterialItemNodeNumber,
      BOMItemInternalChangeCount,
      OperationScrapInPercent,
      IsNetScrap,
      BillOfMaterialComponent,
      Z_ComponentName,
      _TextMaterial.MaterialName as Z_ProductName,
      Language,
      ValidityEndDate,
      ValidityStartDate
}


