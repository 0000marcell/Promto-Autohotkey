config_db_ex_view(){
	Global

	Gui,configdbex:New
	Gui, configdbex:+ownerM
	Gui,font,s%SMALL_FONT%,%FONT%

	Gui, add, ListView,w200 h300 vchoosedb,Nome
	Gui, add, Button,y+5 w100 gconectar,Conectar 
	Gui, add, Button,x+5 w100 gnovaconexao ,Nova Conexao 
	Gui, add, Button,x+5 w100 gdeletarconexao ,Deletar Conexao
	db.load_lv("configdbex", "choosedb", "connections")
	Gui, Show,, Configurar conexoes
	return 

	conectar:
	conectar()
	Gui, configdbex:destroy
	db_ex_view()
	return 

	novaconexao:
	nova_conexao_view()
	return 

	deletarconexao:
	selecteditem := getselecteditems("configdbex","choosedb")
	db.query("DELETE FROM connections WHERE name LIKE '" selecteditem[1] "%';")
	return 
}
