#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"



WSRESTFUL CargaSF7 DESCRIPTION "Api utilizada para carga de Transportadoras" FORMAT APPLICATION_JSON

    WSMETHOD POST GeraSF7; 
    DESCRIPTION "Método para Gerar a carga na SF7, recebe um JSON.";
    WSSYNTAX "/importa";
    PATH "/importa"

    WSMETHOD GET BuscaSF7;
    DESCRIPTION "Busca o último registro da tabela SF7";
    WSSYNTAX "/busca";
    PATH "/busca"

END WSRESTFUL


WSMETHOD POST GeraSF7 WSSERVICE CargaSF7
Local lRet:=.f.
Local aArea:=GetArea()
//Local aSF7Auto := {}
Local oContent:=self:getcontent()
Local oParsedContent:=JsonObject():New()
Local oResponse:=JsonObject():New()
Local cError := ""
Local nx := 0
//Local nOpcAuto := 3
private lAutoErrNoFile:= .T. 
Private lMsErroAuto := .F.

cError := oParsedContent:fromjson(oContent)

If !Empty(cError)

    //--------------------------
    // Retorna o erro do parse.
    //--------------------------
    SetRestFault(400, ENCODEUTF8(cError))

    return .f.
else
    
    //-----------------------------------------------
    // Prepara o ambiente para execução do ExecAuto.
    //-----------------------------------------------

        for nx:=1 to len(oParsedContent['SF7'])

            cFilAnt := Alltrim(oParsedContent['SF7'][nX]['F7_FILIAL'])

            RECLOCK("SF7", .T.)
                SF7->F7_FILIAL := Alltrim(oParsedContent['SF7'][nX]['F7_FILIAL'])
                SF7->F7_GRTRIB := SUBSTRING(Alltrim(oParsedContent['SF7'][nX]['F7_GRTRIB']),1,TamSX3("F7_GRTRIB")[1])
                SF7->F7_SEQUEN :=  SUBSTRING(Alltrim(UPPER(oParsedContent['SF7'][nX]['F7_SEQUEN'])),1,TamSX3("F7_SEQUEN")[1])
                SF7->F7_EST :=   SUBSTRING(Alltrim(UPPER(oParsedContent['SF7'][nX]['F7_EST'])),1,TamSX3("F7_EST")[1]) 
                SF7->F7_TIPOCLI :=    SUBSTRING(Alltrim(oParsedContent['SF7'][nX]['F7_TIPOCLI']),1,TamSX3("F7_TIPOCLI")[1])

                If !empty(oParsedContent['SF7'][nX]['F7_ALIQINT'])
                    SF7->F7_ALIQINT := VAL(oParsedContent['SF7'][nX]['F7_ALIQINT'])
                Endif

                
                If !empty(oParsedContent['SF7'][nX]['F7_MARGEM'])
                    SF7->F7_MARGEM := VAL(oParsedContent['SF7'][nX]['F7_MARGEM'])
                Endif


                If !empty(oParsedContent['SF7'][nX]['F7_GRPCLI'])
                    SF7->F7_GRPCLI := SUBSTRING(Alltrim(UPPER(oParsedContent['SF7'][nX]['F7_GRPCLI'])),1,TamSX3("F7_GRPCLI")[1])      
                Endif

                /*If !empty(oParsedContent['SF7'][nX]['F7_ALIQPIS']) 
                    SF7->F7_ALIQPIS := VAL(oParsedContent['SF7'][nX]['F7_ALIQPIS'])
                Endif

                If !empty(oParsedContent['SF7'][nX]['F7_ALIQCOF']) 
                    SF7->F7_ALIQCOF := VAL(oParsedContent['SF7'][nX]['F7_ALIQCOF'])
                Endif

                If !empty(oParsedContent['SF7'][nX]['F7_REDPIS']) 
                    SF7->F7_REDPIS := VAL(oParsedContent['SF7'][nX]['F7_REDPIS'])
                Endif


                If !empty(oParsedContent['SF7'][nX]['F7_REDCOF']) 
                    SF7->F7_REDCOF := VAL(oParsedContent['SF7'][nX]['F7_REDCOF'])
                Endif*/

                If !empty(oParsedContent['SF7'][nX]['F7_ALIQDST'])
                    SF7->F7_ALIQDST := VAL(oParsedContent['SF7'][nX]['F7_ALIQDST'])
                Endif


                If !empty(oParsedContent['SF7'][nX]['F7_ISS'])
                    SF7->F7_ISS := SUBSTRING(Alltrim(oParsedContent['SF7'][nX]['F7_ISS']),1,TamSX3("F7_ISS")[1])
                Endif

                If !empty(oParsedContent['SF7'][nX]['F7_ICMPAUT'])
                    SF7->F7_ICMPAUT := Alltrim(oParsedContent['SF7'][nX]['F7_ICMPAUT'])
                Endif


                If !empty(oParsedContent['SF7'][nX]['F7_UFBUSCA'])
                    SF7->F7_UFBUSCA := SUBSTRING(Alltrim(oParsedContent['SF7'][nX]['F7_UFBUSCA']),1,TamSX3("F7_UFBUSCA")[1])
                Endif

                /*If !empty(oParsedContent['SF7'][nX]['F7_REDCOF']) 
                    SF7->F7_REDCOF := VAL(oParsedContent['SF7'][nX]['F7_REDCOF'])
                Endif

                If !empty(oParsedContent['SF7'][nX]['F7_BASCMP']) 
                    SF7->F7_BASCMP := VAL(oParsedContent['SF7'][nX]['F7_BASCMP'])
                Endif*/

            

            //------------------------------------
            // Chamada para cadastrar a exceção fiscal.
            //------------------------------------
            MSUNLOCK()



                //----------------------------------------------------------------------
                //Sucesso do ExecAuto e retorna os dados do cliente cadastrado em Json.
                //----------------------------------------------------------------------        
                oResponse['message']:="Exceção cadastrada com sucesso!"


                Conout('Exceção Incluida!')

                self:SetContentType('application/json')
                self:SetResponse( EncodeUtf8(oResponse:toJson()) )

        
        NEXT



        //--------------------------------------------------------------------------------------------
        //Retorno codigo e mensagem de erro, caso não consiga preparar o ambiente com o RPCSetEnv().
        //--------------------------------------------------------------------------------------------            SetRestFault(400, ENCODEUTF8("Não foi possivel preparar o ambiente. Solicite suporte Protheus."))
endif


    RestArea(aArea)

Return lRet
