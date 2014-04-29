linkar_campos_view(info){
	Global db, campos_especificos_cbox, SMALL_FONT, GLOBAL_COLOR
 	Static s_info
		
	s_info := info

 	if(s_info.modelo[2] = ""){
 		MsgBox,16, Erro, % "Selecione um modelo antes de continuar!"
 		return
 	}
	
	/*
		Gui init
	*/
	Gui, linkar_campos_view:New
	Gui, linkar_campos_view:+ownerinserir_campos_view
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%
	Gui, Color, white

	/*
		Campos especificos
	*/
	Gui, Add, Groupbox, w200 h45, Campos especificos
	Gui, Add, Combobox, xp+5 yp+15 w180 vcampos_especificos_cbox,
	Gui, Add, Button, y+10 w100 h30 gselecionar_campo_externo, Selecionar externo

	/*
		Todos os campos
	*/
	Gui, Add, Groupbox, w200 h45, Todos os campos
	Gui, Add, Button, y+20w200 h30 glinkar_todos_os_campos, Linkar todos os campos
	Gui, Show, Autosize, Linkar Campos
	tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
	tabela := db.Modelo.get_tabela_campo_referencia(tabela1)
	control := {window: "linkar_campos_view", combobox: "campos_especificos_cbox"}
	db.load_combobox(control, tabela)
	return

	selecionar_campo_externo:
	Gui, Submit, Nohide
	selecionar_campo_externo_view(s_info)
	return

	linkar_todos_os_campos:
	Gui, Submit, Nohide
	linkar_todos_os_campos_view(s_info)
	return

}