#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//***********************************************

//API de carga da SE2 p/ empresa Xmobots

//***********************************************

WSRESTFUL CargaSE2 DESCRIPTION "Api utilizada para carga de Contas a Pagar" FORMAT APPLICATION_JSON

    WSMETHOD POST GeraSE2; 
    DESCRIPTION "Método para Gerar a carga na SE2, recebe um JSON.";
    WSSYNTAX "/importa";
    PATH "/importa"

    WSMETHOD GET BuscaSE2;
    DESCRIPTION "Busca o último registro da tabela SE2";
    WSSYNTAX "/busca";
    PATH "/busca"

END WSRESTFUL


WSMETHOD POST GeraSE2 WSSERVICE CargaSE2
Local lRet:=.f.
Local aArea:=GetArea()
Local aSE2Auto := {}
Local oContent:=self:getcontent()
Local oParsedContent:=JsonObject():New()
Local oResponse:=JsonObject():New()
Local cError := ""
Local dDatabase := Date()
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

        for nx:=1 to len(oParsedContent['SE2'])

                cFilAnt:=ALLTRIM(oParsedContent['SE2'][nX]['E2_FILIAL'])

                aadd(aSE2Auto,{"E2_FILIAL", ALLTRIM(oParsedContent['SE2'][nX]['E2_FILIAL']), nil})
                aadd(aSE2Auto,{"E2_PREFIXO", Alltrim(oParsedContent['SE2'][nX]['E2_PREFIXO']),nil}) 
                aadd(aSE2Auto,{"E2_NUM",  SUBSTRING(Alltrim(oParsedContent['SE2'][nX]['E2_NUM']),1,TamSX3("E2_NUM")[1]),nil})  

                If !empty(oParsedContent['SE2'][nX]['E2_TIPO'])
                    aadd(aSE2Auto,  {"E2_TIPO",SUBSTRING(Alltrim(oParsedContent['SE2'][nX]['E2_TIPO']),1,TamSX3("E2_TIPO")[1]),nil})  
                Endif

                If !empty(oParsedContent['SE2'][nX]['E2_PARCELA'])
                    aadd(aSE2Auto,  {"E2_PARCELA",SUBSTRING(Alltrim(oParsedContent['SE2'][nX]['E2_PARCELA']),1,TamSX3("E2_PARCELA")[1]),nil})      
                Endif

                If !empty(oParsedContent['SE2'][nX]['E2_NATUREZ'])
                    aadd(aSE2Auto,{"E2_NATUREZ",SUBSTRING(Alltrim(oParsedContent['SE2'][nX]['E2_NATUREZ']),1,TamSX3("E2_NATUREZ")[1]),nil})      
                Endif

                If !empty(oParsedContent['SE2'][nX]['E2_CCUSTO'])
                    aadd(aSE2Auto,{"E2_CCUSTO",SUBSTRING(Alltrim(oParsedContent['SE2'][nX]['E2_CCUSTO']),1,TamSX3("E2_CCUSTO")[1]),nil})    
                Endif

                If !empty(oParsedContent['SE2'][nX]['E2_VALOR'])
                    aadd(aSE2Auto,{"E2_VALOR", oParsedContent['SE2'][nX]['E2_VALOR'],nil})
                Endif


                If !empty(oParsedContent['SE2'][nX]['E2_FORNECE'])
                    aadd(aSE2Auto,{"E2_FORNECE",SUBSTRING(Alltrim(oParsedContent['SE2'][nX]['E2_FORNECE']),1,TamSX3("E2_FORNECE")[1]),nil})  
                Endif

                If !empty(oParsedContent['SE2'][nX]['E2_LOJA'])
                    aadd(aSE2Auto,{"E2_LOJA",SUBSTRING(Alltrim(oParsedContent['SE2'][nX]['E2_LOJA']),1,TamSX3("E2_LOJA")[1]),nil}) 
                Endif

                /*If !empty(oParsedContent['SE2'][nX]['E2_NOMFOR'])
                    aadd(aSE2Auto,{"E2_NOMFOR",SUBSTRING(Alltrim(oParsedContent['SE2'][nX]['E2_NOMFOR']),1,TamSX3("E2_LOJA")[1]),nil}) 
                Endif*/

                If !empty(oParsedContent['SE2'][nX]['E2_EMISSAO'])
                    aadd(aSE2Auto,{"E2_EMISSAO",STOD(oParsedContent['SE2'][nX]['E2_EMISSAO']),nil}) 
                Endif

                If !empty(oParsedContent['SE2'][nX]['E2_VENCTO'])
                    aadd(aSE2Auto,{"E2_VENCTO",STOD(oParsedContent['SE2'][nX]['E2_VENCTO']),nil}) 
                Endif

                If !empty(oParsedContent['SE2'][nX]['E2_VENCTO'])
                    aadd(aSE2Auto,{"E2_VENCREA",STOD(oParsedContent['SE2'][nX]['E2_VENCTO']),nil}) 
                Endif

                If !empty(oParsedContent['SE2'][nX]['E2_HIST'])
                    aadd(aSE2Auto,{"E2_HIST",SUBSTRING(ALLTRIM(oParsedContent['SE2'][nX]['E2_HIST']),1,TAMSX3("E2_HIST")[1]),nil}) 
                Endif

                    /*aadd(aSE2Auto,{"AUTBANCO",ALLTRIM(oParsedContent['SE2'][nX]['E2_BANCO']),nil})

                    Aadd(aSE2Auto,{"AUTAGENCIA",ALLTRIM(oParsedContent['SE2'][nX]['E2_AGENCIA']),nil})

                    aadd(aSE2Auto,{"AUTCONTA",ALLTRIM(oParsedContent['SE2'][nX]['E2_CONTA']),nil})*/


                //aadd(aSE2Auto,{"E2_DESDOBR","N",NIL})
                


            //------------------------------------
            // Chamada para cadastrar a SE2.
            //------------------------------------
            MSExecAuto({|x,y,Z| FINA050(x,y,Z)}, aSE2Auto,, nOpcAuto) 

            If lMsErroAuto  
                //lRet := .F.

                aAutoLog := GetAutoGRLog()
                oResponse['400']:=aAutoLog
                self:SetResponse(EncodeUtf8(oResponse:toJson()))
                //--------------------------------------------------------
                //Busca log de erro do ExecAuto e retorna o erro em Json.
                //-------------------------------------------------------
                codplanilha:=oParsedContent['SE2'][nX]['E2_NUM']
                Conout(codplanilha)

                //RpcClearEnv()
                //return lRet
            Else
                /*RECLOCK("SE2",.F.)

                    If !empty(oParsedContent['SE2'][nX]['ED_GRPTRIB'])
                        SE2->ED_GRPTRIB:= SUBSTRING(Alltrim(oParsedContent['SE2'][nX]['ED_GRPTRIB']),1,TamSX3("ED_GRPTRIB")[1])
                    Endif

                    If !empty(oParsedContent['SE2'][nX]['ED_CONTA'])
                        SE2->ED_CONTA:=SUBSTRING(Alltrim(oParsedContent['SE2'][nX]['ED_CONTA']),1,TamSX3("ED_CONTA")[1]) 
                    Endif

                    If !empty(oParsedContent['SE2'][nX]['ED_ZZCTAAD'])
                        SE2->ED_ZZCTAAD:=SUBSTRING(Alltrim(oParsedContent['SE2'][nX]['ED_ZZCTAAD']),1,TamSX3("ED_ZZCTAAD")[1])
                    Endif

                MSUNLOCK()*/

                    

                //----------------------------------------------------------------------
                //Sucesso do ExecAuto e retorna os dados do cliente cadastrado em Json.
                //----------------------------------------------------------------------        
                oResponse['message']:="Titulo cadastrado com sucesso!"


                Conout('Titulo Incluido!')

                self:SetContentType('application/json')
                self:SetResponse( EncodeUtf8(oResponse:toJson()) )

            EndIf
        
        NEXT



        //--------------------------------------------------------------------------------------------
        //Retorno codigo e mensagem de erro, caso não consiga preparar o ambiente com o RPCSetEnv().
        //--------------------------------------------------------------------------------------------            SetRestFault(400, ENCODEUTF8("Não foi possivel preparar o ambiente. Solicite suporte Protheus."))
endif


    RestArea(aArea)

Return lRet
