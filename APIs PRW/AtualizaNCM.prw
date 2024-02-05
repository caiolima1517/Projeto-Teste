//Bibliotecas
#Include "TOTVS.ch"
  
/*/{Protheus.doc} User Function zImpSYD
Função para atualizar a tabela de NCM no Protheus
@type  Function
@author Atilio
@since 12/11/2022
@obs A atualização é baseada no JSON disponível para download em:
  https://www.gov.br/receitafederal/pt-br/assuntos/aduana-e-comercio-exterior/classificacao-fiscal-de-mercadorias/download-ncm-nomenclatura-comum-do-mercosul
/*/
  
User Function zImpSYD()
    Local aArea := FWGetArea()
  
    //Se a pergunta for confirmada
    If FWAlertYesNo("Deseja atualizar a tabela de NCMs no Protheus?", "Continua")
        Processa({|| fImporta() }, 'NCMs...')
    EndIf
  
    FWRestArea(aArea)
Return
  
Static Function fImporta()
    Local cLinkDown  := "https://portalunico.siscomex.gov.br/classif/api/publico/nomenclatura/download/json?perfil=PUBLICO"
    Local cTxtJson   := ""
    Local cError     := ""
    Local jImport
    Local jNomenclat
    Local jNCMAtu
    Local nNCMAtu    := 0
    Local cCodigo    := ""
    Local cDescric   := ""
    Local aDados     := {}
    Local cLog       := ""
    Local nLinhaErro := 0
    //Variáveis para log do ExecAuto
    Private lMSHelpAuto    := .T.
    Private lAutoErrNoFile := .T.
    Private lMsErroAuto    := .F.
  
    //Baixa o JSON disponível
    cTxtJson := HttpGet(cLinkDown)
    cTxtJson := FWNoAccent(cTxtJson)
  
    //Se houver conteúdo
    If ! Empty(cTxtJson)
        jImport := JsonObject():New()
        cError  := jImport:FromJson(cTxtJson)
  
        DbSelectArea("SYD")
        SYD->(DbSetOrder(1)) // YD_FILIAL + YD_TEC + YD_EX_NCM + YD_EX_NBM + YD_DESTAQU
      
        //Se não tiver erro no parse
        If Empty(cError)
            jNomenclat := jImport:GetJsonObject('Nomenclaturas')
  
            //Percorre os NCM
            nTotal := Len(jNomenclat)
            ProcRegua(nTotal)
            For nNCMAtu := 1 To nTotal
                IncProc("Processando registro " + cValToChar(nNCMAtu) + " de " + cValToChar(nTotal) + "...")
  
                //Pegando o NCM atual, o código e a descrição
                jNCMAtu  := jNomenclat[nNCMAtu]
                cCodigo  := jNCMAtu:GetJsonObject("Codigo")
                cDescric := jNCMAtu:GetJsonObject("Descricao")
  
                //Remove caracteres especiais da descrição
                cDescric := StrTran(cDescric, "-", "")
                cDescric := StrTran(cDescric, "<i>", "")
                cDescric := StrTran(cDescric, "</i>", "")
                cDescric := Alltrim(cDescric)
  
                //Removendo os pontos do código
                cCodigo := Alltrim(cCodigo)
                cCodigo := StrTran(cCodigo, ".", "")
                cCodigo := StrTran(cCodigo, "-", "")
  
                //Se o código tiver 8 caracteres e não conseguir posicionar no registro
                If Len(cCodigo) == 8 .And. ! SYD->(MsSeek(FWxFilial("SYD") + cCodigo))
                    aDados := {}
                    aAdd(aDados, {"YD_TEC",    cCodigo,  Nil})
                    aAdd(aDados, {"YD_DESC_P", cDescric, Nil})
                    aAdd(aDados, {"YD_UNID",   "UN",     Nil})
  
                    //Aciona a inclusão do registro
                    lMsErroAuto := .F.
                    MSExecAuto({|x, y| MVC_EICA130(x, y)}, aDados, 3)
  
                    //Se houve erro, gera o log
                    If lMsErroAuto
                        cPastaErro := '\x_logs\'
                        cNomeErro  := 'erro_syd_cod_' + cCodigo + "_" + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.txt'
  
                        //Se a pasta de erro não existir, cria ela
                        If ! ExistDir(cPastaErro)
                            MakeDir(cPastaErro)
                        EndIf
  
                        //Pegando log do ExecAuto, percorrendo e incrementando o texto
                        cTextoErro := ""
                        cTextoErro += "Codigo:    " + cCodigo + CRLF
                        cTextoErro += "Descricao: " + cDescric + CRLF
                        cTextoErro += "--" + CRLF + CRLF
                        aLogErro := GetAutoGRLog()
                        For nLinhaErro := 1 To Len(aLogErro)
                            cTextoErro += aLogErro[nLinhaErro] + CRLF
                        Next
  
                        //Criando o arquivo txt e incrementa o log
                        MemoWrite(cPastaErro + cNomeErro, cTextoErro)
                        cLog += '- Falha ao incluir registro, codigo [' + cCodigo + '], veja o arquivo de log em ' + cPastaErro + cNomeErro + CRLF
                    Else
                        cLog += '+ Sucesso no Execauto no codigo ' + cCodigo + ';' + CRLF
                    EndIf
                EndIf
            Next
  
            //Se tiver log, mostra ele
            If ! Empty(cLog)
                cDirTmp := GetTempPath()
                cArqLog := 'importacao_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
                MemoWrite(cDirTmp + cArqLog, cLog)
                ShellExecute('OPEN', cArqLog, '', cDirTmp, 1)
            EndIf
  
        Else
            FWAlertError("Houve uma falha na conversão do JSON: " + CRLF + cError, "Erro no Parse")
        EndIf
    EndIf
Return
