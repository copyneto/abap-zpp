@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Conteúdo dos Arquivos: Prod Médio Prazo'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_pp_arq_prod_medio_prazo
  as select from ztpp_prod_medio
  association        to parent zi_pp_arq_carga_producao as _ArqCargaProducao on  $projection.Id = _ArqCargaProducao.Id
  association [0..1] to I_MaterialText                  as _Material         on  $projection.Material = _Material.Material
                                                                             and _Material.Language   = $session.system_language
  association [0..1] to C_Plantvaluehelp                as _Plant            on  $projection.Plant = _Plant.Plant
{
      @UI.hidden: true
  key id                    as Id,
      @UI.hidden: true
  key line                  as Line,
      material              as Material,
      plant                 as Plant,
      version               as Version,
      vers_activ            as VersActiv,
      
      case vers_activ
        when 'X' then 'Sim'
                 else 'Não'
      end                   as VersActivName,
      
      date_type             as DateType,
      req_date              as ReqDate,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      req_qty               as ReqQty,
      unit                  as Unit,
      bomexpl               as BomExpl,
      prod_ves              as ProdVes,

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
      _Plant
}
