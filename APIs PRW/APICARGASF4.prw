#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"



WSRESTFUL CargaSF4 DESCRIPTION "Api utilizada para carga de TES" FORMAT APPLICATION_JSON

    WSMETHOD POST GeraSF4; 
    DESCRIPTION "Método para Gerar a carga na SF4, recebe um JSON.";
    WSSYNTAX "/importa";
    PATH "/importa"

    WSMETHOD GET BuscaSF4;
    DESCRIPTION "Busca o último registro da tabela SF4";
    WSSYNTAX "/busca";
    PATH "/busca"

END WSRESTFUL


WSMETHOD POST GeraSF4 WSSERVICE CargaSF4
Local lRet:=.f.
Local aArea:=GetArea()
Local aSF4Auto := {}
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

        for nx:=1 to len(oParsedContent['SF4'])

                aadd(aSF4Auto,{"F4_FILIAL", xFilial("SF4"), nil})
                aadd(aSF4Auto,{"F4_CODIGO", SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_CODIGO']),1,TamSX3("F4_CODIGO")[1]),nil}) 
                aadd(aSF4Auto,{"F4_TIPO",  SUBSTRING(Alltrim(UPPER(oParsedContent['SF4'][nX]['F4_TIPO'])),1,TamSX3("F4_TIPO")[1]),nil})  
                aadd(aSF4Auto,{"F4_ICM",     SUBSTRING(Alltrim(UPPER(oParsedContent['SF4'][nX]['F4_ICM'])),1,TamSX3("F4_ICM")[1]),nil})      
                aadd(aSF4Auto,{"F4_IPI",    SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_IPI']),1,TamSX3("F4_IPI")[1]),nil})

                If !empty(oParsedContent['SF4'][nX]['F4_CREDICM'])
                    aadd(aSF4Auto,  {"F4_CREDICM",SUBSTRING(Alltrim(UPPER(oParsedContent['SF4'][nX]['F4_CREDICM'])),1,TamSX3("F4_CREDICM")[1]),nil})  
                Endif

                
                If !empty(oParsedContent['SF4'][nX]['F4_CREDIPI'])
                    aadd(aSF4Auto,{"F4_CREDIPI",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_CREDIPI']),1,TamSX3("F4_CREDIPI")[1]),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_DUPLIC'])
                    aadd(aSF4Auto,  {"F4_DUPLIC",SUBSTRING(Alltrim(UPPER(oParsedContent['SF4'][nX]['F4_DUPLIC'])),1,TamSX3("F4_DUPLIC")[1]),nil})      
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_ESTOQUE'])
                    aadd(aSF4Auto,{"F4_ESTOQUE", SUBSTRING(Alltrim(UPPER(oParsedContent['SF4'][nX]['F4_ESTOQUE'])),1,TamSX3("F4_ESTOQUE")[1]),nil})
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_CF'])
                    aadd(aSF4Auto,{"F4_CF",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_CF']),1,TamSX3("F4_CF")[1]),nil})  
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_FINALID'])
                    aadd(aSF4Auto,{"F4_FINALID",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_FINALID']),1,TamSX3("F4_FINALID")[1]),nil})  
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_TEXTO'])
                    aadd(aSF4Auto,{"F4_TEXTO",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_TEXTO']),1,TamSX3("F4_TEXTO")[1]),nil})    
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_PODER3'])
                    aadd(aSF4Auto,{"F4_PODER3",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_PODER3']),1,TamSX3("F4_PODER3")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_LFICM'])
                    aadd(aSF4Auto,{"F4_LFICM",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_LFICM']),1,TamSX3("F4_LFICM")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_LFIPI'])
                    aadd(aSF4Auto,{"F4_LFIPI",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_LFIPI']),1,TamSX3("F4_LFIPI")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_DESTACA'])
                    aadd(aSF4Auto,{"F4_DESTACA",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_DESTACA']),1,TamSX3("F4_DESTACA")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_INCIDE'])
                    aadd(aSF4Auto,{"F4_INCIDE",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_INCIDE']),1,TamSX3("F4_INCIDE")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_COMPL'])
                    aadd(aSF4Auto,{"F4_COMPL",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_COMPL']),1,TamSX3("F4_COMPL")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_SITTRIB'])
                    aadd(aSF4Auto,{"F4_SITTRIB",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_SITTRIB']),1,TamSX3("F4_SITTRIB")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_PISCOF'])
                    aadd(aSF4Auto,{"F4_PISCOF",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_PISCOF']),1,TamSX3("F4_PISCOF")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_PISCRED'])
                    aadd(aSF4Auto,{"F4_PISCRED",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_PISCRED']),1,TamSX3("F4_PISCRED")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_CTIPI'])
                    aadd(aSF4Auto,{"F4_CTIPI",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_CTIPI']),1,TamSX3("F4_CTIPI")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_TPREG'])
                    aadd(aSF4Auto,{"F4_TPREG",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_TPREG']),1,TamSX3("F4_TPREG")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_CSTPIS'])
                    aadd(aSF4Auto,{"F4_CSTPIS",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_CSTPIS']),1,TamSX3("F4_CSTPIS")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_CSTCOF'])
                    aadd(aSF4Auto,{"F4_CSTCOF",SUBSTRING(Alltrim(oParsedContent['SF4'][nX]['F4_CSTCOF']),1,TamSX3("F4_CSTCOF")[1]),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_BASEICM'])
                    aadd(aSF4Auto,{"F4_BASEICM",VAL(oParsedContent['SF4'][nX]['F4_BASEICM']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_BASEIPI'])
                    aadd(aSF4Auto,{"F4_BASEIPI",VAL(oParsedContent['SF4'][nX]['F4_BASEIPI']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_ISS'])
                    aadd(aSF4Auto,{"F4_ISS",Alltrim(oParsedContent['SF4'][nX]['F4_ISS']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_LFISS'])
                    aadd(aSF4Auto,{"F4_LFISS",Alltrim(oParsedContent['SF4'][nX]['F4_LFISS']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_UPRC'])
                    aadd(aSF4Auto,{"F4_UPRC",Alltrim(oParsedContent['SF4'][nX]['F4_UPRC']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_CONSUMO'])
                    aadd(aSF4Auto,{"F4_CONSUMO",Alltrim(oParsedContent['SF4'][nX]['F4_CONSUMO']),nil}) 
                Endif

                /*If !empty(oParsedContent['SF4'][nX]['F4_FORMULA'])
                    aadd(aSF4Auto,{"F4_FORMULA",Alltrim(oParsedContent['SF4'][nX]['F4_FORMULA']),nil}) 
                Endif*/


                If !empty(oParsedContent['SF4'][nX]['F4_AGREG'])
                    aadd(aSF4Auto,{"F4_AGREG",Alltrim(oParsedContent['SF4'][nX]['F4_AGREG']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_INCSOL'])
                    aadd(aSF4Auto,{"F4_INCSOL",Alltrim(oParsedContent['SF4'][nX]['F4_INCSOL']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_DESPIPI'])
                    aadd(aSF4Auto,{"F4_DESPIPI",Alltrim(oParsedContent['SF4'][nX]['F4_DESPIPI']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_STDESC'])
                    aadd(aSF4Auto,{"F4_STDESC",Alltrim(oParsedContent['SF4'][nX]['F4_STDESC']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_BSICMST'])
                    aadd(aSF4Auto,{"F4_BSICMST",VAL(oParsedContent['SF4'][nX]['F4_BSICMST']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_CREDST'])
                    aadd(aSF4Auto,{"F4_CREDST",Alltrim(oParsedContent['SF4'][nX]['F4_CREDST']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_BASEISS'])
                    aadd(aSF4Auto,{"F4_BASEISS",VAL(oParsedContent['SF4'][nX]['F4_BASEISS']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_DESPICM'])
                    aadd(aSF4Auto,{"F4_DESPICM",Alltrim(oParsedContent['SF4'][nX]['F4_DESPICM']),nil}) 
                Endif


                /*If !empty(oParsedContent['SF4'][nX]['F4_TESDV'])
                    aadd(aSF4Auto,{"F4_TESDV",oParsedContent['SF4'][nX]['F4_TESDV'],nil}) 
                Endif*/

                If !empty(oParsedContent['SF4'][nX]['F4_ICMSDIF'])
                    aadd(aSF4Auto,{"F4_ICMSDIF",Alltrim(oParsedContent['SF4'][nX]['F4_ICMSDIF']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_ATUATF'])
                    aadd(aSF4Auto,{"F4_ATUATF",Alltrim(oParsedContent['SF4'][nX]['F4_ATUATF']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_TPIPI'])
                    aadd(aSF4Auto,{"F4_TPIPI",Alltrim(oParsedContent['SF4'][nX]['F4_TPIPI']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_CIAP'])
                    aadd(aSF4Auto,{"F4_CIAP",Alltrim(oParsedContent['SF4'][nX]['F4_CIAP']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_MKPCMP'])
                    aadd(aSF4Auto,{"F4_MKPCMP",Alltrim(oParsedContent['SF4'][nX]['F4_MKPCMP']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_INDNTFR'])
                    aadd(aSF4Auto,{"F4_INDNTFR",Alltrim(oParsedContent['SF4'][nX]['F4_INDNTFR']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_CODBCC'])
                    aadd(aSF4Auto,{"F4_CODBCC",Alltrim(oParsedContent['SF4'][nX]['F4_CODBCC']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_ISSST'])
                    aadd(aSF4Auto,{"F4_ISSST",Alltrim(oParsedContent['SF4'][nX]['F4_ISSST']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_RETISS'])
                    aadd(aSF4Auto,{"F4_RETISS",Alltrim(oParsedContent['SF4'][nX]['F4_RETISS']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_IPIPC'])
                    aadd(aSF4Auto,{"F4_IPIPC",Alltrim(oParsedContent['SF4'][nX]['F4_IPIPC']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_RECDAC'])
                    aadd(aSF4Auto,{"F4_RECDAC",Alltrim(oParsedContent['SF4'][nX]['F4_RECDAC']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_CSTISS'])
                    aadd(aSF4Auto,{"F4_CSTISS",Alltrim(oParsedContent['SF4'][nX]['F4_CSTISS']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_DIFAL'])
                    aadd(aSF4Auto,{"F4_DIFAL",Alltrim(oParsedContent['SF4'][nX]['F4_DIFAL']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_QTDZERO'])
                    aadd(aSF4Auto,{"F4_QTDZERO",Alltrim(oParsedContent['SF4'][nX]['F4_QTDZERO']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_OBSSOL'])
                    aadd(aSF4Auto,{"F4_OBSSOL",Alltrim(oParsedContent['SF4'][nX]['F4_OBSSOL']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_PICMDIF'])
                    aadd(aSF4Auto,{"F4_PICMDIF",Alltrim(oParsedContent['SF4'][nX]['F4_PICMDIF']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_DESPCOF'])
                    aadd(aSF4Auto,{"F4_DESPCOF",Alltrim(oParsedContent['SF4'][nX]['F4_DESPCOF']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_BENSATF'])
                    aadd(aSF4Auto,{"F4_BENSATF",Alltrim(oParsedContent['SF4'][nX]['F4_BENSATF']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_TRANFIL'])
                    aadd(aSF4Auto,{"F4_TRANFIL",ALLTRIM(oParsedContent['SF4'][nX]['F4_TRANFIL']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_DSPRDIC'])
                    aadd(aSF4Auto,{"F4_DSPRDIC",ALLTRIM(oParsedContent['SF4'][nX]['F4_DSPRDIC']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_REGDSTA'])
                    aadd(aSF4Auto,{"F4_REGDSTA",ALLTRIM(oParsedContent['SF4'][nX]['F4_REGDSTA']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_COFDSZF'])
                    aadd(aSF4Auto,{"F4_COFDSZF",ALLTRIM(oParsedContent['SF4'][nX]['F4_COFDSZF']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_DESPPIS'])
                    aadd(aSF4Auto,{"F4_DESPPIS",ALLTRIM(oParsedContent['SF4'][nX]['F4_DESPPIS']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_AGRPIS'])
                    aadd(aSF4Auto,{"F4_AGRPIS",ALLTRIM(oParsedContent['SF4'][nX]['F4_AGRPIS']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_AGRCOF'])
                    aadd(aSF4Auto,{"F4_AGRCOF",ALLTRIM(oParsedContent['SF4'][nX]['F4_AGRCOF']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_LFICMST'])
                    aadd(aSF4Auto,{"F4_LFICMST",ALLTRIM(oParsedContent['SF4'][nX]['F4_LFICMST']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_PISDSZF'])
                    aadd(aSF4Auto,{"F4_PISDSZF",ALLTRIM(oParsedContent['SF4'][nX]['F4_PISDSZF']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_IPIOBS'])
                    aadd(aSF4Auto,{"F4_IPIOBS",ALLTRIM(oParsedContent['SF4'][nX]['F4_IPIOBS']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_MALQCOF'])
                    aadd(aSF4Auto,{"F4_MALQCOF",VAL(oParsedContent['SF4'][nX]['F4_MALQCOF']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_CIAPTRB'])
                    aadd(aSF4Auto,{"F4_CIAPTRB",ALLTRIM(oParsedContent['SF4'][nX]['F4_CIAPTRB']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_DESTRUI'])
                    aadd(aSF4Auto,{"F4_DESTRUI",ALLTRIM(oParsedContent['SF4'][nX]['F4_DESTRUI']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_DEVPARC'])
                    aadd(aSF4Auto,{"F4_DEVPARC",ALLTRIM(oParsedContent['SF4'][nX]['F4_DEVPARC']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_ISEFECP'])
                    aadd(aSF4Auto,{"F4_ISEFECP",ALLTRIM(oParsedContent['SF4'][nX]['F4_ISEFECP']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_CODOBSE'])
                    aadd(aSF4Auto,{"F4_CODOBSE",ALLTRIM(oParsedContent['SF4'][nX]['F4_CODOBSE']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_ICMSTMT'])
                    aadd(aSF4Auto,{"F4_ICMSTMT",ALLTRIM(oParsedContent['SF4'][nX]['F4_ICMSTMT']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_MALQPIS'])
                    aadd(aSF4Auto,{"F4_MALQPIS",VAL(oParsedContent['SF4'][nX]['F4_MALQPIS']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_TNATREC'])
                    aadd(aSF4Auto,{"F4_TNATREC",ALLTRIM(oParsedContent['SF4'][nX]['F4_TNATREC']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_CNATREC'])
                    aadd(aSF4Auto,{"F4_CNATREC",ALLTRIM(oParsedContent['SF4'][nX]['F4_CNATREC']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_MKPSOL'])
                    aadd(aSF4Auto,{"F4_MKPSOL",ALLTRIM(oParsedContent['SF4'][nX]['F4_MKPSOL']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_AGRISS'])
                    aadd(aSF4Auto,{"F4_AGRISS",ALLTRIM(oParsedContent['SF4'][nX]['F4_AGRISS']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_MOTICMS'])
                    aadd(aSF4Auto,{"F4_MOTICMS",ALLTRIM(oParsedContent['SF4'][nX]['F4_MOTICMS']),nil}) 
                Endif



                If !empty(oParsedContent['SF4'][nX]['F4_CINSS'])
                    aadd(aSF4Auto,{"F4_CINSS",ALLTRIM(oParsedContent['SF4'][nX]['F4_CINSS']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_INTBSIC'])
                    aadd(aSF4Auto,{"F4_INTBSIC",ALLTRIM(oParsedContent['SF4'][nX]['F4_INTBSIC']),nil}) 
                Endif



                If !empty(oParsedContent['SF4'][nX]['F4_SOMAIPI'])
                    aadd(aSF4Auto,{"F4_SOMAIPI",ALLTRIM(oParsedContent['SF4'][nX]['F4_SOMAIPI']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_GRPCST'])
                    aadd(aSF4Auto,{"F4_GRPCST",ALLTRIM(oParsedContent['SF4'][nX]['F4_GRPCST']),nil}) 
                Endif


                If !empty(oParsedContent['SF4'][nX]['F4_CODINFC'])
                    aadd(aSF4Auto,{"F4_CODINFC",ALLTRIM(oParsedContent['SF4'][nX]['F4_CODINFC']),nil}) 
                Endif

                If !empty(oParsedContent['SF4'][nX]['F4_IPIFRET'])
                    aadd(aSF4Auto,{"F4_IPIFRET",ALLTRIM(oParsedContent['SF4'][nX]['F4_IPIFRET']),nil}) 
                Endif



            //------------------------------------
            // Chamada para cadastrar o TES.
            //------------------------------------
            MSExecAuto({|x,y| MATA080(x,y)}, aSF4Auto, nOpcAuto)

            If lMsErroAuto  
                //lRet := .F.

                aAutoLog := GetAutoGRLog()
                oResponse['400']:=aAutoLog
                self:SetResponse(EncodeUtf8(oResponse:toJson()))
                //--------------------------------------------------------
                //Busca log de erro do ExecAuto e retorna o erro em Json.
                //-------------------------------------------------------
                codplanilha:=oParsedContent['SF4'][nX]['F4_COD']
                Conout(codplanilha)

                //RpcClearEnv()
                //return lRet
            Else
                RECLOCK("SF4",.F.)

                    If !empty(oParsedContent['SF4'][nX]['F4_TESDV'])
                        SF4->F4_TESDV := ALLTRIM(oParsedContent['SF4'][nX]['F4_TESDV'])
                    Endif

                    If !empty(oParsedContent['SF4'][nX]['F4_FORMULA'])
                        SF4->F4_FORMULA := ALLTRIM(oParsedContent['SF4'][nX]['F4_FORMULA'])
                    Endif

                MSUNLOCK()

                    

                //----------------------------------------------------------------------
                //Sucesso do ExecAuto e retorna os dados do cliente cadastrado em Json.
                //----------------------------------------------------------------------        
                oResponse['message']:="TES Incluída!"


                Conout('TES Incluida!')

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



Static Function NoAcento(cString)

Local cChar	:= ""
Local cVogal	:= "aeiouAEIOU"
Local cAgudo	:= "áéíóú"+"ÁÉÍÓÚ"
Local cCircu	:= "âêîôû"+"ÂÊÎÔÛ"
Local cTrema	:= "äëïöü"+"ÄËÏÖÜ"
Local cCrase	:= "àèìòù"+"ÀÈÌÒÙ" 
Local cTio		:= "ãõÃÕ"
Local cCecid	:= "çÇ"
Local cMaior	:= "&lt;"
Local cMenor	:= "&gt;"
Local cEcom		:= "&"

Local nX		:= 0 
Local nY		:= 0

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase+cEcom
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
		nY:= At(cChar,cEcom)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("eE",nY,1))
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

For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|' 
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX

Return cString
