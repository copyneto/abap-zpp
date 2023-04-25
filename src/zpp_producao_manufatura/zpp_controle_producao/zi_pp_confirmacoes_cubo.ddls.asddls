@AbapCatalog.sqlViewName: 'ZVPP_CONFCUBO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@AccessControl.personalData.blocking: #NOT_REQUIRED
@Analytics.dataCategory: #CUBE
@ClientHandling.algorithm: #SESSION_VARIABLE
@ClientHandling.type: #CLIENT_DEPENDENT
@Metadata.allowExtensions: true
@ObjectModel.usageType: {serviceQuality: #C, sizeCategory: #L, dataClass: #MIXED}
@VDM.viewType: #COMPOSITE
@EndUserText.label: 'Cubo de Confirmações de Ord. Prod.'
define view zi_pp_Confirmacoes_cubo
  as select from zi_pp_Confirmacoes   as conf
    inner join   I_OrderItem          as item on  item.OrderID   = conf.ManufacturingOrder
                                              and item.OrderItem = '0001'
  //inner join   I_MfgOrderOperationBasic as oper on  oper.OrderInternalBillOfOperations = conf.OrderInternalBillOfOperations
  //                                              and oper.OrderIntBillOfOperationsItem  = conf.OrderIntBillOfOperationsItem
    inner join   P_PPH_ReportingDate3 as date on conf.ConfirmedExecutionEndDate = date.ReportingDate

  association [0..1] to I_WorkCenterBySemanticKey as _WorkCenterBySemanticKey on  $projection.WorkCenter      = _WorkCenterBySemanticKey.WorkCenter
                                                                              and $projection.ProductionPlant = _WorkCenterBySemanticKey.Plant
  association [1..1] to I_CalendarDate            as _PostingDate             on  $projection.PostingDate = _PostingDate.CalendarDate
  association [1..1] to I_CalendarDate            as _EntryDate               on  $projection.MfgOrderConfirmationEntryDate = _EntryDate.CalendarDate
  association [0..1] to I_CalendarDate            as _LastChangeDate          on  $projection.LastChangeDate = _LastChangeDate.CalendarDate
  association [0..1] to I_WeekDay                 as _EntryDateWeekDay        on  $projection.EntryDateWeekDay = _EntryDateWeekDay.WeekDay
  association [0..1] to I_CalendarMonth           as _EntryDateMonth          on  $projection.EntryDateMonth = _EntryDateMonth.CalendarMonth
  association [1..1] to I_ReportingPeriod         as _ReportingPeriod         on  $projection.ReportingPeriod = _ReportingPeriod.ReportingPeriod
{
      // Key
      @ObjectModel.foreignKey.association: '_ConfirmationGroup'
  key conf.MfgOrderConfirmation,
      @ObjectModel.text.element: 'ConfirmationText'
  key conf.MfgOrderConfirmationCount,

      // Short Text
      @Semantics.text: true
      conf.ConfirmationText,
      @ObjectModel.foreignKey.association: '_Language'
      conf.Language,

      // Assignments
      @ObjectModel.foreignKey.association: '_Material'
      item.Material,
      @ObjectModel.foreignKey.association: '_Plant'
      conf.Plant,
      @ObjectModel.foreignKey.association: '_WorkCenterBySemanticKey'
      cast(conf._WorkCenter.WorkCenter as pph_arbpl preserving type)                 as WorkCenter,
      @ObjectModel.foreignKey.association: '_WorkCenterType'
      conf.WorkCenterTypeCode,
      @ObjectModel.foreignKey.association: '_WorkCenter'
      conf.WorkCenterInternalID,
      @ObjectModel.foreignKey.association: '_Capacity'
      conf.CapacityInternalID,
      conf.CapacityRequirementSplit,

      // Attributes
      conf.IsFinalConfirmation,
      conf.OpenReservationsIsCleared,
      conf.IsReversed,
      conf.IsReversal,
      conf.CancldMfgOrderOpConfCount,
      conf.IsConfirmedByMilestoneConf,
      conf.MilestoneIsConfirmed,

      // Admin
      @Semantics.user.createdBy: true
      conf.EnteredByUser,
      @Semantics.systemDate.createdAt: true
      conf.MfgOrderConfirmationEntryDate,
      @Semantics.systemTime.createdAt: true
      conf.MfgOrderConfirmationEntryTime,
      cast(left(MfgOrderConfirmationEntryTime,2) as pph_entryhour)                   as MfgOrderConfirmationEntryHour,
      @ObjectModel.foreignKey.association: '_EntryDateWeekDay'
      date.ReportingDateWeekDay                                                      as EntryDateWeekDay,
      @Semantics.calendar.week: true
      date.ReportingDateWeek                                                         as EntryDateWeek,
      @ObjectModel.foreignKey.association: '_EntryDateMonth'
      //@Semantics.calendar.month: true
      date.ReportingDateMonth                                                        as EntryDateMonth,
      @Semantics.calendar.year: true
      date.ReportingDateYear                                                         as EntryDateYear,
      cast(concat(date.ReportingDateYear, date.ReportingDateMonth) as vdm_yearmonth) as EntryDateYearMonth,
      @ObjectModel.foreignKey.association: '_ReportingPeriod'
      cast(date.ReportingPeriod as pph_reportingperiod preserving type)              as ReportingPeriod,

      @Semantics.systemDate.lastChangedAt: true
      conf.LastChangeDate,
      @Semantics.user.lastChangedBy: true
      conf.LastChangedByUser,
      @Semantics.systemDate.createdAt: true
      conf.ConfirmationExternalEntryDate,
      @Semantics.systemTime.createdAt: true
      conf.ConfirmationExternalEntryTime,
      conf.EnteredByExternalUser,

      // Order and operation data
      @ObjectModel.foreignKey.association: '_MfgOrder'
      conf.ManufacturingOrder,
      @ObjectModel.foreignKey.association: '_MfgOrderSequence'
      conf.ManufacturingOrderSequence,
      conf.ManufacturingOrderOperation,
      @ObjectModel.foreignKey.association: '_MfgOrderCategory'
      conf.ManufacturingOrderCategory,
      @ObjectModel.foreignKey.association: '_MfgOrderType'
      conf.ManufacturingOrderType,
      @ObjectModel.foreignKey.association: '_ProductionPlant'
      conf.ProductionPlant,
      @ObjectModel.foreignKey.association: '_ProductionSupervisor'
      conf.ProductionSupervisor,
      @ObjectModel.foreignKey.association: '_MRPController'
      conf.MRPController,
      @ObjectModel.foreignKey.association: '_MRPPlant'
      item.MRPPlant,
      @ObjectModel.foreignKey.association: '_MRPArea'
      item.MRPArea,
      @ObjectModel.foreignKey.association: '_OrdInternalBillOfOperations'
      conf.OrderInternalBillOfOperations,
      @ObjectModel.foreignKey.association: '_MfgOrderOperation'
      conf.OrderIntBillOfOperationsItem,

      // Assignments FI/CO
      @ObjectModel.foreignKey.association: '_BusinessArea'
      conf.BusinessArea,
      @ObjectModel.foreignKey.association: '_CompanyCode'
      conf.CompanyCode,
      @ObjectModel.foreignKey.association: '_ControllingArea'
      conf.ControllingArea,
      @ObjectModel.foreignKey.association: '_ProfitCenter'
      conf.ProfitCenter,
      conf.ProductCostCollector,

      // Assignments HR
      conf.Personnel,
      conf.TimeRecording,
      conf.EmployeeWageType,
      @ObjectModel.foreignKey.association: '_EmployeeWageGroup'
      conf.EmployeeWageGroup,
      @ObjectModel.foreignKey.association: '_EmployeeSuitability'
      conf.EmployeeSuitability,
      conf.NumberOfEmployees,

      // Dates
      conf.ConfirmedExecutionStartDate,
      conf.ConfirmedExecutionEndDate,
      @ObjectModel.foreignKey.association: '_PostingDate'
      @Semantics.businessDate.at: true
      conf.PostingDate,

      // Quantities and UoM
      @ObjectModel.foreignKey.association: '_VarianceReason'
      conf.VarianceReasonCode,
      @Semantics.unitOfMeasure: true
      conf.ConfirmationUnit,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      @DefaultAggregation: #SUM
      conf.ConfirmationYieldQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      @DefaultAggregation: #SUM
      conf.ConfirmationScrapQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      @DefaultAggregation: #SUM
      conf.ConfirmationReworkQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      @DefaultAggregation: #SUM
      conf.ConfirmationTotalQuantity,
      // In Percent
      @DefaultAggregation: #MAX
      case
        when conf.ConfirmationTotalQuantity > 0 then
          Division(conf.ConfirmationScrapQuantity * 100, ConfirmationTotalQuantity, 5)
        else 0
      end                                                                            as ConfirmationScrapPercent,
      @DefaultAggregation: #MAX
      case
        when conf.ConfirmationTotalQuantity > 0 then
          Division(conf.ConfirmationReworkQuantity * 100, ConfirmationTotalQuantity, 5)
        else 0
      end                                                                            as ConfirmationReworkPercent,
      @DefaultAggregation: #MAX
      case
        when conf.ConfirmationTotalQuantity > 0 then
          Division(conf.ConfirmationYieldQuantity * 100, ConfirmationTotalQuantity, 5)
        else 0
      end                                                                            as ConfirmationYieldPercent,
      case
        when conf.ConfirmationTotalQuantity > 0 then
          Division(conf.ConfirmationScrapQuantity * 100, ConfirmationTotalQuantity, 5) +
          Division(conf.ConfirmationReworkQuantity * 100, ConfirmationTotalQuantity, 5)
        else 0
      end                                                                            as ConfirmationScrapReworkPercent,
      //@DefaultAggregation: #MAX
      //cast(oper.OperationScrapPercent as pph_aufak preserving type)                  as OperationPlannedScrapPercent,

      // Item quantities and UoM
      @Semantics.unitOfMeasure: true
      item.ProductionUnit,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      @DefaultAggregation: #SUM
      cast(item.ItemQuantity as co_psmng preserving type)                            as MfgOrderItemPlannedTotalQty,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      @DefaultAggregation: #SUM
      item.MfgOrderItemPlannedScrapQty,
      @DefaultAggregation: #MAX
      case
        when item.ItemQuantity > 0 then
          Division(item.MfgOrderItemPlannedScrapQty * 100, item.ItemQuantity, 5)
        else 0
      end                                                                            as MfgOrderItemPlannedScrapPct,
      item.IsCompletelyDelivered                                                     as MfgOrderItemIsFinallyDelivered,

      // Work Quantities and UoM
      @Semantics.unitOfMeasure: true
      conf.OpWorkQuantityUnit1,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit1'
      @DefaultAggregation: #SUM
      conf.OpConfirmedWorkQuantity1,
      conf.NoFurtherOpWorkQuantity1IsExpd,
      @Semantics.unitOfMeasure: true
      conf.OpWorkQuantityUnit2,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit2'
      @DefaultAggregation: #SUM
      conf.OpConfirmedWorkQuantity2,
      conf.NoFurtherOpWorkQuantity2IsExpd,
      @Semantics.unitOfMeasure: true
      conf.OpWorkQuantityUnit3,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit3'
      @DefaultAggregation: #SUM
      conf.OpConfirmedWorkQuantity3,
      conf.NoFurtherOpWorkQuantity3IsExpd,
      @Semantics.unitOfMeasure: true
      conf.OpWorkQuantityUnit4,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit4'
      @DefaultAggregation: #SUM
      conf.OpConfirmedWorkQuantity4,
      conf.NoFurtherOpWorkQuantity4IsExpd,
      @Semantics.unitOfMeasure: true
      conf.OpWorkQuantityUnit5,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit5'
      @DefaultAggregation: #SUM
      conf.OpConfirmedWorkQuantity5,
      conf.NoFurtherOpWorkQuantity5IsExpd,
      @Semantics.unitOfMeasure: true
      conf.OpWorkQuantityUnit6,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit6'
      @DefaultAggregation: #SUM
      conf.OpConfirmedWorkQuantity6,
      conf.NoFurtherOpWorkQuantity6IsExpd,

      // Business Process
      @ObjectModel.foreignKey.association: '_BusinessProcess'
      conf.BusinessProcess,
      @Semantics.unitOfMeasure: true
      conf.BusinessProcessEntryUnit,
      @Semantics.quantity.unitOfMeasure: 'BusinessProcessEntryUnit'
      @DefaultAggregation: #SUM
      conf.BusinessProcessConfirmedQty,
      conf.NoFurtherBusinessProcQtyIsExpd,
      @Semantics.unitOfMeasure: true
      conf.BusinessProcRemainingQtyUnit,
      @Semantics.quantity.unitOfMeasure: 'BusinessProcRemainingQtyUnit'
      @DefaultAggregation: #SUM
      conf.BusinessProcessRemainingQty,

      // Associations
      conf._ConfirmationGroup,
      @VDM.lifecycle.status: #DEPRECATED
      conf._MfgOrder,
      conf._MfgOrderSequence,
      _MfgOrderOperation,
      conf._MfgOrderCategory,
      conf._MfgOrderType,
      @VDM.lifecycle.status: #DEPRECATED
      conf._OrdInternalBillOfOperations,
      _ConfirmationUnit,
      _ProductionUnit,
      _User,
      conf._Language,
      conf._WorkCenterType,
      conf._WorkCenter,
      _WorkCenterBySemanticKey,
      _Plant,
      _Material,
      conf._ProductionPlant,
      conf._ProductionSupervisor,
      conf._MRPController,
      item._MRPPlant,
      item._MRPArea,
      _Capacity,
      conf._BusinessArea,
      _CompanyCode,
      _ControllingArea,
      _ProfitCenter,
      _BusinessProcess,
      _VarianceReason,
      _EntryDate,
      _LastChangeDate,
      _PostingDate,
      _EmployeeWageGroup,
      _EmployeeSuitability,
      _EntryDateWeekDay,
      _EntryDateMonth,
      _ReportingPeriod
};
