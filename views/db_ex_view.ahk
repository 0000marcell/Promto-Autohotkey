db_ex_view(){
	Global

	info := get_item_info("M", "MODlv")
	cod_table := info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2] "Codigo"
	Gui,dbex:new
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui, color, %GLOBAL_COLOR%
	Gui, dbex:+ownerM
	Gui, add, edit, w900 r1  vpesquisadbex gpesquisadbex uppercase,
	Gui, add, listview, w900 h400 y+5 checked vlvdbex, Codigo|Descricao Completa|Descricao Resumida
	Gui, add, button, w100 h30 y+5 ginserirdbex,Inserir
	Gui, add, button, w100 h30 x+5 gmarctodos,Marc.todos 
	Gui, add, button, w100 h30 x+5 gdesmarctodos,Desm.todos
	Gui, add, button, w100 h30 x+5 ginserirvalores,Inserir Valores
	Gui, add, button, w100 h30 x+5 gconfigdbex,Configurar.
	;Gui, add, button, w100 h30 x+5 ginserirtodos,Inserir todos!!
	Gui, add, button, w100 h30 x+5 gexport_code_list_to_file,Exportar para arquivo
	;Gui, add, button, w100 h30 x+5 gcheck_if_exist_in_external_db, ja foi inserido?
	;Gui, add, button,w100 h30 x+5 ,Remover
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
	for,each,value in ["NCM","UM","ORIGIGEM","CONTA","TIPO","GRUPO","IPI","LOCPAD"]
		LV_InsertCol(each+3,"",value)
	GuiControl, +Redraw,lvdbex
	return 

	check_if_exist_in_external_db:
	check_if_exist_in_external_db()
	return 

	export_code_list_to_file:	
	info := get_item_info("M", "MODlv")
	MsgBox, % "codelist " getvaluesLV("dbex","lvdbex") " `n familia mascara " info.familia[2] " `n select model " selectmodel
	export_code_list_to_file(getvaluesLV("dbex","lvdbex"), info.familia[2], selectmodel)
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
	gosub,configdbex
	Gui,exportarparadb:New
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,add,button,w100 gexportarparadb,Exportar para db
	Gui,Show,,Exportar Para DB
	return 

	
}