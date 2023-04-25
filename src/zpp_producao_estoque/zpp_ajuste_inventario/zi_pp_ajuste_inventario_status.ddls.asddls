@EndUserText.label: 'CDS View para Ajuste de Inventário - Status'
@AbapCatalog.sqlViewName: 'ZVPP_INVENTSTAT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.dataCategory: #TEXT
define view ZI_PP_AJUSTE_INVENTARIO_STATUS
  as select from dd07t as InventStatus
{
      @UI.textArrangement: #TEXT_ONLY
      @ObjectModel.text.element: [ 'StatusText' ]
  key cast(LEFT( domvalue_l, 1 ) as ze_status_cont ) as StatusId,
      @UI.hidden: true
      @Semantics.language: true
      ddlanguage                                     as Language,
      @UI.hidden: true
      @Semantics.text:true
      ddtext                                         as StatusText
}
where
      domname  = 'ZD_STATUS_CONT'
  and as4local = 'A'
