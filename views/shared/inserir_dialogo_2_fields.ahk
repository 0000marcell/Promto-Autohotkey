inserir_dialogo_2_view(action, owner_name, numero_de_campos = 2){
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
	if(numero_de_campos = 2){
		groupbox_height := "130"
	}else{
		groupbox_height := "70"
	}
	Gui, Add, Groupbox, w230 h%groupbox_height%, Campos
	Gui, Add, Text,xp+10 yp+15, Item:
	Gui, Add, Edit, y+10 w200 vinput_name uppercase,
	if(numero_de_campos = 2){
		Gui, Add, Text, y+10, Mascara:
		Gui, Add, Edit, y+10 w200 vinput_mascara uppercase,	
	}
	/*
		Opcoes
	*/
	Gui, Add, Groupbox,xm y+20 w230 h60, Opcoes
	Gui, Add, Button, xp+113 yp+19 w100 h30 g%action% Default, Inserir
	Gui, Show,,Inserir 
	return 
}