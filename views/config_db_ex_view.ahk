config_db_ex_view(){
	Global

	Gui,configdbex:New
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,add,ListView,w200 h300 vchoosedb,Nome
	Gui,add,button,y+5 w100 gconectar,Conectar 
	Gui,add,button,x+5 w100 gnovaconexao ,Nova Conexao 
	Gui,add,button,x+5 w100 gdeletarconexao ,Deletar Conexao
	db.load_lv("configdbex", "choosedb", "connections")
	Gui,Show,, Configurar conexoes
	return 

	conectar:
	conectar()
	return 

	novaconexao:
	nova_conexao_view()
	return 

	deletarconexao:
	selecteditem := getselecteditems("configdbex","choosedb")
	MsgBox, % "selected item " selecteditem 
	db.query("DELETE FROM connections WHERE name LIKE '" selecteditem[1] "%';")
	return 
}
