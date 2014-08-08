addquantidademassa(items){
	Global db,GLOBAL_COLOR
	Static valorquantidade,partecodigo,items1
	
	items1 := items
	Gui,addquantidademassa:New
	Gui, Font, s%SMALL_FONT%,%FONT%
	Gui, Color, %GLOBAL_COLOR%
	Gui, Add, Text,w300,Quantidade
	Gui, Add,Edit,xm y+5 w300 r1 vvalorquantidade uppercase,
	Gui, Add, Text,xm y+5 w300,Parte do codigo do item
	Gui, Add,Edit,y+5 w300 r1 vpartecodigo uppercase,
	Gui, Add, Button,xm y+5 w100 gsalvarquantidademassa default,Salvar
	Gui, Show,,Adicionar Quantidade Em massa
	return 

	salvarquantidademassa:
	GUi,submit,nohide
	itemscount:=0
	for,each,value in items1["code"]{
		parent:=items1["code",A_Index] ">>" items1["desc",A_Index]
		itemscount++
		db.queryS("UPDATE ESTRUTURAS SET QUANTIDADE='" valorquantidade "' WHERE item like '" trim(parent) "%' AND componente like '" trim(partecodigo) "%';")
	}
	MsgBox, % itemscount " item(s) foram alterados!"
	Return
	
}

imprimir_estrutruas(){
	Global 

	checkeditems := GetCheckedRows2("massaestrut","estrutlv")
	if(!checkeditems["code"]){
		MsgBox, % "Selecione um item antes de continuar!"
		return 
	} 
	progress(checkeditems["code"].maxindex())
	for,each,item in checkeditems["code"]{
		tvstring := "",selected := checkeditems["code",A_Index] ">>" checkeditems["desc",A_Index]
		updateprogress("Imprimindo Estruturas: " selected,1)
		loadestrutura(selected,"")     ;RETORNA tvstring com todos os niveis!!
		StringSplit,numberofitems,tvstring,"`n"
		totalheight := numberofitems0*150
		tvstring := ""
		newgdi({w:850,h:totalheight})
		panel({x:0,y:0,w:900,h:totalheight,color: "white",boardcolor: "0x00000000"})
		panel({x:10,y:10,w:710,h:80,color:"nocolor",text:checkeditems["code",A_Index],textsize:70,boardsize: 0,textcolor: "000000"})
		y := -90
		printestrutura(selected,offset)
		IfnotExist,% A_WorkingDir "\Estruturas\" selected_in_tv
		{
			FileCreateDir,% A_WorkingDir "\Estruturas\" selected_in_tv
		} 
		savetofile(A_WorkingDir "\Estruturas\" selected_in_tv "\" checkeditems["code",A_Index] ".png")
		Gdip_DeleteGraphics(G),Gdip_DisposeImage(pBitmapFile)
	}
	Gui,progress:destroy
	MsgBox, % "Os arquivos foram salvos!!"
}

excluir_estruturas(){
	Global

	MsgBox, 4,,Deseja excluir todas as estruturas mascadas?
		IfMsgBox Yes
		{
			result:=GetCheckedRows("massaestrut","lv1")
			progress(result.maxindex())
			for,each,value in result{
				updateprogress("Excluindo estruturas: " result[A_Index,1],1)
				db.query("DELETE FROM ESTRUTURAS WHERE item like '" result[A_Index,1] "%';")  ; EXCLUIR TODAS AS ESTRUTURAS
			} 
		}else{
				return 
		}
		Gui,progress:destroy
		MsgBox,64,, % "As estruturas foram deletadas!!!"
}

excluir_item_estrutura(){
	Global
	
	Gui,treeview,tv2
	id:=TV_GetSelection()
	TV_GetText(item,id)
	parentid:=TV_GetParent(id)
	TV_GetText(element,parentid)
	MsgBox, 4,,Deseja apagar o item %item% da estrutura %element%?
	IfMsgBox Yes
	{
		db.query("DELETE FROM ESTRUTURAS WHERE item like '" element "%' AND componente like '" item "%';")
		TV_Delete(id)
		MsgBox,64,, % " O valor foi deletado!!"
	}else{
		return 
	}
}

exportar_estruturas(){
	Gui,exportestrutnew:New
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,add,button,w100 gexportarparaarquivo,Exportar Arquivo
	Gui,add,button,x+5 w100 gexportarparabanco,Exportar Banco
	Gui,Show,,Exportar Estruturas
}

add_massa(){
	Gui,addmassa:New
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,color,%GLOBAL_COLOR%
	Gui,addmassa:+ownerM
	Gui,add,edit,x415 gpesquisaraddmass w400 r1 vpesquisaraddmass uppercase,Pesquisar!!!
	Gui,add,treeview,xm y+5 w400 h300 vtvaddmass gtvaddmass,
	Gui,add,listview, x+5 w400 h300 vlvaddmass checked glvaddmass,Codigos|DR
	Gui,add,listview,x+5 w400 h300 vlvaddmass2,Codigos
	Gui,add,button,x420 y+5 w100 h30 gaddalista,Adicionar a lista!!
	Gui,add,button,x+300  w100 h30 gaddmassaestrut,Adicionar a estrutura!!
	GUi,add,button,x+5 wp hp gremovelist,Remover da Lista!!
	subitem := {}
	TvDefinition =
	(
		%GLOBAL_TVSTRING%
	)
	gui,treeview,tvaddmass
	TV_Delete()
	CreateTreeView(TvDefinition)
	Gui,Show,,Adicionar em massa!
}

add_quantidade_em_massa(){
	Global

	checkeditems := GetCheckedRows2("massaestrut","estrutlv")

	if(!checkeditems["code"]){
		MsgBox, % "Selecione pelo menos um item antes de continuar!"
		return 
	}
	inserir_dialogo_2_view("adicionar_em_massa", "massaestrut", 2, ["codigo compoenente", "quantidade"])
	;addquantidademassa(checkeditems)
}

adicionar_em_massa:
Gui, Submit, nohide
item := checkeditems["code", 1]
componente := input_name
quantidade := input_mascara
db.Estrutura.inserir_quantidade(item, componente, quantidade)
return

marc_todos(){
	Global
	
	gui,listview,lv1
	Loop, % LV_GetCount(){
		LV_Modify("","+check")
	}
}

descmarc_todos(){
	Global

	gui,listview,lv1
	Loop, % LV_GetCount(){
		LV_Modify("","-check")
	}
}

tv_add_mass(){
	Global

	maska := []
	Gui, Treeview, tvaddmass
	id := TV_GetSelection()
	MsgBox, % "ira iniciar o loop"
	Loop
	{
		TV_GetText(text,id)
		MsgBox, % "text" text
		if(A_Index = 1)
			selected2 := text
		if hashmask[text]!=""
			maska.insert(hashmask[text])
		MsgBox, % "hashmask" hashmask[text]
		id:=TV_GetParent(id)
		if !id 
			Break
	}
	newarray:=reversearray(maska)
	mask=
	for,each,value in newarray 
		mask.=value
	;MsgBox, % "valor " mask
	Listaddmass:=[]
	table:=db.query("SELECT Codigos,DR FROM  " mask "Codigo;")
	while(!table.EOF){  
        value1:=table["Codigos"],value2:=table["DR"]
        Listaddmass[A_Index,1]:=value1 
        Listaddmass[A_Index,2]:=value2
        table.MoveNext()
	}
	search.LV.set_searcheable_list(Listaddmass)
	db.loadlv("addmassa","lvaddmass",mask "Codigo","Codigos, Descricao Completa, Descricao Resumida, Descricao ingles", 1)
	return 
}

tv_strut(window, tv, lv){
	Global
	Local id, super_id, tv_level

	tv_level := get_tv_level(window, tv)
	info := get_item_info(window, "", tv, "", window)
	tabela1 := info.empresa[2] info.tipo[2] info.subfamilia[2] info.familia[1]

	if(tv_level = 3){
		model_table := db.get_reference("Modelo", tabela1)
		db.load_subitems_tv(get_tv_id(window, lv), model_table)
		return
	}	

	if(tv_level = 4 || tv_level = 5){
		
		if(info.subfamilia[2] != ""){
			tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[1]
			model_table := db.get_reference("Modelo", tabela1)
			db.load_subitems_tv(get_tv_id(window, lv), model_table)
			return
		}
		Gui, %window%:default
		Gui, Treeview, tv		
		id := TV_GetSelection()
		TV_GetText(selected_model, id)
		super_id := TV_GetParent(id)
		info := get_item_info(window, "", tv, super_id, window)
		code_table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] S_ETF_hashmask[selected_model] "Codigo"
		db.load_lv(window, lv, code_table, 1)
		search.LV.set_searcheable_list(db.load_table_in_array(code_table))
	}
}

estrut_lv(){
	Global db
	if A_GuiEvent = DoubleClick
	{
		codigo := GetSelected("massaestrut","lv1")
		db.load_estrut("massaestrut", "tv2", codigo)
	}
}

add_componente_marcado(){
	Global db

	checked_items := GetCheckedRows2("massaestrut","lv1")
	checked_componentes :=  GetCheckedRows2("massaestrut","lvaddmass")

	if(checked_items["code", 1] = ""){
		MsgBox, 16, Erro, % "Selecione pelo menos um item para inserir compoenentes" 
		return
	}

	if(checked_componentes["code", 1] = ""){
		MsgBox, 16, Erro, % "Selecione pelo menos um componente a ser inserido nas estruturas marcadas!"
		return 
	}

	for,each,value in checked_items["code"]{
		item := checked_items["code", A_Index]
		if(item = "")
			Continue
		for, each, value in checked_componentes["code"]{
			componente := checked_componentes["code", A_Index]
			if(componente = "")
				Continue
			db.Estrutura.inserir(item, componente)
		}
	}
	MsgBox, 64, Sucesso, % "Os items foram inseridos!" 
}

remove_strut(){
	Global

	checked_items := GetCheckedRows2("massaestrut","lv1")
	MsgBox, 4,, % "tem certeza que deseja excluir " checked_items.maxindex() " estrutura(s)."  
	IfMsgBox Yes
	{
		for, each, value in checked_items["code"]{
			item := checked_items["code", A_Index]
			db.Estrutura.remove_strut(item)
		}
		MsgBox, 64, Sucesso, % "todos os items foram deletados com sucesso!"
	}else{	
	}
}

remove_componente(item, componente){
	Global 

	if(item = ""){
		MsgBox, 16, Erro, % "Selecione um item a ser excluido!"
		return 
	}

	if(componente = ""){
		MsgBox, 16, Erro, % " Selecione um componente a ser excluido!" 
	}

	if(db.Estrutura.remove_componente(item, componente)){
		return true
	}else{
		return false
	}
}

export_strut(){
	Global db

	checked_items := GetCheckedRows2("massaestrut","estrutlv")
	
	if(checked_items["code", 1] = ""){
		MsgBox, % " Marque um item antes de exportar!"
		return
	}

	FileDelete, % "temp\export_strut.csv"
	for, each, value in checked_items["code"]{
		item := checked_items["code", A_Index]
		db.Estrutura.export_strut(item)
	}
	MsgBox, 64, Sucesso, % "Os items foram exportados!"
	run, % "temp\export_strut.csv"
}


			