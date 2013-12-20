db_ex_view(){
	Global

	info := get_item_info("M", "MODlv")
	cod_table := info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2] "Codigo"
	MsgBox, % "cod table " cod_table
	Gui,dbex:new
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui, color, %GLOBAL_COLOR%
	Gui, dbex:+ownerM
	Gui, add, edit, w900 r1  vpesquisadbex gpesquisadbex uppercase,
	Gui, add, listview, w900 h400 y+5 checked vlvdbex, Codigo|Descricao Completa|Descricao Resumida
	Gui, add, button, w100 h30 y+5 ginserirdbex,Inserir
	Gui, add, button, w100 h30 x+5 gmarctodos,Marc.todos 
	Gui, add, button, w100 h30 x+5 gdesmarctodos,Desm.todos
	Gui, add, button, w100 h30 x+5 ginserirvalores,Inserir Valores
	Gui, add, button, w100 h30 x+5 gconfigdbex,Configurar.
	Gui, add, button, w100 h30 x+5 ginserirtodos,Inserir todos!!
	Gui, add, button, w100 h30 x+5 gexport_code_list_to_file,Exportar para arquivo
	Gui, add, button, w100 h30 x+5 gcheck_if_exist_in_external_db, ja foi inserido?
	Gui, add, button,w100 h30 x+5 ,Remover
	Gui, Show,, adicionar db externo!
	GuiControl, -Redraw, lvdbex
	Listdbex := []
	table := db.load_table_in_array(cod_table)
	Listdbex := table
	for, each, value in table{
		if(table[A_Index, 1] = "")
			Continue
		value1 := table[A_Index, 1]
		%value1% := {}
	}
	db.load_lv("dbex", "lvdbex", cod_table)
	GuiControl, -Redraw, lvdbex
	for,each,value in ["NCM","UM","ORIGIGEM","CONTA","TIPO","GRUPO","IPI","LOCPAD"]
		LV_InsertCol(each+3,"",value)
	GuiControl, +Redraw,lvdbex
	return 

	check_if_exist_in_external_db:
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
	return 

	export_code_list_to_file:	
	export_code_list_to_file(getvaluesLV("dbex","lvdbex"),FamiliaMascara,selectmodel)
	return 

	inserirtodos:
	loadvaltables()
	COLUNAS:=["NCM","UM","ORIGEM","TCONTA","TIPO","GRUPO","IPI","LOCPAD"]
	checkedlistdb:=GetCheckedRows("dbex","lvdbex")
	Gui,inserirval:new
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,add,edit,w300 r1 x165 vpesquisaiv gpesquisaiv uppercase,
	Gui,add,listview,w150 h300 xm y+5 vlviv gcolvalue altsubmit,colunas
	Gui,add,listview,w700 h300 x+5 vlviv2 -multi,Valores|descricao
	Gui,add,button,w100 h30 y+5 gsalvartodos,Salvar!
	Gui,add,button,w100 h30 x+5 ginserirdbextudo,Inserir Tudo
	Gui,add,button,w100 h30 x+5 gimportarval,Importar Valor
	Gui,add,button,w100 h30 x+5 gexcluirval,Excluir
	Gui,Show,,
	Gui,listview,lviv
	for,each,value in COLUNAS
		LV_Add("",value)
	Gui,listview,lviv2
	Listiv:=[]
	for,each,value in NCM{
		Listiv[A_Index,1]:=each
		Listiv[A_Index,2]:=value
		LV_Add("",each,value)
	}
	Gui,listview,lviv
	LV_Modify(1, "+Select")
	return 

	inserirdbextudo:
	tbilist:=object()
	countindex:=1
	for,each,value in list:=db.getvalues("Mascara",modtable){
		for,each,value in list2:=db.getvalues("Codigos,DC,DR",EmpresaMascara AbaMascara FamiliaMascara list[A_Index,1] "Codigo"){
			tbilist[countindex,1]:=list2[A_Index,1]
			tbilist[countindex,2]:=list2[A_Index,2]
			tbilist[countindex,3]:=list2[A_Index,3]
			tbilist[countindex,4]:=NCM 
			tbilist[countindex,5]:=UM 
			tbilist[countindex,6]:=ORIGEM 
			tbilist[countindex,7]:=TCONTA
			tbilist[countindex,8]:=TIPO 
			tbilist[countindex,9]:=GRUPO
			tbilist[countindex,10]:=IPI
			countindex++
		}
	}
	inserirdbexterno(tbilist)
	MsgBox, % " os valores foram inseridos!!!"
	return 

	salvartodos:
	gui,submit,nohide
	checkedval:=GetSelected("inserirval","lviv2")
	if(checkedval=""){
		MsgBox, % "Selecione um valor antes de continuar!"
	}
	%selectedvaluecol%:=checkedval
	MsgBox,64,, % " O " selectedvaluecol " Foi preenchido!!!"
	return  

	configdbex:
	Gui,configdbex:New
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,add,ListView,w200 h300 vchoosedb,Nome
	Gui,add,button,y+5 w100 gconectar,Conectar 
	Gui,add,button,x+5 w100 gnovaconexao ,Nova Conexao 
	Gui,add,button,x+5 w100 gdeletarconexao ,Deletar Conexao
	db.load_lv("configdbex", "choosedb", cod_table)
	Gui,Show
	return 

	conectar:
	selecteditem := getselecteditems("configdbex","choosedb")
	connectionvalue := db.load_table_in_array()
	connectionvalue := db.query("SELECT name,connection,type FROM connections WHERE name LIKE '" selecteditem[1] "%';")
	if(connectionvalue["connection"]=""){
		MsgBox, % "Nao existe conxao para esse nome tente adicionar outra conexao."
		return 
	}
	ddDatabaseConnection:= connectionvalue["connection"]
	ddDatabaseType:= connectionvalue["type"]
	;MsgBox, % "ddDatabaseConnection " ddDatabaseConnection "`n ddDatabaseType " ddDatabaseType  
	try {
		sigaconnection:= DBA.DataBaseFactory.OpenDataBase(ddDatabaseType,ddDatabaseConnection)
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
	return 

	novaconexao:
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
	connectstring.close
	return 

	deletarconexao:
	selecteditem:=getselecteditems("configdbex","choosedb")
	db.query("DELETE FROM connections WHERE name LIKE '" selecteditem[1] "%';")
	return 

	salvarconfig:
	Gui,submit,nohide 
	MsgBox, % "Ira testar a conexao antes de inserir o valor!"
	try {
		sigaconnection:= DBA.DataBaseFactory.OpenDataBase(configedit2,configedit)
	} catch e {
		MsgBox,16, Error, % "Erro ao tentar conectar!`n`n" ExceptionDetail(e)
		return 
	}
	if(IsObject(sigaconnection)){
		 MsgBox,64,,% "A connexao esta funcionando!!!"
	}else{
	    MsgBox,16,,% "A conexao falhou!! confira os parametros!!"
	    return 
	} 
	db.createtable("connections","(name TEXT,connection TEXT,type TEXT,PRIMARY KEY(name ASC))")
	MsgBox, % "connectionname " connectionname " configedit " configedit " configedit2 " configedit2
	db.query("INSERT INTO connections (name,connection,type) VALUES ('" connectionname "','" configedit "','" configedit2 "');")
	MsgBox,64,,% "Os valores da nova conexao foram salvos!" 
	return 

	inserirdbex:
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
	inserirdbexterno(values)
	return 

	nao_bloquear_outros_items:
	bloquear_outros_items := False
	Gui, bloquear_outros:destroy
	inserirdbexterno(values)
	Return 


 pesquisadbex:
 Gui,submit,nohide
 pesquisalvmod("dbex","lvdbex",pesquisadbex,Listdbex)
 return 

	inserirvalores:
	loadvaltables()
	COLUNAS:=["NCM","UM","ORIGEM","TCONTA","TIPO","GRUPO","IPI","LOCPAD"]
	checkedlistdb:=GetCheckedRows("dbex","lvdbex")
	Gui,inserirval:new
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,add,edit,w300 r1 x165 vpesquisaiv gpesquisaiv uppercase,
	Gui,add,listview,w150 h300 xm y+5 vlviv gcolvalue altsubmit,colunas
	Gui,add,listview,w700 h300 x+5 vlviv2 -multi,Valores|descricao
	Gui,add,button,w100 h30 y+5 ginserirvalcamp,Inserir.
	Gui,add,button,w100 h30 x+5 ginserirval,Inserir Valor
	Gui,add,button,w100 h30 x+5 gimportarval,Importar Valor
	Gui,add,button,w100 h30 x+5 gexcluirval,Excluir
	Gui,Show,,
	Gui,listview,lviv
	for,each,value in COLUNAS
		LV_Add("",value)
	Gui,listview,lviv2
	Listiv:=[]
	for,each,value in NCM{
		Listiv[A_Index,1] := each
		Listiv[A_Index,2] := value
		LV_Add("",each,value)
	}
	Gui,listview,lviv
	LV_Modify(1, "+Select")
	return 

	importarval:
	Gui,submit,nohide
      FileSelectFile,source,""
      Stringright,_iscsv,source,3
      MsgBox, % _iscsv
      if(_iscsv!="csv"){
      	MsgBox, % "o arquivo selecionado tem que ser .csv!!!!"
      	return 
      }
      if(selectedvaluecol=""){
		MsgBox, % "selecione uma coluna antes de continuar!!"
		return 
		}
      db.query("CREATE TABLE " selectedvaluecol "(valor,descricao);")
      db.query("DELETE FROM " selectedvaluecol ";")
      x:= new OTTK(source)
      for,each,value in x{
          valuetochange:=x[A_Index,1]
          StringReplace,valuetochange,valuetochange,.,,All
          db.query("INSERT INTO " selectedvaluecol "(valor,descricao) VALUES ('" valuetochange "','" x[A_Index,2] "');")
      }
      MsgBox,64,,% "valores importados!!!!"
	return 

	exportarparabanco:
	gosub,configdbex
	Gui,exportarparadb:New
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,add,button,w100 gexportarparadb,Exportar para db
	Gui,Show,,Exportar Para DB
	return 
		
	inserirval:
	if(selectedvaluecol=""){
		MsgBox, % "selecione uma coluna antes de continuar!!"
		return 
	}
	Gui,inserirval2:New
	Gui,font,s%SMALL_FONT%,%FONT% 
	Gui,inserirval2:+ownerinserirval
	Gui,add,text,,Valor Campo:
	Gui,add,edit,w150 y+5 r1 veditinserirval1 uppercase
	Gui,add,text,y+5,Nome Campo:
	Gui,add,edit,w150 y+5 r1 veditinserirval2 uppercase
	Gui,add,button,w100 h30 y+5 gsalvarval,Salvar
	Gui,Show,,Inserir!!
	return 

  salvarval:
  Gui,submit,nohide
  if(editinserirval1="")||(editinserirval2="")
      MsgBox, % "Nenhum dos campos pode estar em branco!!!"
  MsgBox, % "selectedvaluecol " selectedvaluecol
  db.query("CREATE TABLE " selectedvaluecol "(valor,descricao);")
  MsgBox, % " editar val 1 " editinserirval1 " editar val 2 " editinserirval2
  db.insert(selectedvaluecol,"(valor,descricao)","('" . editinserirval1 . "','" editinserirval2 "')")
  loadvaltables()
  loadlv(selectedvaluecol)
  Gui,inserirval2:destroy
  return 

	excluirval:
	currentvalue:=object()
	currentvalue:=GetSelectedRow("inserirval","lviv2")
	MsgBox, % "valor " currentvalue[1] " descricao " currentvalue[2]  "  selectcolum " selectedvaluecol 
	MsgBox, 4,,Deseja apagar a Campo %currentvalue%?
    IfMsgBox Yes
    {
        db.query("DELETE FROM " selectedvaluecol " WHERE valor='"  currentvalue[1] "' AND descricao='" currentvalue[2] "';")
        loadvaltables()
        loadlv(selectedvaluecol)
    }else{
        return 
    }
	return

	inserirvalcamp:
	gui,submit,nohide
	checkedval:=GetSelected("inserirval","lviv2")
	if(checkedval=""){
		MsgBox, % "Selecione um valor antes de continuar!"
	}
	for,each,value in checkedlistdb{
		codname:=checkedlistdb[A_Index,1]
		%codname%[selectedvaluecol]:=checkedval
	}
	loadlvdbex()
	return 

	pesquisaiv:
	Gui,submit,nohide
	pesquisalv("inserirval","lviv2",pesquisaiv,Listiv)
	return 

	colvalue:
	if A_GuiEvent=i
	{
		Gui,submit,nohide
		gui,listview,lviv
		selectedvaluecol:=GetSelected("inserirval","lviv")
		if(selectedvaluecol="")
			return 
		else 
			loadlv(selectedvaluecol)
	}
	return 
	return 
}