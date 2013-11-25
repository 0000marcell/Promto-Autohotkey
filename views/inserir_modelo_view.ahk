inserir_modelo_view(model_table, empresa, tipo, familia){
	Global mariaDB, SMALL_FONT, GLOBAL_COLOR, importar_button, exportar_button,more_options_button,opcoes_groupbox, modelos_foto_control
	/*
		Gui init
	*/
	Gui, inserir_modelo_view:New
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%
	Gui, Color, white
	
	/*
		Listview
	*/
	Gui, Add, Groupbox, w300 h400, Lista de modelos
	Gui, Add, Listview, xp+5 yp+15 w280 h380,Modelos|Mascara

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm y+20 w300 h60 vopcoes_groupbox,Opcoes
	Gui, Add, Button, xp+30 yp+15 w100 h30 ginserir_modelo,Inserir
	Gui, Add, Button, x+5 w100 h30 gexcluir_modelo,Excluir
	Gui, Add, Button, x+5 w30 h30 ginserir_modelo_more_options vmore_options_button,+
	Gui, Add, Button, x40 y+5 w100 h30 vimportar_button,Importar
	Gui, Add, Button, x+5 w100 h30 vexportar_button,Exportar
	GuiControl, Hide, importar_button
	GuiControl, Hide, exportar_button 

	/*
		Foto
	*/
	Gui, Add, Groupbox, x+70 ym w200 h200 , Fotos
	Gui, Add, Picture, xp+5 yp+15 w150 h150 gmodelos_foto_button vmodelos_foto_control, 
	Gui, Show, Autosize, Inserir Modelo
	return 

	inserir_modelo:
	
	/*
	 Parcial que cria uma janela de insercao com 2 edits
	*/
	inserir_dialogo_2_view("salvar_modelo_button", "inserir_modelo_view")
	return

	salvar_modelo_button:
	Gui, Submit, Nohide
	input_name , input_mascara
	db.Modelo.incluir("TL.L.EXE.010", "010", "TMPCH")
	db.
	return

	excluir_modelo_button:
	return


	inserir_modelo_more_options:
	if(_plus = 1 || _plus = ""){
		GuiControl,Move, opcoes_groupbox, h100
		GuiControl, Show,	importar_button
		GuiControl, Show, exportar_button
		GuiControl,, more_options_button,- 
		Gui, Show, Autosize,
		_plus := 0	
	}else if(_plus = 0){
		GuiControl,Move, opcoes_groupbox, h60
		GuiControl, Hide,	importar_button
		GuiControl, Hide, exportar_button
		GuiControl,, more_options_button, +
		Gui, Show, Autosize,
		_plus := 1
	}
	return

	modelos_foto_button:
	result := GetSelectedRow("inserir1","lv1") 
	if(result[2] = "mascara" || result[2] = ""){
		MsgBox, % "Selecione um item antes de continuar!!"
		return 
	}
	selecteditem := result[1]
	iprefix := args1["mascaraant"] result[2]
	inserirfoto(iprefix, selecteditem, "", args1["owner"])
	return 
}

inserir_modelo_view("modelo", "c", "b", "a")


