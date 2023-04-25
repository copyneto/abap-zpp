@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Logs de Ordens de Produção'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_PP_LOG_ORDENS_PRODUCAO
  as select from ztpp_log_mes
{

  key z_log_no                       as ZLogNo,
      ltrim(manufacturingorder, '0') as ManufacturingOrder,
      ltrim(material, '0')           as Material,
      ltrim(confirmacao, '0')        as Confirmacao,
      ltrim(contador, '0')           as Contador,
      prodplant                      as ProdPlant,
      date_cr                        as DateCr,
      @Semantics.systemDateTime.createdAt: true
      created_at                     as CreatedAt,
      z_reciv_mes                    as ZRecivMes,
      z_msg_mes                      as ZMsgMes
}
