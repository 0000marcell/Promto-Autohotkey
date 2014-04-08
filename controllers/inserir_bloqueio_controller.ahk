bloquear_codigo(){
	Global

	Gui, Listview, codigos_bloqueados
	LV_Modify(0, "-Select")
	selected_items := ""
	selected_numbers := ""
	; Pega os items selecionados na listview
	selected_items := getselecteditems("MAB", "codigos_livres")
	last_item := bloqueados_a.maxindex()
	if(last_item = "")
		last_item := 0
	for, each, value in selected_items{
		selected_item := selected_items[A_Index]
		if(selected_item = "Codigos" || selected_item = ""){
			Continue
		}
		last_item++
		bloqueados_a[last_item, 1] := selected_item 
		Gui, Listview, codigos_bloqueados

		item_inserted := LV_Add("", selected_item)
	}
	remove_selected_in_lv("MAB", "codigos_livres")
}

desbloquear_codigo(){
	Global

	algum_codigo_foi_desbloqueado := true

	Gui, Listview, codigos_livres
	LV_Modify(0, "-Select")
	selected_items := ""
	selected_items := getselecteditems("MAB","codigos_bloqueados")
	
	for, each, value in selected_items{
		selected_item := selected_items[A_Index]

		if(selected_item = "Codigos" || selected_item = ""){
			Continue
		}
		;remove os items que foram desbloqueados do array
		bloqueados_a := remove_from_array(bloqueados_a, selected_item)
		Gui, Listview, codigos_livres
		item_inserted := LV_Add("", selected_item)
	} 
	remove_selected_in_lv("MAB", "codigos_bloqueados")
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
	main_view.set_code_number(promto_node.get_number_of_items()) 
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
  	db.clean_table(bloq_table)
  }
  x:= new OTTK(source)
  prefixo := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.subfamilia[2]
  progress(x.maxindex())
  for,each,value in x{
  	if(x[A_Index, 1] = "")
  		Continue
  	updateprogress("Inserindo Items da Lista: " x[A_Index, 1],1) 
  	LV_Add("", x[A_Index, 1]) 
  	db.Modelo.incluir_bloqueio(x[A_Index, 1], bloq_table)

  }
  db.load_lv("MAB", "codigos_bloqueados", bloq_table)
  Gui,progress:destroy
  MsgBox,64,,% "valores importados!"
	return

	exportar_lista_bloqueio:
	Gui, Submit, Nohide
	Gui, Listview, codigos_bloqueados
	export_bloqueados := get_lv_in_array("MAB", "codigos_bloqueados")
	if(export_bloqueados.maxindex() != 0 && export_bloqueados.maxindex() != "" )
		FileDelete, % "temp\bloq_export.csv"
		 
	for, each, value in export_bloqueados{
		if(export_bloqueados[A_Index, 1] = "")
			Continue
		FileAppend, % export_bloqueados[A_Index, 1] "`n", % "temp\bloq_export.csv"
	}
	run, % "temp\bloq_export.csv"
	MsgBox,64, Sucesso, % "Os valores foram exportados!"
	return
}

