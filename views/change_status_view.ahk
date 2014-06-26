change_status_view(info){
	Global db, USER_NAME, SMALL_FONT, GLOBAL_COLOR
	Static s_info, radio_group, aditional_msg
	s_info := info

	/*
		Gui init
	*/
	Gui, change_status_view:New
	Gui, change_status_view:+ownerM
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, x10 ym w200 h150, % "Opcoes"
	Gui, Add, Radio, xp+5 yp+15 w100 h30 vradio_group, % "OK"
	Gui, Add, Radio, y+5 w100 h30 , % "Em andamento"
	Gui, Add, Radio, y+5 w100 h30 , % "Com problemas"
	Gui, Add, Radio, y+5 w100 h10 , % "Nao foi feito"
	Gui, Add, Text, xm y+20 w100, % "Mensagem adicional"
	Gui, Add, Edit, xm y+5 w200 h50 vaditional_msg,
	Gui, Add, Button, xm y+10 w100 h30 gsave_changes, % "Salvar" 
	Gui, Show,, Mudar o status
	return 

	save_changes:
	Gui, submit,
	db.Status.change_status(s_info, radio_group, USER_NAME, aditional_msg)
	load_status_in_main_window(s_info)
	return 
}