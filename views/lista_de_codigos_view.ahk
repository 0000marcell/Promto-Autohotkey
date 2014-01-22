lista_de_codigos(info){
	Global db, SMALL_FONT, GLOBAL_COLOR, updownv, ordem_lv, pesquisarcod, Listpesqcod, lvcodetable
	Static tabela_ordem, s_info

	s_info := info

	/*
		Gui init
	*/
	Gui, lista_de_codigos_view:New
	Gui, lista_de_codigos_view:+ownerM
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Pesquisa
	*/
	Gui, Add, Groupbox, w1000 h50, Pesquisa
	Gui, Add, Edit, xp+10 yp+15 w980 vpesquisarcod gpesquisarcod uppercase, 
	
	/*
		Listview
	*/
	Gui, Add, Groupbox, xm y+20 w1000 h520, Codigos
	Gui, Add, Listview, xp+10 yp+15 w980 h500 vlvcodetable checked glvcodetable,Codigo|Descricao Completa|Descricao Resumida|Descricao Ingles

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm y+10 w800, Opcoes
	Gui, Add, Button, xp+10 yp+15 w100 h30 gcarregartabela, Salvar em Arquivo
	Gui, Add, Button, x+5 w100 h30 ggerarplaquetas, Gerar Plaquetas

	code_table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "Codigo"
	Listpesqcod := db.load_table_in_array(code_table)
	db.load_lv("lista_de_codigos_view", "lvcodetable", code_table)
	LV_ModifyCol(1, 100), LV_ModifyCol(2, 300), LV_ModifyCol(3, 300), LV_ModifyCol(4, 300) 
	Gui, Show,, Lista de Codigos
	return

	pesquisarcod:
	Gui,submit,nohide 
	pesquisalv4("lista_de_codigos_view","lvcodetable", pesquisarcod, Listpesqcod)
	return  

	lvcodetable:
	;if A_GuiEvent=DoubleClick
	;{
	;	currentvalue:=GetSelectedRow("codetable","lvcodetable")
	;	tvstring:="",selecteditemtoloadestrut:=currentvalue[1] ">>" currentvalue[3]
	;	loadestrutura(selecteditemtoloadestrut,"",,0)
	;	tvwindow2(args)		
	;}
	return

	carregartabela:
	FileDelete,temp.csv 
	for each, value in Listpesqcod{
		FileAppend, % Listpesqcod[A_Index,1] ";" Listpesqcod[A_Index,2] "`n",temp.csv	
	}
	Run,temp.csv		
	return

	gerarplaquetas:

	codigos_selecionados := GetCheckedRows("lista_de_codigos_view","lvcodetable")
	append_debug("@@@@@@@@@@@@" codigos_selecionados[1, 1])
	prefix := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.subfamilia[2]
	model_mask := s_info.modelo[2]
	ordened_prefix := db.get_ordened_prefix(s_info)
	StringReplace, ordened_prefix, ordened_prefix, %model_mask%,, All
	model_name := s_info.modelo[1]
	createtag(prefix, ordened_prefix, model_mask, model_name, prefix model_mask "Codigo", codigos_selecionados)
	return 

}