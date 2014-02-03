selecionar_campo_externo_view(campos_especificos_cbox, info){
	Global db, lista_pesquisa_selecionar_campos, pesquisa_selecionar_campo_externo, selecionar_campo_externo_lv
	Static s_info
	s_info := info

	/*
		Gui init
	*/
	Gui, selecionar_campo_externo_view:New
	Gui, selecionar_campo_externo_view:+ownerlinkar_campos_view
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Pesquisa
	*/
	Gui, Add, Groupbox, w500 h50, Pesquisa
	Gui, Add, Edit, xp+10 yp+15 w480 vpesquisa_selecionar_campo_externo gpesquisa_selecionar_campo_externo uppercase, 
	
	/*
		Listview
	*/
	Gui, Add, Groupbox, xm y+20 w1000 h520, Tabela de relacoes
	Gui, Add, Listview, xp+10 yp+15 w980 h500 vselecionar_campo_externo_lv checked, Tipo|Tabela 1|Tabela2

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm y+10 w800, Opcoes
	Gui, Add, Button, xp+10 yp+15 w100 h30 gsalvar_relacao, Salvar
	LV_ModifyCol(1, 100), LV_ModifyCol(2, 300), LV_ModifyCol(3, 300) 
	Gui, Show,, Linkar Campos

	StringReplace, campos_especificos_cbox, campos_especificos_cbox, %A_Space%,, All
	table_values := db.find_items_where("tipo like '" campos_especificos_cbox "'", "reltable")
	load_lv_from_array(["tipo", "Tabela 1", "Tabela 2"], table_values, "selecionar_campo_externo_view", "selecionar_campo_externo_lv")
	lista_pesquisa_selecionar_campos := table_values
	return

	pesquisa_selecionar_campo_externo:
	Gui, Submit, Nohide
	any_word_search("selecionar_campo_externo_view", "selecionar_campo_externo_lv", pesquisa_selecionar_campo_externo, lista_pesquisa_selecionar_campos)
	return

	salvar_relacao:
	selected_values := GetSelectedRow("selecionar_campo_externo_view", "selecionar_campo_externo_lv")
	values := {tipo: selected_values[1], tabela2: selected_values[3]} 
	db.Modelo.link_specific_field(values, s_info)
	MsgBox, 64, Sucesso, % "A linkagem foi concluida!" 
	return


}