User Function zTeste()
    Local aArea    := GetArea()
    //Local aAreaB1  := SB1->(GetArea())
    Local cDelOk   := ".T."
    Local cFunTOk  := ".T." //Pode ser colocado como "u_zVldTst()"
 
    //Chamando a tela de cadastros
    AxCadastro('RGB', 'RGB', cDelOk, cFunTOk)
 
    //RestArea(aAreaB1)
    RestArea(aArea)
Return
