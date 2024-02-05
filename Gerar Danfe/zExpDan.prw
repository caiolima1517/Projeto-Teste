//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} zExpDan
FunÃ§Ã£o para gerar os pdf e os xml de um intervalo em uma pasta
@author Atilio
@since 23/06/2019
@version 1.0
@type function
/*/

User Function zExpDan()
	Local aArea   := GetArea()
	Local aPergs  := {}
	Local cDiret  := "C:\TOTVS\NF\" + Space(99)
	Local dDataDe := FirstDate(Date())
	Local dDataAt := Date()
	
	//Adiciona os parÃ¢metros
	aAdd(aPergs, {1, "Diretório",     cDiret,  "",   ".T.", "", ".T.", 80, .T.})
	aAdd(aPergs, {1, "Data De",       dDataDe, "",   ".T.", "", ".T.", 80, .T.})
	aAdd(aPergs, {1, "Data Até",      dDataAt, "",   ".T.", "", ".T.", 80, .T.})
	aAdd(aPergs, {2, "Gera pdf",      2, {"1=Sim",  "2=Não"}, 040, ".T.", .F.})
	aAdd(aPergs, {2, "Gera xml",      1, {"1=Sim",  "2=Não"}, 040, ".T.", .F.})
	aAdd(aPergs, {2, "Tipo",          1, {"1=Normal (N)",  "2=Devolução (D)", "3=Fornecedor (B)"}, 060, ".T.", .F.})
	
	//Mostra a tela para informas os parÃ¢metros
	If ParamBox(aPergs, "Informe os parâmetros")
		MV_PAR04 := cValToChar(MV_PAR04)
		MV_PAR05 := cValToChar(MV_PAR05)
		MV_PAR06 := cValToChar(MV_PAR06)
		
		//Se nÃ£o existir o diretÃ³rio,forÃ§a a criaÃ§Ã£o
		MV_PAR01 := Alltrim(MV_PAR01)
		If ! ExistDir(MV_PAR01)
			MakeDir(MV_PAR01)
		EndIf
		
		//Se a data atÃ© for maior que a data inicial
		If MV_PAR03 >= MV_PAR02
		
			//Se for para gerar o pdf ou o xml, chama a rotina de processamento
			If MV_PAR04 == "1" .Or. MV_PAR05 == "1"
				Processa({|| fProcessa() }, "Processando...")
			EndIf
			
		Else
			MsgStop("Data Até tem que ser maior que Data De", "Atenção")
		EndIf
	EndIf
	
	
	RestArea(aArea)
Return

Static Function fProcessa()
	Local aArea  := GetArea()
	Local cQuery := ""
	Local nAtual := 0
	Local nTotal := 0
	Local lXML   := MV_PAR05 == "1"
	Local lPDF   := MV_PAR04 == "1"
	Local cDir   := MV_PAR01
	
	//Montando a query para geraÃ§Ã£o das Notas Fiscais
	cQuery := " SELECT " + CRLF
	cQuery += "     F2_DOC, " + CRLF
	cQuery += "     F2_SERIE, " + CRLF
	cQuery += "     F2_EMISSAO " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += "     " + RetSQLName('SF2') + " SF2 WITH (NOLOCK) " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += "     F2_FILIAL = '" + FWxFilial('SF2') + "' " + CRLF
	cQuery += "     AND F2_EMISSAO >= '" + dToS(MV_PAR02) + "' " + CRLF
	cQuery += "     AND F2_EMISSAO <= '" + dToS(MV_PAR03) + "' " + CRLF
	If MV_PAR06 == "1"
		cQuery += "     AND F2_TIPO = 'N' " + CRLF
	ElseIf MV_PAR06 == "2"
		cQuery += "     AND F2_TIPO = 'D' " + CRLF
	ElseIf MV_PAR06 == "3"
		cQuery += "     AND F2_TIPO = 'B' " + CRLF
	EndIf
	cQuery += "     AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " ORDER BY " + CRLF
	cQuery += "     F2_EMISSAO, F2_DOC " + CRLF
	TCQuery cQuery New Alias "QRY_XML"
	TCSetField("QRY_XML", "F2_EMISSAO", "D")
	
	//Se tiver notas
	If ! QRY_XML->(EoF())
		
		//Pegando o total e definindo o tamanho da rÃ©gua
		Count To nTotal
		ProcRegua(nTotal)
		QRY_XML->(DbGoTop())
		
		//Enquanto houver notas
		While ! QRY_XML->(EoF())
			
			//Incrementa a rÃ©gua
			nAtual++
			IncProc("Gerando nota " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " (dia " + dToC(QRY_XML->F2_EMISSAO) + ")...")
			
			//Chamando a funÃ§Ã£o para gerar o xml e/ou o pdf
			u_zGerDanfe(QRY_XML->F2_DOC, QRY_XML->F2_SERIE, cDir, lXML, lPDF)
			
			QRY_XML->(DbSkip())
		EndDo
		
	Else
		MsgStop("Não existem notas no período informado!", "Atenção")
	EndIf
	QRY_XML->(DbCloseArea())
	
	RestArea(aArea)
Return
