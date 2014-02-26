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
	
	current_connection_value := ""
	selecteditem := getselecteditems("configdbex","choosedb")
	selected_item_name :=  selecteditem[1]
	current_connection_value := selected_item_name

	StringLeft, base_test_name, selected_item_name, 10
	base_value := ""
	if(base_test_name = "TOTALLIGHT"){
		base_value := "SB1060" 
	}else{
		base_value := "SB1010"
	}
	connectionvalue := db.query_table("connections",["name", selecteditem[1]], ["name", "connection", "type"])

	if(connectionvalue["connection"] = ""){
		MsgBox, % "Nao existe conxao para esse nome tente adicionar outra conexao."
		return 
	}
	ddDatabaseConnection := connectionvalue["connection"]
	ddDatabaseType:= connectionvalue["type"]
	try {
		sigaconnection := DBA.DataBaseFactory.OpenDataBase(ddDatabaseType,ddDatabaseConnection)
	} catch e {
		MsgBox,16, Error, % "A conexao falhou!`n" ExceptionDetail(e)
		return 
	}
	if(IsObject(sigaconnection)){
			CONNECTED_DBEX := selecteditem[1]
		 MsgBox,64,,% "A connexao esta funcionando!!!"
		 GuiControl,, connection_status, % "Conectado a " selected_item_name
	}else{
	    MsgBox,64,,% "A conexao falhou!! confira os parametros!!"
	    return 
	} 
	dbex := new SQL(ddDatabaseType,ddDatabaseConnection)
}

salvar_config(){
	Global

	Gui,submit,nohide 
	db.inserir_conexao(connectionname, configedit, configedit2) 
	Gui, configdbex:default
	Gui, Listview, choosedb 
	LV_Add("", connectionname)
}

loadvaltables(){
	Global

	NCM := {}, UM := {}, ORIGEM := {}, TCONTA := {}, TIPO := {}, GRUPO := {}, IPI := {}, LOCPAD := {}
	for,each,list_name in ["NCM","UM","ORIGEM","TCONTA","TIPO","GRUPO","IPI","LOCPAD"]{
		if(list_name = "")
			Continue
		
		if((current_connection_value = "MACCOMEVAP") && (list_name = "TCONTA" || list_name = "LOCPAD" )){
			selectedvaluecol_23 := list_name "_" current_connection_value 
		}else{
			selectedvaluecol_23 := list_name 
		}

    table := db.load_table_in_array(selectedvaluecol_23)
    
    for, each, value in table{
    	%list_name%["valor", A_Index] := table[A_Index, 1]
    	%list_name%["descricao", A_Index] := table[A_Index, 2]
    }
	}
}

salvar_val(){
	Global
  Local current_selected_table
	Gui,submit,nohide
  if(editinserirval1="")||(editinserirval2="")
      MsgBox, % "Nenhum dos campos pode estar em branco!"
  
  if((current_connection_value = "MACCOMEVAP") && (selectedvaluecol = "TCONTA" || selectedvaluecol = "LOCPAD" )){
		selectedvaluecol_2 := selectedvaluecol "_" current_connection_value 
	}else{
		selectedvaluecol_2 := selectedvaluecol
	}

  db.create_val_table(selectedvaluecol_2)
  db.insert_val(editinserirval1, editinserirval2, selectedvaluecol_2)
  %selectedvaluecol_2%["valor"].insert(editinserirval1)
  %selectedvaluecol_2%["descricao"].insert(editinserirval2)
  current_selected_table := selectedvaluecol_2
  loadvaltables()
  loadlv(selectedvaluecol_2)
  db.load_lv("inserirval", "lviv2", current_selected_table)
  Gui, inserirval2:destroy	
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
