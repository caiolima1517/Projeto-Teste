#INCLUDE "PROTHEUS.CH"
#INCLUDE "TbIconn.ch"
#INCLUDE "TopConn.ch" 
#include "rwmake.ch"
#INCLUDE "RESTFUL.CH"

//https://centraldeatendimento.totvs.com/hc/pt-br/articles/360046079234?source=search


WSRESTFUL SaldoInicial DESCRIPTION "Saldo Inicial"

    WSMETHOD POST CriaSaldo;
        DESCRIPTION "Endpoint para criar saldo inicial";
        WSSYNTAX "/cria";
        PATH "/cria"


END WSRESTFUL

WSMETHOD POST CriaSaldo WSSERVICE SaldoInicial

    Local PARAMIXB1 := {}
    Local PARAMIXB2 := 3
    Local cBody := ::GetContent()
    Local cProd := ""
    Local cArm := ""
    Local nQtdIni := 0
    Local clote :=""
    Local cEnder:=""
    Local nValor:= 0
    Local nX := 0
    PRIVATE oParsedContent := JsonObject():New()
    PRIVATE oResponse := JsonObject():New()
    PRIVATE aAutoLog := {}
    PRIVATE lMsErroAuto := .F.
    private lAutoErrNoFile:= .T. 


    cError := oParsedContent:FromJson(FWNoAccent(DecodeUTF8(cBody)))

    //------------------------//| Abertura do ambiente |//------------------------

    /*
    RPCSetEnv("99","01",,,'EST')
    u_showstring(Repl("-",80))
    u_showstring(PadC("Teste de Cadastro de Saldos Iniciais",80))
    u_showstring("Inicio: "+Time())
    */

RPCSetEnv("01","0101",,,'EST')

For nx := 1 To Len(oParsedContent['SLD'])

    cProd := oParsedContent['SLD'][nx]['B1_COD']
    cArm := oParsedContent['SLD'][nx]['B1_LOCAL']
    nQtdIni := oParsedContent['SLD'][nx]['QTD']
    clote := ""
    cEnder:=oParsedContent['SLD'][nx]['END']
    nValor:= 0

    PARAMIXB1 := {}

    aadd(PARAMIXB1,{"B9_COD",cProd,})
    aadd(PARAMIXB1,{"B9_LOCAL",cArm,})
    aadd(PARAMIXB1,{"B9_QINI",0,})


    begin transaction

        MSExecAuto({|x,y| mata220(x,y)},PARAMIXB1,PARAMIXB2)


        If !lMsErroAuto
            
            u_TMATA241(cProd,cLote,nQtdIni,cArm,cEnder,nValor)

        Else

            aAutoLog := GetAutoGRLog()

            oResponse['400']:=aAutoLog

            SetRestFault(400,EncodeUtf8(oResponse:toJson()))
            //--------------------------------------------------------
            //Busca log de erro do ExecAuto e retorna o erro em Json.
            //-------------------------------------------------------
            codplanilha:=oParsedContent['SLD'][nX]['B1_COD']

            Conout(codplanilha)
            Conout("Erro na inclusao!")

        EndIf

    end transaction
        
Next nx

    Conout("Fim")

    oResponse['200']:="Carga Efetuada"
    SetRestFault(200,ENCODEUTF8(oResponse:toJson()))

    Return Nil



    ///MOVIMENTAÇÃO INTERNA
    User Function TMATA241(cProd,cLote,nQtdIni,cArm,cEnder,nValor)
    Local _aCab1 := {}
    Local _aItem := {}
    Local _atotitem:={}
    Local cCodigoTM:="002"


    Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
    Private lMsErroAuto := .f. //necessario a criacao

    //Private _acod:={"1","MP1"}
    //PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "EST"

        cUnid:=""
        cUnid:=Posicione("SB1",1,xFilial("SB1")+cProd,"B1_UM")

        cRastro:=""    
        cRastro:=Posicione("SB1",1,xFilial("SB1")+cProd,"B1_RASTRO")

    _aCab1 := {{"D3_DOC" ,NextNumero("SD3",2,"D3_DOC",.T.), NIL},;
              {"D3_TM" ,cCodigoTM , NIL},;
              {"D3_CC" ,"        ", NIL},;
              {"D3_EMISSAO" ,ddatabase, NIL}}


    If cRastro=="L"

        _aItem:={{"D3_COD" ,cProd ,NIL},;
            {"D3_UM" ,cUnid ,NIL},; 
            {"D3_QUANT" ,nQtdIni ,NIL},;
            {"D3_LOCAL" ,cArm ,NIL},;
            {"D3_CUSTO1" ,nValor ,NIL},;
            {"D3_LOTECTL" ,cLote,NIL},;
            {"D3_DTVALID" ,dDatabase+3650,NIL},;
            {"D3_LOCALIZ" , cEnder,NIL}}
    ELSE

        _aItem:={{"D3_COD" ,cProd ,NIL},;
            {"D3_UM" ,cUnid ,NIL},; 
            {"D3_QUANT" ,nQtdIni ,NIL},;
            {"D3_LOCAL" ,cArm ,NIL},;
            {"D3_LOCALIZ" , cEnder,NIL}}
    ENDIF    

    aadd(_atotitem,_aitem) 
    MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)
    //MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)

    If lMsErroAuto 

        aAutoLog := GetAutoGRLog()

        oResponse['400']:=aAutoLog

        SetRestFault(400,EncodeUtf8(oResponse:toJson()))
        //--------------------------------------------------------
        //Busca log de erro do ExecAuto e retorna o erro em Json.
        //-------------------------------------------------------
        //codplanilha:=oParsedContent['SLD'][nX]['B1_COD']

        Conout(cProd)

        DisarmTransaction() 

    ELSE

        oResponse['200']:="Movimentação ok"

        SetRestFault(200,EncodeUtf8(oResponse:toJson()))

        U_ACOM016I(cProd,cLote,cArm,cEnder)

    EndIf

    Return 


    //*****************************
    /*/{Protheus.doc} ACOM016
    Rotina para gerar endereçamento automatico para o produto.

    @author Lucas
    @since 24/03/2017
    @version 1.0

    @param cOpc, characters, Opções I = Incluir | D = Deletar

    @type function
    /*/
    //*****************************
    User Function ACOM016( cOpc )

    do case
    case cOpc == 'I'
    ACOM016I()
    // fim case

    case cOpc == 'D'
    If ApMsgYesNo('Deseja realmente estornar os endereçamentos?', 'Documento de Entrada')
    ACOM016D()
    endif
    // fim case
    endcase

    Return

    //*****************************
    /*/{Protheus.doc} ACOM016I
    Utiliza a opção de endereçar do MATA265 padrão.

    @author Lucas
    @since 28/03/2017
    @version 1.0

    @type function
    /*/
    //*****************************
    User Function ACOM016I(cProd,cLote,cArm,cEnder)

    Local cAlias :=''
    Local aCabSDA := {}
    Local aItSDB := {}
    Local aItensSDB := {}
    Local nCount := 0

    Private lMsErroAuto := .F.

    cAlias := getNextAlias()
    BeginSql Alias cAlias


    SELECT * FROM SDA010 (nolock) 
    WHERE D_E_L_E_T_ <> '*' AND DA_SALDO >0  and DA_PRODUTO = %EXP:cProd%  and DA_LOTECTL = %EXP:cLote% and DA_LOCAL  = %EXP:cArm% and D_E_L_E_T_ <> '*'


    /*
    SELECT
    SD1.D1_COD, SDA.DA_NUMSEQ, SD1.D1_XENDPAD, SDA.DA_LOCAL,
    SD1.D1_QUANT, SDA.DA_SALDO
    FROM
    %TABLE:SD1% SD1
    INNER JOIN %TABLE:SDA% SDA ON
    SDA.DA_FILIAL = SD1.D1_FILIAL
    AND SDA.DA_DOC = SD1.D1_DOC
    AND SDA.DA_SERIE = SD1.D1_SERIE
    AND SDA.DA_CLIFOR = SD1.D1_FORNECE
    AND SDA.DA_LOJA = SD1.D1_LOJA
    AND SDA.DA_LOCAL = SD1.D1_LOCAL
    AND SDA.DA_ORIGEM = %EXP:'SD1'%
    AND SDA.DA_SALDO > %EXP:0%
    AND SDA.%NOTDEL%
    WHERE
    SD1.D1_FILIAL = %EXP:SF1->F1_FILIAL%
    AND SD1.D1_DOC = %EXP:SF1->F1_DOC%
    AND SD1.D1_SERIE = %EXP:SF1->F1_SERIE%
    AND SD1.D1_FORNECE = %EXP:SF1->F1_FORNECE%
    AND SD1.D1_LOJA = %EXP:SF1->F1_LOJA%
    AND SD1.D1_XENDPAD <> %EXP:SPACE(TAMSX3('D1_XENDPAD')[1])%
    AND SD1.%NOTDEL%

    */
    EndSQl

    (cAlias)->(dbEval( { || nCount++ } ))
    (cAlias)->(dbGoTop())

    if nCount == 0
        Conout('Sem itens disponíveis para o endereçamento!')
    else
        dbSelectArea('SDA')
        SDA->(dbSetOrder(1))

        //ProcRegua( nCount )
        //processMessage()

        while !(cAlias)->(EOF())
            //incProc('Produto: ' + allTrim((cAlias)->DA_PRODUTO) + ' – Sequencial: ' + (cAlias)->DA_NUMSEQ )
            //processMessage()

            SDA->(dbGoTop()) // posiciona o cabeçalho
            if SDA->(dbSeek( xfilial('SDA') + (cAlias)->DA_PRODUTO + (cAlias)->DA_LOCAL + (cAlias)->DA_NUMSEQ))
                if SDA->DA_SALDO > 0
                    lMsErroAuto := .F.

                    aCabSDA := {}
                    aAdd( aCabSDA, {'DA_PRODUTO' ,SDA->DA_PRODUTO, Nil} )
                    aAdd( aCabSDA, {'DA_NUMSEQ' ,SDA->DA_NUMSEQ , Nil} )

                    aItSDB := {}
                    aAdd( aItSDB, {'DB_ITEM' , '0001' , Nil} )
                    aAdd( aItSDB, {'DB_ESTORNO', '' , Nil} )
                    aAdd( aItSDB, {'DB_LOCALIZ', cEnder, Nil} )
                    aAdd( aItSDB, {'DB_DATA' , dDataBase , Nil} )
                    aAdd( aItSDB, {'DB_QUANT' , SDA->DA_SALDO , Nil} )

                    aItensSDB := {}
                    aadd( aItensSDB, aitSDB )
                    MATA265( aCabSDA, aItensSDB, 3)
                endif
            endif

            (cAlias)->(dbSkip())
        enddo
    endif
    (cAlias)->(dbCloseArea())

    Return


    /*User Function ShowString(cString)
    @ 116,090 To 416,707 Dialog oDlgMemo Title "AP5 Remote"
    @ 001,005 Get cString   Size 300,120  MEMO                 Object oMemo
    @ 137,10+5*50 Button OemToAnsi("_Fechar")   Size 35,14 Action Close(oDlgMemo)
    Activate Dialog oDlgMemo
    Return nil*/



    User Function CRIASB9()  //CRIA SALDO INICIAL COM QTD 0

    Local PARAMIXB1 := {}
    Local PARAMIXB2 := 3
    Local cProd := ""
    PRIVATE lMsErroAuto := .F.

    //------------------------//| Abertura do ambiente |//------------------------

    /*
    RPCSetEnv("99","01",,,'EST')
    u_showstring(Repl("-",80))
    u_showstring(PadC("Teste de Cadastro de Saldos Iniciais",80))
    u_showstring("Inicio: "+Time())
    */

    RPCSetEnv("01","0102",,,'EST')

    cSql:=" select * from SB1010 (NOLOCK) WHERE B1_TIPO in ('PA','ME') AND D_E_L_E_T_ <> '*' "
    U_SHOWSTRING(CSQL)
    TcQuery cSql new alias "SLD"




    //------------------------//| Teste de Inclusao |//------------------------

    While !SLD->(EoF()) 

        csql:="SELECT * FROM SB9010 (NOLOCK) WHERE B9_COD = '"+SLD->B1_COD+"' AND B9_LOCAL= '15' AND D_E_L_E_T_ <> '*' "
        TcQuery cSql new alias "TEM"


        ctemB9:=""
        cTemB9:=TEM->B9_COD

        If empty(cTemB9)
            cProd := SLD->B1_COD
        ENDIF
        TEM->(DBCLOSEAREA())

    

        PARAMIXB1 := {}

        If empty(cTemB9)
            aadd(PARAMIXB1,{"B9_COD",cProd,})
            aadd(PARAMIXB1,{"B9_LOCAL","15",})
            aadd(PARAMIXB1,{"B9_QINI",0,})
    


        //u_showstring("antes")

            begin transaction

                MSExecAuto({|x,y| mata220(x,y)},PARAMIXB1,PARAMIXB2)

            end transaction

        ENDIF

        SLD->(DBSKIP())       

     ENDDO

     SLD->(DBCLOSEAREA())
        u_showstring("Fim : "+Time())
    RETURN


RETURN .T.  
