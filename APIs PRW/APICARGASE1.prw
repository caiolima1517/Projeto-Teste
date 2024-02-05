#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//***********************************************

//API de carga da SE1 p/ empresa Xmobots

//***********************************************

WSRESTFUL CargaSE1 DESCRIPTION "Api utilizada para carga de Contas a Pagar" FORMAT APPLICATION_JSON

    WSMETHOD POST GeraSE1; 
    DESCRIPTION "Método para Gerar a carga na SE1, recebe um JSON.";
    WSSYNTAX "/importa";
    PATH "/importa"

    WSMETHOD GET BuscaSE1;
    DESCRIPTION "Busca o último registro da tabela SE1";
    WSSYNTAX "/busca";
    PATH "/busca"

END WSRESTFUL


WSMETHOD POST GeraSE1 WSSERVICE CargaSE1
Local lRet:=.f.
Local aArea:=GetArea()
Local aVetSE1 := {}
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

        for nx:=1 to len(oParsedContent['SE1'])

                cFilAnt:=ALLTRIM(oParsedContent['SE1'][nX]['E1_FILIAL'])

                aadd(aVetSE1,{"E1_FILIAL", ALLTRIM(oParsedContent['SE1'][nX]['E1_FILIAL']), nil})
                aadd(aVetSE1,{"E1_PREFIXO", Alltrim(oParsedContent['SE1'][nX]['E1_PREFIXO']),nil}) 
                aadd(aVetSE1,{"E1_NUM",  SUBSTRING(Alltrim(oParsedContent['SE1'][nX]['E1_NUM']),1,TamSX3("E1_NUM")[1]),nil})  

                If !empty(oParsedContent['SE1'][nX]['E1_TIPO'])
                    aadd(aVetSE1,  {"E1_TIPO",Alltrim(oParsedContent['SE1'][nX]['E1_TIPO']),nil})  
                Endif

                If !empty(oParsedContent['SE1'][nX]['E1_PARCELA'])
                    aadd(aVetSE1,  {"E1_PARCELA",Alltrim(oParsedContent['SE1'][nX]['E1_PARCELA']),nil})      
                Endif

                If !empty(oParsedContent['SE1'][nX]['E1_NATUREZ'])
                    aadd(aVetSE1,{"E1_NATUREZ",Alltrim(oParsedContent['SE1'][nX]['E1_NATUREZ']),nil})      
                Endif

                If !empty(oParsedContent['SE1'][nX]['E1_CCUSTO'])
                    aadd(aVetSE1,{"E1_CCUSTO",Alltrim(oParsedContent['SE1'][nX]['E1_CCUSTO']),nil})    
                Endif

                If !empty(oParsedContent['SE1'][nX]['E1_VALOR'])
                    aadd(aVetSE1,{"E1_VALOR", oParsedContent['SE1'][nX]['E1_VALOR'],nil})
                Endif


                If !empty(oParsedContent['SE1'][nX]['E1_CLIENTE'])
                    aadd(aVetSE1,{"E1_CLIENTE",Alltrim(oParsedContent['SE1'][nX]['E1_CLIENTE']),nil})  
                Endif

                If !empty(oParsedContent['SE1'][nX]['E1_LOJA'])
                    aadd(aVetSE1,{"E1_LOJA",Alltrim(oParsedContent['SE1'][nX]['E1_LOJA']),nil}) 
                Endif

                /*If !empty(oParsedContent['SE1'][nX]['E1_NOMFOR'])
                    aadd(aVetSE1,{"E1_NOMFOR",SUBSTRING(Alltrim(oParsedContent['SE1'][nX]['E1_NOMFOR']),1,TamSX3("E1_LOJA")[1]),nil}) 
                Endif*/

                If !empty(oParsedContent['SE1'][nX]['E1_EMISSAO'])
                    aadd(aVetSE1,{"E1_EMISSAO",STOD(oParsedContent['SE1'][nX]['E1_EMISSAO']),nil}) 
                Endif

                If !empty(oParsedContent['SE1'][nX]['E1_VENCTO'])
                    aadd(aVetSE1,{"E1_VENCTO",STOD(oParsedContent['SE1'][nX]['E1_VENCTO']),nil}) 
                Endif

                If !empty(oParsedContent['SE1'][nX]['E1_VENCTO'])
                    aadd(aVetSE1,{"E1_VENCREA",STOD(oParsedContent['SE1'][nX]['E1_VENCTO']),nil}) 
                Endif

                If !empty(oParsedContent['SE1'][nX]['E1_HIST'])
                    aadd(aVetSE1,{"E1_HIST",SUBSTRING(ALLTRIM(oParsedContent['SE1'][nX]['E1_HIST']),1,TAMSX3("E1_HIST")[1]),nil}) 
                Endif

                aAdd(aVetSE1, {"E1_MOEDA"   ,1                  ,   Nil})

                If !empty(oParsedContent['SE1'][nX]['E1_BANCO'])
                    aadd(aVetSE1,{"CBCOAUTO",ALLTRIM(oParsedContent['SE1'][nX]['E1_BANCO']),nil})
                endif

                If !empty(oParsedContent['SE1'][nX]['E1_AGENCIA'])
                    Aadd(aVetSE1,{"CAGEAUTO",ALLTRIM(oParsedContent['SE1'][nX]['E1_AGENCIA']),nil})
                endif

                If !empty(oParsedContent['SE1'][nX]['E1_CONTA'])
                    aadd(aVetSE1,{"CCTAAUTO",ALLTRIM(oParsedContent['SE1'][nX]['E1_CONTA']),nil}) 
                endif

            //------------------------------------
            // Chamada para cadastrar a SE1.
            //------------------------------------
            MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)

            If lMsErroAuto  
                //lRet := .F.

                aAutoLog := GetAutoGRLog()
                oResponse['400']:=aAutoLog
                self:SetResponse(EncodeUtf8(oResponse:toJson()))
                //--------------------------------------------------------
                //Busca log de erro do ExecAuto e retorna o erro em Json.
                //-------------------------------------------------------
                codplanilha:=oParsedContent['SE1'][nX]['E1_NUM']
                Conout(codplanilha)

                //RpcClearEnv()
                //return lRet
            Else       

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
