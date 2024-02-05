//Bibliotecas
#Include "Totvs.ch"
  
/*/{Protheus.doc} User Function zImpCC2
Importa��o de Munic�pios
@author Atilio
@since 13/11/2022
@version 1.0
@type function
/*/
  
User Function zImpCC2()
    Local aArea := FWGetArea()
    Local cDirIni := GetTempPath()
    Local cTipArq := 'Arquivos com separa��es (*.csv) | Arquivos texto (*.txt) | Todas extens�es (*.*)'
    Local cTitulo := 'Sele��o de Arquivos para Processamento'
    Local lSalvar := .F.
    Local cArqSel := ''
   
    //Se n�o estiver sendo executado via job
    If ! IsBlind()
   
        //Chama a fun��o para buscar arquivos
        cArqSel := tFileDialog(;
            cTipArq,;  // Filtragem de tipos de arquivos que ser�o selecionados
            cTitulo,;  // T�tulo da Janela para sele��o dos arquivos
            ,;         // Compatibilidade
            cDirIni,;  // Diret�rio inicial da busca de arquivos
            lSalvar,;  // Se for .T., ser� uma Save Dialog, sen�o ser� Open Dialog
            ;          // Se n�o passar par�metro, ir� pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT ser� poss�vel pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY ser� poss�vel selecionar o diret�rio
        )
  
        //Se tiver o arquivo selecionado e ele existir
        If ! Empty(cArqSel) .And. File(cArqSel)
            Processa({|| fImporta(cArqSel) }, 'Importando...')
        EndIf
    EndIf
      
    FWRestArea(aArea)
Return
      
/*/{Protheus.doc} fImporta
Fun��o que processa o arquivo e realiza a importa��o para o sistema
@author Atilio
@since 13/11/2022
@version 1.0
@type function
/*/
  
Static Function fImporta(cArqSel)
    Local cDirTmp    := GetTempPath()
    Local cArqLog    := 'importacao_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
    Local nTotLinhas := 0
    Local cLinAtu    := ''
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local oArquivo
    Local cPastaErro := '\x_logs\'
    Local cNomeErro  := ''
    Local cTextoErro := ''
    Local aLogErro   := {}
    Local nLinhaErro := 0
    Local cLog       := ''
    //Vari�veis do ExecAuto
    Private aDados         := {}
    Private lMSHelpAuto    := .T.
    Private lAutoErrNoFile := .T.
    Private lMsErroAuto    := .F.
    //Vari�veis da Importa��o
    Private cAliasImp  := 'CC2'
    Private cSeparador := ';'
  
    //Abre as tabelas que ser�o usadas
    DbSelectArea(cAliasImp)
    (cAliasImp)->(DbSetOrder(1))
    (cAliasImp)->(DbGoTop())
  
    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqSel)
  
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
  
        //Se n�o for fim do arquivo
        If ! (oArquivo:EoF())
  
            //Definindo o tamanho da r�gua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
  
            //M�todo GoTop n�o funciona (dependendo da vers�o da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqSel)
            oArquivo:Open()
  
            DbSelectArea("CC2")
            CC2->(DbSetOrder(1)) // CC2_FILIAL + CC2_EST + CC2_CODMUN
  
            //Enquanto tiver linhas
            While (oArquivo:HasLine())
  
                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc('Analisando linha ' + cValToChar(nLinhaAtu) + ' de ' + cValToChar(nTotLinhas) + '...')
  
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := Separa(cLinAtu, cSeparador)
  
                //Se houver posi��es no array e somente a partir da linha 2
                If Len(aLinha) > 0 .And. nLinhaAtu >= 2
                    //Busca o estado conforme o c�digo
                    cEstado := Lj901AUF(aLinha[1])
  
                    //Somente se n�o encontrar a cidade ja cadastrada
                    If ! CC2->(MsSeek(FWxFilial("CC2") + cEstado + aLinha[11]))
  
                        //Monta o array de importa��o
                        aDados := {}
                        aAdd(aDados, {'CC2_EST',    cEstado,    Nil})
                        aAdd(aDados, {'CC2_CODMUN', aLinha[11], Nil})
                        aAdd(aDados, {'CC2_MUN',    aLinha[13], Nil})
  
                        lMsErroAuto := .F.
                        MSExecAuto({|x, y| FISA010(x, y)}, aDados, 3)
  
                        //Se houve erro, gera o log
                        If lMsErroAuto
                            cPastaErro := '\x_logs\'
                            cNomeErro  := 'erro_' + cAliasImp + '_lin_' + cValToChar(nLinhaAtu) + '_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.txt'
  
                            //Se a pasta de erro n�o existir, cria ela
                            If ! ExistDir(cPastaErro)
                                MakeDir(cPastaErro)
                            EndIf
  
                            //Pegando log do ExecAuto, percorrendo e incrementando o texto
                            cTextoErro := ""
                            aLogErro := GetAutoGRLog()
                            For nLinhaErro := 1 To Len(aLogErro)
                                cTextoErro += aLogErro[nLinhaErro] + CRLF
                            Next
  
                            //Criando o arquivo txt e incrementa o log
                            MemoWrite(cPastaErro + cNomeErro, cTextoErro)
                            cLog += '- Falha ao incluir registro, linha [' + cValToChar(nLinhaAtu) + '], arquivo de log em ' + cPastaErro + cNomeErro + CRLF
                        Else
                            cLog += '+ Sucesso no Execauto na linha ' + cValToChar(nLinhaAtu) + ';' + CRLF
                        EndIf
  
                    EndIf
  
                EndIf
  
            EndDo
  
            //Se tiver log, mostra ele
            If ! Empty(cLog)
                MemoWrite(cDirTmp + cArqLog, cLog)
                ShellExecute('OPEN', cArqLog, '', cDirTmp, 1)
            EndIf
  
        Else
            FWAlertError('Arquivo n�o tem conte�do!', 'Aten��o')
        EndIf
  
        //Fecha o arquivo
        oArquivo:Close()
    Else
        FWAlertError('Arquivo n�o pode ser aberto!', 'Aten��o')
    EndIf
  
Return
