inserir_campo_esp_view(campo, info){
	Global db, input_name, input_mascara, SMALL_FONT, GLOBAL_COLOR, codigo_field_esp, dr_field_esp, dc_field_esp, di_field_esp 
	Static s_info, s_campo

	s_info := info
	s_campo := campo

	/*
		Gui init
	*/
	Gui, inserir_campo_esp_view:New
	Gui, inserir_campo_esp_view:+ownerinserir_campos_view
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Campos
	*/
	Gui, Add, Groupbox, w300 h230, Campos
	Gui, Add, Text, xp+10 yp+15, Codigo
	Gui, Add, Edit, y+5 w250 vcodigo_field_esp UPPERCASE limit5,
	Gui, Add, Text, y+15, Descricao Resumida
	Gui, Add, Edit, y+5 w250 vdr_field_esp UPPERCASE,
	Gui, Add, Text, y+15, Descricao completa
	Gui, Add, Edit, y+5 w250 vdc_field_esp UPPERCASE,
	Gui, Add, Text, y+15, Descricao Ingles
	Gui, Add, Edit, y+5 w250 vdi_field_esp UPPERCASE, 

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm w300 h60, Opcoes
	Gui, Add, Button, xp+10 yp+15 w100 h30 gsalvar_campo_esp Default, Salvar
	Gui, Show,, Incluir Campo.
	Return

	salvar_campo_esp:
	Gui, Submit, Nohide
	if(codigo_field_esp = "" || dr_field_esp = "" || dc_field_esp = "" || di_field_esp = ""){
		MsgBox,16, Erro, % "O valor do codigo e a descricao resumida nao podem estar em branco!" 
		return
	}
	valores := {codigo: codigo_field_esp, dr: dr_field_esp, dc: dc_field_esp, di: di_field_esp}
	db.Modelo.incluir_campo_esp(s_campo ,valores, s_info)
	Gui, inserir_campo_esp_view:destroy
	tabela_campos_especificos := db.Modelo.get_tabela_campo_esp(s_campo, s_info)
	db.load_lv("inserir_campos_view", "valores_de_campo_lv", tabela_campos_especificos)
	MsgBox, 64, Sucesso, % "O valor foi incluido!"
	Return
}