@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Arquivos de Carga de Produção'
@Metadata.allowExtensions: true
define root view entity zi_pp_arq_carga_producao
  as select from ztpp_arq_prod
  composition [1..*] of zi_pp_arq_prod_medio_prazo as _ArqMedioPrazo
  composition [1..*] of zi_pp_arq_prod_curto_prazo as _ArqCurtoPrazo
  association [0..1] to P_USER_ADDR                as _User  on $projection.Userid = _User.bname
  association [0..1] to C_Plantvaluehelp           as _Plant on $projection.Plant = _Plant.Plant

{

      @UI.hidden: true
  key id                    as Id,
      name                  as Name,
      userid                as Userid,
      import_date           as ImportDate,
      import_time           as ImportTime,

      type                  as Type,

      case type
        when 'M' then 'Planejamento de Médio Prazo'
        when 'C' then 'Planejamento de Curto Prazo'
                 else ''
      end                   as TypeName,

      plant                 as Plant,

      status                as Status,

      case status
        when 'P' then 'Processado'
        when 'L' then 'Carregado'
                 else 'Inicial'
      end                   as StatusName,

      case status
        when 'P' then 3     -- 'Processado'
        when 'L' then 2     -- 'Carregado'
                 else 1     -- 'Inicial'
      end                   as StatusCriticality,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _ArqMedioPrazo,
      _ArqCurtoPrazo,
      _User,
      _Plant
}
