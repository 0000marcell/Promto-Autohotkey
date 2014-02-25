inserir_val_view(){
	Global
	
	if(selectedvaluecol = ""){
		MsgBox, % "selecione uma coluna antes de continuar!!"
		return 
	}

	Gui, inserirval2:New
	Gui, Font, s%SMALL_FONT%,%FONT% 
	Gui, inserirval2:+ownerinserirval

	Gui, Add, text,,Valor Campo:
	Gui, Add, edit,w150 y+5 r1 veditinserirval1 uppercase
	Gui, Add, text,y+5,Nome Campo:
	Gui, Add, edit,w150 y+5 r1 veditinserirval2 uppercase
	Gui, Add, button,w100 h30 y+5 gsalvarval,Salvar
	Gui,Show,, Inserir!!	
	return

	salvarval:
  	salvar_val()
  	return 
}
