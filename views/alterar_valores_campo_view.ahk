alterar_valores_campo_view(currentvalue, campo, info){
	Global db, input_name, input_mascara, SMALL_FONT, GLOBAL_COLOR, alt_codigo_field_esp, alt_dr_field_esp, alt_dc_field_esp, alt_di_field_esp 
	Static s_info, s_campo, s_old_cod

	s_info := info
	s_campo := campo
	s_old_cod := currentvalue[1]

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
	Gui, Add, Edit, y+5 w250 valt_codigo_field_esp UPPERCASE, % currentvalue[1]
	Gui, Add, Text, y+15, Descricao Resumida
	Gui, Add, Edit, y+5 w250 r1 valt_dr_field_esp UPPERCASE, % currentvalue[3]
	Gui, Add, Text, y+15, Descricao Completa
	Gui, Add, Edit, y+5 w250 r1 valt_dc_field_esp UPPERCASE, % currentvalue[2]
	Gui, Add, Text, y+15, Descricao Ingles
	Gui, Add, Edit, y+5 w250 r1 valt_di_field_esp UPPERCASE,  % currentvalue[4]

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm w300 h60, Opcoes
	Gui, Add, Button, xp+10 yp+15 w100 h30 galterar_campo_esp Default, Salvar
	Gui, Show,, Alterar Campos.
	Return

	alterar_campo_esp:
	Gui, Submit, Nohide
	if(alt_codigo_field_esp = "" || alt_dr_field_esp = ""){
		MsgBox,16, True, % "O valor do codigo e a descricao resumida nao podem estar em branco!" 
	}
	;MsgBox, % "codigo : " alt_codigo_field_esp " dr " alt_dr_field_esp " dc " alt_dc_field_esp " di " alt_di_field_esp 
	valores := {codigo: alt_codigo_field_esp, dr: alt_dr_field_esp, dc: alt_dc_field_esp, di: alt_di_field_esp}
	if(!db.Modelo.alterar_valores_campo(s_campo, valores, s_info, s_old_cod))
		return
	tabela_campos_especificos := get_tabela_campo_esp(s_campo, s_info)
	db.load_lv("inserir_campos_view", "valores_de_campo_lv", tabela_campos_especificos)
	MsgBox, 64, Sucesso, % "Os valores foram alterados!"
	return
}