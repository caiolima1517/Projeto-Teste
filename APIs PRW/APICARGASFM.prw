#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"



WSRESTFUL CargaSFM DESCRIPTION "Api utilizada para carga de TES Inteligente" FORMAT APPLICATION_JSON

    WSMETHOD POST GeraSFM; 
    DESCRIPTION "Método para Gerar a carga na SFM, recebe um JSON.";
    WSSYNTAX "/importa";
    PATH "/importa"

    WSMETHOD GET BuscaSFM;
    DESCRIPTION "Busca o último registro da tabela SFM";
    WSSYNTAX "/busca";
    PATH "/busca"

END WSRESTFUL


WSMETHOD POST GeraSFM WSSERVICE CargaSFM
Local lRet:=.f.
Local aArea:=GetArea()
Local oContent:=self:getcontent()
Local oParsedContent:=JsonObject():New()
Local oResponse:=JsonObject():New()
Local cError := ""
Local nx := 0

cError := oParsedContent:fromjson(oContent)

DBSELECTAREA("SFM")
DBSETORDER(1)

for nx:=1 to len(oParsedContent['TES'])
    IF !empty(oParsedContent['TES'][nx]['FM_TS']) 
        RECLOCK("SFM", .T.)

            SFM->FM_FILIAL:= oParsedContent['TES'][nx]['FM_FILIAL']
            SFM->FM_ID:=oParsedContent['TES'][nx]['FM_ID']
            SFM->FM_DESCR:=oParsedContent['TES'][nx]['FM_DESCR']
            SFM->FM_TIPO:=cvaltochar(oParsedContent['TES'][nx]['FM_TIPO'])
            SFM->FM_EST:=oParsedContent['TES'][nx]['FM_EST']
            SFM->FM_GRTRIB:=oParsedContent['TES'][nx]['FM_GRTRIB']
            SFM->FM_TIPOMOV:=oParsedContent['TES'][nx]['FM_TIPOMOV']
            SFM->FM_TIPOCLI:=oParsedContent['TES'][nx]['FM_TIPOCLI']
            SFM->FM_PRODUTO:=oParsedContent['TES'][nx]['FM_PRODUTO']
            SFM->FM_GRPROD:=oParsedContent['TES'][nx]['FM_GRPROD']
            SFM->FM_POSIPI:=oParsedContent['TES'][nx]['FM_POSIPI']
            SFM->FM_TS:=cvaltochar(oParsedContent['TES'][nx]['FM_TS'])

        MSUNLOCK()
    else
        RECLOCK("SFM", .T.)

            SFM->FM_FILIAL:= oParsedContent['TES'][nx]['FM_FILIAL']
            SFM->FM_ID:=oParsedContent['TES'][nx]['FM_ID']
            SFM->FM_DESCR:=oParsedContent['TES'][nx]['FM_DESCR']
            SFM->FM_TIPO:=oParsedContent['TES'][nx]['FM_TIPO']
            SFM->FM_EST:=oParsedContent['TES'][nx]['FM_EST']
            SFM->FM_GRTRIB:=oParsedContent['TES'][nx]['FM_GRTRIB']
            SFM->FM_TIPOMOV:=oParsedContent['TES'][nx]['FM_TIPOMOV']
            SFM->FM_TIPOCLI:=oParsedContent['TES'][nx]['FM_TIPOCLI']
            SFM->FM_PRODUTO:=oParsedContent['TES'][nx]['FM_PRODUTO']
            SFM->FM_GRPROD:=oParsedContent['TES'][nx]['FM_GRPROD']
            SFM->FM_POSIPI:=oParsedContent['TES'][nx]['FM_POSIPI']
            SFM->FM_TE:=oParsedContent['TES'][nx]['FM_TE']

        MSUNLOCK()
    ENDIF

        oResponse['message']:="TES Incluída!"


        Conout('TES Incluida!')

        self:SetContentType('application/json')
        self:SetResponse( EncodeUtf8(oResponse:toJson()) )

NEXT

SFM->(DBCLOSEAREA())

if lRet
    oResponse['Message']:='Carga Efetuada Com Sucesso!'
else
    oResponse['Message']:='Carga não efetuada'
endif

self:SetContentType('application/json')
self:SetResponse( EncodeUtf8(oResponse:toJson()) )

RestArea(aArea)

Return lRet

