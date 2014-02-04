linkar_todos_os_campos_view(info){
	Global db, ETF_TVSTRING
	Static s_info

	s_info := info

	/*
		Gui init
	*/
	Gui, linkar_todos_os_campos_view:New
	Gui, linkar_todos_os_campos_view:+ownerlinkar_campos_view
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Treeview
	*/
	Gui, Add, Groupbox, w1000 h520, Tabela de relacoes
	Gui, Add, Treeview, xp+10 yp+15 w980 h500 vselecionar_campo_externo_tv gselecionar_campo_externo_tv,

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm y+10 w800, Opcoes
	Gui, Add, Button, xp+10 yp+15 w100 h30 gsalvar_relacao_todos, Salvar
	LV_ModifyCol(1, 100), LV_ModifyCol(2, 300), LV_ModifyCol(3, 300) 
	Gui, Show,, Linkar todos os campos
	TvDefinition =
	(
		%ETF_TVSTRING%
	)
	Gui, Treeview, linkar_todos_os_campos_view
	CreateTreeView(TvDefinition)
	return

	selecionar_campo_externo_tv:
	tv_strut("linkar_todos_os_campos_view", "selecionar_campo_externo_tv", "")
	return

	salvar_relacao_todos:
	
	return

}