estruturas_view(){
	;if(_reload_gettable = True ){    ; Variavel utilizada para saber se a tabela de formacao de estrutura precisa ser recaregada
	;	GLOBAL_TVSTRING := ""
	;	gettable("empresa",0,"","")
	;	_reload_gettable := False 
	;}

	/* 
		Gui init
	*/
	Gui,massaestrut:New
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,massaestrut:+ownerM
	Gui,color,%GLOBAL_COLOR%
	

	Gui, Add, Edit, x415 gpesquisarlv w400 r1 vpesquisarlv uppercase ,Pesquisar!!!
	Gui, Add, Treeview, xm y+5 w400 h300 vtv1 gtvstrut,
	Gui, Add, Listview, x+5 w400 h300 vlv1 checked gestrutlv,Codigos|DR
	Gui, Add, Treeview, x+5 w400 h300 vtv2, 
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
		%GLOBAL_TVSTRING%
	)
	gui, Treeview, tv1
	CreateTreeView(TvDefinition)
	Gui, Show,, Estruturas!!
	return

	imprimirestrut:
	
	return

	excluirestrut:
	return 

	excluiritemestrut:
	Return

	exportarestrut:
	return
	
	addmassa:
	return 

	addquantidademassa:
	return 

	remmassa:
	return

	marctodos:
	return 

	desmarctodos:
	return 
}

estruturas_view()