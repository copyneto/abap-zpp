@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Norma de Apropriação Ordens(ProdGrãos)'
define view entity ZI_PP_NRM_APR_ORD
  as select from    ztpp_nrm_apr_ord     as Ord

    left outer join ZI_PP_MANUFITEM_SUM  as _OrdItem531 on  Ord.order_number              = _OrdItem531.ManufacturingOrder
                                                        and _OrdItem531.GoodsMovementType = '531'
    left outer join ZI_PP_MANUFITEM_SUM  as _OrdItem532 on  Ord.order_number              = _OrdItem532.ManufacturingOrder
                                                        and _OrdItem532.GoodsMovementType = '532'
    left outer join I_ManufacturingOrder as _Order      on Ord.order_number = _Order.ManufacturingOrder

  association        to parent ZI_PP_NRM_APR_H as _H      on $projection.DocUuidH = _H.DocUuidH
  association        to C_Materialvh           as _Mat    on $projection.Material = _Mat.Material
  association [0..1] to ZI_MM_VH_CENTRO        as _Centro on $projection.Plant = _Centro.Plant
  association [0..1] to ZI_PP_TIPO_ORDEM_vh    as _TipoO  on $projection.OrderType = _TipoO.OrderType
  association [0..1] to ZI_PP_NRM_APR_STATUS   as _Status on $projection.Status = _Status.StatusId

{

  key Ord.doc_uuid_h                   as DocUuidH,
  key Ord.doc_uuid_ordem               as DocUuidOrdem,

      Ord.order_number                 as ProcessOrder,
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'C_Materialvh',
              element: 'Material'
          }
      }]
      Ord.material                     as Material,
      _Mat.MaterialName                as MaterialName,
      Ord.plant                        as Plant,
      _Centro.PlantName                as PlantName,
      Ord.order_type                   as OrderType,
      _TipoO.OrderTypeName             as OrderTypeName,
      Ord.basic_start_date             as BasicStartDate,
      @Semantics.quantity.unitOfMeasure : 'QuantityUom'
      Ord.quantity                     as Quantity,
      @Semantics.quantity.unitOfMeasure : 'QuantityUom'
      _Order.MfgOrderConfirmedYieldQty as QuantityConfirmed,
      @EndUserText.label: 'Quantidade Refugo'
      case when _OrdItem531.QuantityInBaseUnit is initial or _OrdItem531.QuantityInBaseUnit is null
            then cast( 0 as abap.dec( 13, 3 ) )
            else _OrdItem531.QuantityInBaseUnit
            end
         - case when _OrdItem532.QuantityInBaseUnit is initial or _OrdItem532.QuantityInBaseUnit is null
            then cast( 0 as abap.dec( 13, 3 ) )
            else _OrdItem532.QuantityInBaseUnit
            end                        as QuantityRefugo,

        @EndUserText.label: 'Quantidade Total'
      case when _OrdItem531.QuantityInBaseUnit is initial or _OrdItem531.QuantityInBaseUnit is null
            then cast( 0 as abap.dec( 13, 3 ) )
            else _OrdItem531.QuantityInBaseUnit
            end
         - case when _OrdItem532.QuantityInBaseUnit is initial or _OrdItem532.QuantityInBaseUnit is null
            then cast( 0 as abap.dec( 13, 3 ) )
            else _OrdItem532.QuantityInBaseUnit
            end
         + case when _Order.MfgOrderConfirmedYieldQty is initial or _Order.MfgOrderConfirmedYieldQty is null
            then cast( 0 as abap.dec( 13, 3 ) )
            else cast(_Order.MfgOrderConfirmedYieldQty as abap.dec( 13, 3 ) )
            end                        as QuantityTotal,

      @Consumption.valueHelpDefinition: [{entity: {name: 'I_UnitOfMeasureStdVH', element: 'UnitOfMeasure' }}]
      Ord.quantity_uom                 as QuantityUom,
      Ord.percentage                   as Percentage,
      100                              as Total,
      case when Ord.percentage <= 20 then 1
             when Ord.percentage <= 50 then 2
             else 3 end                as CriticalPerc,

      Ord.status                       as Status,
      _Status.StatusText               as StatusTxt,
      case Ord.status
        when '0' then 2 -- Pendente         | 2: yellow colour
        when '1' then 1 -- Erro             | 1: red colour
        when '2' then 3 -- Completo         | 3: green colour
        when '3' then 3 -- Encerrado        | 3: green colour
        else 0          --                  | 0: unknown
      end                              as StatusCriticality,
      @Semantics.user.createdBy: true
      Ord.created_by                   as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      Ord.created_at                   as CreatedAt,
      @Semantics.user.lastChangedBy: true
      Ord.last_changed_by              as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      Ord.last_changed_at              as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      Ord.local_last_changed_at        as LocalLastChangedAt,
      'ZNRM_APR'                       as LogObjectId,
      'PRD_GRAOS'                      as LogObjectSubId,
      Ord.prod_version                 as ProdVersion,

      _H
}
