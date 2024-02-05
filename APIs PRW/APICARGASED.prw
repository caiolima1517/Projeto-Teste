#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"



WSRESTFUL CargaSED DESCRIPTION "Api utilizada para carga de Transportadoras" FORMAT APPLICATION_JSON

    WSMETHOD POST GeraSED; 
    DESCRIPTION "Método para Gerar a carga na SED, recebe um JSON.";
    WSSYNTAX "/importa";
    PATH "/importa"

    WSMETHOD GET BuscaSED;
    DESCRIPTION "Busca o último registro da tabela SED";
    WSSYNTAX "/busca";
    PATH "/busca"

END WSRESTFUL


WSMETHOD POST GeraSED WSSERVICE CargaSED
Local lRet:=.f.
Local aArea:=GetArea()
Local aSEDAuto := {}
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

        for nx:=1 to len(oParsedContent['SED'])

                aadd(aSEDAuto,{"ED_FILIAL", xFilial("SED"), nil})
                aadd(aSEDAuto,{"ED_CODIGO", SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_CODIGO']),1,TamSX3("ED_CODIGO")[1]),nil}) 
                aadd(aSEDAuto,{"ED_DESCRIC",  SUBSTRING(Alltrim(UPPER(oParsedContent['SED'][nX]['ED_DESCRIC'])),1,TamSX3("ED_DESCRIC")[1]),nil})  

                If !empty(oParsedContent['SED'][nX]['ED_CALCIRF'])
                    aadd(aSEDAuto,  {"ED_CALCIRF",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_CALCIRF']),1,TamSX3("ED_CALCIRF")[1]),nil})  
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_CALCISS'])
                    aadd(aSEDAuto,  {"ED_CALCISS",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_CALCISS']),1,TamSX3("ED_CALCISS")[1]),nil})      
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_PERCIRF'])
                    aadd(aSEDAuto,{"ED_PERCIRF",oParsedContent['SED'][nX]['ED_PERCIRF'],nil})      
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_CALCINS'])
                    aadd(aSEDAuto,{"ED_CALCINS",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_CALCINS']),1,TamSX3("ED_CALCINS")[1]),nil})    
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_PERCINS'])
                    aadd(aSEDAuto,{"ED_PERCINS", VAL(oParsedContent['SED'][nX]['ED_PERCINS']),nil})
                Endif


                If !empty(oParsedContent['SED'][nX]['ED_CALCCSL'])
                    aadd(aSEDAuto,{"ED_CALCCSL",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_CALCCSL']),1,TamSX3("ED_CALCCSL")[1]),nil})  
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_CALCCOF'])
                    aadd(aSEDAuto,{"ED_CALCCOF",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_CALCCOF']),1,TamSX3("ED_CALCCOF")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_CALCPIS'])
                    aadd(aSEDAuto,{"ED_CALCPIS",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_CALCPIS']),1,TamSX3("ED_CALCPIS")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_PERCCSL'])
                    aadd(aSEDAuto,{"ED_PERCCSL",VAL(oParsedContent['SED'][nX]['ED_PERCCSL']),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_PERCCOF'])
                    aadd(aSEDAuto,{"ED_PERCCOF",VAL(oParsedContent['SED'][nX]['ED_PERCCOF']),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_PERCPIS'])
                    aadd(aSEDAuto,{"ED_PERCPIS",VAL(oParsedContent['SED'][nX]['ED_PERCPIS']),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_CONTA'])
                    aadd(aSEDAuto,{"ED_CONTA",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_CONTA']),1,TamSX3("ED_CONTA")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_ZZCTAC'])
                    aadd(aSEDAuto,{"ED_ZZCTAC",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_ZZCTAC']),1,TamSX3("ED_ZZCTAC")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_DEDPIS'])
                    aadd(aSEDAuto,{"ED_DEDPIS",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_DEDPIS']),1,TamSX3("ED_DEDPIS")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_DEDCOF'])
                    aadd(aSEDAuto,{"ED_DEDCOF",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_DEDCOF']),1,TamSX3("ED_DEDCOF")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_DEDINSS'])
                    aadd(aSEDAuto,{"ED_DEDINSS",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_DEDINSS']),1,TamSX3("ED_DEDINSS")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_TIPO'])
                    aadd(aSEDAuto,{"ED_TIPO",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_TIPO']),1,TamSX3("ED_TIPO")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_PAI'])
                    aadd(aSEDAuto,{"ED_PAI",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_PAI']),1,TamSX3("ED_PAI")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_COND'])
                    aadd(aSEDAuto,{"ED_COND",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_COND']),1,TamSX3("ED_COND")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SED'][nX]['ED_TPREG'])
                    aadd(aSEDAuto,{"ED_TPREG",SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_TPREG']),1,TamSX3("ED_TPREG")[1]),nil}) 
                Endif


            //------------------------------------
            // Chamada para cadastrar a natureza.
            //------------------------------------
            MSExecAuto({|x, y| FINA010(x, y)}, aSEDAuto, nOpcAuto) 

            If lMsErroAuto  
                //lRet := .F.

                aAutoLog := GetAutoGRLog()
                oResponse['400']:=aAutoLog
                self:SetResponse(EncodeUtf8(oResponse:toJson()))
                //--------------------------------------------------------
                //Busca log de erro do ExecAuto e retorna o erro em Json.
                //-------------------------------------------------------
                codplanilha:=oParsedContent['SED'][nX]['ED_COD']
                Conout(codplanilha)

                //RpcClearEnv()
                //return lRet
            Else
                /*RECLOCK("SED",.F.)

                    If !empty(oParsedContent['SED'][nX]['ED_GRPTRIB'])
                        SED->ED_GRPTRIB:= SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_GRPTRIB']),1,TamSX3("ED_GRPTRIB")[1])
                    Endif

                    If !empty(oParsedContent['SED'][nX]['ED_CONTA'])
                        SED->ED_CONTA:=SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_CONTA']),1,TamSX3("ED_CONTA")[1]) 
                    Endif

                    If !empty(oParsedContent['SED'][nX]['ED_ZZCTAAD'])
                        SED->ED_ZZCTAAD:=SUBSTRING(Alltrim(oParsedContent['SED'][nX]['ED_ZZCTAAD']),1,TamSX3("ED_ZZCTAAD")[1])
                    Endif

                MSUNLOCK()*/

                    

                //----------------------------------------------------------------------
                //Sucesso do ExecAuto e retorna os dados do cliente cadastrado em Json.
                //----------------------------------------------------------------------        
                oResponse['message']:="Cliente cadastrado com sucesso!"


                Conout('Cliente Incluido!')

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
