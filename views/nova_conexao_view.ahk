nova_conexao_view(){
	Global

	Gui,config:new
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,add,text,xm y+5,Nome: 
	Gui,add,edit,xm y+5 vconnectionname uppercase, 
	Gui,add,text,xm y+5 h50 cblue,Exemplo:Provider=SQLOLEDB.1;Persist Security Info=False;User `n ID=lvieira;Initial Catalog=MP11_MAC_PRODUCAO;`n Data Source=192.168.10.5\microsiga
	Gui,add,text,y+5,Database Connection:
	Gui,add,edit,vconfigedit y+5 h100 w500 uppercase,
	Gui,add,text,cblue y+5,Exemplo:ADO
	Gui,add,text,y+5,Database Type:
	Gui,add,edit,vconfigedit2 y+5 r1 w150 uppercase,
	Gui,add,button,gsalvarconfig y+5 w100 h30,Salvar!!!
	Gui,Show,,Configurar Banco externo!!!
	return

	salvarconfig:
	salvar_config()
	return 
}