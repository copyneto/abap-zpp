@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View para Ajuste de Inventário'
@ObjectModel.semanticKey: ['DocumentNo']
define root view entity ZI_PP_AJUSTE_INVENTARIO_HEADER
  as select from ztpp_ajust_inv_h as Header
  
  composition [1..*] of ZI_PP_AJUSTE_INVENTARIO_ITEM   as _Item
  
  association [1..*] to ZI_PP_AJUSTE_INVENTARIO_TOTALS as _Totals       on _Totals.Documentouuid = $projection.DocumentoUUID
  association [1..1] to I_Plant                        as _Plant        on _Plant.Plant = $projection.Plant
  association [0..1] to ZI_PP_AJUSTE_INVENTARIO_STATUS as _InventStatus on _InventStatus.StatusId = $projection.Status
  association [1..1] to I_CreatedByUser                as _User         on _User.UserName = $projection.CreatedBy
{
  key Header.documentouuid         as DocumentoUUID,
      Header.documentno            as DocumentNo,
      Header.idcontagem            as IdContagem,
      Header.plant                 as Plant,
      Header.datestart             as DateStart,
      Header.dateend               as DateEnd,
      Header.docname               as DocName,
      Header.description           as Description,
      Header.status                as Status,
      //Add Critically information
      case Header.status
        when ' ' then 0 -- Pendente         | 0: unknown
        when '1' then 2 -- Em processamento | 2: yellow colour
        when '2' then 1 -- Erro             | 1: red colour
        when '3' then 3 -- Completo         | 3: green colour
        when '4' then 3 -- Encerrado        | 3: green colour
        when '5' then 2 -- Advertência      | 2: yellow colour
        else 0          --                  | 0: unknown
      end                          as StatusCriticality,

      @Semantics.user.createdBy: true
      Header.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      Header.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      Header.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      Header.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      Header.local_last_changed_at as LocalLastChangedAt,

      _User,
      _Item,
      _Totals,
      _InventStatus,
      _Plant
}
