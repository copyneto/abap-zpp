@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@VDM.viewType: #COMPOSITE
@EndUserText.label: 'View Composite MATERIALBOM'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_PP_MaterialBOM
  as select from    I_MaterialBOMLink

    left outer join I_BillOfMaterialHeader    as _Header    on  I_MaterialBOMLink.BillOfMaterial        = _Header.BillOfMaterial
                                                            and I_MaterialBOMLink.BillOfMaterialVariant = _Header.BillOfMaterialVariant



    left outer join I_BillOfMaterialComponent as _Component on  I_MaterialBOMLink.BillOfMaterial        = _Component.BillOfMaterial
                                                            and I_MaterialBOMLink.BillOfMaterialVariant = _Component.BillOfMaterialVariant

    left outer join I_BillOfMaterialItem      as _Item      on _Item.BillOfMaterialItemUUID = _Component.BillOfMaterialItemUUID





  association [0..1] to I_MaterialText as _TextComponent on  _TextComponent.Material = I_MaterialBOMLink.Material
                                                         and _TextComponent.Language = $session.system_language

{
  key I_MaterialBOMLink.BillOfMaterial,
  key I_MaterialBOMLink.BillOfMaterialVariant,
  key I_MaterialBOMLink.Material,
  key I_MaterialBOMLink.Plant,
  key I_MaterialBOMLink.BillOfMaterialVariantUsage,
      I_MaterialBOMLink.BillOfMaterialCategory,
      I_MaterialBOMLink.IsConfiguredMaterial,
      I_MaterialBOMLink.MaterialBOMObjectID,
      I_MaterialBOMLink.CreatedByUser,
      I_MaterialBOMLink.LastChangedByUser,
      _Header.BOMHeaderText               as BOMHeaderText,
      _Header.BOMAlternativeText          as BOMAlternativeText,
      _Header.BOMHeaderBaseUnit           as BOMHeaderBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BOMHeaderBaseUnit'
      _Header.BOMHeaderQuantityInBaseUnit as BOMHeaderQuantityInBaseUnit,
      _Header.BOMExplosionApplication     as BOMExplosionApplication,
      _Header.BillOfMaterialStatus        as BillOfMaterialStatus,
      _Item.BillOfMaterialItemNumber      as BillOfMaterialItemNumber,
      _Item.BillOfMaterialItemUnit        as BillOfMaterialItemUnit,
      @Semantics.quantity.unitOfMeasure: 'BillOfMaterialItemUnit'
      _Item.BillOfMaterialItemQuantity    as BillOfMaterialItemQuantity,
      _Item.BillOfMaterialItemNodeNumber  as BillOfMaterialItemNodeNumber,
      _Item.BOMItemInternalChangeCount    as BOMItemInternalChangeCount,
      _Item.OperationScrapInPercent       as OperationScrapInPercent,
      _Item.IsNetScrap                    as IsNetScrap,
      _Component.BillOfMaterialComponent  as BillOfMaterialComponent,
      _TextComponent.MaterialName         as Z_ComponentName,
      _Header.BOMIsArchivedForDeletion    as BOMIsArchivedForDeletion,
      _Item.ValidityEndDate               as ValidityEndDate,
      _Item.ValidityStartDate             as ValidityStartDate,

      $session.system_language            as Language,

      //      _Header,
      //      _Component,
      _TextComponent
}

where
      _Header.BOMIsArchivedForDeletion             <> 'X'
  and I_MaterialBOMLink.BillOfMaterialVariantUsage =  '1'
  and _Header.BOMExplosionApplication              =  'PP01'
