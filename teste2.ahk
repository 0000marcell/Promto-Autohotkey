/*
	Gui init
*/
Gui, alterar:New
;Gui, Font, s%SMALL_FONT%, %FONT%
Gui, Color, white

/*
	Tab
*/
Gui, Add, Tab2, w320 h370, Alterar Empresa|Alterar Tipo|Alterar Familia 

/*
	Tab 1
*/
Gui, Tab, 1 
Gui, Add, Listview, x+10 y+15 w300 h320 vlv_empresas_alterar,Items|Mascara

	/*
		Opcoes 1
	*/
	Gui, Add, Groupbox, xm y380 w320 h100, Opcoes
	Gui, Add, Button, xp+5 yp+15 w100 h30, Inserir
	Gui, Add, Button, x+5 w100 h30, Renomear
	Gui, Add, Button, x+5 w100 h30, Linkar
	Gui, Add, Button, x15 y+10 w100 h30, Importar
	Gui, Add, Button, x+5 w100 h30, Exportar
	Gui, Add, Button, x+5 w100 h30, Excluir

/*
	Tab 2
*/
Gui, Tab, 2 
Gui, Add, Listview, x+10 y+15 w300 h320 vlv_tipos_alterar,Items|Mascara

	/*
		Opcoes 2
	*/
	Gui, Add, Groupbox, xm y380 w320 h100, Opcoes
	Gui, Add, Button, xp+5 yp+15 w100 h30, Inserir
	Gui, Add, Button, x+5 w100 h30, Renomear
	Gui, Add, Button, x+5 w100 h30, Linkar
	Gui, Add, Button, x15 y+10 w100 h30, Importar
	Gui, Add, Button, x+5 w100 h30, Exportar
	Gui, Add, Button, x+5 w100 h30, Excluir

/*
	Tab 3
*/
Gui, Tab, 3 
Gui, Add, Listview, x+10 y+15 w300 h320 vlv_familias_alterar,Items|Mascara

	/*
		Opcoes 3
	*/
	Gui, Add, Groupbox, xm y380 w320 h100, Opcoes
	Gui, Add, Button, xp+5 yp+15 w100 h30, Inserir
	Gui, Add, Button, x+5 w100 h30, Renomear
	Gui, Add, Button, x+5 w100 h30, Linkar
	Gui, Add, Button, x15 y+10 w100 h30, Importar
	Gui, Add, Button, x+5 w100 h30, Exportar
	Gui, Add, Button, x+5 w100 h30, Excluir

Gui, Show,, Alterar
return
