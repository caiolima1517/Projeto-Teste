#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "MsObject.ch"


WSRESTFUL CargaSB1 DESCRIPTION "Api utilizada para carga de Produtos" FORMAT APPLICATION_JSON

    WSMETHOD POST GeraSB1; 
    DESCRIPTION "Método para Gerar a carga na SB1, recebe um JSON.";
    WSSYNTAX "/importa";
    PATH "/importa"

    WSMETHOD GET BuscaSB1;
    DESCRIPTION "Busca o último registro da tabela SB1";
    WSSYNTAX "/busca";
    PATH "/busca"

END WSRESTFUL


WSMETHOD POST GeraSB1 WSSERVICE CargaSB1
Local lRet:=.f.
Local aArea:=GetArea()
Local oContent:=self:getcontent()
Local oParsedContent:=JsonObject():New()
Local oResponse:=JsonObject():New()
Local cError := ""
Local nx := 0

cError := oParsedContent:fromjson(oContent)

If !Empty(cError)

    //--------------------------
    // Retorna o erro do parse.
    //--------------------------
    SetRestFault(400, ENCODEUTF8(cError))

    return .f.
else
    oModel := FWLoadModel("MATA010")
    oModel:SetOperation(3)
    oModel:Activate()

    //oParsedContent := DECODEUTF8(oParsedContent)

    for nx:=1 to len(oParsedContent['SB1'])


        //Pegando o model e setando os campos
        nTamDesc:=TamSX3('B1_DESC')[1]
        desc := Substring(oParsedContent['SB1'][nX]['B1_DESC'],1,nTamDesc)
        oSB1Mod := oModel:GetModel("SB1MASTER")
        //oSB1Mod:SetValue("B1_COD"    , oParsedContent['SB1'][nx]['B1_COD']      ) 
        oSB1Mod:SetValue("B1_DESC"   , Upper(NoAcento(desc))      )      
        oSB1Mod:SetValue("B1_TIPO"   , oParsedContent['SB1'][nx]['B1_TIPO']      )
        oSB1Mod:SetValue("B1_GRUPO"   , oParsedContent['SB1'][nx]['B1_GRUPO']      )      
        oSB1Mod:SetValue("B1_UM"     , oParsedContent['SB1'][nx]['B1_UM']      )        
        oSB1Mod:SetValue("B1_LOCPAD" , oParsedContent['SB1'][nx]['B1_LOCPAD']      )
        oSB1Mod:SetValue("B1_POSIPI" , oParsedContent['SB1'][nx]['B1_POSIPI']      )
        
        If !empty(oParsedContent['SB1'][nx]['B1_IPI'])
            oSB1Mod:SetValue("B1_IPI" , val(oParsedContent['SB1'][nx]['B1_IPI']))     
        Endif

        If !empty(oParsedContent['SB1'][nx]['B1_PICM'])    
            oSB1Mod:SetValue("B1_PICM" , val(oParsedContent['SB1'][nx]['B1_PICM']))
        Endif

        If !empty(oParsedContent['SB1'][nx]['B1_PICMENT'])    
            oSB1Mod:SetValue("B1_PICMENT" , val(oParsedContent['SB1'][nx]['B1_PICMENT']))
        Endif

        If !empty(oParsedContent['SB1'][nx]['B1_CODISS'])
            //oSB1Mod:SetValue("B1_CODISS" , oParsedContent['SB1'][nx]['B1_CODISS']      )
        Endif

        oSB1Mod:SetValue("B1_ORIGEM" , oParsedContent['SB1'][nx]['B1_ORIGEM']      )
        
        If !empty(oParsedContent['SB1'][nx]['B1_RASTRO'])
            oSB1Mod:SetValue("B1_RASTRO" , oParsedContent['SB1'][nx]['B1_RASTRO']      )
        endif


        oSB1Mod:SetValue("B1_UREV" , iif(empty(oParsedContent['SB1'][nx]['B1_UREV']),ddatabase,oParsedContent['SB1'][nx]['B1_UREV'])      )

        If !empty(oParsedContent['SB1'][nx]['B1_GRTRIB'])
            oSB1Mod:SetValue("B1_GRTRIB" , oParsedContent['SB1'][nx]['B1_GRTRIB']      )
        Endif

        If !empty(oParsedContent['SB1'][nx]['B1_MRP'])
            oSB1Mod:SetValue("B1_MRP" , oParsedContent['SB1'][nx]['B1_MRP']      )
        Endif

        oSB1Mod:SetValue("B1_LOCALIZ" , oParsedContent['SB1'][nx]['B1_LOCALIZ']      )
        
        If !empty(oParsedContent['SB1'][nx]['B1_CEST'])
            oSB1Mod:SetValue("B1_CEST" , oParsedContent['SB1'][nx]['B1_CEST']      )
        Endif

        If !empty(oParsedContent['SB1'][nx]['B1_INSS'])
            oSB1Mod:SetValue("B1_INSS" , oParsedContent['SB1'][nx]['B1_INSS']      )
        Endif

        If !empty(oParsedContent['SB1'][nx]['B1_PIS'])    
            oSB1Mod:SetValue("B1_PIS" , oParsedContent['SB1'][nx]['B1_PIS']      )
        Endif

        If !empty(oParsedContent['SB1'][nx]['B1_COFINS'])    
            oSB1Mod:SetValue("B1_COFINS" , oParsedContent['SB1'][nx]['B1_COFINS']      )
        Endif

        If alltrim(oParsedContent['SB1'][nx]['B1_CSLL']) != "2"
            oSB1Mod:SetValue("B1_CSLL" , oParsedContent['SB1'][nx]['B1_CSLL']      )
        Endif
        
        IF oParsedContent['SB1'][nx]['B1_IRRF']$"S"
            oSB1Mod:SetValue("B1_IRRF" , oParsedContent['SB1'][nx]['B1_IRRF']      )
        endif

        /*IF !EMPTY(oParsedContent['SB1'][nx]['B1_X_CDSNR'])
            oSB1Mod:SetValue("B1_X_CDSNR" , oParsedContent['SB1'][nx]['B1_X_CDSNR']      )
        ENDIF


        IF !EMPTY(oParsedContent['SB1'][nx]['B1_X_PARTN'])
            oSB1Mod:SetValue("B1_X_PARTN" , oParsedContent['SB1'][nx]['B1_X_PARTN']      )
        ENDIF*/

        oSB1Mod:SetValue("B1_IMPORT" , oParsedContent['SB1'][nx]['B1_IMPORT']      )

        cCod:= ZB1COD(substr(oParsedContent['SB1'][nx]['B1_GRUPO'],3,2) )

        oSB1Mod:SetValue("B1_COD", cCod)

        //Se conseguir validar as informações
        If oModel:VldData()

            //Tenta realizar o Commit
            If oModel:CommitData()
                lOk := .T.

            //Se não deu certo, altera a variável para false
            Else
                lOk := .F.
            EndIf

        //Se não conseguir validar as informações, altera a variável para false
        Else
            lOk := .F.
        EndIf

        //Se não deu certo a inclusão, mostra a mensagem de erro
        If ! lOk
            //Busca o Erro do Modelo de Dados
            aErro := oModel:GetErrorMessage()

            //Monta o Texto que será mostrado na tela
            cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
            cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
            cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
            cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
            cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
            cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
            cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
            cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
            cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'

            //Mostra mensagem de erro
            lRet := .F.
            ConOut("Erro: " + cMessage)
        Else
            lRet := .T.
            ConOut("Produto incluido!")
        EndIf

        
        

        //lRet:= .T.

    NEXT

        //Desativa o modelo de dados
        oModel:DeActivate()

    

    if lRet
        oResponse['Message']:='Carga Efetuada Com Sucesso!'
    else
        oResponse['Message']:='Carga não efetuada'
    endif

    self:SetContentType('application/json')
    self:SetResponse( EncodeUtf8(oResponse:toJson()) )

    RestArea(aArea)
Endif

Return lRet




/*STATIC FUNCTION ZB1COD(_cTipo,_cGrupo)

Local cTipo := ALLTRIM(_cTipo)
Local cGrupo := ALLTRIM(_cGrupo)
Local cCod := ""
Local cQuery := ""

    If Select("SQLCOD") > 0 
        SQLCOD->(DbCloseArea())
    EndIf

    cQuery := " SELECT Substring(MAX(B1_COD),7,10)+1 AS B1_COD "+CRLF
    cQuery += " FROM "+ RETSQLNAME("SB1") +" WHERE "+CRLF
    cQuery += " B1_FILIAL='"+ xFilial("SB1") +"' AND "+CRLF
    cQuery += " B1_COD LIKE '"+ cTipo+cGrupo+"%'  "+CRLF

    TCQUERY cQuery New Alias "SQLCOD"

    If !SQLCOD->(EOF())
        If SQLCOD->B1_COD > 0
            cCod := cTipo+cGrupo+strzero(SQLCOD->B1_COD,9)
        else
            cCod := cTipo+cGrupo+"000000001"
        ENDIF

        //SQLCOD->(DBCLOSEAREA())
    ENDIF


Return(cCod)*/


STATIC FUNCTION ZB1COD(_cGrupo)

//Local cTipo := ALLTRIM(_cTipo)
Local cGrupo := ALLTRIM(_cGrupo)
Local cCod := ""
Local cQuery := ""

    If Select("SQLCOD") > 0 
        SQLCOD->(DbCloseArea())
    EndIf

    cQuery := " SELECT Substring(MAX(B1_COD),3,8)+1 AS B1_COD "+CRLF
    cQuery += " FROM "+ RETSQLNAME("SB1") +" WHERE "+CRLF
    cQuery += " B1_FILIAL='"+ xFilial("SB1") +"' AND "+CRLF
    cQuery += " B1_COD LIKE '"+cGrupo+"%'  "+CRLF

    TCQUERY cQuery New Alias "SQLCOD"

    If !SQLCOD->(EOF())
        If SQLCOD->B1_COD > 0
            cCod := cGrupo+strzero(SQLCOD->B1_COD,6)
        else
            cCod := cGrupo+"000001"
        ENDIF

        //SQLCOD->(DBCLOSEAREA())
    ENDIF


Return(cCod)




static FUNCTION NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõÃÕ"
Local cCecid := "çÇ"
Local cMaior := "&lt;"
Local cMenor := "&gt;"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0          
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

If cMaior$ cString 
	cString := strTran( cString, cMaior, "" ) 
EndIf
If cMenor$ cString 
	cString := strTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, CRLF, " " )

Return cString
