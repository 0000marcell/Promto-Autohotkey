check_if_exist_in_external_db(){
	Global

	if(CONNECTED_DBEX = ""){
		MsgBox,16,,% "Conecte em um banco externo antes de continuar."
		return 
	}
	if(!IsObject(sigaconnection)){
			 CONNECTED_DBEX := selecteditem[1]
			 MsgBox,64,,% "Conectado em " CONNECTED_DBEX 
		}else{
		    MsgBox,16,,% "A conexao falhou, confira os parametros"
		    return 
	} 
	_was_missing := 0
	for,each,value in Listdbex{
		 Listdbex[A_Index,1]
		_exist_in_dbex := existindb(sigaconnection,"Select B1_COD from SB1010 WHERE B1_COD = '" Listdbex[A_Index,1] "'")
		if(_exist_in_dbex = False){
			_was_missing := 1
			MsgBox,16,,% "Um ou mais items nao existiam no db externo!"
			Break 
		}
	}
	if(_was_missing = 0)
		MsgBox,64,,% "Todos os items ja estavam no db externo."
}

conectar(){
	Global
	
	selecteditem := getselecteditems("configdbex","choosedb")
	selected_item_name :=  selecteditem[1]
	StringLeft, base_test_name, selected_item_name, 10
	base_value := ""
	;MsgBox, % "base test name " base_test_name
	if(base_test_name = "TOTALLIGHT"){
		base_value := "SB1060" 
	}else{
		base_value := "SB1010"
	}
	connectionvalue := db.query_table("connections",["name", selecteditem[1]], ["name", "connection", "type"])
	;MsgBox, % "connection " connectionvalue["connection"]
	if(connectionvalue["connection"] = ""){
		MsgBox, % "Nao existe conxao para esse nome tente adicionar outra conexao."
		return 
	}
	ddDatabaseConnection := connectionvalue["connection"]
	ddDatabaseType:= connectionvalue["type"]
	;MsgBox, % "ddDatabaseConnection " ddDatabaseConnection "`n ddDatabaseType " ddDatabaseType  
	try {
		sigaconnection := DBA.DataBaseFactory.OpenDataBase(ddDatabaseType,ddDatabaseConnection)
	} catch e {
		MsgBox,16, Error, % "A conexao falhou!`n" ExceptionDetail(e)
		return 
	}
	if(IsObject(sigaconnection)){
			CONNECTED_DBEX := selecteditem[1]
		 MsgBox,64,,% "A connexao esta funcionando!!!"
	}else{
	    MsgBox,64,,% "A conexao falhou!! confira os parametros!!"
	    return 
	} 
	dbex := new SQL(ddDatabaseType,ddDatabaseConnection)
}

salvar_config(){
	Global

	Gui,submit,nohide 
	;MsgBox, % "Ira testar a conexao antes de inserir o valor!"
	;MsgBox, % "valores configedit2 " configedit2 " configedit " configedit
	;try {
	;	sigaconnection:= DBA.DataBaseFactory.OpenDataBase(configedit2,configedit)
	;} catch e {
	;	MsgBox,16, Error, % "Erro ao tentar conectar!`n`n" ExceptionDetail(e)
	;	return 
	;}
	;if(IsObject(sigaconnection)){
	;	 MsgBox,64,,% "A connexao esta funcionando!!!"
	;}else{
	;    MsgBox,16,,% "A conexao falhou!! confira os parametros!!"
	;    return 
	;}
	;MsgBox, % "connectionname " connectionname " configedit " configedit " configedit2 " configedit2 
	db.inserir_conexao(connectionname, configedit, configedit2)
	;MsgBox,64,,% "Os valores da nova conexao foram salvos!" 
	Gui, configdbex:default
	Gui, Listview, choosedb 
	LV_Add("", connectionname)
}

loadvaltables(){
	Global

	NCM := {},UM := {},ORIGEM:={},TCONTA:={},TIPO:={},GRUPO:={},IPI:={},LOCPAD:={}
	for,each,list_name in ["NCM","UM","ORIGEM","TCONTA","TIPO","GRUPO","IPI","LOCPAD"]{
    table := db.load_table_in_array(list_name)
    for, each, value in table{
    	%list_name%["valor", A_Index] := table[A_Index, 1]
    	%list_name%["descricao", A_Index] := table[A_Index, 2]
    }
	}
}

salvar_val(){
	Global

	Gui,submit,nohide
  if(editinserirval1="")||(editinserirval2="")
      MsgBox, % "Nenhum dos campos pode estar em branco!!!"
  ;MsgBox, % "selectedvaluecol " selectedvaluecol
  db.create_val_table(selectedvaluecol)
  ;MsgBox, % " editar val 1 " editinserirval1 " editar val 2 " editinserirval2
  db.insert_val(editinserirval1, editinserirval2, selectedvaluecol)
  loadvaltables()
  db.load_lv("inserirval", "lviv2", selectedvaluecol)
  Gui,inserirval2:destroy	
}

/*
	carregar lv db ex
*/
loadlvdbex(){
	Global 
	Gui,dbex:default
	Gui,listview,lvdbex
	for,each,value in Listdbex{
		codname:=Listdbex[A_Index,1]
		LV_Modify(A_Index,"",codname,Listdbex[A_Index,2],Listdbex[A_Index,3],%codname%["NCM"],%codname%["UM"],%codname%["ORIGEM"],%codname%["TCONTA"],%codname%["TIPO"],%codname%["GRUPO"],%codname%["IPI"],%codname%["LOCPAD"])
	}	
	pesquisalvmod("dbex","lvdbex",pesquisadbex,Listdbex)
}
