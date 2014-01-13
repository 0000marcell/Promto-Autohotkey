foto_individual_view(){
	Global

	info := get_item_info("M", "MODlv")
	/*
		GUi init 
	*/
	Gui,massaphoto:New 
	Gui, Color,%GLOBAL_COLOR%
	
	Gui, Add, Listview, w500 h300 xm section checked vlv altsubmit gmassalv,Codigos
	Gui, Add, Picture, x+5 w300 h300 vpicture,%A_WorkingDir%\noimage.png
	Gui, Add, Button, xm y+5 w100 gmarcartodos,Marcar todos
	Gui, Add, Button, x+5 w100 gdesmarcartodos,Desmarcar todos
	Gui, Add, Button, x+260  w100 ginserirfotoemmassa ,Inserir
	Gui, Show, Adicionar fotos
	code_table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "codigo"
	db.loadlv("massaphoto","lv", code_table)
	return 

	massalv:
	massa_lv()
	return 

	marcartodos:
	check_all("massaphoto", "lv")
	return 

	desmarcartodos:
	uncheck_all("massaphoto", "lv")
	return 

	inserirfotoemmassa:
	MsgBox, 4,,Inserir fotos que estao no banco de dados?
	IfMsgBox Yes
	{
		inserir_imagem_db_view("massa_photo", "picture")
	}else{
		inserir_imagem_view("massa_photo", "picture")
	}
	return 

	excluirfotosemmassa:
	return 

}