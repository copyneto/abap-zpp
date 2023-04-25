@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Estoque Inventário de Produção'
@Metadata.allowExtensions: true
view entity ZC_PP_INVENTARIO_PRODUCAO
  with parameters
    p_datade  : abap.dats,
    p_dataate : abap.dats
  as select from ZC_PP_INVENT_PROD_DOC_ITEM( p_datade: $parameters.p_datade , p_dataate: $parameters.p_dataate ) as inventProdDocItem
    join         I_MaterialStock                                                                                                         on  I_MaterialStock.Material               = inventProdDocItem.Material
                                                                                                                                         and I_MaterialStock.Plant                  = inventProdDocItem.Plant
                                                                                                                                         and I_MaterialStock.Batch                  = inventProdDocItem.Batch
                                                                                                                                         and I_MaterialStock.MatlDocLatestPostgDate <= $parameters.p_dataate
    join         I_CurrentMatlPriceByCostEst                                                                     as I_MatlPriceByCostEst on  I_MatlPriceByCostEst.Material      = I_MaterialStock.Material
                                                                                                                                         and I_MatlPriceByCostEst.ValuationArea = I_MaterialStock.Plant

{
      @Semantics.text: true
  key inventProdDocItem.Material                          as Material,
  key inventProdDocItem.Plant                             as Plant,
  key inventProdDocItem.Batch                             as Batch,
  key I_MaterialStock.StorageLocation                     as StorageLocation,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      sum( I_MaterialStock.MatlWrhsStkQtyInMatlBaseUnit ) as MatlWrhsStkQtyInMatlBaseUnit,
      I_MaterialStock.MaterialBaseUnit                    as MaterialBaseUnit,
      DIVISION( cast( I_MatlPriceByCostEst.InventoryPrice as abap.dec( 11, 2 ) ),
        I_MatlPriceByCostEst.MaterialPriceUnitQty, 2 )    as PriceUnit,
      I_MatlPriceByCostEst.Currency                       as Currency

}
group by
  inventProdDocItem.Material,
  inventProdDocItem.Plant,
  inventProdDocItem.Batch,
  I_MaterialStock.StorageLocation,
  I_MaterialStock.MaterialBaseUnit,
  I_MatlPriceByCostEst.InventoryPrice,
  I_MatlPriceByCostEst.MaterialPriceUnitQty,
  I_MatlPriceByCostEst.Currency
