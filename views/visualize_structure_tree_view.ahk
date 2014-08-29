visualize_structure_tree_view() {
	Global 
	
	Gui, structure_tree_view:New
	Gui, Font,s%SMALL_FONT%,%FONT%
	Gui, Add, Groupbox, w300 h110, Dados
  Gui, Add, Text, xp+5 yp+15, Codigo:
  Gui, Add, Edit, w280 vcode_structure, 
  Gui, Add, Button, w100 h30 gvisualize_structure, Visualizar
	Gui,Show, , Visualizar estrutura
	return 
	
	visualize_structure:
	Gui, Submit, Nohide 
	MsgBox, % "gonna try to generate the JSON"
	json_structure := new PromtoJSONStructure()
	json_structure.test()
	try{
		json_structure.generate_JSON(code_structure) 
	}catch e{
		MsgBox, 16, Erro, % "Houve um erro ao gerar o arquivo JSON da estrutura!"
	}
	return 
}

