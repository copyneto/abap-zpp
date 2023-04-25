@AbapCatalog.sqlViewName: 'ZVPPVHORDERTP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help Search: Tipo da Ordem'
define view ZI_PP_TIPO_ORDEM_vh
  as select from    I_OrderType     as A
    left outer join I_OrderTypeText as B on A.OrderType = B.OrderType
{

  key A.OrderType,
      B.OrderTypeName


}
where
  B.Language = $session.system_language
