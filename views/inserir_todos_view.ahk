inserir_todos_view(){
	Global

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

	inserirdbextudo:
	tbilist:=object()
	values_in_lv := get_lv_in_array("dbex", "lvdbex", 11)
	for, each, value in values_in_lv{
		tbilist[A_Index, 1] := values_in_lv[A_Index, 1]
		tbilist[A_Index, 2] := values_in_lv[A_Index, 2]
		tbilist[A_Index, 3] := values_in_lv[A_Index, 3]
		tbilist[A_Index, 4] := values_in_lv[A_Index, 4] 
		tbilist[A_Index, 5] := values_in_lv[A_Index, 5]
		tbilist[A_Index, 6] := values_in_lv[A_Index, 6]
		tbilist[A_Index, 7] := values_in_lv[A_Index, 7]
		tbilist[A_Index, 8] := values_in_lv[A_Index, 8] 
		tbilist[A_Index, 9] := values_in_lv[A_Index, 9]
		tbilist[A_Index, 10] := values_in_lv[A_Index, 10]
		tbilist[A_Index, 11] := values_in_lv[A_Index, 11]
		MsgBox, % "codigo : " values_in_lv[A_Index, 1] " `n descricao completa : " values_in_lv[A_Index, 2] " `n descricao resumida " values_in_lv[A_Index, 3] " `n ncm : " values_in_lv[A_Index, 4] " `n um : " values_in_lv[A_Index, 5] "`n origem : " values_in_lv[A_Index, 6] " `n conta : " values_in_lv[A_Index, 7] " `n tipo : " values_in_lv[A_Index, 8] " `n grupo : " values_in_lv[A_Index, 9] "`n ipi : " values_in_lv[A_Index, 10] "`n locpad " values_in_lv[A_Index, 11]
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
}
