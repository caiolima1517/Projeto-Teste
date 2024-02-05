#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"



WSRESTFUL CargaSBM DESCRIPTION "Api utilizada para carga de Grupo de Produtos" FORMAT APPLICATION_JSON

    WSMETHOD POST GeraSBM; 
    DESCRIPTION "Método para Gerar a carga na SBM, recebe um JSON.";
    WSSYNTAX "/importa";
    PATH "/importa"

    WSMETHOD GET BuscaSBM;
    DESCRIPTION "Busca o último registro da tabela SBM";
    WSSYNTAX "/busca";
    PATH "/busca"

END WSRESTFUL


WSMETHOD POST GeraSBM WSSERVICE CargaSBM
Local lRet:=.f.
Local aArea:=GetArea()
Local oContent:=self:getcontent()
Local oParsedContent:=JsonObject():New()
Local oResponse:=JsonObject():New()
Local cError := ""
Local nx := 0

cError := oParsedContent:fromjson(oContent)

DBSELECTAREA("SBM")
DBSETORDER(1)

for nx:=1 to len(oParsedContent['SBM'])

        nTamDescSBM:=TamSX3("BM_DESC")[1]
        cDesc:=Substring(oParsedContent['SBM'][nx]['BM_DESC'],1,nTamDescSBM)
        RECLOCK("SBM", .T.)

            SBM->BM_FILIAL:= oParsedContent['SBM'][nx]['BM_FILIAL']
            SBM->BM_GRUPO:=oParsedContent['SBM'][nx]['BM_GRUPO']
            SBM->BM_DESC:=cDesc
            SBM->BM_MARKUP:=0
            SBM->BM_MARGPRE:=0
            SBM->BM_LENREL:=0
            SBM->BM_CORP:=.F.
            SBM->BM_EVENTO:=.F.
            SBM->BM_LAZER:=.F.
            SBM->BM_ZZCTA := oParsedContent['SBM'][nx]['BM_ZZCTA']
            SBM->BM_ZZCTAC := oParsedContent['SBM'][nx]['BM_ZZCTAC']
            SBM->BM_ZZCTAR := oParsedContent['SBM'][nx]['BM_ZZCTAR']


        MSUNLOCK()
    

    lRet:= .T.

NEXT

SBM->(DBCLOSEAREA())

if lRet
    oResponse['Message']:='Carga Efetuada Com Sucesso!'
else
    oResponse['Message']:='Carga não efetuada'
endif

self:SetContentType('application/json')
self:SetResponse( EncodeUtf8(oResponse:toJson()) )

RestArea(aArea)

Return lRet

