@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS View para Ajuste de Inventário-Sum'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory : #L
@ObjectModel.usageType.dataClass: #MASTER
define view entity ZI_PP_AJUSTE_INVENTARIO_TOTALS
  as select from ztpp_ajust_inv_i as _Item  
{
      @EndUserText.label: 'Guid Total'
  key _Item.documentouuid                                                                                                                            as Documentouuid,
      @EndUserText.label: 'Unidade de Medida'
  key _Item.unit                                                                                                                                     as Unit,
      @EndUserText.label: 'Moeda'
  key _Item.currency                                                                                                                                 as Currency,
      @EndUserText.label: 'Unidade'
      cast( '%' as meins )                                                                                                                           as Percentage,
      @EndUserText.label: 'Total Unitário'
      @Semantics.amount.currencyCode: 'Currency'
      sum( _Item.price )                                                                                                                             as SumPrice,
      @EndUserText.label: 'Quantidade Estoque'
      @Semantics.quantity.unitOfMeasure: 'Unit'
      sum( _Item.quantity )                                                                                                                          as SumQuantity,
      @EndUserText.label: 'Valor Estoque'
      @Semantics.amount.currencyCode: 'Currency'
      sum( fltp_to_dec( ( cast( _Item.quantity as abap.fltp ) * cast( _Item.price as abap.fltp ) ) as abap.dec( 13, 2 ) ) )                          as SumTotalQuantity,
      @EndUserText.label: 'Quantidade Contagem'
      @Semantics.quantity.unitOfMeasure: 'Unit'
      sum( _Item.counting )                                                                                                                          as SumCounting,
      @EndUserText.label: 'Valor Contagem'
      @Semantics.amount.currencyCode: 'Currency'
      sum( fltp_to_dec( ( cast( _Item.counting as abap.fltp ) * cast( _Item.price as abap.fltp ) ) as abap.dec( 13, 2 ) ) )                          as SumTotalCounting,
      @EndUserText.label: 'Quantidade Saldo'
      @Semantics.quantity.unitOfMeasure: 'Unit'
      sum( cast( _Item.quantity as abap.dec( 13, 3 )) - cast( _Item.counting as abap.dec( 13, 3 ) ) )                                                as SumBalance,
      @EndUserText.label: 'Valor Saldo'
      @Semantics.amount.currencyCode: 'Currency'
      sum( abs( ( cast( _Item.quantity as abap.dec( 13, 3 )) - cast( _Item.counting as abap.dec( 13, 3 ) ) ) * cast( _Item.price as abap.dec( 13, 3 ) ) ) ) as SumTotalBalance,
      @EndUserText.label: 'Acuracidade'
      @Semantics.quantity.unitOfMeasure: 'Percentage'
      cast( case
            when sum( _Item.counting ) = 0
              or sum( fltp_to_dec( ( cast( _Item.quantity as abap.fltp ) * cast( _Item.price as abap.fltp ) ) as abap.dec( 13, 2 ) ) ) = 0
            then 0
            else
              ( 1 - abs( (division(sum( (cast(_Item.quantity as abap.dec(13,3)) - cast(_Item.counting as abap.dec(13,3)))),
                                   sum( fltp_to_dec((cast(_Item.quantity as abap.fltp)) as abap.dec(13,4)) ), 4) ) ) ) * 100
            end as abap.dec(13,2))                                                                                                                   as AvgAccuracy
}
group by
  _Item.documentouuid,
  _Item.currency,
  _Item.unit
