inserir_val_camp(){
	Global

	gui,submit,nohide
	checkedval:=GetSelected("inserirval","lviv2")
	if(checkedval=""){
		MsgBox, % "Selecione um valor antes de continuar!"
	}

	for,each,value in checkedlistdb{
		codname := checkedlistdb[A_Index,1]
		%codname%[selectedvaluecol] := checkedval
	}
	loadlvdbex()	
}

importar_val(){
	Global

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
  x := new OTTK(source)
  for,each,value in x{
      valuetochange:=x[A_Index,1]
      StringReplace,valuetochange,valuetochange,.,,All
      db.query("INSERT INTO " selectedvaluecol "(valor,descricao) VALUES ('" valuetochange "','" x[A_Index,2] "');")
  }
  MsgBox,64,,% "valores importados!!!!"
}

excluir_val(){
	Global

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
}
