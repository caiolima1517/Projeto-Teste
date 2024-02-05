#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"



WSRESTFUL CargaSA4 DESCRIPTION "Api utilizada para carga de Transportadoras" FORMAT APPLICATION_JSON

    WSMETHOD POST GeraSA4; 
    DESCRIPTION "Método para Gerar a carga na SA4, recebe um JSON.";
    WSSYNTAX "/importa";
    PATH "/importa"

    WSMETHOD GET BuscaSA4;
    DESCRIPTION "Busca o último registro da tabela SA4";
    WSSYNTAX "/busca";
    PATH "/busca"

END WSRESTFUL


WSMETHOD POST GeraSA4 WSSERVICE CargaSA4
Local lRet:=.f.
Local aArea:=GetArea()
Local aSA4Auto := {}
Local oContent:=self:getcontent()
Local oParsedContent:=JsonObject():New()
Local oResponse:=JsonObject():New()
Local cError := ""
Local nx := 0
Local nOpcAuto := 3
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

        for nx:=1 to len(oParsedContent['SA4'])

            RECLOCK("SA4",.T.)
                SA4->A4_FILIAL:= xFilial("SA4")
                SA4->A4_COD:= SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_COD']),1,TamSX3("A4_COD")[1]) 
                SA4->A4_NOME:=  SUBSTRING(Alltrim(UPPER(oParsedContent['SA4'][nX]['A4_NOME'])),1,TamSX3("A4_NOME")[1])  
                SA4->A4_NREDUZ:=     SUBSTRING(Alltrim(UPPER(oParsedContent['SA4'][nX]['A4_NREDUZ'])),1,TamSX3("A4_NREDUZ")[1])      
                SA4->A4_VIA:=    SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_VIA']),1,TamSX3("A4_VIA")[1])

                If !empty(oParsedContent['SA4'][nX]['A4_END'])
                    SA4->A4_END:=  SUBSTRING(Alltrim(UPPER(oParsedContent['SA4'][nX]['A4_END'])),1,TamSX3("A4_END")[1])  
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_BAIRRO'])
                    SA4->A4_BAIRRO:=     SUBSTRING(Alltrim(UPPER(oParsedContent['SA4'][nX]['A4_BAIRRO'])),1,TamSX3("A4_BAIRRO")[1])      
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_EST'])
                    SA4->A4_EST:=     SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_EST']),1,TamSX3("A4_EST")[1])      
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_COD_MUN'])
                    SA4->A4_COD_MUN  := SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_COD_MUN']),1,TamSX3("A4_COD_MUN")[1])    
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_MUN'])
                    SA4->A4_MUN := SUBSTRING(Alltrim(UPPER(oParsedContent['SA4'][nX]['A4_MUN'])),1,TamSX3("A4_MUN")[1])
                Endif


                If !empty(oParsedContent['SA4'][nX]['A4_CEP'])
                    SA4->A4_CEP:=SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_CEP']),1,TamSX3("A4_CEP")[1])  
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_DDD'])
                    SA4->A4_DDD:=SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_DDD']),1,TamSX3("A4_DDD")[1]) 
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_TEL'])
                    SA4->A4_TEL:=SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_TEL']),1,TamSX3("A4_TEL")[1]) 
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_CGC'])
                    SA4->A4_CGC:=SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_CGC']),1,TamSX3("A4_CGC")[1])
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_INSEST'])
                    SA4->A4_INSEST:=SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_INSEST']),1,TamSX3("A4_INSEST")[1])  
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_EMAIL'])
                    SA4->A4_EMAIL:=SUBSTRING(Alltrim(UPPER(oParsedContent['SA4'][nX]['A4_EMAIL'])),1,TamSX3("A4_EMAIL")[1])
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_CONTATO'])
                    SA4->A4_CONTATO:=SUBSTRING(Alltrim(UPPER(oParsedContent['SA4'][nX]['A4_CONTATO'])),1,TamSX3("A4_CONTATO")[1]) 
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_RATFRE'])
                    SA4->A4_RATFRE:=SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_RATFRE']),1,TamSX3("A4_RATFRE")[1])
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_COMPLEM'])
                    SA4->A4_COMPLEM:=SUBSTRING(Alltrim(UPPER(oParsedContent['SA4'][nX]['A4_COMPLEM'])),1,TamSX3("A4_COMPLEM")[1]) 
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_SUFRAMA'])
                    SA4->A4_SUFRAMA:=SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_SUFRAMA']),1,TamSX3("A4_SUFRAMA")[1])
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_CODPAIS'])
                    SA4->A4_CODPAIS:=SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_CODPAIS']),1,TamSX3("A4_CODPAIS")[1])  
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_TPTRANS'])
                    SA4->A4_TPTRANS:=SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_TPTRANS']),1,TamSX3("A4_TPTRANS")[1])
                Endif

                If !empty(oParsedContent['SA4'][nX]['A4_ANTT'])
                    SA4->A4_ANTT:=SUBSTRING(Alltrim(oParsedContent['SA4'][nX]['A4_ANTT']),1,TamSX3("A4_ANTT")[1]) 
                Endif
            
            MSUNLOCK()
            
            



            //------------------------------------
            // Chamada para cadastrar o cliente.
            //------------------------------------
            /*MSExecAuto({|x,y|mata050(x,y)},aSA4Auto,nOpcAuto)

            If lMsErroAuto  
                lRet := .F.

                //--------------------------------------------------------
                //Busca log de erro do ExecAuto e retorna o erro em Json.
                //--------------------------------------------------------
                aAutoLog := GetAutoGRLog()
                oResponse['message']:=aAutoLog
                self:SetResponse(EncodeUtf8(oResponse:toJson()))

                Conout(aAutoLog)

                RpcClearEnv()
                return lRet
            Else

                If EMPTY(SA4->A4_COD_MUN)

                    If !empty(oParsedContent['SA4'][nX]['A4_COD_MUN'])
                        RECLOCK("SA4",.F.)
                            SA4->A4_COD_MUN:=oParsedContent['SA4'][nX]['A4_COD_MUN']
                        MSUNLOCK()
                    Endif
                Endif

                If EMPTY(SA4->A4_MUN)

                    If !empty(oParsedContent['SA4'][nX]['A4_MUN'])
                        RECLOCK("SA4",.F.)
                            SA4->A4_MUN:=oParsedContent['SA4'][nX]['A4_MUN']
                        MSUNLOCK()
                    Endif
                Endif*/
                //----------------------------------------------------------------------
                //Sucesso do ExecAuto e retorna os dados do cliente cadastrado em Json.
                //----------------------------------------------------------------------        
                oResponse['message']:="Transportadora cadastrado com sucesso!"


                Conout('Transportadora Incluida!')

                self:SetContentType('application/json')
                self:SetResponse( EncodeUtf8(oResponse:toJson()) )

            //EndIf
        
        NEXT



        //--------------------------------------------------------------------------------------------
        //Retorno codigo e mensagem de erro, caso não consiga preparar o ambiente com o RPCSetEnv().
        //--------------------------------------------------------------------------------------------            SetRestFault(400, ENCODEUTF8("Não foi possivel preparar o ambiente. Solicite suporte Protheus."))
endif


    RestArea(aArea)

Return lRet
