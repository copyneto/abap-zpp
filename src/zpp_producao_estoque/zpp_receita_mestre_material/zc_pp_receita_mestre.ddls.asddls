@EndUserText.label: 'Receita Mestre por Material'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZC_PP_RECEITA_MESTRE as projection on ZI_PP_RECEITA_MESTRE as ReceitaMestre {
    @Search.defaultSearchElement: true    
    key Material,
    @Search.defaultSearchElement: true
    key Centro,
    @Search.defaultSearchElement: true
    key VersaoPrdocucao,
    key NOperacao,
    key ChaveControle,
    Grupo,
    MaterialName,
    NumeradorGrupo,    
    TextoOperacao,
    UmbOperacao,
    Quantidade,
    Valor01,
    Umb01,
    Valor02,
    Umb02,
    Valor03,
    Umb03,
    @EndUserText.label: 'Pacotes P/Minuto'
    PacotesPorMinuto,
    MaterialType,
    /* Associations */
    _Material
}
