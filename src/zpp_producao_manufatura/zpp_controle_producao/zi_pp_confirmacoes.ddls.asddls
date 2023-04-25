@AbapCatalog.sqlViewName: 'ZVPP_CONFORDENS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@AccessControl.personalData.blocking: #NOT_REQUIRED
@AccessControl.privilegedAssociations: ['_MRPController', '_ProductionSupervisor']
@Analytics.dataCategory: #DIMENSION
@ClientHandling.algorithm: #SESSION_VARIABLE
@Metadata.allowExtensions: true
@ObjectModel.representativeKey: 'MfgOrderConfirmationCount'
@ObjectModel.semanticKey: ['MfgOrderConfirmation', 'MfgOrderConfirmationCount']
@ObjectModel.usageType: {serviceQuality: #B, sizeCategory: #L, dataClass: #TRANSACTIONAL}
@VDM.viewType: #BASIC
@EndUserText.label: 'Confirmações de Ordens de Produção'

/*+[hideWarning] { "IDS" : [ "CALCULATED_FIELD_CHECK", "CARDINALITY_CHECK" ]  } */

define view zi_pp_Confirmacoes
  as select from afru  as afru
    inner join   caufv as aufv on aufv.aufnr = afru.aufnr

  association [1..1] to I_ConfirmationGroup           as _ConfirmationGroup           on  $projection.MfgOrderConfirmation = _ConfirmationGroup.ConfirmationGroup
  association [1..1] to I_MfgOrder                    as _MfgOrder                    on  $projection.ManufacturingOrder = _MfgOrder.ManufacturingOrder
  association [1..1] to I_MfgOrderSequence            as _MfgOrderSequence            on  $projection.ManufacturingOrder         = _MfgOrderSequence.ManufacturingOrder
                                                                                      and $projection.ManufacturingOrderSequence = _MfgOrderSequence.ManufacturingOrderSequence
  association [1..1] to I_MfgOrderOperationBasic      as _MfgOrderOperation           on  $projection.OrderInternalBillOfOperations = _MfgOrderOperation.OrderInternalBillOfOperations
                                                                                      and $projection.OrderIntBillOfOperationsItem  = _MfgOrderOperation.OrderIntBillOfOperationsItem
  association [1..1] to I_MfgOrderCategory            as _MfgOrderCategory            on  $projection.ManufacturingOrderCategory = _MfgOrderCategory.ManufacturingOrderCategory
  association [1..1] to I_MfgOrderType                as _MfgOrderType                on  $projection.ManufacturingOrderType = _MfgOrderType.ManufacturingOrderType
  association [1..1] to I_OrdInternalBillOfOperations as _OrdInternalBillOfOperations on  $projection.OrderInternalBillOfOperations = _OrdInternalBillOfOperations.OrderInternalBillOfOperations
  association [0..1] to I_FinalConfirmationType       as _FinalConfirmationType       on  $projection.FinalConfirmationType = _FinalConfirmationType.FinalConfirmationType
  association [0..1] to I_ConfirmationRecordType      as _ConfirmationRecordType      on  $projection.OrderConfirmationRecordType = _ConfirmationRecordType.OrderConfirmationRecordType
  association [1..1] to I_UnitOfMeasure               as _ConfirmationUnit            on  $projection.ConfirmationUnit = _ConfirmationUnit.UnitOfMeasure
  association [1..1] to I_User                        as _User                        on  $projection.EnteredByUser = _User.UserID
  association [1..1] to I_Plant                       as _ProductionPlant             on  $projection.ProductionPlant = _ProductionPlant.Plant
  association [0..1] to I_WorkCenterType              as _WorkCenterType              on  $projection.WorkCenterTypeCode = _WorkCenterType.WorkCenterTypeCode
  association [0..1] to I_WorkCenter                  as _WorkCenter                  on  $projection.WorkCenterTypeCode   = _WorkCenter.WorkCenterTypeCode
                                                                                      and $projection.WorkCenterInternalID = _WorkCenter.WorkCenterInternalID
  association [0..1] to I_Plant                       as _Plant                       on  $projection.Plant = _Plant.Plant
  association [0..1] to I_Capacity                    as _Capacity                    on  $projection.CapacityInternalID = _Capacity.CapacityInternalID
  association [0..1] to I_ShiftGrouping               as _ShiftGrouping               on  $projection.ShiftGrouping = _ShiftGrouping.ShiftGrouping
  association [0..*] to I_ShiftDefinition             as _ShiftDefinition             on  $projection.ShiftGrouping   = _ShiftDefinition.ShiftGrouping
                                                                                      and $projection.ShiftDefinition = _ShiftDefinition.ShiftDefinition
  association [0..1] to I_ProductionSupervisor        as _ProductionSupervisor        on  $projection.Plant                = _ProductionSupervisor.Plant
                                                                                      and $projection.ProductionSupervisor = _ProductionSupervisor.ProductionSupervisor
  association [0..1] to I_MRPController               as _MRPController               on  $projection.Plant         = _MRPController.Plant
                                                                                      and $projection.MRPController = _MRPController.MRPController
  association [0..1] to I_Language                    as _Language                    on  $projection.Language = _Language.Language
  association [0..1] to I_BusinessArea                as _BusinessArea                on  $projection.BusinessArea = _BusinessArea.BusinessArea
  association [0..1] to I_CompanyCode                 as _CompanyCode                 on  $projection.CompanyCode = _CompanyCode.CompanyCode
  association [0..1] to I_ControllingArea             as _ControllingArea             on  $projection.ControllingArea = _ControllingArea.ControllingArea
  association [0..*] to I_ProfitCenter                as _ProfitCenter                on  $projection.ControllingArea = _ProfitCenter.ControllingArea
                                                                                      and $projection.ProfitCenter    = _ProfitCenter.ProfitCenter
  association [0..1] to I_ProductCostCtrlgOrder       as _ProductCostCollector        on  $projection.ProductCostCollector = _ProductCostCollector.OrderID
  association [0..1] to I_BusinessProcess             as _BusinessProcess             on  $projection.ControllingArea = _BusinessProcess.ControllingArea
                                                                                      and $projection.BusinessProcess = _BusinessProcess.BusinessProcess
  association [0..1] to I_UnitOfMeasure               as _BusinessProcessUnit         on  $projection.BusinessProcessEntryUnit = _BusinessProcessUnit.UnitOfMeasure
  association [0..1] to I_UnitOfMeasure               as _WorkQuantityUnit1           on  $projection.OpWorkQuantityUnit1 = _WorkQuantityUnit1.UnitOfMeasure
  association [0..1] to I_UnitOfMeasure               as _WorkQuantityUnit2           on  $projection.OpWorkQuantityUnit2 = _WorkQuantityUnit2.UnitOfMeasure
  association [0..1] to I_UnitOfMeasure               as _WorkQuantityUnit3           on  $projection.OpWorkQuantityUnit3 = _WorkQuantityUnit3.UnitOfMeasure
  association [0..1] to I_UnitOfMeasure               as _WorkQuantityUnit4           on  $projection.OpWorkQuantityUnit4 = _WorkQuantityUnit4.UnitOfMeasure
  association [0..1] to I_UnitOfMeasure               as _WorkQuantityUnit5           on  $projection.OpWorkQuantityUnit5 = _WorkQuantityUnit5.UnitOfMeasure
  association [0..1] to I_UnitOfMeasure               as _WorkQuantityUnit6           on  $projection.OpWorkQuantityUnit6 = _WorkQuantityUnit6.UnitOfMeasure
  association [0..1] to I_UnitOfMeasure               as _BreakDurationUnit           on  $projection.BreakDurationUnit = _BreakDurationUnit.UnitOfMeasure
  association [0..1] to I_VarianceReason              as _VarianceReason              on  $projection.Plant              = _VarianceReason.Plant
                                                                                      and $projection.VarianceReasonCode = _VarianceReason.VarianceReasonCode
  association [0..1] to I_EmployeeWageGroup           as _EmployeeWageGroup           on  $projection.Plant             = _EmployeeWageGroup.Plant
                                                                                      and $projection.EmployeeWageGroup = _EmployeeWageGroup.EmployeeWageGroup
  association [0..1] to I_EmployeeSuitability         as _EmployeeSuitability         on  $projection.Plant               = _EmployeeSuitability.Plant
                                                                                      and $projection.EmployeeSuitability = _EmployeeSuitability.EmployeeSuitability
  --association [0..1] to I_Employee                    as _Employee                    on  $projection.Personnel = _Employee.Employee
  association [0..1] to I_WorkforcePerson             as _Employee                    on  $projection.Personnel = _Employee.PersonExternalID
{
      // Key
      @ObjectModel.foreignKey.association: '_ConfirmationGroup'
  key afru.rueck                                                        as MfgOrderConfirmation,
      @ObjectModel.text.element: 'ConfirmationText'
  key afru.rmzhl                                                        as MfgOrderConfirmationCount,

      // Order and operation data
      @ObjectModel.foreignKey.association: '_MfgOrder'
      cast(afru.aufnr as manufacturingorder preserving type)            as ManufacturingOrder,
      @ObjectModel.foreignKey.association: '_MfgOrderSequence'
      cast(afru.aplfl as manufacturingordersequence preserving type)    as ManufacturingOrderSequence,
      --    @ObjectModel.foreignKey.association: '_MfgOrderOperation'
      cast(afru.vornr as manufacturingorderoperation preserving type)   as ManufacturingOrderOperation,
      @ObjectModel.foreignKey.association: '_MfgOrderCategory'
      cast(aufv.autyp as manufacturingordercategory preserving type)    as ManufacturingOrderCategory,
      @ObjectModel.foreignKey.association: '_MfgOrderType'
      cast(aufv.auart as manufacturingordertype preserving type)        as ManufacturingOrderType,
      @ObjectModel.foreignKey.association: '_ProductionPlant'
      cast(aufv.werks as pwwrk preserving type)                         as ProductionPlant,
      @ObjectModel.foreignKey.association: '_ProductionSupervisor'
      cast(aufv.fevor as pph_fevor preserving type)                     as ProductionSupervisor,
      @ObjectModel.foreignKey.association: '_MRPController'
      cast(aufv.dispo as pph_dispo preserving type)                     as MRPController,

      @ObjectModel.foreignKey.association: '_OrdInternalBillOfOperations'
      cast(afru.aufpl as orderinternalbillofoperations preserving type) as OrderInternalBillOfOperations,
      @ObjectModel.foreignKey.association: '_MfgOrderOperation'
      cast(afru.aplzl as orderintbillofoperationsitem preserving type)  as OrderIntBillOfOperationsItem,

      // Assignments
      @ObjectModel.foreignKey.association: '_Plant'
      afru.werks                                                        as Plant,
      @ObjectModel.foreignKey.association: '_WorkCenterType'
      cast('A '       as pph_objty preserving type)                     as WorkCenterTypeCode,
      @ObjectModel.foreignKey.association: '_WorkCenter'
      cast(afru.arbid as pph_arbid preserving type)                     as WorkCenterInternalID,
      @ObjectModel.foreignKey.association: '_Capacity'
      afru.kapid                                                        as CapacityInternalID,
      cast(afru.split as pph_split preserving type)                     as CapacityRequirementSplit,
      @ObjectModel.foreignKey.association: '_ShiftGrouping'
      afru.schgrup                                                      as ShiftGrouping,
      --    @ObjectModel.foreignKey.association: '_ShiftDefinition'
      afru.kaptprog                                                     as ShiftDefinition,

      // Short Text
      @Semantics.text: true
      cast(afru.ltxa1 as pph_rtext preserving type)                     as ConfirmationText,
      @ObjectModel.foreignKey.association: '_Language'
      cast(afru.txtsp as spras preserving type)                         as Language,

      // Attributes
      @ObjectModel.foreignKey.association: '_FinalConfirmationType'
      cast(afru.aueru as pph_aueru preserving type)                     as FinalConfirmationType,
      cast(case afru.aueru
        when 'X' then 'X'
        else ''
      end as endru preserving type)                                     as IsFinalConfirmation,
      afru.ausor                                                        as OpenReservationsIsCleared,
      afru.stokz                                                        as IsReversed,
      cast(case afru.stzhl
        when '00000000' then ''
        else 'X'
      end as pph_stzhl preserving type)                                 as IsReversal,
      afru.stzhl                                                        as CancldMfgOrderOpConfCount,
      cast(case afru.manur
        when '2' then 'X'
        else ''
      end as pph_meilr preserving type)                                 as IsConfirmedByMilestoneConf,
      afru.meilr                                                        as MilestoneIsConfirmed,
      @ObjectModel.foreignKey.association: '_ConfirmationRecordType'
      afru.satza                                                        as OrderConfirmationRecordType,

      // Admin
      @Semantics.systemDate.createdAt: true
      cast(afru.ersda as ru_ersda preserving type)                      as MfgOrderConfirmationEntryDate,
      @Semantics.systemTime.createdAt: true
      cast(afru.erzet as ru_erzet preserving type)                      as MfgOrderConfirmationEntryTime,
      @Semantics.user.createdBy: true
      cast(afru.ernam as ru_ernam preserving type)                      as EnteredByUser,
      @Semantics.systemDate.lastChangedAt: true
      afru.laeda                                                        as LastChangeDate,
      @Semantics.user.lastChangedBy: true
      afru.aenam                                                        as LastChangedByUser,
      @Semantics.systemDate.createdAt: true
      cast(afru.exerd as ru_exerd preserving type)                      as ConfirmationExternalEntryDate,
      @Semantics.systemTime.createdAt: true
      cast(afru.exerz as ru_exerz preserving type)                      as ConfirmationExternalEntryTime,
      cast(afru.exnam as ru_exnam preserving type)                      as EnteredByExternalUser,

      // Assignments FI/CO
      @ObjectModel.foreignKey.association: '_BusinessArea'
      aufv.gsber                                                        as BusinessArea,
      @ObjectModel.foreignKey.association: '_CompanyCode'
      aufv.bukrs                                                        as CompanyCode,
      @ObjectModel.foreignKey.association: '_ControllingArea'
      aufv.kokrs                                                        as ControllingArea,
      @ObjectModel.foreignKey.association: '_ProfitCenter'
      aufv.prctr                                                        as ProfitCenter,
      @ObjectModel.foreignKey.association: '_ProductCostCollector'
      cast(aufv.pkosa as pkosa_d preserving type)                       as ProductCostCollector,

      // Assignments HR
      --    @ObjectModel.foreignKey.association: '_Employee'
      cast(afru.pernr as pph_pernr preserving type)                     as Personnel,
      cast(afru.zausw as pph_zausw preserving type)                     as TimeRecording,
      cast(afru.loart as pph_loart preserving type)                     as EmployeeWageType,
      @ObjectModel.foreignKey.association: '_EmployeeWageGroup'
      cast(afru.logrp as pph_logrp preserving type)                     as EmployeeWageGroup,
      @ObjectModel.foreignKey.association: '_EmployeeSuitability'
      cast(afru.qualf as pph_qualf preserving type)                     as EmployeeSuitability,
      cast(afru.anzma as pph_anzms preserving type)                     as NumberOfEmployees,

      // Dates
      @Semantics.businessDate.at: true
      cast(afru.budat as pph_budat preserving type)                     as PostingDate,

      // Time Events
      afru.isdd                                                         as ConfirmedExecutionStartDate,
      afru.isdz                                                         as ConfirmedExecutionStartTime,
      afru.ierd                                                         as ConfirmedSetupEndDate,
      afru.ierz                                                         as ConfirmedSetupEndTime,
      afru.isbd                                                         as ConfirmedProcessingStartDate,
      afru.isbz                                                         as ConfirmedProcessingStartTime,
      afru.iebd                                                         as ConfirmedProcessingEndDate,
      afru.iebz                                                         as ConfirmedProcessingEndTime,
      afru.isad                                                         as ConfirmedTeardownStartDate,
      afru.isaz                                                         as ConfirmedTeardownStartTime,
      afru.iedd                                                         as ConfirmedExecutionEndDate,
      afru.iedz                                                         as ConfirmedExecutionEndTime,
      cast(afru.pedd as pph_pedd preserving type)                       as ActualForecastEndDate,
      cast(afru.pedz as pph_pedz preserving type)                       as ActualForecastEndTime,

      // Confirmation Quantities and UoM
      @ObjectModel.foreignKey.association: '_VarianceReason'
      cast(afru.grund as pph_agrnd preserving type)                     as VarianceReasonCode,
      @Semantics.unitOfMeasure: true
      afru.meinh                                                        as ConfirmationUnit,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      @DefaultAggregation: #SUM
      afru.lmnga                                                        as ConfirmationYieldQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      @DefaultAggregation: #SUM
      afru.xmnga                                                        as ConfirmationScrapQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      @DefaultAggregation: #SUM
      afru.rmnga                                                        as ConfirmationReworkQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      @DefaultAggregation: #SUM
      cast((afru.lmnga + afru.xmnga + afru.rmnga) as pph_tmnga)         as ConfirmationTotalQuantity,

      @Semantics.unitOfMeasure: true
      cast(afru.gmein as productionunit preserving type)                as ProductionUnit,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      @DefaultAggregation: #SUM
      afru.gmnga                                                        as ConfYieldQtyInProductionUnit,

      --    @Semantics.quantity.unitOfMeasure: 'OperationUnit' // not yet available
      afru.smeng                                                        as OpPlannedTotalQuantity,

      // Header Quantities and UoM
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      @DefaultAggregation: #SUM
      cast(aufv.igmng as co_igmng preserving type)                      as MfgOrderConfirmedYieldQty,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      @DefaultAggregation: #SUM
      cast(aufv.iasmg as co_iasmg preserving type)                      as MfgOrderConfirmedScrapQty,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      @DefaultAggregation: #SUM
      cast(aufv.rmnga as rmnga preserving type)                         as MfgOrderConfirmedReworkQty,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      @DefaultAggregation: #SUM
      cast((aufv.igmng + aufv.iasmg + aufv.rmnga) as pph_tmnga)         as MfgOrderConfirmedTotalQty,

      // Work Quantities and UoM
      @Semantics.unitOfMeasure: true
      cast(afru.ile01 as pph_ismngeh preserving type)                   as OpWorkQuantityUnit1,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit1'
      @DefaultAggregation: #SUM
      afru.ism01                                                        as OpConfirmedWorkQuantity1,
      afru.lek01                                                        as NoFurtherOpWorkQuantity1IsExpd,
      @Semantics.unitOfMeasure: true
      cast(afru.ile02 as pph_ismngeh preserving type)                   as OpWorkQuantityUnit2,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit2'
      @DefaultAggregation: #SUM
      afru.ism02                                                        as OpConfirmedWorkQuantity2,
      afru.lek02                                                        as NoFurtherOpWorkQuantity2IsExpd,
      @Semantics.unitOfMeasure: true
      cast(afru.ile03 as pph_ismngeh preserving type)                   as OpWorkQuantityUnit3,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit3'
      @DefaultAggregation: #SUM
      afru.ism03                                                        as OpConfirmedWorkQuantity3,
      afru.lek03                                                        as NoFurtherOpWorkQuantity3IsExpd,
      @Semantics.unitOfMeasure: true
      cast(afru.ile04 as pph_ismngeh preserving type)                   as OpWorkQuantityUnit4,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit4'
      @DefaultAggregation: #SUM
      afru.ism04                                                        as OpConfirmedWorkQuantity4,
      afru.lek04                                                        as NoFurtherOpWorkQuantity4IsExpd,
      @Semantics.unitOfMeasure: true
      cast(afru.ile05 as pph_ismngeh preserving type)                   as OpWorkQuantityUnit5,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit5'
      @DefaultAggregation: #SUM
      afru.ism05                                                        as OpConfirmedWorkQuantity5,
      afru.lek05                                                        as NoFurtherOpWorkQuantity5IsExpd,
      @Semantics.unitOfMeasure: true
      cast(afru.ile06 as pph_ismngeh preserving type)                   as OpWorkQuantityUnit6,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit6'
      @DefaultAggregation: #SUM
      afru.ism06                                                        as OpConfirmedWorkQuantity6,
      afru.lek06                                                        as NoFurtherOpWorkQuantity6IsExpd,

      // Business Process
      @ObjectModel.foreignKey.association: '_BusinessProcess'
      afru.prz01                                                        as BusinessProcess,
      @Semantics.unitOfMeasure: true
      afru.ipre1                                                        as BusinessProcessEntryUnit,
      @Semantics.quantity.unitOfMeasure: 'BusinessProcessEntryUnit'
      @DefaultAggregation: #SUM
      afru.iprz1                                                        as BusinessProcessConfirmedQty,
      afru.iprk1                                                        as NoFurtherBusinessProcQtyIsExpd,
      @Semantics.unitOfMeasure: true
      afru.opre1                                                        as BusinessProcRemainingQtyUnit,
      @Semantics.quantity.unitOfMeasure: 'BusinessProcRemainingQtyUnit'
      @DefaultAggregation: #SUM
      cast(afru.oprz1 as pph_oprz1 preserving type)                     as BusinessProcessRemainingQty,

      // Durations
      @Semantics.unitOfMeasure: true
      afru.zeier                                                        as BreakDurationUnit,
      @Semantics.calendarItem.duration: true
      afru.iserh                                                        as ConfirmedBreakDuration,

      // Associations
      _ConfirmationGroup,
      @VDM.lifecycle.status: #DEPRECATED
      _MfgOrder,
      _MfgOrderSequence,
      _MfgOrderOperation,
      _MfgOrderCategory,
      _MfgOrderType,
      @VDM.lifecycle.status: #DEPRECATED
      _OrdInternalBillOfOperations,
      _FinalConfirmationType,
      _ConfirmationRecordType,
      _ConfirmationUnit,
      _User,
      _Language,
      _WorkCenterType,
      _WorkCenter,
      _Plant,
      _ProductionPlant,
      _ProductionSupervisor,
      _MRPController,
      _Capacity,
      _ShiftGrouping,
      _ShiftDefinition,
      _BusinessArea,
      _CompanyCode,
      _ControllingArea,
      _ProfitCenter,
      _ProductCostCollector,
      _BusinessProcess,
      _BusinessProcessUnit,
      _WorkQuantityUnit1,
      _WorkQuantityUnit2,
      _WorkQuantityUnit3,
      _WorkQuantityUnit4,
      _WorkQuantityUnit5,
      _WorkQuantityUnit6,
      _BreakDurationUnit,
      _VarianceReason,
      _EmployeeWageGroup,
      _EmployeeSuitability,
      _Employee
}
where
     afru.orind = '2'
  or afru.orind = '6' //Manufacturing Orders only
  or afru.orind = '8'; //including results recording
