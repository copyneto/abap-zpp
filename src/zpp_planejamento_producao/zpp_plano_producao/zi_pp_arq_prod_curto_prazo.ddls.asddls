@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Conteúdo dos Arquivos: Prod. Curto Prazo'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_pp_arq_prod_curto_prazo
  as select from ztpp_prod_curto
  association        to parent zi_pp_arq_carga_producao as _ArqCargaProducao on  $projection.Id = _ArqCargaProducao.Id
  association [0..1] to I_MaterialText                  as _Material         on  $projection.Material = _Material.Material
                                                                             and _Material.Language   = $session.system_language
  association [0..1] to C_Plantvaluehelp                as _PlanPlant        on  $projection.PlanPlant = _PlanPlant.Plant
  association [0..1] to C_Plantvaluehelp                as _ProdPlant        on  $projection.ProdPlant = _ProdPlant.Plant
{
      @UI.hidden: true
  key id                    as Id,
      @UI.hidden: true
  key line                  as Line,
      pldord_profile        as PldordProfile,
      material              as Material,

      plan_plant            as PlanPlant,
      prod_plant            as ProdPlant,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      total_plord_qty       as TotalPlordQty,
      order_start_date      as OrderStartDate,
      firming_ind           as FirmingInd,
      unit                  as Unit,
      version               as Version,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* associations */
      _ArqCargaProducao,
      _Material,
      _PlanPlant,
      _ProdPlant
}
