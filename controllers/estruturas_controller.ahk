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

add_quantidade_massa(){
	Global

	checkeditems := GetCheckedRows2("massaestrut","estrutlv")
	if(!checkeditems["code"]){
		MsgBox, % "Selecione pelo menos um item antes de continuar!"
		return 
	}
	addquantidademassa(checkeditems)
}

rem_massa(){
	Global

	checkedremmassa:=GetCheckedRows2("massaestrut","estrutlv")
	if(checkedremmassa["code"]=""){
		MsgBox,64,, % "Marque os codigos das estruturas que deseja apagar items!!"
		return 
	}
	Gui,remmassa:New
	Gui,font,s%SMALL_FONT%,%FONT%
	;Gui,remmassa:+toolwindow
	Gui,color,%GLOBAL_COLOR%
	Gui,add,text,xm cred w250 ,codigo do item a ser removido:
	Gui,add,edit,xm y+5 w250 r1 vremedit uppercase
	Gui,add,button,xm y+5 w100 h30 gremmassabutton,Remover!!
	Gui,Show,,Remover em massa!!!
}

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