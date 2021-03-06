selecionar_campo_externo_view(info){
	Global db, search, lista_pesquisa_selecionar_campos, pesquisa_selecionar_campo_externo, selecionar_campo_externo_lv, SMALL_FONT, GLOBAL_COLOR, campos_especificos_cbox
	Static s_info
	s_info := info

	/*
		Gui init
	*/
	Gui, selecionar_campo_externo_view:New
	Gui, selecionar_campo_externo_view:+ownerinserir_campos_view
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Selecionar Campo
	*/
	Gui, Add, Groupbox, w200 h50, Campos especificos
	Gui, Add, Combobox, xp+5 yp+15 w180 vcampos_especificos_cbox gcampos_especificos,

	/*
		Pesquisa
	*/
	Gui, Add, Groupbox, x+20 ym w500 h50, Pesquisa
	Gui, Add, Edit, xp+10 yp+15 w480 vpesquisa_selecionar_campo_externo gpesquisa_selecionar_campo_externo uppercase, 
	
	/*
		Listview
	*/
	Gui, Add, Groupbox, xm y+20 w1000 h520, Tabela de relacoes
	Gui, Add, Listview, xp+10 yp+15 w980 h500 vselecionar_campo_externo_lv,Tipo|Tabela1|Tabela2

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm y+10 w800, Opcoes
	Gui, Add, Button, xp+10 yp+15 w100 h30 gsalvar_relacao, Salvar
	LV_ModifyCol(1, 100), LV_ModifyCol(2, 300), LV_ModifyCol(3, 300) 
	Gui, Show,, Linkar Campos

	/*
		Carrega o combobox com os campos
	*/
	tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
	tabela := db.Modelo.get_tabela_campo_referencia(tabela1)
	control := {window: "selecionar_campo_externo_view", combobox: "campos_especificos_cbox"}
	db.load_combobox(control, tabela)
	return

	campos_especificos:
	Gui, Submit, Nohide
	StringReplace, campos_especificos_cbox, campos_especificos_cbox, %A_Space%,, All
	table_values := db.find_items_where("tipo like '" campos_especificos_cbox "'", "reltable")
	load_lv_from_matrix("3", table_values, "selecionar_campo_externo_view", "selecionar_campo_externo_lv")
	search.LV.set_searcheable_list(table_values)
	return

	pesquisa_selecionar_campo_externo:
	Gui, Submit, Nohide
	search.LV.any_word_search("selecionar_campo_externo_view", "selecionar_campo_externo_lv", pesquisa_selecionar_campo_externo)
	return

	salvar_relacao:
	selected_values := GetSelectedRow("selecionar_campo_externo_view", "selecionar_campo_externo_lv")
	values := {tipo: selected_values[1], tabela2: selected_values[3]} 
	tabela1 := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.subfamilia[2] s_info.modelo[2] s_info.modelo[1]
	db.Modelo.link_specific_field(values, tabela1, s_info)
	MsgBox, 64, Sucesso, % "A linkagem foi concluida!" 
	return

}