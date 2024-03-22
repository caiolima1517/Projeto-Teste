#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"



User Function ReqAuto()

    Local aArea := GetArea()
    Local aCabec := {}
    Local aItem := {}
    Local aTotItem := {}
    Local cSql := ""
    Local cTM := ""
    Private lMsErroAuto := .f.
    Private lMSHelpAuto := .F.

    RPCSetType(3) // Nao utilizar licenca
    RPCSetEnv("01","0101",,,'EST') 

    cSql := "SELECT B2_COD, B1_UM, BF_LOCAL,BF_LOCALIZ,BF_QUANT,B2_QATU FROM "+RETSQLNAME("SB2")+" SB2"+CRLF
    cSql += "INNER JOIN "+RETSQLNAME("SBF")+" SBF ON BF_PRODUTO = B2_COD AND SBF.D_E_L_E_T_ <> '*' "+CRLF
    cSql += "INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_COD = B2_COD AND SB1.D_E_L_E_T_ <> '*'"
    cSql += "WHERE  B2_COD IN ( "+CRLF
    cSql += "'10000358', "+CRLF
    cSql += "'10000357', "+CRLF
    cSql += "'10000350', "+CRLF
    cSql += "'10000353', "+CRLF
    cSql += "'10000391', "+CRLF
    cSql += "'10001069',"+CRLF
    cSql += "'10000415', "+CRLF
    cSql += "'10000995',"+CRLF
    cSql += "'10000417', "+CRLF
    cSql += "'10000374', "+CRLF
    cSql += "'10000351', "+CRLF
    cSql += "'10001077',"+CRLF
    cSql += "'10000987',"+CRLF
    cSql += "'10000986',"+CRLF
    cSql += "'10000399', "+CRLF
    cSql += "'10000377', "+CRLF
    cSql += "'10000990',"+CRLF
    cSql += "'10000354', "+CRLF
    cSql += "'10000356', "+CRLF
    cSql += "'10001009',"+CRLF
    cSql += "'10000355', "+CRLF
    cSql += "'8800085',"+CRLF
    cSql += "'10000988',"+CRLF
    cSql += "'10001076',"+CRLF
    cSql += "'10001073',"+CRLF
    cSql += "'10001072',"+CRLF
    cSql += "'10000416', "+CRLF
    cSql += "'10000414', "+CRLF
    cSql += "'10000368', "+CRLF
    cSql += "'10000367', "+CRLF
    cSql += "'10000401', "+CRLF
    cSql += "'10000359', "+CRLF
    cSql += "'10001074',"+CRLF
    cSql += "'10000977',"+CRLF
    cSql += "'10000980',"+CRLF
    cSql += "'10000380', "+CRLF
    cSql += "'10000381', "+CRLF
    cSql += "'10000382', "+CRLF
    cSql += "'10000370', "+CRLF
    cSql += "'10000394', "+CRLF
    cSql += "'10000388', "+CRLF
    cSql += "'10000343', "+CRLF
    cSql += "'10000384', "+CRLF
    cSql += "'10000385', "+CRLF
    cSql += "'10000386', "+CRLF
    cSql += "'10001002',"+CRLF
    cSql += "'10000974',"+CRLF
    cSql += "'10000383', "+CRLF
    cSql += "'10000973',"+CRLF
    cSql += "'10000347', "+CRLF
    cSql += "'10000397', "+CRLF
    cSql += "'10000398', "+CRLF
    cSql += "'10000412', "+CRLF
    cSql += "'10000390', "+CRLF
    cSql += "'10000396', "+CRLF
    cSql += "'10000389', "+CRLF
    cSql += "'10001000',"+CRLF
    cSql += "'10000395', "+CRLF
    cSql += "'10000420', "+CRLF
    cSql += "'10000392', "+CRLF
    cSql += "'10000400', "+CRLF
    cSql += "'10000344', "+CRLF
    cSql += "'10000345', "+CRLF
    cSql += "'10000372', "+CRLF
    cSql += "'10000348', "+CRLF
    cSql += "'10000349', "+CRLF
    cSql += "'10000409', "+CRLF
    cSql += "'10000998',"+CRLF
    cSql += "'10000407', "+CRLF
    cSql += "'10000373', "+CRLF
    cSql += "'10001014',"+CRLF
    cSql += "'10000379', "+CRLF
    cSql += "'10000422', "+CRLF
    cSql += "'10000346', "+CRLF
    cSql += "'10000970',"+CRLF
    cSql += "'10000387', "+CRLF
    cSql += "'10000978',"+CRLF
    cSql += "'10001063',"+CRLF
    cSql += "'10000968',"+CRLF
    cSql += "'10001005',"+CRLF
    cSql += "'10000408', "+CRLF
    cSql += "'10001062',"+CRLF
    cSql += "'10000410', "+CRLF
    cSql += "'10000402', "+CRLF
    cSql += "'10000403', "+CRLF
    cSql += "'10000982',"+CRLF
    cSql += "'10001075',"+CRLF
    cSql += "'10000979',"+CRLF
    cSql += "'10000981',"+CRLF
    cSql += "'10000413', "+CRLF
    cSql += "'10000989',"+CRLF
    cSql += "'10000992',"+CRLF
    cSql += "'10000983',"+CRLF
    cSql += "'10000366', "+CRLF
    cSql += "'10000969',"+CRLF
    cSql += "'10000365', "+CRLF
    cSql += "'10000994',"+CRLF
    cSql += "'10001065',"+CRLF
    cSql += "'10001067',"+CRLF
    cSql += "'10000393', "+CRLF
    cSql += "'10001064',"+CRLF
    cSql += "'10001001',"+CRLF
    cSql += "'10000352', "+CRLF
    cSql += "'10000418', "+CRLF
    cSql += "'10001004',"+CRLF
    cSql += "'10000406', "+CRLF
    cSql += "'10000364', "+CRLF
    cSql += "'10000421', "+CRLF
    cSql += "'10000975',"+CRLF
    cSql += "'10000404', "+CRLF
    cSql += "'10000405', "+CRLF
    cSql += "'10000411', "+CRLF
    cSql += "'10001003',"+CRLF
    cSql += "'10000419', "+CRLF
    cSql += "'10001068',"+CRLF
    cSql += "'10001061',"+CRLF
    cSql += "'10000363', "+CRLF
    cSql += "'10000361', "+CRLF
    cSql += "'10000362', "+CRLF
    cSql += "'10000971',"+CRLF
    cSql += "'10000972',"+CRLF
    cSql += "'10001070',"+CRLF
    cSql += "'10001081',"+CRLF
    cSql += "'10000991',"+CRLF
    cSql += "'10001078',"+CRLF
    cSql += "'10000371', "+CRLF
    cSql += "'10001050',"+CRLF
    cSql += "'10001052',"+CRLF
    cSql += "'10001051') AND SB2.D_E_L_E_T_ <> '*' AND B2_QATU > 0 "+CRLF

    TCQUERY cSql New Alias "SQL_SB2"

    cTM := "502"

    While !SQL_SB2->(eof())

        aCabec := {{"D3_DOC", NextNumero("SD3",2,"D3_DOC",.T.), NIL},;
                   {"D3_TM", cTM, NIL},;
                   {"D3_CC", " ", NIL},;
                   {"D3_EMISSAO", dDatabase, NIL}}

        aItem := {{"D3_COD", PADR(SQL_SB2->B2_COD,15), NIL},;
                   {"D3_UM", SQL_SB2->B1_UM, NIL },;
                   {"D3_QUANT", SQL_SB2->B2_QATU, NIL},;
                   {"D3_LOCAL", SQL_SB2->BF_LOCAL, NIL},;
                   {"D3_LOCALIZ", PADR(SQL_SB2->BF_LOCALIZ,15), NIL}}

        aadd(aTotItem, aItem)
        
        MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotItem,3)

        If lMsErroAuto

            Mostraerro()

        Endif

        aCabec := {}
        aItem :={}
        aTotItem := {}

    SQL_SB2->(DBSKIP())

    Enddo

    RestArea(aArea)

Return
