#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


WSRESTFUL ConsultaForTop1 DESCRIPTION "Consulta Fornecedores Top1" FORMAT APPLICATION_JSON
    WSMETHOD GET top1;
    Description "Metodo p/ consulta top 1";
    WSSYNTAX "/fornecedores/top1";
    PATH "/fornecedores/top1";
    PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD GET top1 WSSERVICE ConsultaForTop1
    Local response:=JsonObject():New()
    Local cSql:= ""
    Local lret:= .T.

    cSql:="SELECT TOP 1 A2_COD, A2_NOME, A2_EST, A2_LOJA, A2_TEL,A2_MUN, R_E_C_N_O_ AS RECNO FROM "+RETSQLNAME("SA2")+" A2 "+CRLF
    cSql +=" ORDER BY A2.R_E_C_N_O_ DESC "
    TCQUERY cSql New Alias "TRB"

    WHILE !TRB->(EOF())
        response['Codigo']:=TRB->A2_COD
        response['Nome']:=TRB->A2_NOME
        response['Loja']:=TRB->A2_LOJA
        response['Estado']:=TRB->A2_EST
        response['Mun']:=TRB->A2_MUN
        response['Telefone']:=TRB->A2_TEL
        response['RECNO']:=TRB->RECNO
        TRB->(DbSkip())
    ENDDO

TRB->(DBCLOSEAREA(  ))



::SetContentType('application/json')
::SetResponse( EncodeUtf8(response:toJson()) )

return lret
