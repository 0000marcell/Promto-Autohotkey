inserir_bloqueio_view(){
	Global

	if(bloq_table = ""){
		MsgBox,64, Erro, % "A tabela de bloqueio estava em branco!"
		return 
	}
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
	cod_table := info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2] "Codigo"
	desbloqueados_a := db.load_table_in_array(cod_table) 
	bloqueados_a := db.load_table_in_array(bloq_table)
	db.load_lv("MAB", "codigos_livres", cod_table)
	db.load_lv("MAB", "codigos_bloqueados", bloq_table)
	Gui, Show,, Bloqueio
	return

	pesquisa_cod_livre:
	Gui,submit,nohide 
	pesquisa_simple_array("MAB", "codigos_livres", pesquisa_cod_livre, desbloqueados_a)
	return

	pesquisa_cod_bloq:
	pesquisa_simple_array("MAB", "codigos_bloqueados", pesquisa_cod_bloq, bloqueados_a)
	return

	bloquear_codigo:
	selected_item := GetSelected("MAB","codigos_livres")
	selected_number := GetSelected("MAB","codigos_livres", "number")
	if(selected_item = "Codigos" || selected_item = ""){
		MsgBox,16, Erro, % "Selecione um item antes de continuar!"
		return
	}
	;MsgBox, % "selected_item " selected_item " selected_number " selected_number
	Gui, Listview, codigos_livres
	LV_Delete(selected_number)

	Gui, Listview, codigos_bloqueados
	item_inserted := LV_Add("", selected_item)
	;MsgBox, % "item inserted " item_inserted
	LV_Modify(item_inserted, "Select")
	LV_Modify(item_inserted, "Focus")
	return

	desbloquear_codigo:
	selected_item := GetSelected("MAB","codigos_bloqueados")
	selected_number := GetSelected("MAB","codigos_bloqueados", "number")
	if(selected_item = "Codigos" || selected_item = ""){
		MsgBox,16, Erro, % "Selecione um item antes de continuar!"
		return
	}

	Gui, Listview, codigos_bloqueados
	LV_Delete(selected_number)

	Gui, Listview, codigos_livres
	item_inserted := LV_Add("", selected_item)
	LV_Modify(item_inserted, "Select")
	LV_Modify(item_inserted, "Focus")
	return

	importar_lista_bloqueio:


	FileSelectFile, source, ""
	Stringright,_iscsv,source,3
  if(_iscsv!="csv"){
  	MsgBox, % "o arquivo selecionado tem que ser .csv!!!!"
  	return 
  }

  MsgBox, 4,, Deseja apagar os items atuais?
  IfMsgBox Yes
  {
  	;MsgBox, % "apagar tabela " tabela_tbi
  	db.clean_table(bloq_table)
  }
  x:= new OTTK(source)
  prefixo := s_info.empresa[2] s_info.tipo[2] s_info.familia[2]
  progress(x.maxindex())
  for,each,value in x{
  	if(value = "")
  		Continue
  	updateprogress("Inserindo Items da Lista: " x[A_Index, 1],1)
  	db.Modelo.incluir_bloqueio(value, bloq_table)
  }
  Gui,progress:destroy
  MsgBox,64,,% "valores importados!"
	return

	exportar_lista_bloqueio:
	Gui, Submit, Nohide
	Gui, Listview, codigos_bloqueados
	export_bloqueados := get_lv_in_array("MAB", "codigos_bloqueados")
	for, each, value in export_bloqueados{
		if(export_bloqueados[A_Index, 1] = "")
			Continue
		FileAppend, % export_bloqueados[A_Index, 1] "`n", % "temp\bloq_export.csv"
	}
	run, % "temp\temp_export.csv"
	MsgBox,64, Sucesso, % "Os valores foram exportados!"
	return

	salvar_bloqueio:

	/*
		Compara os items da tabela de 
		bloqueados com a tabela de desbloqueados
		e retira os items bloqueados da tabela de desbloqueados
	*/
	current_bloq := get_lv_in_array("MAB", "codigos_bloqueados")
	current_desbloq := get_lv_in_array("MAB", "codigos_livres")
	result_table := []
	db.clean_table(bloq_table)
	for, each, value in current_bloq{
		cod_bloqueado := current_bloq[A_Index, 1]
		if(cod_bloqueado = "")
			Continue
		db.Modelo.remover_codigo(cod_bloqueado, cod_table)
		db.Modelo.incluir_bloqueio(cod_bloqueado, bloq_table)
	} 
	MsgBox, 64, Sucesso, % "Os valores foram inseridos!"
	return
}