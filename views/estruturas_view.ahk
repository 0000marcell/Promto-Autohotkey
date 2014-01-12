estruturas_view(){
	Global

	;if(_reload_gettable = True ){    ; Variavel utilizada para saber se a tabela de formacao de estrutura precisa ser recaregada
	;	GLOBAL_TVSTRING := ""
	;	gettable("empresa",0,"","")
	;	_reload_gettable := False 
	;}

	/* 
		Gui init
	*/
	Gui,massaestrut:New
	Gui, Font,s%SMALL_FONT%, %FONT%
	Gui,massaestrut:+ownerM
	Gui, Color, %GLOBAL_COLOR%	
	Gui, Add, Edit, x415 gpesquisarlv w400 r1 vpesquisarlv uppercase ,Pesquisar!!!
	Gui, Add, Treeview, xm y+5 w400 h300 vtv1 gtvstrut,
	Gui, Add, Listview, x+5 w400 h300 vlv1 checked gestrutlv,Codigos| Descricao Completa| Descricao Resumida | Descricao Ingles
	Gui, Add, Treeview, x+5 w400 h300 vtv2,
	Gui, Add, Treeview, xm y+5 w400 h300 vtvaddmass gtvaddmass,
	Gui, Add, Listview, x+5 w400 h300 vlvaddmass checked glvaddmass,Codigos|DR
	Gui, Add, Listview, x+5 w400 h300 vlvaddmass2,Codigos 
	Gui, Add, Button, xm w100 h30 gimprimirestrut,Imprimir Estruturas!!
	Gui, Add, Button, x+250  w100 h30 gaddmassa, Add em Massa
	Gui, Add, Button, x+5  w100 h30 gaddquantidademassa, Add Quantidade em Massa
	Gui, Add, Button, x+5 w100 h30 gremmassa,Remover em Massa 
	Gui, Add, Button, x+5 w100 h30 gmarctodos,Marc.Todos!
	Gui, Add, Button, x+5 w100 h30 gdesmarctodos,Des.Marc.Todos!
	Gui, Add, Button, x+5 w100 h30 gexcluirestrut,Excluir estrutura!
	Gui, Add, Button, x+5 w100 h30 gexcluiritemestrut,Excluir item!
	Gui, Add, Button, x+5 w100 h30 gexportarestrut,Exportar estruturas!! 
	TvDefinition =
	(
		%ETF_TVSTRING%
	)
	Gui, Treeview, tv1
	CreateTreeView(TvDefinition)
	Gui, Treeview, tvaddmass
	CreateTreeView(TvDefinition)
	Gui, Show,, Estruturas!!
	return

	imprimirestrut:
	return

	pesquisarlv:
	Gui,submit,nohide
	any_word_search("massaestrut", "lv1", pesquisarlv, Listestrut)
	return

	tvstrut:
	tv_strut("massaestrut", "tv1", "lv1")
	return

	estrutlv:
	FileDelete, % "debug.txt"
	estrut_lv()
	return

	excluirestrut:
	return 

	excluiritemestrut:
	Return

	exportarestrut:
	return
	
	addmassa:
	add_componente_marcado()
	return 

	addquantidademassa:
	add_quantidade_em_massa()
	return 

	remmassa:
	return

	marctodos:
	return 

	desmarctodos:
	return 

	tvaddmass:
	tv_strut("massaestrut", "tvaddmass", "lvaddmass")
	return

	lvaddmass:
	return 
}

estruturas_view()