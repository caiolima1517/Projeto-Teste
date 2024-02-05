#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"



User Function MVCJPA()
Local oBrowse:= FwLoadBrw("MVCJPA")

return


Static Function BrowseDef()
Local oBrowse:=FwmBrowse():New()

oBrowse:SetAlias("SA1")
oBrowse:SetDescription("Teste")

oBrowse:AddLegend("SA1->A1_MSBLQL == '2'", "GREEN", "ATIVO")
oBrowse:AddLegend("SA1->A1_MSBLQL == '1'", "RED", "INATIVO")

oBrowse:ACTIVATE()

return oBrowse


Static Function MenuDef()
Local aMenu := {}

ADD OPTION aMenu TITLE "Visualizar" ACTION 'VIEWDEF.MVCJPA' OPERATION 2 ACCESS 0 
ADD OPTION aMenu TITLE "Incluir"  ACTION 'VIEWDEF.MVCJPA'    OPERATION 3 ACCESS 0 
ADD OPTION aMenu TITLE "Alterar"  ACTION 'VIEWDEF.MVCJPA'    OPERATION 4 ACCESS 0 
ADD OPTION aMenu TITLE "Excluir"  ACTION 'VIEWDEF.MVCJPA'    OPERATION 5 ACCESS 0 


return aMenu


Static Function ViewDef()
Local oView:=NIL
Local oModel:=FwloadModel("MVCJPA")
Local oStructSA1:=FwFormStruct(2,"SA1")

oView:=FwFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEWSA1",oStructSA1,"FORMSA1")

oView:CreateHorizontalBox("TELASA1",100)

oView:EnableTitleView("VIEWSA1", "View Teste")

oView:SetCloseOnOk({||.T.})

oView:SetOwnerView("VIEWSA1", "TELASA1")


return oView


Static Function ModelDef()
Local oModel:=NIL
Local oStructSA1:=FwFormStruct(1,"SA1")

oModel:=MpFormModel():New("MVCJPAM", , , , )

oModel:AddFields("FORMSA1",,oStructSA1)

//oModel:SetPrimaryKey("R_E_C_N_O_")

oModel:SetDescription("Model de dados")

oModel:GetModel("FORMSA1"):SetDescription("Formulario")

return oModel
