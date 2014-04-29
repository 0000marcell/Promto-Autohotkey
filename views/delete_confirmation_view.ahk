delete_confirmation_view(selected_name){
	Global delete_confirmation, confirm_deletion_status, SMALL_FONT, GLOBAL_COLOR
	Static s_selected_name, confirm_name

	s_selected_name := selected_name

	/*
		Gui init
	*/
	Gui, delete_confirmation:New
	Gui, delete_confirmation:+ownerM
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Info
	*/
	Gui, Font, cRed s15,
	Gui, Add, Text, w200 h50, % "Escreva o nome do item a ser deletado."
	Gui, Font, cBlack s8,

	/*
		Campo
	*/
	Gui, Add, Groupbox, y+5 w250 h50, Item
	Gui, Add, Edit, xp+5 yp+20 w240 vconfirm_name UPPERCASE,

	/*
		Opcoes
	*/
	Gui, Add, Button, xm y+15 w100 h30 gconfirm_deletion, Confirmar
	Gui, Show,, Confirmar remocao
	return

	confirm_deletion:
	Gui, Submit, Nohide
	
	if(confirm_name = s_selected_name){
		Gui, delete_confirmation:destroy
		delete_item()
	}else{
		MsgBox, 16, Erro, % "O nome digitado nao corresponde ao item `n para cancelar a remocao feche a janela de cancelamento!" 
	}
	return
}