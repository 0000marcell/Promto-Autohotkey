linkar_modelos_view(info){
	Global db, pesquisa_linkar_modelos, linkar_modelos_lv, SMALL_FONT, GLOBAL_COLOR, lista_pesquisa_linkar_modelos
	Static s_info

	s_info := info

	/*
		Gui init
	*/
	Gui, linkar_modelos_view:New
	Gui, linkar_modelos_view:+ownerinserir_modelo_view
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Pesquisa
	*/
	Gui, Add, Groupbox, w500 h50, Pesquisa
	Gui, Add, Edit, xp+10 yp+15 w480 vpesquisa_linkar_modelos gpesquisa_linkar_modelos uppercase, 
	
	/*
		Listview
	*/
	Gui, Add, Groupbox, xm y+20 w1000 h520, Tabela de relacoes
	Gui, Add, Listview, xp+10 yp+15 w980 h500 vlinkar_modelos_lv, Tipo|Tabela1|Tabela2

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm y+10 w800, Opcoes
	Gui, Add, Button, xp+10 yp+15 w100 h30 gsalvar_relacao_modelos, Linkar
	LV_ModifyCol(1, 100), LV_ModifyCol(2, 300), LV_ModifyCol(3, 300) 
	Gui, Show,, Linkar Campos

	/*
		Carrega a listview com as relacoes de modelos
	*/
	table_values := db.find_items_where("tipo like 'Modelo'", "reltable")
	load_lv_from_matrix("3", table_values, "linkar_modelos_view", "linkar_modelos_lv")
	lista_pesquisa_linkar_modelos := table_values
	return

	pesquisa_linkar_modelos:
	Gui, Submit, Nohide
	any_word_search("linkar_modelos_view", "linkar_modelos_lv", pesquisa_linkar_modelos, lista_pesquisa_linkar_modelos)
	return

	salvar_relacao_modelos:
	selected_values := GetSelectedRow("linkar_modelos_view", "linkar_modelos_lv")
	values := {tipo: selected_values[1], tabela2: selected_values[3]} 
	
	if(s_info.subfamilia[1] != ""){
		tabela1 := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.subfamilia[1]		
	}else{
		tabela1 := s_info.empresa[2] s_info.tipo[2] s_info.familia[1] 
	}

	MsgBox, % "ira inserir o link tabela1 " tabela1 
	db.Modelo.link_models_table(values, tabela1, s_info)
	MsgBox, 64, Sucesso, % "A linkagem foi concluida!" 
	return
}