@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View para Ajuste de Inventário-Item'
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory : #L
@ObjectModel.usageType.dataClass: #MASTER
define view entity ZI_PP_AJUSTE_INVENTARIO_ITEM
  as select from ztpp_ajust_inv_i
  association        to parent ZI_PP_AJUSTE_INVENTARIO_HEADER as _Header          on  $projection.DocumentoUUID = _Header.DocumentoUUID
  association [1..1] to I_Material                            as _Material        on  $projection.Material = _Material.Material
  association [1..1] to I_Plant                               as _Plant           on  $projection.Plant = _Plant.Plant
  association [0..1] to I_StorageLocation                     as _StorageLocation on  $projection.Plant           = _StorageLocation.Plant
                                                                                  and $projection.StorageLocation = _StorageLocation.StorageLocation
  association [0..1] to I_Currency                            as _Currency        on  $projection.Currency = _Currency.Currency
  association [0..*] to I_MaterialText                        as _MaterialText    on  $projection.Material = _MaterialText.Material
  association [0..1] to ZI_PP_AJUSTE_INVENTARIO_STATUS        as _ItemStatus      on  $projection.Status = _ItemStatus.StatusId
  association [0..1] to ZI_PP_AJUSTE_INVENTARIO_MSG           as _Messages        on  $projection.DocumentoItemUUID = _Messages.DocumentoItemUUID
{
  key documentoitemuuid                                                                                  as DocumentoItemUUID,
      documentouuid                                                                                      as DocumentoUUID,
      @Semantics.text: true
      material                                                                                           as Material,
      plant                                                                                              as Plant,
      storagelocation                                                                                    as StorageLocation,
      batch                                                                                              as Batch,
      @Semantics.amount.currencyCode: 'Currency'
      price                                                                                              as Price,
      currency                                                                                           as Currency,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      quantity                                                                                           as Quantity,
      unit                                                                                               as Unit,
      @Semantics.amount.currencyCode: 'Currency'
      fltp_to_dec( ( cast( quantity as abap.fltp ) * cast( price as abap.fltp ) ) as abap.dec( 13, 2 ) ) as TotalQuantity,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      counting                                                                                           as Counting,
      @Semantics.amount.currencyCode: 'Currency'
      fltp_to_dec( ( cast( counting as abap.fltp ) * cast( price as abap.fltp ) ) as abap.dec( 13, 2 ) ) as TotalCounting,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      case counting
        when 0 then 0
        else
         cast( quantity as abap.dec( 13, 3 )) - cast( counting as abap.dec( 13, 3 ) )
      end                                                                                                as Balance,
      @Semantics.amount.currencyCode: 'Currency'
      case counting
        when 0 then 0
        else
      ( cast( quantity as abap.dec( 13, 3 )) - cast( counting as abap.dec( 13, 3 ) ) ) * cast( price as abap.dec( 13, 3 ) )
      end                                                                                                as TotalBalance,

      cast( case
            when counting = 0
              or quantity = 0
              or price = 0
            then 0
            else
              ( 1 - abs( ( division(fltp_to_dec(cast(quantity as abap.fltp) - cast(counting as abap.fltp) as abap.dec(13,4)),
                                    fltp_to_dec(cast(quantity as abap.fltp) as abap.dec(13,4)), 4) ) ) ) * 100
            end  as abap.dec(13,2))                                                                      as Accuracy,

      cast( '%' as meins )                                                                               as Percentage,
      status                                                                                             as Status,
      _MaterialText[  Language = $session.system_language ].MaterialName                                 as MaterialName,
      //Add Critically information
      case status
        when ' ' then 0 -- Pendente         | 0: unknown
        when '1' then 2 -- Em processamento | 2: yellow colour
        when '2' then 1 -- Erro             | 1: red colour
        when '3' then 3 -- Completo         | 3: green colour
        when '4' then 3 -- Encerrado        | 3: green colour
        when '5' then 2 -- Advertência      | 2: yellow colour
        else 0          --                  | 0: unknown
      end                                                                                                as StatusCriticality,

      @Semantics.user.createdBy: true
      created_by                                                                                         as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                                                                                         as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                                                                                    as LastChangedBy,
      @Semantics.systemDate.lastChangedAt: true
      last_changed_at                                                                                    as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                                                                              as LocalLastChangedAt,

      _Header,
      _Material,
      _Plant,
      _StorageLocation,
      _Currency,
      _MaterialText,
      _Messages,
      _ItemStatus
}
