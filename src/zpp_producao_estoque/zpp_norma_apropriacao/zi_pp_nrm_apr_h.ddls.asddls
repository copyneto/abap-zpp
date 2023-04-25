@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Norma de Apropriação - Cabeçalho'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_PP_NRM_APR_H
  as select from ztpp_nrm_apr_h as _H
  composition [0..*] of ZI_PP_NRM_APR_ORD    as _Ordens
  composition [0..*] of ZI_PP_NRM_APR_CON    as _Consumo
  association [0..1] to ZI_PP_NRM_APR_STATUS as _Status on $projection.Status = _Status.StatusId
  association [0..1] to ZI_MM_VH_CENTRO      as _Centro on $projection.Plant = _Centro.Plant
  association [0..1] to ZI_PP_TIPO_ORDEM_vh  as _TipoO  on $projection.OrderType = _TipoO.OrderType

{

  key doc_uuid_h                as DocUuidH,
      documentno                as Documentno,
      docname                   as Docname,

      @Consumption.valueHelpDefinition: [{
            entity: {
                name: 'ZI_MM_VH_CENTRO',
                element: 'Plant' }
      }]
      plant                     as Plant,
      _Centro.PlantName         as PlantName,

      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_PP_TIPO_ORDEM_VH',
              element: 'OrderType'
          }
      }]
      order_type                as OrderType,
      _TipoO.OrderTypeName      as OrderTypeName,
      basic_start_date          as BasicStartDate,
      status                    as Status,
      _Status.StatusText        as StatusTxt,

      case status
        when '0' then 2 -- Pendente         | 2: yellow colour
        when '1' then 1 -- Erro             | 1: red colour
        when '2' then 3 -- Completo         | 3: green colour
        when '3' then 3 -- Encerrado        | 3: green colour
        else 0          --                  | 0: unknown
      end                       as StatusCriticality,



      @Semantics.user.createdBy: true
      created_by                as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by           as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at           as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at     as LocalLastChangedAt,

      'ZNRM_APR'                as LogObjectId,
      'PRD_GRAOS'               as LogObjectSubId,

      cast( '' as abap.char(4)) as Printer,
      _Ordens,
      _Consumo

}
