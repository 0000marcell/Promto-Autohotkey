list_options_view(){
	Global db, SMALL_FONT, GLOBAL_COLOR
	Static radio_group_list
	/*
		Gui init
	*/
	Gui, list_options_view:New
	Gui, list_options_view:+ownerM
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%
	Gui, Add, Text, x10 y15 w290 h15, % "Marque uma das opcoes para tirar uma listagem `n com todos os modelos que se encontram nessa situacao"

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm y+10 w300 h150, % "Opcoes" 
	Gui, Add, Radio, xp+5 yp+15 w100 h30 vradio_group_list, % "OK"
	Gui, Add, Radio, y+5 w100 h30 , % "Em andamento"
	Gui, Add, Radio, y+5 w100 h30 , % "Com problemas"
	Gui, Add, Radio, y+5 w100 h10 , % "Nao foi feito"
	Gui, Add, Button, xm y+20 w100 h30 ggenerate_list, % "Gerar listagem" 
	Gui, Show,, Listas
	return 

	generate_list:
	Gui, Submit, Nohide
	if(!radio_group_list){
		MsgBox, 16, Erro, % "Selecione uma das opcoes antes de gerar a listagem!"
		return
	}
	items := db.Status.get_items("Status like '" radio_group_list "'")
	show_status_result_view(items)
	return 

}