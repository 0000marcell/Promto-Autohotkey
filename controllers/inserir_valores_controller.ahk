inserir_val_camp(){
	Global

	gui,submit,nohide
	checkedval := GetSelected("inserirval","lviv2")
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
  db.create_val_table(selectedvaluecol)  
  db.clean_table(selectedvaluecol)
  x := new OTTK(source)
  for,each,value in x{
      valuetochange := x[A_Index,1]
      StringReplace,valuetochange,valuetochange,.,,All
      db.insert_val(valuetochange, x[A_Index,2], selectedvaluecol)
  }
  MsgBox,64,,% "valores importados!!!!"
}

excluir_val(){
	Global

  if((current_connection_value = "MACCOMEVAP") && (selectedvaluecol = "TCONTA" || selectedvaluecol = "LOCPAD" )){
    selectedvaluecol_2 := selectedvaluecol "_" current_connection_value 
  }else{
    selectedvaluecol_2 := selectedvaluecol
  }

	currentvalue := object()
	currentvalue := GetSelectedRow("inserirval","lviv2")

	MsgBox, 4,,Deseja apagar a Campo %currentvalue%?
  IfMsgBox Yes
  {
    db.delete_items_where("valor='"  currentvalue[1] "' AND descricao='" currentvalue[2] "';", selectedvaluecol_2)
    loadvaltables()
    loadlv(selectedvaluecol_2)
  }else{
    return 
  }
}
