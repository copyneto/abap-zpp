@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View para Ajuste de Inventário'
@ObjectModel.semanticKey: ['DocumentNo']
define root view entity ZI_PP_CRIAR_INVENTARIO_HEADER
  as select from ztpp_ajust_inv_h
  composition [1..*] of ZI_PP_CRIAR_INVENTARIO_ITEM    as _Item
  association [1..1] to I_Plant                        as _Plant        on $projection.Plant = _Plant.Plant
  association [0..1] to ZI_PP_AJUSTE_INVENTARIO_STATUS as _InventStatus on $projection.Status = _InventStatus.StatusId
{
  key documentouuid as documentoUuid,
      documentno               as DocumentNo,
      idcontagem               as IdContagem,
      plant                    as Plant,
      datestart                as DateStart,
      dateend                  as DateEnd,
      docname                  as DocName,
      description              as Description,
      @ObjectModel.text.element: ['StatusText']
      @EndUserText.label: 'Status'
      status                   as Status,
      _InventStatus.StatusText as StatusText,
      //Add Critically information
      case status
        when ' ' then 0 -- Pendente         | 0: unknown
        when '1' then 2 -- Em processamento | 2: yellow colour
        when '2' then 1 -- Erro             | 1: red colour
        when '3' then 3 -- Completo         | 3: green colour
        when '4' then 3 -- Encerrado        | 3: green colour
        else 0          --                  | 0: unknown
      end                      as StatusCriticality,

      @Semantics.user.createdBy: true
      created_by               as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at               as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by          as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt,

      _Item,
      _InventStatus,
      _Plant
}
