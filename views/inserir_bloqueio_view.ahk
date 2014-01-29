inserir_bloqueio_view(){
	Global

	algum_codigo_foi_desbloqueado := false
	if(bloq_table = "" || info.modelo[2] = ""){
		MsgBox,64, Erro, % "A tabela de bloqueio estava em branco!"
		return 
	}
	
	/*
		Gui init
	*/
	Gui,MAB:New
	;Gui,font,s%SMALL_FONT%,%FONT%
	Gui,MAB:+ownerM
	Gui, color, white

	/*
		Pesquisa codigos livres
	*/
	Gui, Font, s20 cGreen 
	Gui, Add, text, xm, Livres
	Gui, Font, s8 cBlack
	Gui, Add, Groupbox, w200 h50, Pesquisa
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
	Gui, Add, Listview, xp+10 yp+15 w180 h280 vcodigos_livres, Codigos

	/*
		Bloquear / Desbloquear
	*/
	Gui, Add, Button, x+20 y150 w50 h50 gbloquear_codigo hwndhb,
	ILButton(hb, "promtoshell.dll:" 0, 32, 32, 0)
	Gui, Add, Button, y+10 w50 h50 gdesbloquear_codigo hwndhd, 
	ILButton(hd, "promtoshell.dll:" 1, 32, 32, 0)
	
	/*
		Listview Codigo bloqueado
	*/
	Gui, Add, Groupbox, x+10 yp-100 w200 h300, Codigos Bloqueados
	Gui, Add, Listview, xp+10 yp+15 w180 h280 vcodigos_bloqueados, Codigos
	
	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm y+10 w400 h60, Opcoes
	Gui, Add, Button, xp+10 yp+15 w100 h30 gsalvar_bloqueio, Salvar
	Gui, Add, Button, x+5 w100 h30 gimportar_lista_bloqueio, Importar
	Gui, Add, Button, x+5 w100 h30 gexportar_lista_bloqueio, Exportar
	cod_table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "Codigo"
	desbloqueados_a := db.load_table_in_array(cod_table) 
	bloqueados_a := db.load_table_in_array(bloq_table)
	db.load_lv("MAB", "codigos_livres", cod_table)
	db.load_lv("MAB", "codigos_bloqueados", bloq_table)
	Gui, Show,, Bloqueio
	return

	pesquisa_cod_livre:
	Gui,submit,nohide 
	pesquisalv4("MAB", "codigos_livres", pesquisa_cod_livre, desbloqueados_a)
	return

	pesquisa_cod_bloq:
	Gui, submit, nohide
	pesquisalv4("MAB", "codigos_bloqueados", pesquisa_cod_bloq, bloqueados_a)
	return

	bloquear_codigo:
	bloquear_codigo()
	return

	desbloquear_codigo:
	desbloquear_codigo()
	return

	importar_lista_bloqueio:
	importar_lista_bloqueio()
	return

	salvar_bloqueio:
	salvar_bloqueio()
	return
}