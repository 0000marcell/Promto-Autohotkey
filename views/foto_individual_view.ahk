foto_individual_view(){
	Global

	info := get_item_info("M", "MODlv")
	/*
		GUi init 
	*/
	Gui,massaphoto:New 
	Gui, Color,%GLOBAL_COLOR%
	Gui, Add, Listview, w900 h300 xm section checked vlv altsubmit gmassalv,Codigos|Descricao Completa|Descricao Resumida, Descricao Ingles
	Gui, Add, Picture, x+5 w300 h300 vpicture, % "img\sem_foto.jpg"
	Gui, Add, Button, xm y+5 w100 gmarcartodos, Marcar todos
	Gui, Add, Button, x+5 w100 gdesmarcartodos, Desmarcar todos
	Gui, Add, Button, x+260  w100 ginserirfotoemmassa , Inserir imagem
	Gui, Show,, Adicionar fotos
	code_table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "codigo"
	db.load_lv("massaphoto","lv", code_table, 1)
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
	codigos_selecionados := GetCheckedRows2("massaphoto","lv")

	MsgBox, 4,, Inserir fotos que estao no banco de dados?
	IfMsgBox Yes
	{
		inserir_imagem_db_view("massaphoto", "picture", codigos_selecionados)
	}else{
		inserir_imagem_view("massaphoto", "picture", codigos_selecionados)
	}
	return 

	excluirfotosemmassa:
	return 
}