inserir_dialogo_2_view(action, owner_name){
	Global db, input_name, input_mascara, SMALL_FONT, GLOBAL_COLOR

	/*
		Gui init
	*/
	Gui, insert_dialogo_2:New
	Gui, insert_dialogo_2:+owner%owner_name%
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Campos
	*/
	Gui, Add, Groupbox, w230 h130, Campos
	Gui, Add, Text,xp+10 yp+15, Item:
	Gui, Add, Edit, y+10 w200 vinput_name uppercase,
	Gui, Add, Text, y+10, Mascara:
	Gui, Add, Edit, y+10 w200 vinput_mascara uppercase,

	/*
		Opcoes
	*/
	Gui, Add, Groupbox,xm y+20 w230 h60, Opcoes
	Gui, Add, Button, xp+113 yp+19 w100 h30 g%action% Default, Inserir
	Gui, Show,,Inserir 
	return 
}