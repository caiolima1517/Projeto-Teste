#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


WSRESTFUL ConsultaFor DESCRIPTION "Consulta Fornecedores" FORMAT APPLICATION_JSON
    WSDATA cCodFor as string optional
    WSDATA cCodLoja as string optional

    WSMETHOD Get Consulta;
    Description "Metodo p/ consulta";
    WSSYNTAX "/consultar/fornecedores/?{cCodfor}&{cCodloja}";
    PATH "/consultar/fornecedores";
    PRODUCES APPLICATION_JSON

END WSRESTFUL



WSMETHOD GET Consulta HEADERPARAM cCodFor, cCodLoja WSSERVICE ConsultaFor
    Local response:= JsonObject():New()
    Local cCodFornece:=""
    Local cCodLojaFor:=""
    Local lret:=.t.

    cCodFornece := self:cCodFor
    cCodLojaFor:= self:cCodLoja

    DBSELECTAREA("SA2")
    DBSETORDER(1)

    IF SA2->(DBSEEK(XFILIAL("SA2")+cCodFornece+cCodLojaFor))
        response['Codigo']:= SA2->A2_COD
        response['Nome']:=SA2->A2_NOME
        response['Loja']:=SA2->A2_LOJA
    else
        response['message']:='Fornecedor nao encontrado'
    endif


::SetContentType('application/json')
::SetResponse( EncodeUtf8(response:toJson()) )


return lret
