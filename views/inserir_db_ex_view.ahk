inserir_db_ex_view(){
	Global

	values := GetCheckedRows("dbex","lvdbex")
	if(values[1,1] = ""){
		MsgBox, % "Marque um item antes de continuar."
		return 
	}
	Gui, bloquear_outros:New
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui, Add, Text,,Deseja bloquear os outros items da lista?
	Gui, Add, Button,xm y+5 w100 h30 gbloquear_outros_items, Sim
	Gui, Add, Button,x+5 w100 h30 gnao_bloquear_outros_items, Nao
	Gui, Show,,Bloquear outros items?
	return

	bloquear_outros_items:
	bloquear_outros_items := True
	Gui, bloquear_outros:destroy
	MsgBox, % "codigo : " values[1,1] " locpad : " values[1, 11]
	inserirdbexterno(values)
	return 

	nao_bloquear_outros_items:
	bloquear_outros_items := False
	Gui, bloquear_outros:destroy
	inserirdbexterno(values)
	Return 
}