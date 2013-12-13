inserir_campos_view(info){
	Global db, input_name, SMALL_FONT,GLOBAL_COLOR, campos_combobox, valores_de_campo_lv,empresa, tipo, familia, input_name, input_mascara,importar_button, inserir_modelo_lv, exportar_button,more_options_button,opcoes_groupbox, modelos_foto_control, modelo 
 	Static s_info
	
	s_info := info

 	if(s_info.modelo[2] = ""){
 		MsgBox,16, Erro, % "Selecione um modelo antes de continuar!"
 		return
 	}

 	;MsgBox, % "empresa mascara: " info.empresa[2] "`n tipo mascara: " info.tipo[2] "`n familia mascara: " info.familia[2] " `n " 
	
	/*
		Gui init
	*/
	Gui, inserir_campos_view:New
	Gui, inserir_campos_view:+ownerM
	;Gui, Font, s%SMALL_FONT%, %FONT%
	;Gui, Color, %GLOBAL_COLOR%
	Gui, Color, white

	/*
		Campos
	*/
	Gui, Add, Groupbox, w200 h45, Campos
	Gui, Add, Combobox, xp+5 yp+15 w180 vcampos_combobox gcampos_combobox,

	/*
		Opcoes campo
	*/
	Gui, Add, Groupbox, x+20 yp-15 w220 h45, Opcoes campo
	Gui, Add, Button, xp+5 yp+15 w100 h20 gincluir_campo_button, Incluir
	Gui, Add, Button, x+5  w100 h20 gexcluir_campo_button, Excluir

	/*
		Valores de campo
	*/
	Gui, Add, Groupbox, xm y+10 w700 h300, Valores de campo
	Gui, Add, Listview, xp+5 yp+15 w680 h280 vvalores_de_campo_lv gvalores_de_campo_action,Codigo|Descricao Resumida|Descricao Completa|Descricao Ingles

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm y+5 w400 h60, Campos
	Gui, Add, Button, xp+15 yp+15 w100 h30 ginserir_valores_campo_button Default,Inserir 
	Gui, Add, Button, x+5 w100 h30 galterar_valores_campo_button ,Alterar
	Gui, Add, Button, x+5 w100 h30 gexcluir_valores_campo_button, Excluir
	Gui, Show, Autosize, Inserir campos e valores
	
	/*
		Carrega o combobox
	*/
	tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2] info.modelo[1]
	tabela := db.Modelo.get_tabela_campo_referencia(tabela1)
	control := {window: "inserir_campos_view", combobox: "campos_combobox"}
	db.load_combobox(control, tabela)
	return

	alterar_valores_campo_button:
	Gui, Submit, Nohide
	currentvalue := GetSelectedRow("inserir_campos_view", "valores_de_campo_lv")
	alterar_valores_campo_view(currentvalue, campos_combobox, s_info)
	return 

	incluir_campo_button:
	Gui, Submit, Nohide
	inserir_dialogo_2_view("incluir_campo_action", "inserir_campos_view", 1) 
	return

	incluir_campo_action: 
	Gui, Submit, Nohide
	if(input_name = ""){
		MsgBox,16, Erro, % "O nome do campo estava em branco!"
		return
	}
	tabela1 := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.modelo[2] s_info.modelo[1]
	db.Modelo.incluir_campo(input_name, s_info)
	tabela1 := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.modelo[2] s_info.modelo[1]
	tabela := db.Modelo.get_tabela_campo_referencia(tabela1)
	control := {window: "inserir_campos_view", combobox: "campos_combobox"}
	db.load_combobox(control, tabela)
	MsgBox,64, Sucesso, % "O campo foi inserido!"
	return

	excluir_campo_button: 
	Gui, Submit, Nohide
	if(campos_combobox = "" || s_info.modelo[2] = ""){
		MsgBox,16, Erro, % "Selecione um campo antes de continuar!"
		return
	}
	db.Modelo.excluir_campo(campos_combobox, s_info)
	tabela1 := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.modelo[2] s_info.modelo[1]
	tabela := db.Modelo.get_tabela_campo_referencia(tabela1)
	control := {window: "inserir_campos_view", combobox: "campos_combobox"}
	db.load_combobox(control, tabela)
	MsgBox, 64, Sucesso, % "O campo foi excluido com sucesso!"
	Gui, inserir_campos_view:default
	Gui, listview, valores_de_campo_lv
	LV_Delete()
	return

	inserir_valores_campo_button:
	Gui, Submit, Nohide
	if(campos_combobox = "" || s_info.modelo[2] = ""){
		MsgBox,16, Erro, % "Selecione um campo antes de continuar!"
		return
	}
	inserir_campo_esp_view(campos_combobox, s_info)
	return

	excluir_valores_campo_button:
	Gui, Submit, Nohide
	/*
		Pega o codigo selecionado na listview
		passa a tabela de campo esp e o codigo para o excluir
	*/
	selected_item := GetSelected("inserir_campos_view","valores_de_campo_lv")
	tabela_campos_especificos := get_tabela_campo_esp(campos_combobox, s_info)
	db.Modelo.excluir_campo_esp(selected_item, tabela_campos_especificos)
	db.load_lv("inserir_campos_view", "valores_de_campo_lv", tabela_campos_especificos)
	MsgBox,64,Sucesso, % "O valor foi excluido!" 
	return

	campos_combobox:
	Gui, Submit, Nohide
	if(campos_combobox = "" || s_info.modelo[2] = ""){
		MsgBox,16, Erro, % "Selecione um campo antes de continuar!"
		return
	} 
	tabela_campos_especificos := get_tabela_campo_esp(campos_combobox, s_info)
	db.load_lv("inserir_campos_view", "valores_de_campo_lv", tabela_campos_especificos)
	LV_ModifyCol(1, 150), LV_ModifyCol(2, 150), LV_ModifyCol(3, 150), LV_ModifyCol(4, 150)	
	return

	valores_de_campo_action:

	return
}
	