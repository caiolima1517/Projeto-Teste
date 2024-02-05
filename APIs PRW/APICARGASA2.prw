#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"



WSRESTFUL CargaSA2 DESCRIPTION "Api utilizada para carga de Transportadoras" FORMAT APPLICATION_JSON

    WSMETHOD POST GeraSA2; 
    DESCRIPTION "Método para Gerar a carga na SA2, recebe um JSON.";
    WSSYNTAX "/importa";
    PATH "/importa"

    WSMETHOD GET BuscaSA2;
    DESCRIPTION "Busca o último registro da tabela SA2";
    WSSYNTAX "/busca";
    PATH "/busca"

END WSRESTFUL


WSMETHOD POST GeraSA2 WSSERVICE CargaSA2
Local lRet:=.f.
Local aArea:=GetArea()
Local aSA2Auto := {}
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

        for nx:=1 to len(oParsedContent['SA2'])

                aadd(aSA2Auto,{"A2_FILIAL", xFilial("SA2"), nil})
                aadd(aSA2Auto,{"A2_COD", SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_COD']),1,TamSX3("A2_COD")[1]),nil}) 
                aadd(aSA2Auto,{"A2_LOJA",  SUBSTRING(Alltrim(UPPER(oParsedContent['SA2'][nX]['A2_LOJA'])),1,TamSX3("A2_LOJA")[1]),nil})  
                aadd(aSA2Auto,{"A2_NOME",     SUBSTRING(Alltrim(UPPER(oParsedContent['SA2'][nX]['A2_NOME'])),1,TamSX3("A2_NOME")[1]),nil})      
                aadd(aSA2Auto,{"A2_NREDUZ",    SUBSTRING(Alltrim(UPPER(oParsedContent['SA2'][nX]['A2_NREDUZ'])),1,TamSX3("A2_NREDUZ")[1]),nil})

                If !empty(oParsedContent['SA2'][nX]['A2_END'])
                    aadd(aSA2Auto,  {"A2_END",SUBSTRING(Alltrim(UPPER(oParsedContent['SA2'][nX]['A2_END'])),1,TamSX3("A2_END")[1]),nil})  
                Endif

                
                If !empty(oParsedContent['SA2'][nX]['A2_COMPLEM'])
                    aadd(aSA2Auto,{"A2_COMPLEM",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_COMPLEM']),1,TamSX3("A2_COMPLEM")[1]),nil}) 
                Endif


                If !empty(oParsedContent['SA2'][nX]['A2_BAIRRO'])
                    aadd(aSA2Auto,  {"A2_BAIRRO",SUBSTRING(Alltrim(UPPER(oParsedContent['SA2'][nX]['A2_BAIRRO'])),1,TamSX3("A2_BAIRRO")[1]),nil})      
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_EST'])
                    aadd(aSA2Auto,{"A2_EST", SUBSTRING(Alltrim(UPPER(oParsedContent['SA2'][nX]['A2_EST'])),1,TamSX3("A2_EST")[1]),nil})
                Endif

                /*If !empty(oParsedContent['SA2'][nX]['A2_COD_MUN'])
                    aadd(aSA2Auto,{"A2_COD_MUN",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_COD_MUN']),1,TamSX3("A2_COD_MUN")[1]),nil})  
                Endif*/

                If !empty(oParsedContent['SA2'][nX]['A2_DEDBSPC'])
                    aadd(aSA2Auto,{"A2_DEDBSPC",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_DEDBSPC']),1,TamSX3("A2_DEDBSPC")[1]),nil})  
                Endif


                If !empty(oParsedContent['SA2'][nX]['A2_TIPO'])
                    aadd(aSA2Auto,{"A2_TIPO",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_TIPO']),1,TamSX3("A2_TIPO")[1]),nil})    
                Endif


                If !empty(oParsedContent['SA2'][nX]['A2_CEP'])
                    aadd(aSA2Auto,{"A2_CEP",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_CEP']),1,TamSX3("A2_CEP")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_MUN'])
                    aadd(aSA2Auto,{"A2_MUN",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_MUN']),1,TamSX3("A2_MUN")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_PAIS'])
                    aadd(aSA2Auto,{"A2_PAIS",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_PAIS']),1,TamSX3("A2_PAIS")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_CODPAIS'])
                    aadd(aSA2Auto,{"A2_CODPAIS",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_CODPAIS']),1,TamSX3("A2_CODPAIS")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_CGC'])
                    aadd(aSA2Auto,{"A2_CGC",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_CGC']),1,TamSX3("A2_CGC")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_INSCR'])
                    aadd(aSA2Auto,{"A2_INSCR",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_INSCR']),1,TamSX3("A2_INSCR")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_INSCRM'])
                    aadd(aSA2Auto,{"A2_INSCRM",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_INSCRM']),1,TamSX3("A2_INSCRM")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_CONTATO'])
                    aadd(aSA2Auto,{"A2_CONTATO",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_CONTATO']),1,TamSX3("A2_CONTATO")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_DDD'])
                    aadd(aSA2Auto,{"A2_DDD",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_DDD']),1,TamSX3("A2_DDD")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_TEL'])
                    aadd(aSA2Auto,{"A2_TEL",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_TEL']),1,TamSX3("A2_TEL")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_RECISS'])
                    aadd(aSA2Auto,{"A2_RECISS",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_RECISS']),1,TamSX3("A2_RECISS")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_RECINSS'])
                    aadd(aSA2Auto,{"A2_RECINSS",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_RECINSS']),1,TamSX3("A2_RECINSS")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_RECCOFI'])
                    aadd(aSA2Auto,{"A2_RECCOFI",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_RECCOFI']),1,TamSX3("A2_RECCOFI")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_RECCSLL'])
                    aadd(aSA2Auto,{"A2_RECCSLL",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_RECCSLL']),1,TamSX3("A2_RECCSLL")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_RECPIS'])
                    aadd(aSA2Auto,{"A2_RECPIS",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_RECPIS']),1,TamSX3("A2_RECPIS")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_CONTRIB'])
                    aadd(aSA2Auto,{"A2_CONTRIB",IIF(oParsedContent['SA2'][nX]['A2_CONTRIB']$"N","2","1"),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_CALCIRF'])
                    aadd(aSA2Auto,{"A2_CALCIRF",oParsedContent['SA2'][nX]['A2_CALCIRF'],nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_SIMPNAC'])
                    aadd(aSA2Auto,{"A2_SIMPNAC",oParsedContent['SA2'][nX]['A2_SIMPNAC'],nil}) 
                Endif


                If !empty(oParsedContent['SA2'][nX]['A2_GRPTRIB'])
                    aadd(aSA2Auto,{"A2_GRPTRIB",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_GRPTRIB']),1,TamSX3("A2_GRPTRIB")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_CONTA'])
                    aadd(aSA2Auto,{"A2_CONTA",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_CONTA']),1,TamSX3("A2_CONTA")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SA2'][nX]['A2_ZZCTAAD'])
                    aadd(aSA2Auto,{"A2_ZZCTAAD",SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_ZZCTAAD']),1,TamSX3("A2_ZZCTAAD")[1]),nil}) 
                Endif

                


            //------------------------------------
            // Chamada para cadastrar o fornecedor.
            //------------------------------------
            MSExecAuto({|x,y| MATA020(x,y)}, aSA2Auto, nOpcAuto)

            If lMsErroAuto  
                //lRet := .F.

                aAutoLog := GetAutoGRLog()
                oResponse['400']:=aAutoLog
                self:SetResponse(EncodeUtf8(oResponse:toJson()))
                //--------------------------------------------------------
                //Busca log de erro do ExecAuto e retorna o erro em Json.
                //-------------------------------------------------------
                codplanilha:=oParsedContent['SA2'][nX]['A2_COD']
                Conout(codplanilha)

                //RpcClearEnv()
                //return lRet
            Else
                RECLOCK("SA2",.F.)

                    /*If !empty(oParsedContent['SA2'][nX]['A2_GRPTRIB'])
                        SA2->A2_GRPTRIB:= SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_GRPTRIB']),1,TamSX3("A2_GRPTRIB")[1])
                    Endif*/

                    /*If !empty(oParsedContent['SA2'][nX]['A2_CONTA'])
                        SA2->A2_CONTA:=SUBSTRING(Alltrim(oParsedContent['SA2'][nX]['A2_CONTA']),1,TamSX3("A2_CONTA")[1]) 
                    Endif*/

                    SA2->A2_COD_MUN := Alltrim(oParsedContent['SA2'][nX]['A2_COD_MUN'])

                    /*If !empty(oParsedContent['SA2'][nX]['A2_ZZCTAAD'])
                        SA2->A2_ZZCTAAD:="1103012000001"
                    Endif*/

                MSUNLOCK()

                    

                //----------------------------------------------------------------------
                //Sucesso do ExecAuto e retorna os dados do cliente cadastrado em Json.
                //----------------------------------------------------------------------        
                oResponse['message']:="Fornecedor cadastrado com sucesso!"


                Conout('Fornecedor Incluido!')

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
