inserir_bloqueio_view(){
	Global

	/*
		Gui init
	*/
	Gui,MAB:New
	;Gui,font,s%SMALL_FONT%,%FONT%
	;Gui,MAB:+ownerM
	Gui, color, white

	/*
		Pesquisa codigos livres
	*/
	Gui, Font, s20 cGreen 
	Gui, Add, text, xm, Livres
	Gui, Font, s8 cBlack
	Gui, Add, Groupbox, y+10 w200 h50, Pesquisa
	Gui, Add, Edit, xp+10 yp+15 w180 gpesquisa_cod_livre vpesquisa_cod_livre,

	/*
		Pesquisa codigos bloqueados
	*/
	Gui, Font, s20 cRed
	Gui, Add, text, x+80 yp-60 , Bloqueados
	Gui, Font, s8 cBlack
	Gui, Add, Groupbox, y+10 w200 h50, Pesquisa
	Gui, Add, Edit, xp+10 yp+15 w180 gpesquisa_cod_bloq vpesquisa_cod_bloq,
	
	/*
		Listview Codigo livre
	*/
	Gui, Add, Groupbox, xm y+20 w200 h300, Codigos Livres
	Gui, Add, Listview, xp+10 yp+15 w180 h280 vcodigos_livres,

	/*
		Bloquear / Desbloquear
	*/
	Gui, Add, Button, x+20 y150 w50 h50 gbloquear_codigo hwndhb, Bloquear
	;ILButton(hb, "promtoshell.dll:" 5, 32, 32, 0)
	Gui, Add, Button, y+10 w50 h50 gdesbloquear_codigo hwndhd, Desbloquear 
	;ILButton(hd, "promtoshell.dll:" 5, 32, 32, 0)
	
	/*
		Listview Codigo bloqueado
	*/
	Gui, Add, Groupbox, x+10 yp-100 w200 h300, Codigos Bloqueados
	Gui, Add, Listview, xp+10 yp+15 w180 h280 vcodigos_bloquedos,
	
	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm y+10 w400 h60, Opcoes
	Gui, Add, Button, xp+10 yp+15 w100 h30, Salvar
	Gui, Add, Button, x+5 w100 h30 gimportar_lista_bloqueio, Importar
	Gui, Add, Button, x+5 w100 h30 gexportar_lista_bloqueio, Exportar
	bloqueados_a := db.load_table_in_array(bloq_table)
	 := db.get_bloq(values_tbe)
	desbloqueados_a := db.get_desbloq(values_tbe)  
	Gui, Show,, Bloqueio
	return

	pesquisa_cod_livre:
	return

	pesquisa_cod_bloq:
	return

	bloquear_codigo:
	return

	desbloquear_codigo:
	return

	importar_lista_bloqueio:
	return

	exportar_lista_bloqueio:
	return

	;Gui,Add, Picture,w310 h50 0xE vbanner 
	;banner(BANNER_COLOR,banner,"Bloqueados")
	;Gui,add,edit,w300 y+5 r1 gpesquisabloq vpesquisamam uppercase,
	;Gui,add,listview,w300 h400 y+5 vMABlv  checked,
	;Gui,add,button,w100 h30 y+5 ginserirwindow,Inserir Bloqueios
	;Gui,add,button,w100 h30 x+5 gretirarbloq,Retirar do bloqueio
	;Gui,add,button,w100 h30 x+5 gfiltrarcod,Filtrar Codigos!!
	;Gui,add,button,w100 h30 y+5 xm gmarctodosmab,Marc.Todos
	;Gui,add,button,w100 h30 x+5 gdestodosmab,Des.Todos
	;Gui,add,button,w100  h30 x+5 gexportarbloqueio,Exportar
	;Gui,add,button,w100 h30 xm y+5 gimportarbloqueio,Importar
	;Gui,Show,,Modelos-Bloqueados!!
	;Listbloq:=[]
	;table:=db.query("SELECT Codigos FROM " bloqtable ";")
	;while(!table.EOF){  
	;        value1 := table["Codigos"],value2 := table["DC"]
	;        Listbloq[A_Index,1] := value1 
	;        Listbloq[A_Index,2] := value2
	;        table.MoveNext()
	;}
	;table.close()
	;db.loadlv("MAB","MABlv",bloqtable,"Codigos")
}

inserir_bloqueio_view()