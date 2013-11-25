x := inserir_dialog("salvar")
return 
salvar:
Gui, Submit, Nohide
MsgBox, % input_1
return 

inserir_dialog(action){
	Global 
	Gui, Add, Edit, w150 vinput_1, 
	Gui, Add, Edit, w150 vinput_2,
	Gui, Add, Button, w100 h30 g%action%, Salvar
	Gui, Show
	return
}