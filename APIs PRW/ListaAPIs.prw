#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

WSRESTFUL Lista DESCRIPTION "Lista APIs Disponíveis P/ Carga de Dados" FORMAT APPLICATION_JSON
    
    WSMETHOD GET busca DESCRIPTION "Busca APIs Disponíveis";
    WSSYNTAX "/busca";
    PATH "/busca";
    PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET busca WSSERVICE Lista
Local oResponse := JsonObject():New()


oResponse['message:']:="APIs Disponíveis"
oResponse['APIs:']:="Tes Inteligente(SFM)"

self:SetContentType('application/json')
self:SetResponse( EncodeUtf8(oResponse:toJson()) )




Return .t.



