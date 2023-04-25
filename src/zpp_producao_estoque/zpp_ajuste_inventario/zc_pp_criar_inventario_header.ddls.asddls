@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projec view p/ Criação Inventário-Header'
//@ObjectModel.semanticKey: ['DocumentNo']
define root view entity ZC_PP_CRIAR_INVENTARIO_HEADER
  as projection on ZI_PP_CRIAR_INVENTARIO_HEADER
{
      key documentoUuid,
      DocumentNo,
      IdContagem,
      Plant,
      DateStart,
      DateEnd,
      DocName,
      @ObjectModel.text.element: ['StatusText']
      @EndUserText.label: 'Status'
      Status,
      _InventStatus.StatusText as StatusText,
      StatusCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Item : redirected to composition child ZC_PP_CRIAR_INVENTARIO_ITEM
}
where
     Status = ''
  or Status = '2'
