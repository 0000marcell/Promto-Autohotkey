show_status_result_view(items){
	Global
	Static s_items

	s_items := items
	/*
		Gui init
	*/
	Gui, show_status_result:New
	Gui, show_status_result:+ownerM
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	
	Gui, Add, Listview, y+5 w300 h400, Id|Status|Mensagem
	Gui, Add, Button, xm y+5 w100 h30 gsave_in_file, % "Salvar em arquivo"
	Gui, Add, Button, x+5 w100 h30 gdetailed_list, % "Lista detalhada"
	Gui, Show,, Resultado status
	for, each, item in items{
		if(items[A_Index, 1] = "")
			Continue
		LV_Add("", items[A_Index, 5], items[A_Index, 3], items[A_Index, 4])
	}
	LV_ModifyCol()
	return 

	save_in_file:
	For, each, item in s_items{
		if(s_items[A_Index, 1] = "")
			Continue
		FileAppend, % s_items[A_Index, 5] ";" s_items[A_Index, 3] ";" s_items[A_Index, 4] "`n", % "temp/temp_list.csv"	
	}
	run, % "temp\temp_list.csv"
	MsgBox, 64, Sucesso, % "O arquivo foi salvo e sera carregado!"
	return

	detailed_list:
	MsgBox, 16, % "Erro", "Sera implementado depois do dia 04/04/2014"
	return

}