bloquear_codigo(){
	Global

	selected_item := GetSelected("MAB","codigos_livres")
	selected_number := GetSelected("MAB","codigos_livres", "number")
	if(selected_item = "Codigos" || selected_item = ""){
		MsgBox,16, Erro, % "Selecione um item antes de continuar!"
		return
	}
	Gui, Listview, codigos_livres
	LV_Delete(selected_number)

	Gui, Listview, codigos_bloqueados
	item_inserted := LV_Add("", selected_item)
	LV_Modify(item_inserted, "Select")
	LV_Modify(item_inserted, "Focus")
}

desbloquear_codigo(){
	Global

	algum_codigo_foi_desbloqueado := true
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
}


salvar_bloqueio(){
	Global

	if(algum_codigo_foi_desbloqueado){
		Gosub, gerarcodigos	
	}
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
	algum_codigo_foi_desbloqueado := false
	number_of_items() 
	MsgBox, 64, Sucesso, % "Os valores foram inseridos!"
}

importar_lista_bloqueio(){
	Global

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
}
