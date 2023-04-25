sap.ui.define(["sap/ui/export/Spreadsheet","sap/ui/export/library"],function(e,a){"use strict";return{downloadLayout:function(t){var s=[];s.push({label:"MATERIAL",property:"MATERIAL",type:a.EdmType.String});s.push({label:"DEPOSITO",property:"STGE_LOC",ty+
pe:a.EdmType.String});s.push({label:"LOTE",property:"BATCH",type:a.EdmType.String});s.push({label:"QUANTIDADE",property:"ENTRY_QNT",type:a.EdmType.String});s.push({label:"UMB",property:"ENTRY_UOM",type:a.EdmType.String});var r={workbook:{columns:s},dataS+
ource:[""],count:1,fileName:"Modelo.xlsx"};var o=new e(r);o.build().finally(function(){o.destroy()})},uploadFile:function(e){var a=this;var t=new sap.m.Dialog({contentWidth:"300px",resizable:true,type:"Message"});t.setTitle("Carregar arquivo Excel");var +
s="/sap/opu/odata/SAP/ZPP_NORMA_APROPRIACAO_SRV/";var r=new sap.ui.model.odata.ODataModel(s,false);var o=s+"excelSet";var i=new sap.ui.unified.FileUploader({width:"100%",fileType:["xlsx","xls"],typeMissmatch:this.handleTypeMissmatch,uploadComplete:functi+
on(e){this.oView.getController().extensionAPI.refresh();t.close();t.destroy();if(e.mParameters.status=="200"||e.mParameters.status=="201"){sap.m.MessageToast.show("Carga realizada com sucesso.")}else{if(e.mParameters.response){if(e.mParameters.responseRa+
w.search("<message>")){var a=e.mParameters.responseRaw.split("<message>")[1].split("</message>")[0];alert(a)}else{alert("Return Code: "+e.mParameters.response,"Response","Response")}}}}.bind(this)});i.setName("Simple Uploader");i.setUploadUrl(o);i.setSen+
dXHR(true);i.setUseMultipart(false);i.setUploadOnChange(false);var n=new sap.ui.unified.FileUploaderParameter({name:"x-csrf-token",value:r.getSecurityToken()});i.insertHeaderParameter(n);var p=new sap.m.Button({text:"Upload",type:"Accept",press:function(+
){var e=i.getFocusDomRef();var a=e.files[0];if(i.getValue()===""){sap.m.MessageToast.show("Favor selecionar um arquivo");return}var t=new sap.ui.unified.FileUploaderParameter({name:"Content-Type",value:a.type});i.insertHeaderParameter(t);var s=this.getVi+
ew().getBindingContext();var r=s.getPath();var o=s.getModel().getProperty(r);i.insertHeaderParameter(new sap.ui.unified.FileUploaderParameter({name:"SLUG",value:o.DocUuidH+";"+i.getValue()}));i.upload()}.bind(this)});var l=new sap.m.Button({text:"Cancela+
r",type:"Reject",press:function(){t.close();t.destroy();this.getView().removeAllDependents()}.bind(this)});t.addContent(i);t.setBeginButton(l);t.setEndButton(p);t.open()},handleTypeMissmatch:function(e){var a=e.getSource().getFileType();jQuery.each(a,fun+
ction(e,t){a[e]="*."+t});var t=a.join(", ");sap.m.MessageToast.show("Tipo de arquivo *."+e.getParameter("fileType")+" não é suportado. Escolha um dos tipos a seguir: "+t)}}});                                                                                