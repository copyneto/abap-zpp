@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'View para materiais da etiqueta'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_pp_mat_etiqueta 
as select from zi_pp_Confirmacoes_cubo as Operation

association [0..*] to I_ManufacturingOrder as _Order on $projection.ordem = _Order.ManufacturingOrder
association [0..1] to I_MaterialText as _Text on $projection.material = _Text.Material
association [0..1] to ZI_pp_mean as _Ean on $projection.material = _Ean.material 
association [0..1] to ZI_PP_BUSCAR_LOTE as _Lote on $projection.ordem = _Lote.ordem and 
                                                    $projection.confirmacao = _Lote.confirmacao and
                                                    $projection.contador = _Lote.contador

 {
 key Operation.ManufacturingOrder as ordem,
    Operation.MfgOrderConfirmation as confirmacao,
    Operation.MfgOrderConfirmationCount as contador,
    _Order._MfgOrderMaterialDocItem.ManufactureDate as dtproducao,
    Operation.Material as material,
    Operation.Plant as planta,
    @Semantics.quantity.unitOfMeasure: 'unidade'
    Operation.ConfirmationYieldQuantity as quantidade,
    Operation.ConfirmationUnit as unidade,
    Operation.PostingDate as dtlancamento,
    Operation.MfgOrderConfirmationEntryTime as hrlancamento,
    Operation.ConfirmationText as confirmacaotexto,
    _Lote.lote as lote,
    _Text.MaterialName as descricao,
    _Ean.ean as ean,
    _Ean.unidade as eanunidade,
    
 _Order,
 _Text,
 _Ean,
 _Lote
}
where _Text.Language = 'P'
group by Operation.ManufacturingOrder, 
Operation.MfgOrderConfirmation,
Operation.MfgOrderConfirmationCount,
_Order._MfgOrderMaterialDocItem.ManufactureDate,
Operation.Material,
Operation.Plant,
Operation.ConfirmationYieldQuantity,
Operation.ConfirmationUnit,
Operation.PostingDate,
Operation.MfgOrderConfirmationEntryTime,
Operation.ConfirmationText,
_Lote.lote,
_Text.MaterialName,
_Ean.ean,
_Ean.unidade
