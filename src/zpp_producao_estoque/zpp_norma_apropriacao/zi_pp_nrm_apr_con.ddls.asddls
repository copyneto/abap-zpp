@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Norma de Apropriação(Grãos Consumidos)'
define view entity ZI_PP_NRM_APR_CON
  as select from ztpp_nrm_apr_con
  association        to parent ZI_PP_NRM_APR_H as _H      on $projection.DocUuidH = _H.DocUuidH
  association [0..1] to ZI_PP_NRM_APR_STATUS   as _Status on $projection.Status = _Status.StatusId
  association [0..1] to ZI_MM_VH_CENTRO        as _Centro on $projection.Plant = _Centro.Plant
{

  key doc_uuid_h            as DocUuidH,
  key doc_uuid_consumo      as DocUuidConsumo,
      @Consumption.valueHelpDefinition: [{
              entity: {
                  name: 'C_Materialvh',
                  element: 'Material'
              }
          }]
      material              as Material,
      plant                 as Plant,
      _Centro.PlantName     as PlantName,
      @Consumption.valueHelpDefinition: [{
              entity: {
                  name: 'ZI_CA_VH_DEPOSITO',
                  element: 'lgort' },
                  additionalBinding: [{  element: 'werks', localElement: 'plant' }]
          }]
      stge_loc              as StgeLoc,
      batch                 as Batch,
      @Semantics.quantity.unitOfMeasure : 'EntryUom'
      entry_qnt             as EntryQnt,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_UnitOfMeasureStdVH', element: 'UnitOfMeasure' }}]
      entry_uom             as EntryUom,
      status                as Status,
      _Status.StatusText    as StatusTxt,

      case status
        when '0' then 2 -- Pendente         | 2: yellow colour
        when '1' then 1 -- Erro             | 1: red colour
        when '2' then 3 -- Completo         | 3: green colour
        when '3' then 3 -- Encerrado        | 3: green colour
        else 0          --                  | 0: unknown
      end                   as StatusCriticality,
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
      'ZNRM_APR'            as LogObjectId,
      'PRD_GRAOS'          as LogObjectSubId,

      _H
}
