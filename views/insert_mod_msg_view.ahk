insert_mod_msg_view(){
	Global db, SMALL_FONT, GLOBAL_COLOR, info, USER_NAME
	Static msg_value_edit

	/*
		Gui init
	*/
	Gui, insert_mod_msg_view:New
	Gui, insert_mod_msg_view:+ownerM
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%
	
	/*
		Info
	*/
	msg := "Insira uma breve mensagem explicando o motivo da mudanca"
	Gui, Add, Groupbox, x10 y10 w300 h110, % "Info"
	Gui, Add, Text, xp+5 yp+15 w170 h30 , % msg
	Gui, Add, Edit, y+5 w290 vmsg_value_edit,
	Gui, Add, Button, y+5 w100 h30 gsave_changes_in_insert , % "Salvar"
	Gui, Show,, Inserir mensagem! 
	return  


	save_changes_in_insert:
	Gui, Submit, Nohide
	db.Log.insert_mod_info(info, USER_NAME, msg_value_edit)
	load_mod_info()
	load_formation_in_main_window(info)
	return
}