inserir_valores_view(){
	Global

	loadvaltables()
	COLUNAS := ["NCM","UM","ORIGEM","TCONTA","TIPO","GRUPO","IPI","LOCPAD"]
	checkedlistdb := GetCheckedRows("dbex","lvdbex")
	Gui,inserirval:new
	Gui, font,s%SMALL_FONT%,%FONT%
	Gui, Add, edit,w300 r1 x165 vpesquisaiv gpesquisaiv uppercase,
	Gui, Add, listview,w150 h300 xm y+5 vlviv gcolvalue altsubmit,colunas
	Gui, Add, listview,w700 h300 x+5 vlviv2 -multi,Valores|descricao
	Gui, Add, button, w100 h30 y+5 ginserirvalcamp,Inserir
	Gui, Add, button, w100 h30 x+5 ginserirval,Inserir Valor
	Gui, Add, button, w100 h30 x+5 gimportarval,Importar Valor
	Gui, Add, button, w100 h30 x+5 gexcluirval,Excluir
	Gui,Show,,
	Gui, listview, lviv
	for,each,value in COLUNAS
		LV_Add("",value)
	Gui,listview,lviv2
	Listiv := []
	for,each,value in NCM{
		Listiv[A_Index,1] := each
		Listiv[A_Index,2] := value
		LV_Add("",each,value)
	}
	Gui,listview,lviv
	LV_Modify(1, "+Select")
	return

	colvalue:
	if A_GuiEvent = i
	{
		Gui, Submit, Nohide
		Gui, Listview, lviv
		selectedvaluecol := GetSelected("inserirval","lviv")
		if(selectedvaluecol = "")
			return 
		else 
			loadlv(selectedvaluecol)
	}
	return 

	pesquisaiv:
	Gui, Submit, Nohide
	pesquisalv("inserirval","lviv2",pesquisaiv,Listiv)
	return 

	inserirvalcamp:
	inserir_val_camp()
	return 

	inserirval:
	inserir_val_view()
	return 

	importarval:
	importar_val()
	return 

	excluirval:
	excluir_val()
	return
}