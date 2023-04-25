@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Receita Mestre por Material'
define root view entity ZI_PP_RECEITA_MESTRE
  as select from    mkal as ProdMaterial
    left outer join plko as Plano           on  Plano.plnal = ProdMaterial.alnal
                                            and Plano.plnnr = ProdMaterial.plnnr
                                            and Plano.plnty = ProdMaterial.plnty
                                            and Plano.werks = ProdMaterial.werks
    left outer join mapl as AtribuicaoPlano on  AtribuicaoPlano.matnr = ProdMaterial.matnr
                                            and AtribuicaoPlano.plnnr = ProdMaterial.plnnr
                                            and AtribuicaoPlano.plnty = ProdMaterial.plnty
                                            and AtribuicaoPlano.werks = ProdMaterial.werks
                                            and AtribuicaoPlano.plnal = ProdMaterial.alnal
    left outer join plas as Roteiro         on  Roteiro.plnal = Plano.plnal
                                            and Roteiro.plnnr = Plano.plnnr
                                            and Roteiro.plnty = Plano.plnty
                                            and Roteiro.loekz <> 'X'  
    left outer join plpo as PlanoOperacao   on  PlanoOperacao.plnkn = Roteiro.plnkn
                                            and PlanoOperacao.plnnr = Roteiro.plnnr
                                            and PlanoOperacao.plnty = Roteiro.plnty
  association [0..1] to I_Material as _Material on _Material.Material = $projection.Material

{

  key      ProdMaterial.matnr                            as Material,
  key      ProdMaterial.werks                            as Centro,
  key      ProdMaterial.verid                            as VersaoPrdocucao,
  key      cast( PlanoOperacao.vornr as abap.char( 4 ) ) as NOperacao,
  key      PlanoOperacao.steus                           as ChaveControle,
           ProdMaterial.plnnr                            as Grupo,
           _Material._Text[1: Language = $session.system_language ].MaterialName,
           Plano.plnal                                   as NumeradorGrupo,


           PlanoOperacao.ltxa1                           as TextoOperacao,

           PlanoOperacao.bmsch                           as Quantidade,
           PlanoOperacao.meinh                           as UmbOperacao,

           @EndUserText.label: 'Setup'
           PlanoOperacao.vgw01                           as Valor01,
           PlanoOperacao.vge01                           as Umb01,
           @EndUserText.label: 'Máquina'
           PlanoOperacao.vgw02                           as Valor02,
           PlanoOperacao.vge02                           as Umb02,
           @EndUserText.label: 'Mão de obra'
           PlanoOperacao.vgw03                           as Valor03,
           PlanoOperacao.vge03                           as Umb03,

           @ObjectModel.virtualElement: true
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCLPP_CDS_PACOTE_MINUTO'
           Plano.bmsch                                   as PacotesPorMinuto,
           _Material.MaterialType,

           _Material

}
