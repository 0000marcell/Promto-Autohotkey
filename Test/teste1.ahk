;/*
;	Empresas View
;*/
;Gui, Color,white
;Gui, Add, Groupbox, w400 h400,Empresas
;Gui, Add, Groupbox, y+5 w400 h60,Opcoes
;Gui, Add, Button, xp+290 yp+20 w100 h30,Alterar
;Gui,Show,,

/*
	Modelos View
*/

Gui, Color, White
/*
	Pesquisa
*/
Gui, Add, Groupbox, w600 h60, Pesquisa
Gui, Add, Edit, xp+5 yp+15 w550,
Gui, Add, Button, x+5, Pesquisar
/*
	Tab
*/
;Gui, Add, Groupbox, xm y+5 w600 h500, Familias
Gui, Add, Tab2,xm y+30 w550 h550,Produtos Acabados|Produtos Semi-Acabados|Materia Prima
/*
	Opcoes
*/
Gui, Add, Groupbox, xm y+5 w600 h60 , Opcoes
Gui, Add, Button, xp+550 yp+15 w100 h30, Salvar
Gui, Show,,
return
