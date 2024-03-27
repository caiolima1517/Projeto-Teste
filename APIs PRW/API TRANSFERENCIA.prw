#INCLUDE "PROTHEUS.CH"
#INCLUDE "TbIconn.ch"
#INCLUDE "TopConn.ch" 
#include "rwmake.ch"
#INCLUDE "RESTFUL.CH"


WSRESTFUL Transferencia DESCRIPTION "Transferencia Armazem"

    WSMETHOD POST Transfere;
        DESCRIPTION "Endpoint para transferencia entre armazens";
        WSSYNTAX "/transfere";
        PATH "/transfere"


END WSRESTFUL

WSMETHOD POST Transfere WSSERVICE Transferencia

    Local cBody := ::GetContent()
    Local cDoc := ""
    Local cSql := ""
    Local nX := 0
    Local aItem := {}
    Local aTransfer := {}
    PRIVATE oParsedContent := JsonObject():New()
    PRIVATE oResponse := JsonObject():New()
    PRIVATE aAutoLog := {}
    PRIVATE lMsErroAuto := .F.
    private lAutoErrNoFile:= .T. 


    cError := oParsedContent:FromJson(FWNoAccent(DecodeUTF8(cBody)))


    RPCSetEnv("01","0101",,,'EST')

    For nX := 1 To Len(oParsedContent['TRN'])

        cDoc := NextNumero("SD3",2,"D3_DOC",.T.)

        /* Montagem de dados da origem */

        aadd(aItem, {"ITEM", '001', NIL})

        AADD(aItem, {"D3_COD", Padr(oParsedContent['TRN'][nX]["B1_COD"],15)})

        DBSetOrder(1)
        SB1->(MSSEEK(FWxFilial("SB1")+oParsedContent['TRN'][nX]["B1_COD"]))

        cDesc:= SB1->B1_DESC

        AADD(aItem, {"D3_DESCRI", cDesc, NIL})

        cUM := SB1->B1_UM

        AADD(aItem, {"D3_UM", cUM, NIL})
        AADD(aItem, {"D3_LOCAL", oParsedContent['TRN'][nX]["D3_ORIGEM"]})
        AADD(aItem, {"D3_LOCALIZ", oParsedContent['TRN'][nX]["D3_LOCALIZORIG"]})





        /* Montagem de dados para destino */

        AADD(aItem, {"D3_COD", Padr(oParsedContent['TRN'][nX]["B1_COD"],15)})
        AADD(aItem, {"D3_DESCRI", cDesc, NIL})
        AADD(aItem, {"D3_UM", cUM, NIL})
        AADD(aItem, {"D3_LOCAL", oParsedContent['TRN'][nX]["D3_DESTINO"]})
        AADD(aItem, {"D3_LOCALIZ", oParsedContent['TRN'][nX]["D3_LOCALIZDEST"]})




        /* Demais campos */

        AADD(aItem, {"D3_NUMSERI", "", nil  })
        AADD(aItem, {"D3_LOTECTL", "", nil  })
        AADD(aItem, {"D3_NUMLOTE", "", nil  })
        AADD(aItem, {"D3_DTVALID", '', nil  })
        AADD(aItem, {"D3_POTENCI", 0, nil  })
        AADD(aItem, {"D3_QUANT", oParsedContent['TRN'][nX]["QTD"], nil  })
        AADD(aItem, {"D3_QTSEGUM", 0, nil  })
        AADD(aItem, {"D3_ESTORNO", "", nil  })
        AADD(aItem, {"D3_NUMSEQ", "", nil  })
        AADD(aItem, {"D3_LOTECTL", "", nil  })
        AADD(aItem, {"D3_NUMLOTE", "", nil  })
        AADD(aItem, {"D3_DTVALID", '', nil  })
        AADD(aItem, {"D3_ITEMGRD", "", nil  })
        AADD(aItem, {"D3_CODLAN", "", nil  })
        AADD(aItem, {"D3_CODLAN", "", nil  })

        
        AADD(aTransfer, {cDoc, dDATABASE})
        AADD(aTransfer, aItem)

        cSql := "SELECT * FROM "+RETSQLNAME("SB2")+" B2 "+CRLF
        cSql += "WHERE B2_COD = '"+oParsedContent['TRN'][nX]["B1_COD"]+"%' AND B2_LOCAL = '"+oParsedContent['TRN'][nX]["D3_DESTINO"]+"'"

        TCQUERY cSql New Alias "SQL_SB2"

        If SQL_SB2->(EOF())

            CriaSb2(Padr(oParsedContent['TRN'][nX]["B1_COD"],15), oParsedContent['TRN'][nX]["D3_DESTINO"])

        EndIf

        SQL_SB2->(DBCLOSEAREA())

        MsExecAuto({|x,y| MATA261(x,y)}, aTransfer, 3)

        If lMsErroAuto

            aLogAuto := GetAutoGRLog()
            
            oResponse['400']:=aLogAuto
            
            self:SetResponse(EncodeUtf8(oResponse:toJson()))

            cCod := oParsedContent['TRN'][nX]["B1_COD"]

            ConOut(cCod)

        Else 
            oResponse['message']:="produto transferido"
            
            self:SetResponse(EncodeUtf8(oResponse:toJson()))
            
            ConOut('Produto Transferido')

        Endif

    Next

Return
