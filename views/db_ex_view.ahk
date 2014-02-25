db_ex_view(){
	Global

	if(current_connection_value = ""){
		MsgBox, 16, Erro, % "E preciso selecionar uma conexao externa antes de prosseguir!" 
		return
	}

	info := get_item_info("M", "MODlv")
	
	cod_table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "Codigo"
	Gui,dbex:new
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui, color, %GLOBAL_COLOR%
	Gui, dbex:+ownerM

	Gui, add, edit, w900 r1  vpesquisadbex gpesquisadbex uppercase,
	Gui, add, listview, w900 h400 y+5 checked vlvdbex, Codigo|Descricao Completa|Descricao Resumida
	Gui, add, button, w100 h30 y+5 ginserirdbex,Inserir
	Gui, add, button, w100 h30 x+5 gmarctodos_dbex,Marc.todos 
	Gui, add, button, w100 h30 x+5 gdesmarctodos_dbex,Desm.todos
	Gui, add, button, w100 h30 x+5 ginserirvalores,Inserir Valores
	Gui, add, button, w100 h30 x+5 gconfigdbex,Configurar.
	Gui, add, button, w100 h30 x+5 gexport_code_list_to_file, Exportar para arquivo
	Gui, Font, s15 cGreen
	Gui, add, Text, xm y+5 w800 h30 vconnection_status, % "Conectado a " current_connection_value
	Gui, Show,, adicionar db externo!
	GuiControl, -Redraw, lvdbex
	Listdbex := []
	table := db.load_table_in_array(cod_table)
	Listdbex := table
	for, each, value in table{
		if(table[A_Index, 1] = "")
			Continue
		value1 := table[A_Index, 1]
		%value1% := {}
	}
	db.load_lv("dbex", "lvdbex", cod_table)
	LV_ModifyCol(1, 150), LV_ModifyCol(2, 300)
	GuiControl, -Redraw, lvdbex
	for,each,value in ["NCM", "UM", "ORIGIGEM", "CONTA", "TIPO", "GRUPO", "IPI", "LOCPAD"]
		LV_InsertCol(each+3,"",value)
	GuiControl, +Redraw,lvdbex
	return 

	check_if_exist_in_external_db:
	check_if_exist_in_external_db()
	return 

	export_code_list_to_file:	
	info := get_item_info("M", "MODlv")
	export_code_list_to_file(getvaluesLV("dbex","lvdbex"), info.familia[2] info.subfamilia[2], selectmodel)
	return 

	inserirtodos:
	inserir_todos_view()
	return 

	

	configdbex:
	config_db_ex_view()
	return 


	

	inserirdbex:
	inserir_db_ex_view()
	return 


 pesquisadbex:
 Gui,submit,nohide
 pesquisalvmod("dbex","lvdbex",pesquisadbex,Listdbex)
 return 

	inserirvalores:
	inserir_valores_view()
	return 

	

	exportarparabanco:
	gosub, configdbex
	Gui, exportarparadb:New
	Gui,font, s%SMALL_FONT%, %FONT%
	Gui,add,button, w100 gexportarparadb, Exportar para db
	Gui,Show,, Exportar Para DB
	return 

	marctodos_dbex:
	check_all("dbex", "lvdbex")
	return

	desmarctodos_dbex:
	uncheck_all("dbex", "lvdbex")
	return
}