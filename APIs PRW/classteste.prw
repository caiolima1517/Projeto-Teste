#include "totvs.ch"



class cliente

    data nome
    data nome_reduz
    data cgc

    method new() constructor
    method getcgc()

end class

method new(p_nome, p_nome_reduz, p_cgc) class cliente

    default p_nome := ""
    default p_nome_reduz := ""
    default p_cgc := ""

    self:nome := ""
    self:nome_reduz := ""
    self:cgc := ""

return self

method getcgc() class cliente 


return self:cgc

