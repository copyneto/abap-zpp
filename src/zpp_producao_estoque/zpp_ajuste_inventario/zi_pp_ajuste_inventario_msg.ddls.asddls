@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View Ajuste de Inventário-Mensagens'
define view entity ZI_PP_AJUSTE_INVENTARIO_MSG
  as select from ztpp_ajust_inv_m
//  association to parent ZI_PP_AJUSTE_INVENTARIO_ITEM as _Item on $projection.DocumentoItemUUID = _Item.DocumentoItemUUID
{
  key documentouuid     as DocumentoUUID, 
  key documentoitemuuid as DocumentoItemUUID,
  key seqnr             as Sequence,
      msgty             as MessageType,
      msgid             as MessageId,
      msgno             as MessageNo,
      msgv1             as MessageV1,
      msgv2             as MessageV2,
      msgv3             as MessageV3,
      msgv4             as MessageV4,
      message           as MessageText
      //      @Semantics.user.createdBy: true
      //      created_by            as CreatedBy,
      //      @Semantics.systemDate.createdAt: true
      //      created_at            as CreatedAt,
      //      @Semantics.user.lastChangedBy: true
      //      last_changed_by       as LastChangedBy,
      //      @Semantics.systemDate.lastChangedAt: true
      //      last_changed_at       as LastChangedAt,
      //      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      //      local_last_changed_at as LocalLastChangedAt
//      _Item
}
