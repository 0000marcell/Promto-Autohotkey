#SingleInstance,force
#NoTrayIcon
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;##################################################
;#												  											#
;#			PROMTO(FRONT-END)(NATIVE)			  					#
;#												  											#
;##################################################

;##################################################
;#												  											#
;#				EMPRESAS						  									#
;#												  											#
;##################################################

/*
	Parametros de configuracao 
*/
$$ := JSON_load(A_WorkingDir "\settings.json")
jsonString := JSON_to($$)
settings := JSON_from(jsonString)
db_type := settings.db_type 
db_location := settings.db_location
TAB_COLOR := settings.tab_color
TAB_TEXT_SIZE := settings.tab_text_size
SMALL_FONT := settings.small_font 
MEDIUM_FONT := settings.medium_font 
LARGE_FONT := settings.large_font 
BUTTON_SIZE := settings.button_size 
if(BUTTON_SIZE = "small")
	button_h := 15
GLOBAL_COLOR := settings.global_color
BANNER_COLOR := settings.banner_color
TextOptions := "x0p y10 s" settings.banner_text_size " Center c" settings.banner_text_color " r4 Bold"
if(settings.banner_size = "small")
	banner_h := 20
if(settings.banner_size = "medium")
	banner_h := 50
if(settings.banner_size = "large")
	banner_h := 100 
Font := settings.font

/*
	Iniciando GDI
*/
If !pToken := Gdip_Startup()
{
    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
    ExitApp
}

/*
	Conectando no banco
*/
db := new PromtoSQL(
	(JOIN 
		db_type,
		db_location
	))
/*
	Resetando as 
	duas strings que quardao as 
	treeviews.
*/
GLOBAL_TVSTRING := ""
ETF_TVSTRING := ""
hashmask:={},field:=["Aba","Familia","Modelo"]
_reload_gettable := True

E:
/*
	Gui init
*/
Gui, initialize:New
Gui, Font, s%SMALL_FONT%, %FONT%
Gui, Color, %GLOBAL_COLOR%
Gui, Add, Picture, xm ym w300 h150,logotipos\logo.png

/*
	Localizacao
*/
Gui, Add, Groupbox, w300 h60 , Localizacao DB
Gui, Add, Edit, xp+25 yp+25 w250 vdb_location_to_save , %db_location%

/*
	Opcoes
*/
Gui, Add, Groupbox, xm y+25 w300 h60, Opcoes
Gui, Add, Button, xp+45 yp+20 w100 h30 gloading_main vloading_main Default,Iniciar
Gui, Add, Button, x+5 w100 h30 gedit_config_file vedit_config_file, Editar Configuracao
Gui, Show,,	Inicializacao 
Return

	edit_config_file:
	Return

	loading_main:
	Gui, initialize:default
	GuiControl, Disable, loading_main,
	GuiControl, Disable, edit_config_file
	Gui, Add, Text, xm y+10, Carregando...
	Gui, Add, Progress, xm y+5 vprogress  -Smooth 0x8 w300 h18
	Gui, Show, AutoSize, Carregando...
  SetTimer, undetermine_progress_action,45
  load_ETF(db)
  Gui, initialize:destroy
  Gosub, M
	Return 

		undetermine_progress_action:
		Gui, initialize:default
		GuiControl,, progress, 1
		Return
	
;	EA:
;	args := {}
;	args["closefunc"] := "refreshemp", args["table"] := "empresa",args["field"] := "Empresas,Mascara", args["owner"] := "E"
;	args["field1"] := "Empresas", args["field2"] := "Mascara", args["primarykey"] := "Empresas ASC,Mascara ASC"
;	args["tipo"] := "Aba", args["relcondition"] := true
;	inserir1(args)
;	return

;refreshemp(){
;	Gosub, E
;}




M:
/*
	Gui init	
*/
Gui, M:New
Gui, Font, s%SMALL_FONT%, %FONT%
Gui, Color, %GLOBAL_COLOR%

/*
	Familias
*/
Gui, Add, Groupbox, xm w230 h40,Pesquisa
Gui, Add, Edit, xp+5 yp+15 w220,

/*
	Empresas/Tipos/Familias
*/
Gui, Add, Groupbox, xm y+10 w230 h530,Empresas/Tipos/Familias
Gui, Add, TreeView, xp+5 yp+15 w220 h500 vmain_tv gmain_tv
load_main_tv()

/*
	Opcoes
*/
Gui, Add, Groupbox, xm y+20 w230 h60, Opcoes
Gui, Add, Button, xp+60 yp+15 w100 h30 ginsert_empresa, Criar Empresa 

/*
	Modelos 
*/
Gui, Add, Groupbox, xm+240 ym w220 h290, Modelos 
Gui, Add, Listview, xp+5 yp+15 w200 h270 section  vMODlv gMODlv altsubmit,Modelo|Mascara
Gui, Add, Groupbox, xm+240 y+10 w220 h60, Numero de items:
Gui, Font, s15
Gui, Add,	Text, xp+75 yp+15 w100 vnumberofitems cblue,
Gui, Font, s8

/*
	Opcoes
*/
Gui, Add, Groupbox, xm+240 y+20 w220 h300, Opcoes 
Gui, Add, Button, xp+5 yp+15 w100 h30 gMAM, Modelos
glabels:=["MAB","MAC","ordemprefix","MAOC","MAODC","MAODR","MAODI"]
for,each,value in ["Bloqueados","Campos","Ordem Prefix","Ordem Codigo","Ordem Desc Completa","Ordem Desc Resumida","Ordem Desc Ingles"]{
	glabel := glabels[A_Index]
	Gui, Add, Button, wp hp g%glabel%,% "&" value
}
Gui, Add, Button, x+5 y380 wp hp ggerarcodigos,Gerar Codigos
glabels := ["gerarestruturas","linkarm","dbex","massaestrut","codetable","plotcode"]
for,each,value in ["Gerar Estruturas","Linkar","Add db Externo","Estrutura","Lista de Codigos","Imprimir"]{
	glabel := glabels[A_Index]
	Gui, Add, Button, wp hp g%glabel%,% "&" value
}

/*
	Pesquisa
*/
Gui, Add, Groupbox, x480 ym w815 h50,Pesquisa
Gui, Font,s7
Gui, Add, Combobox, xp+5 yp+15 w695 vcombocodes gcombocodes,
Gui, Font, s8
Gui, Add, Button, x+5 gfotoindividual w100, Foto

/*
	Informacao 
*/
Gui, Add, Groupbox, x480 y+20 w815 h300, Informacao:
Gui, Add, Picture, xp+5 yp+15 w800 vptcode ,
_loading := 1
Gui, Show,W1300 h700 , %FamiliaName%
Gui, Listview, MODlv
LV_ModifyCol(2,300) 
LV_Modify(2, "+Select")
_loading := 0
return	

insert_empresa:
inserir_ETF_view("M", "main_tv", "", "Empresas")
return

MGuiContextMenu:
if A_GuiControl = main_tv
{
	/*
		verifica em que nivel a selecao esta
		caso esteja no nivel tres somente
		a opcao de remover aparecera
	*/
	tv_level_menu := get_tv_level("M", "main_tv") 
	
	Menu, main_tv_menu, Add, Adicionar, adicionar_item
	Menu, main_tv_menu, Add, Remover, remover_item	
	Menu, remover_menu, Add, Remover, remover_item


	/* 
		Pega a tabela onde serao inseridos 
		os valores
	*/
	TV_GetText(current_selected_name, A_EventInfo)
	current_id := A_EventInfo
	
	/*
		Caso a selecao esteja no nivel de insercao 
		de tipos
	*/
	if(tv_level_menu = 1){
		current_columns := "Abas"
	}

	/*
		Caso a insercao esteja no nivel 
		de familias
	*/
	if(tv_level_menu = 2){
		current_columns := "Familias"
		;parent_id := TV_GetParent(A_EventInfo)
		;TV_GetText(parent_name, parent_id)
		;empresa_mascara := ETF_hashmask[parent_name]
		;table_ETF := getreferencetable("Familia", empresa_mascara current_selected_name)
	}

	/*
		Case esteja no nivel das familias nao existe opcao de incluir
	*/
	if(tv_level_menu = 3){
		Menu, remover_menu, Show, x%A_GuiX% y%A_GuiY%	
	}Else{
		Menu, main_tv_menu, Show, x%A_GuiX% y%A_GuiY%	
	}
}
return

	adicionar_item:
	inserir_ETF_view("M", "main_tv", current_id, current_columns)
	return 

	remover_item:
	MsgBox, % "empresa nome " empresa.nome " empresa mascara " empresa.mascara
	;remover_item_ETF("M")
	return

	main_tv:
	
  /*
  	funcao que busca o nivel 
  	que a selecao esta
  */
  tv_level := get_tv_level("M", "main_tv")
  if(tv_level = 3){
  	/*
  		Se estiver no nivel das 
  		familias ira buscar a tabela de modelos
  		e carrega-la na listview ao lado. 
  	*/
  	
  	/*
  		Pega a tabela de modelos
  	*/	
		familia := get_tv_info("Familia")
		tipo := get_tv_info("Tipo")
		empresa := get_tv_info("Empresa")

		/*
			Metodo que peca a tabela de modelos 
			linkada
		*/
		model_table := db.get_reference("Modelo",empresa.mascara tipo.mascara familia.nome)
		
		/*
			Metodo que carrega a lista de modelos
			em determinada listview
		*/
		db.load_lv("M", "MODlv", model_table)
		LV_ModifyCol(1)	
  }
	return 

	fotoindividual:
	Gui,submit,nohide
	massainsertphoto(codtable) 
	return 

	combocodes:
	Gui,submit,nohide
	StringReplace,combocodes,combocodes,% ">>",|, All
	StringSplit,combocodes,combocodes,|
	result := db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" combocodes1 "'")
	comboimagepath := ""
	if(result["tabela2"] != ""){
		db.loadimage("","",result["tabela2"])
		comboimagepath := "image.png"
	}else{
		comboimagepath := "noimage.png"
	}
	result.close()
	;showimageandcode(comboimagepath, 10, 10, EmpresaMascara AbaMascara FamiliaMascara,ModeloMascara, combocodes1 "`n" combocodes2 ,20)
	Guicontrol,,ptcode,simpleplot.png
	return 

	MAODI:
	args:={}
	args["camptable"] := camptable, args["table"] := oditable, args["field"] := "Campos", args["comparar"] := true, args["owner"] := "M"
	alterarordem(args)
	return 

	plotcode:
	Gui,escolha_plotcode:New
	Gui,font,s%SMALL_FONT%,%FONT% 
	Gui,add,button,w100 gplotar_esse_item,Imprimir item marcado
	Gui,add,button,x+5 w100 gplotar_todos_os_items,Imprimir todos os items 
	Gui,add,button,xm y+5 w100 gplotar_todos_os_items_em_lista,Imprimir lista com todos os items 
	Gui,Show,,Imprimir Escolha
	return 

	plotar_todos_os_items_em_lista:
	items_to_plot := getvaluesLV("M","MODlv")
	plot_pt_code_list()
	return


	plotar_todos_os_items:
	items_to_plot := getvaluesLV("M","MODlv")
	progress(items_to_plot.maxindex())
	FileRemoveDir, % A_WorkingDir "\temp\" FamiliaName
	FileCreateDir, %  A_WorkingDir "\temp\" FamiliaName
	FileDelete,% A_WorkingDir "\temp\" FamiliaName "\semprefixo.csv"  
	_prefixos_em_falta := False
	for,each,item in items_to_plot{
		prefixpt2:=""
		result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" EmpresaMascara AbaMascara FamiliaMascara items_to_plot[A_Index,2] items_to_plot[A_Index,1] "'") 
		db.loadimage("","",result["tabela2"])
		result.close()
		for,each,value in list:=db.getvalues("Campos",EmpresaMascara AbaMascara FamiliaMascara items_to_plot[A_Index,2] "prefixo"){
			prefixpt2.=list[A_Index,1]	
		}
		if(prefixpt2 = ""){
			_prefixos_em_falta := True
			FileAppend, % EmpresaMascara AbaMascara FamiliaMascara items_to_plot[A_Index,2] "`n", % A_WorkingDir "\temp\" FamiliaName "\semprefixo.csv"
			continue
		}
		plotptcode(EmpresaMascara AbaMascara FamiliaMascara,prefixpt2,items_to_plot[A_Index,2],,900,6000)
		updateprogress("Imprimindo : " prefixpt2 modelpt,1)
	}
	if(_prefixos_em_falta = True)
		MsgBox,16,,"Alguns items nao foram gerados pois o prefixo do codigo ainda nao tinha sido definido !"
	Else
		MsgBox,64,,"Todos os items foram gerados e estao na pasta \temp\ !"
	gui,progress:destroy
	return

	plotar_esse_item:
	selecteditem:=GetSelected("M","MODlv")
	currentvalue:=GetSelectedRow("M","MODlv")
	selectmodel:=selecteditem
	result:=db.query("SELECT Mascara FROM " . modtable . " WHERE Modelos='" . selecteditem . "'")
	ModeloMascara:=result["Mascara"]
	prefixpt2:=""
	for,each,value in list:=db.getvalues("Campos",EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "prefixo"){
		prefixpt2.=list[A_Index,1]	
	} 
	StringReplace,prefixpt2,prefixpt2,% currentvalue[2],,All
	_showcode:=1
	MsgBox, % "currentvalue: " currentvalue[2] "  modelpt: " modelpt 
	plotptcode(EmpresaMascara AbaMascara FamiliaMascara,prefixpt2,currentvalue[2],1,900,6000)
	return 

MGuiSize:
GuiSize:
	UpdateScrollBars(A_Gui, A_GuiWidth, A_GuiHeight)
return

	codetable:
	Gui,codetable:New
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,codetable:+ownerM
	Gui,Add, Picture,w1000 h%banner_h% 0xE vbannercodetable
	banner(BANNER_COLOR,bannercodetable,"Lista de Codigos",TextOptions) 
	Gui,add,edit,vpesquisarcod gpesquisarcod w1000 r1 uppercase
	Gui,add,Listview,w1000 h500 xm y+5 vlvcodetable glvcodetable,
	Gui,add,button,y+5 w100 h30 gcarregartabela,Salvar em Arquivo
	Gui,add,button,x+5 w100 h30 ggerarplaquetas,Gerar Plaquetas
	Gui,Show,,Lista de Codigos
	Listpesqcod:=[]
	table:=db.query("SELECT Codigos,DC,DR,DI FROM " codtable ";")
	while(!table.EOF){  
        Listpesqcod[A_Index,1] := table["Codigos"] 
        Listpesqcod[A_Index,2] := table["DC"]
        Listpesqcod[A_Index,3] := table["DR"]
        Listpesqcod[A_Index,4] := table["DI"]
        table.MoveNext()
	}
	table.close()
	db.query("ALTER TABLE " codtable " ADD COLUMN DI TEXT;")
	db.loadlv("codetable","lvcodetable",codtable,"Codigos,DC,DR,DI",1)
	return  

		pesquisarcod:
		Gui,submit,nohide 
		for,each,value in PesqList{
			Break
		}
		pesquisalv4("codetable","lvcodetable",pesquisarcod,Listpesqcod)
		return  

		lvcodetable:
		if A_GuiEvent=DoubleClick
		{
			currentvalue:=GetSelectedRow("codetable","lvcodetable")
			tvstring:="",selecteditemtoloadestrut:=currentvalue[1] ">>" currentvalue[3]
			loadestrutura(selecteditemtoloadestrut,"",,0)
			tvwindow2(args)		
		}
		return 

		gerarplaquetas:
		createtag(EmpresaMascara AbaMascara FamiliaMascara,prefixpt2,ModeloMascara,selectmodel,EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "Codigo")
		return 

		carregartabela:
		FileDelete,temp.csv 
		for,each,value in list:=db.getvalues("Codigos,DC",codtable){ 
   			 FileAppend, % list[A_Index,1] ";" list[A_Index,2] "`n",temp.csv
		}
		Run,temp.csv		
		return 

	massaestrut:
	if(_reload_gettable = True ){    ; Variavel utilizada para saber se a tabela de formacao de estrutura precisa ser recaregada
		GLOBAL_TVSTRING := ""
		gettable("empresa",0,"","")
		_reload_gettable := False 
	}
	Gui,massaestrut:New
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,massaestrut:+ownerM
	Gui,color,%GLOBAL_COLOR%
	Gui,add,edit,x415 gpesquisarlv w400 r1 vpesquisarlv uppercase ,Pesquisar!!!
	Gui,add,treeview,xm y+5 w400 h300 vtv1 gtvstrut,
	Gui,add,listview, x+5 w400 h300 vlv1 checked gestrutlv,Codigos|DR
	Gui,add,treeview,x+5 w400 h300 vtv2, 
	Gui,add,button,xm w100 h30 gimprimirestrut,Imprimir Estruturas!!
	Gui,add,button,x+250  w100 h30 gaddmassa,Add em Massa
	Gui,add,button,x+5  w100 h30 gaddquantidademassa,Add Quantidade em Massa
	Gui,add,button,x+5 w100 h30 gremmassa,Remover em Massa 
	Gui,add,button,x+5 w100 h30 gmarctodos,Marc.Todos!
	Gui,add,button,x+5 w100 h30 gdesmarctodos,Des.Marc.Todos!
	Gui,add,button,x+5 w100 h30 gexcluirestrut,Excluir estrutura!
	Gui,add,button,x+5 w100 h30 gexcluiritemestrut,Excluir item!
	Gui,add,button,x+5 w100 h30 gexportarestrut,Exportar estruturas!! 
	TvDefinition =
	(
		%GLOBAL_TVSTRING%
	)
	gui, Treeview, tv1
	CreateTreeView(TvDefinition)
	Gui, Show,, Estruturas!!
	return

		addquantidademassa:
		checkeditems := GetCheckedRows2("massaestrut","estrutlv")
		if(!checkeditems["code"]){
			MsgBox, % "Selecione pelo menos um item antes de continuar!"
			return 
		}
		addquantidademassa(checkeditems)
		return 

	addquantidademassa(items){
		Global db,GLOBAL_COLOR
		Static valorquantidade,partecodigo,items1
		items1:=items
		Gui,addquantidademassa:New
		Gui,font,s%SMALL_FONT%,%FONT%
		Gui,color,%GLOBAL_COLOR%
		Gui,add,text,w300,Quantidade
		Gui,add,edit,xm y+5 w300 r1 vvalorquantidade uppercase,
		Gui,add,text,xm y+5 w300,Parte do codigo do item
		Gui,add,edit,y+5 w300 r1 vpartecodigo uppercase,
		Gui,add,button,xm y+5 w100 gsalvarquantidademassa default,Salvar
		Gui,show,,Adicionar Quantidade Em massa
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

		excluiritemestrut:
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
		return 

		imprimirestrut:
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
		return 

		exportarestrut:
		Gui,exportestrutnew:New
		Gui,font,s%SMALL_FONT%,%FONT%
		Gui,add,button,w100 gexportarparaarquivo,Exportar Arquivo
		Gui,add,button,x+5 w100 gexportarparabanco,Exportar Banco
		Gui,Show,,Exportar Estruturas
		return

		exportarparaarquivo:
		checkeditems:=GetCheckedRows2("massaestrut","estrutlv")
		filedelete,dadosestrutura.csv
		MsgBox, % checkeditems["code"].maxindex()
		FileAppend,% "G1_COD;G1_COMP;G1_QUANT;G1_INI;G1_FIM;G1_FIXVAR;G1_REVFIM;G1_NIV;G1_NIVINV`n",dadosestrutura.csv
		already_in_structure:=""
		filedelete,debug.txt
		filedelete,debug2.txt
		number_of_parents:=0
		for,each,value in checkeditems["code"]{
			fileappend,% "checkeditem: " checkeditems["code",A_Index] "`n",debug2.txt
			loadestruturatofile(checkeditems["code",A_Index] ">>" checkeditems["desc",A_Index])
		}
		run,dadosestrutura.csv
		Gui,progress:destroy
		MsgBox, % "As estruturas foram exportadas"
		return 

		exportarparabanco:
		gosub,configdbex
		Gui,exportarparadb:New
		Gui,font,s%SMALL_FONT%,%FONT%
		Gui,add,button,w100 gexportarparadb,Exportar para db
		Gui,Show,,Exportar Para DB
		return 

		exportarparadb:
		checkeditems:=GetCheckedRows2("massaestrut","estrutlv")
		rs:=sigaconnection.OpenRecordSet("SELECT TOP 1 G1_COD,G1_COMP,R_E_C_N_O_ FROM SG1010 ORDER BY R_E_C_N_O_ DESC")
		R_E_C_N_O_TBI:=rs["R_E_C_N_O_"]
		rs.close() 
		progress(checkeditems["code"].maxindex())
		prefixbloq:=""
		for,each,value in checkeditems["code"]{
			updateprogress("Incluindo Estruturas banco: " checkeditems["code",A_Index],1)
			loadestruturatodb(checkeditems["code",A_Index] ">>" checkeditems["desc",A_Index])
		}
		Gui,progress:destroy
		MsgBox, % "As estruturas foram exportadas"
		return  


		excluirestrut:
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
		return 

		marctodos:
		gui,listview,lv1
		Loop, % LV_GetCount(){
			LV_Modify("","+check")
		}
		return 

		desmarctodos:
		gui,listview,lv1
		Loop, % LV_GetCount(){
			LV_Modify("","-check")
		}
		return 

		estrutlv:
		if A_GuiEvent=DoubleClick
		{
			LV_GetText(selected,A_EventInfo)
			currentvalue:=GetSelectedRow("massaestrut","estrutlv")
			tvstring:="",selected:=currentvalue[1] ">>" currentvalue[2]
			loadestrutura(selected,"")
			TvDefinition=
			(
				%tvstring%
			)
			Gui,treeview,tv2
			TV_Delete()
			CreateTreeView(TvDefinition)
		}
		return 

		tvstrut:
		;O hashmask e formado no gettable.
		maska := []
		gui,treeview,tv1
		id := TV_GetSelection()
		TV_GetText(selected_in_tv,id)  
		Loop
		{
			TV_GetText(text,id)
			if(A_Index=1)
				selected2 := text
			if hashmask[text] != ""
				maska.insert(hashmask[text])
				
			id:=TV_GetParent(id)
			if !id 
				Break
		}
		newarray := reversearray(maska)
		mask =
		for,each,value in newarray 
			mask .= value
		Listestrut := []
		table := db.query("SELECT Codigos,DR FROM  " mask "Codigo;")
		while(!table.EOF){  
      value1 := table["Codigos"],value2:=table["DR"]
      Listestrut[A_Index,1] := value1 
      Listestrut[A_Index,2] := value2
      table.MoveNext()
		}
		table.close()
		db.loadlv("massaestrut","lv1",mask "Codigo","Codigos,DR",1)
		return 

		pesquisarlv:
		Gui,submit,nohide
		any_word_search("massaestrut","lv1",pesquisarlv,Listestrut)
		return 

		addmassa:
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
		TvDefinition=
		(
			%GLOBAL_TVSTRING%
		)
		gui,treeview,tvaddmass
		TV_Delete()
		CreateTreeView(TvDefinition)
		Gui,Show,,Adicionar em massa!!!
		return 

			addmassaestrut:
			checkeditems := GetCheckedRows2("massaestrut","estrutlv")
			if(!checkeditems["code"].maxindex()){
				MsgBox,64,, % "Selecione items onde serao incluidos os codigos antes de continuar!!!"
				return 
			}
			itemstoinsert:=getvaluesLV("addmassa","lvaddmassa2")
			progress(checkeditems.maxindex())
			for,each,element in checkeditems["code"]{
				element:=checkeditems["code",A_Index] ">>" checkeditems["desc",A_Index]
 				updateprogress("inserindo nas estruturas: " element,1)
				for,each,item in itemstoinsert{
					if(element=itemstoinsert[A_Index,1]){
						MsgBox, % "Um item nao pode ser inserido dentro dele mesmo na estrutura!"
						continue 
					}
					if(!db.exist("item,componente","item like '" element "%' AND componente like '" itemstoinsert[A_Index,1] "%'","ESTRUTURAS"))
						db.query("INSERT INTO ESTRUTURAS (item,componente,QUANTIDADE) VALUES ('" element "','" itemstoinsert[A_Index,1] "','1');")
					else
						MsgBox, % "o item " itemstoinsert[A_Index,1] "ja existe nas estruturas!!"
				} 
			}
			Gui,progress:destroy
			MsgBox,64,, % "os valores foram inseridos!!!"
			return 

			removelist:
			selecteditem:=GetSelected("addmassa","lvaddmass2","number")
			Gui,listview,lvaddmass2
			LV_Delete(selecteditem)
			return 

			addalista:
			Gui,submit,nohide
			result:=GetCheckedRows2("addmassa","lvaddmass")
			gui,listview,lvaddmass2
			for,each,value in result["code"]{
				LV_Add("",result["code",A_Index] ">>" result["desc",A_Index])
			}
			return 


			lvaddmass:
			return 

			tvaddmass:
			maska := []
			gui,treeview,tvaddmass
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
			;MsgBox, % mask "Codigo"
			db.loadlv("addmassa","lvaddmass",mask "Codigo","Codigos,DR", 1)
			return 

			pesquisaraddmass:
			Gui,submit,nohide
			any_word_search("addmassa","lvaddmass",pesquisaraddmass,Listaddmass)
			return 


		remmassa:
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
		return 

			remmassabutton:
			Gui,submit,nohide 	
			count:=0
			for,each,value in checkedremmassa["code"]{
				count++
				table:=db.iquery("SELECT item,componente FROM ESTRUTURAS WHERE item LIKE '" checkedremmassa["code",A_Index] "%' AND componente LIKE '" remedit "%';")
				if(table.Rows.Count()=0){
					MsgBox, % "O item a ser deletado nao existia na estrutura: " checkedremmassa["code",A_Index] 
					count-=1
				}
				db.query(db.query("DELETE FROM ESTRUTURAS WHERE item like '" checkedremmassa["code",A_Index] "%' AND componente like '" remedit "%';"))
			}
			if(count=0){
				MsgBox, % "Nenhum item foi removido"
			}else{
				MsgBox,64,, % "o item " remedit " foi removido de " count " estruturas!!!"
			}
			return

	ordemprefix:
	args:={}
	tablename:=EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "prefixo"
	args["table"]:=tablename,args["field"]:="Campos",args["comparar"]:=false ,args["owner"]:="M"
	db.query("create table if not exists " tablename "(Campos,PRIMARY KEY(Campos ASC))")
	For,each,value in [EmpresaMascara,AbaMascara,FamiliaMascara,ModeloMascara]{
		if(!db.exist("Campos","Campos='" value "'",tablename))&&(value!="")
			db.insert(tablename,"(Campos)","('" value "')")
	}
	alterarordem(args)
	return 

	dbex:
	Gui,dbex:new
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui, color, %GLOBAL_COLOR%
	Gui, Add, Picture, w900 h50 0xE vbanner 
	banner(BANNER_COLOR, banner, "DB externo")
	Gui, dbex:+ownerM
	Gui, add, edit, w900 r1  vpesquisadbex gpesquisadbex uppercase,
	Gui, add, listview, w900 h400 y+5 checked vlvdbex,
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
	table := db.query("SELECT Codigos,DC,DR FROM  " codtable ";")
	while(!table.EOF){  
        value1 := table["Codigos"],value2:=table["DC"],value3:=table["DR"]
        %value1% := {}
		Listdbex[A_Index,1] := value1
        Listdbex[A_Index,2] := value2
        Listdbex[A_Index,3] := value3
        table.MoveNext()
	}
	table.close
	db.loadlv("dbex", "lvdbex", codtable,"Codigos,DC,DR", 1)
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
		Gui,add,ListView,w200 h300 vchoosedb
		Gui,add,button,y+5 w100 gconectar,Conectar 
		Gui,add,button,x+5 w100 gnovaconexao ,Nova Conexao 
		Gui,add,button,x+5 w100 gdeletarconexao ,Deletar Conexao
		Gui,Show
		db.loadlv("configdbex","choosedb","connections","name")
		return 

			conectar:
			selecteditem:=getselecteditems("configdbex","choosedb")
			connectionvalue:=db.query("SELECT name,connection,type FROM connections WHERE name LIKE '" selecteditem[1] "%';")
			if(connectionvalue["connection"]=""){
				MsgBox, % "Nao existe conxao para esse nome tente adicionar outra conexao."
				return 
			}
			ddDatabaseConnection:= connectionvalue["connection"]
			ddDatabaseType:= connectionvalue["type"]
			;MsgBox, % "ddDatabaseConnection " ddDatabaseConnection "`n ddDatabaseType " ddDatabaseType  
			FileAppend, ddDatabaseConnection ";" ddDatabaseType,conection.csv
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

		loadvaltables(){
			Global
			NCM:={},UM:={},ORIGEM:={},TCONTA:={},TIPO:={},GRUPO:={},IPI:={},LOCPAD:={}
			for,each,value in ["NCM","UM","ORIGEM","TCONTA","TIPO","GRUPO","IPI","LOCPAD"]{
			    table:=db.query("SELECT valor,descricao FROM " value ";")
			    while(!table.EOF){
			        %value%["valor",A_Index]:=table["valor"]
			        %value%["descricao",A_Index]:=table["descricao"]
			        table.MoveNext()
			    }
			    table.close
			}
		}
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

			loadlv(hash){
				Global Listiv
				Gui,inserirval:default
				Gui,listview,lviv2
				LV_Delete()
				Listiv:=[]
				for,each,value in %hash%["valor"]{
					Listiv[A_Index,1]:=%hash%["valor",A_Index]
					Listiv[A_Index,2]:=%hash%["descricao",A_Index]
					LV_Add("",%hash%["valor",A_Index],%hash%["descricao",A_Index])
				}
				lv_modifycol(1,200)
			}

	pesquisalvmod(wname,lvname,string,List){    ;funcao de pesquisa na listview modificada!!!!
		Global 

		Gui,%wname%:default
	    Gui,listview,%lvname%
	    GuiControl, -Redraw,%lvname%
	    Gui, Submit, NoHide
	    resultsearch:=[] 
	    If (string=""){ 
	        LV_Delete()
			for,each,value in List{
	        	codname:=List[A_Index,1]
	            LV_Add("",List[A_Index,1],List[A_Index,2],List[A_Index,3],%codname%["NCM"],%codname%["UM"],%codname%["ORIGEM"],%codname%["TCONTA"],%codname%["TIPO"],%codname%["GRUPO"],%codname%["IPI"],%codname%["LOCPAD"])
	        }    
	    }Else{
	        for,each,value in List{
	            i++
	            string2:=List[A_Index,1] List[A_Index,2]
	            IfInString,string2,%string%
	            {
	                resultsearch.insert(i)
	            }
	        }
	        i:=0
	        LV_Delete()
	        for,each,value in resultsearch{
	        	codname:=List[value,1]
	            LV_Add("",List[value,1],List[value,2],List[A_Index,3],%codname%["NCM"],%codname%["UM"],%codname%["ORIGEM"],%codname%["TCONTA"],%codname%["TIPO"],%codname%["GRUPO"],%codname%["IPI"])
	        }
	    }
	    GuiControl, +Redraw,%lvname%
	    LV_Modify(1, "+Select")
	}
	return 
	
	
	return 

CODlv:
if A_GuiEvent=DoubleClick
{
	LV_GetText(selected,A_EventInfo)
	tvstring:=""
	loadestrutura(selected,"")
	tvwindow2(args)
}
return 


tvwindow2(args){
	Global tvstring,db,GLOBAL_COLOR
	Static tv2,itemtext,parenttext,itemid
	Gui,tv2:New
	Gui,font,s%SMALL_FONT%,%FONT%
	;Gui,tv2:+toolwindow
	Gui,color,%GLOBAL_COLOR%
	Gui,add,treeview,w1200 h500 vtv2,
	Gui,add,button,x100 y+5 w100 h40 gtv2action disabled ,Remover
	gui,show,,Estrutura 
	TvDefinition=
	(
		%tvstring%
	)
	CreateTreeView(TvDefinition)
	return 

	tv2GuiContextMenu: 
	TV_GetText(itemtext,A_EventInfo)
	itemid:=A_EventInfo
	TV_GetText(parenttext,TV_GetParent(A_EventInfo))
	if A_GuiControl <> tv2  ; This check is optional. It displays the menu only for clicks inside the TreeView.
		return
	Menu, MyMenu, Add,Add Quantidade,addquantidade
	Menu, MyMenu, Add,Add Preco,addpreco
	Menu, MyMenu,Show, %A_GuiX%, %A_GuiY%
	return 

		addquantidade:
		if(parenttext=""){
			MsgBox,16,, % "Voce nao pode mudar a quantidade desse item!"
			return 
		}
		addquantidade(itemtext,parenttext,itemid)
		return 



		addpreco:
		Gui,add,text,w300,Quantidade
		Gui,add,edit,y+5 w300 r1 uppercase,
		Gui,add,button,xm y+5 w100 gsalvarquantidade ,Salvar
		return 

	tv2action:
	button:=A_GuiControl
	Gui,treeview,tv2
	if(button="Remover"){
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
	return 
}

addquantidade(itemtext,parenttext,itemid){
	Global db,selecteditemtoloadestrut,tvstring
	Static valorquantidade,itemtext1,parenttext1,itemid1
	itemid1:=itemid
	itemtext1:=itemtext,parenttext1:=parenttext
	Gui,addquantidade:New
	Gui,font,s%SMALL_FONT%,%FONT%
	Gui,color,%GLOBAL_COLOR%
	Gui,add,text,w300,Quantidade
	Gui,add,edit,y+5 w300 r1 vvalorquantidade uppercase,
	Gui,add,button,xm y+5 w100 gsalvarquantidade default,Salvar
	Gui,show,,Adicionar Quantidade
	return 

		salvarquantidade:
		Gui,submit,nohide
		loop,parse,parenttext1,|
		{
			if(A_Index=1)
				parenttext11:=A_LoopField
		}
		loop,parse,itemtext1,|
		{
			if(A_Index=1)
				itemtext11:=A_LoopField
		}
		db.queryS("UPDATE ESTRUTURAS SET QUANTIDADE='" valorquantidade "' WHERE item like '" trim(parenttext11) "%' AND componente like '" trim(itemtext11) "%';")
		MsgBox,64,, % " A quantidade foi atualizada!"
		Gui,tv2:default
		Gui,TreeView,tv2
		TV_Modify(itemid1,"",trim(itemtext11) "|UN:" valorquantidade)
		tvstring:=""
		gui,addquantidade:destroy
		return 
}

loadestrutura(item,nivel,ownercode="",semUN=1,quantidade=""){
	Global db,tvstring
	if item =
		return
	nivel.="`t"
	table:=db.query("SELECT item,componente,QUANTIDADE FROM ESTRUTURAS WHERE item='" . item . "'")
	if (table["componente"]=""){
		if(ownercode!=""){
		 	IfNotInString,%ownercode%,%item%
		 	{
		 		%ownercode%.="`n" item
		 		if(semUN=1)
		 			tvstring.="`n" . nivel . item
		 		else 
		 			tvstring.="`n" . nivel . item . "|UN:" quantidade
		 	}
		}else{
			IfNotInString,maincodes,%item%
		 	{
				maincodes.="`n" item
				if(semUN=1)
					tvstring.="`n" . nivel . item
				else 
					tvstring.="`n" . nivel . item . "|UN:" quantidade
		 	}
		}
	 }
	while(!table.EOF){
		tableitem:=table["item"]	
		if(ownercode!=""){
			IfNotInString,%ownercode%,%tableitem%
			{
				%ownercode%.="`n" table["item"]
				if(semUN=1)
					tvstring.="`n" . nivel . table["item"]
				else 
				 	tvstring.="`n" . nivel . table["item"] . "|UN:" quantidade
			}
		}else{
			IfNotInString,maincodes,%tableitem%
		 	{
				maincodes.="`n" tableitem
				if(semUN=1)
					tvstring.="`n" . nivel . table["item"]
				Else
					tvstring.="`n" . nivel . table["item"] . "|UN:1" 
		 	}
		}
		StringReplace,parseditem,tableitem,>>,|,All
		StringSplit,parseditem,parseditem,|
		StringReplace,parseditem1,parseditem1,%A_Space%,,All
		loadestrutura(table["componente"],nivel,parseditem1,semUN,table["QUANTIDADE"])
		table.MoveNext()
	}
}

loadestruturatofile(item){
	Global db,already_in_structure,number_of_parents
	if item =
		return
	table:=db.query("SELECT item,componente,QUANTIDADE FROM ESTRUTURAS WHERE item='" item "'")
	subitems:=object()
	while(!table.EOF){
		itemtbi:=table["item"],componentetbi:=table["componente"]
		StringReplace,itemtbi,itemtbi,% ">>",|, All
		StringSplit,itemtbi,itemtbi,|
		StringReplace,componentetbi,componentetbi,% ">>",|, All
		StringSplit,componentetbi,componentetbi,|
		StringLeft,testprefix,componentetbi1,3
		if(testprefix="mpt")
			StringReplace,componentetbi1,componentetbi1,MPT,MP, All    ;SUBSTITUI O MPT POR MP
		if(testprefix="mod")
			StringReplace,componentetbi1,componentetbi1,MODT,MOD, All    ;SUBSTITUI O MODT POR MOD
		StringLeft,testprefix,itemtbi1,3
		if(testprefix="mpt")
			StringReplace,itemtbi1,itemtbi1,MPT,MP, All    ;SUBSTITUI O MPT POR MP
		if(testprefix="mod")
			StringReplace,itemtbi1,itemtbi1,MODT,MOD, All    ;SUBSTITUI O MODT POR MOD
		if(testprefix="TL0"){
			number_of_parents++
			FileAppend, % number_of_parents " item " itemtbi1 "`n" ,debug.txt
		}
		IfNotInString,already_in_structure,%itemtbi1%;%componentetbi1%
		{
			if(testprefix="TL0"){
				FileAppend, % ">>>>>>>>> Nao existia na estrutura `n",debug.txt
			}
			FileAppend,% itemtbi1 ";" componentetbi1 ";" table["QUANTIDADE"] ";31/12/2006;31/12/2049;V;ZZZZ;01;99" "`n",dadosestrutura.csv
		}
		already_in_structure.=itemtbi1 ";" componentetbi1 "`n"
		subitems.insert(table["componente"])
		table.MoveNext()
	}
	table.close()	
	for,each,value in subitems{
		loadestruturatofile(value)
	}
}

loadestruturatodb(item){
	Global db,sigaconnection,R_E_C_N_O_TBI
	if item =
		return
	table:=db.query("SELECT item,componente,QUANTIDADE FROM ESTRUTURAS WHERE item='" item "'")
	subitems:=object()
	while(!table.EOF){
		itemtbi:=table["item"],componentetbi:=table["componente"]
		StringLeft,testprefix,componentetbi,3
		if(testprefix="mpt")
			StringReplace,componentetbi,componentetbi,MPT,MP, All    ;SUBSTITUI O MPT POR MP
		if(testprefix="mod")
			StringReplace,componentetbi,componentetbi,MODT,MOD, All    ;SUBSTITUI O MODT POR MOD
		StringLeft,testprefix,itemtbi,3
		if(testprefix="mpt")
			StringReplace,itemtbi,itemtbi,MPT,MP, All    ;SUBSTITUI O MPT POR MP
		if(testprefix="mod")
			StringReplace,itemtbi,itemtbi,MODT,MOD, All    ;SUBSTITUI O MODT POR MOD
		StringReplace,itemtbi,itemtbi,% ">>",|, All
		StringSplit,itemtbi,itemtbi,|
		StringReplace,componentetbi,componentetbi,% ">>",|, All
		StringSplit,componentetbi,componentetbi,|
		FileAppend, % "Select G1_COD from SG1010 WHERE G1_COD LIKE '" itemtbi1 "%' AND G1_COMP LIKE '" componentetbi1 "%'" "`n",debug.txt
		exist:=existindb(sigaconnection,"Select G1_COD from SG1010 WHERE G1_COD LIKE '" itemtbi1 "%' AND G1_COMP LIKE '" componentetbi1 "%'")
		if(exist=true){ 
			sql:=
			(JOIN
				"UPDATE SG1010 SET G1_COD='" itemtbi1 
				"',G1_COMP='" componentetbi1
				"',G1_QUANT='" table["QUANTIDADE"] 
				"',G1_INI='20060101" 
				"',G1_FIM='20491231"
				"',G1_FIXVAR='V"
				"',G1_REVFIM='ZZZ"
				"',G1_NIV='01"   
				"',G1_NIVINV='99"
				"',G1_FILIAL='01" 
				"',D_E_L_E_T_='"
				"' WHERE G1_COD='" itemtbi1 "' AND G1_COMP='" componentetbi1 "'"
			)
			FileAppend,% sql "`n",debug.txt
			sigaconnection.query(sql)
		}else{
			R_E_C_N_O_TBI++
			sql:=
			(JOIN
				"INSERT INTO SG1010 (G1_COD,G1_COMP,G1_QUANT,G1_INI,G1_FIM,G1_FIXVAR,G1_REVFIM,G1_NIV,R_E_C_N_O_,G1_FILIAL,D_E_L_E_T_,G1_NIVINV)" 
				" VALUES ('" itemtbi1
				"','" componentetbi1
				"','" table["QUANTIDADE"]
				"','20060101" 
				"','20491231"
				"','V"
				"','ZZZ"
				"','01"
				"','" R_E_C_N_O_TBI
				"','01"
				"','" 
				"','99')"
			)
			FileAppend,% sql "`n",debug.txt
			sigaconnection.query(sql)
		}
		FileAppend,% "Select B1_COD from SB1010 WHERE B1_COD LIKE '" itemtbi1 "%'" "`n",debug.txt
		exist:=existindb(sigaconnection,"Select B1_COD from SB1010 WHERE B1_COD LIKE '" itemtbi1 "%'")
		if(exist=false){
			FileAppend, % itemtbi1 "`n",missingitems.csv
		}
		FileAppend,% "Select B1_COD from SB1010 WHERE B1_COD LIKE '" componentetbi1 "%'" "`n",debug.txt
		exist:=existindb(sigaconnection,"Select B1_COD from SB1010 WHERE B1_COD LIKE '" componentetbi1 "%'")
		if(exist=false){
			FileAppend, % componentetbi1 "`n",missingitems.csv
		}
		subitems.insert(table["componente"])
		table.MoveNext()
	}
	table.close()	
	for,each,value in subitems{
		loadestruturatodb(value)
	}
}

exist_in_db(connection,sql){  ;connection fora da classe sql 
	tableexist := connection.Query(sql)
	columnCount := tableexist.Columns.Count()
	for each,row in tableexist.Rows{
		Loop, % columnCount{
			if(row[A_index]!=""){
				returnvalue:=True
				Break
			}else{
				returnvalue:=False
				Break
			}
		}
	}
	tableexist.close()
	return returnvalue
}




gerarestruturas:
if(_reload_gettable = True ){    ; Variavel utilizada para saber se a tabela de formacao de estrutura precisa ser recaregada
		GLOBAL_TVSTRING := ""
		gettable("empresa",0,"","")
		_reload_gettable := False 
}
db.createtable("ESTRUTURAS","(item,componente)") 
args := {},hashmask := {},subitem := {}
args["table"]:="empresa",args["loadfunc"]:="gettable",args["mascaraant"]:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara,args["savetvfunc"]:="savetvfunc1"
field:=["Aba","Familia","Modelo"],args["owner"]:="M"
tvstring := ""
tvwindow(args)
return 

tvwindow(args){
	Global tvstring,selectmodel,hashmask,subitem,GLOBAL_COLOR,GLOBAL_TVSTRING
	Static args1
	
	args1:=args 
	Gui,tvwindow:New
	Gui,font,s%SMALL_FONT%,%FONT%
	owner:=args["owner"]
	if(owner!="")
		Gui,tvwindow:+owner%owner%
	;Gui,tvwindow:+toolwindow
	Gui,color,%GLOBAL_COLOR%
	Gui, Add, GroupBox, x2 y0 w490 h550 , Gerar Estrutura
	Gui, Add, GroupBox, x12 y20 w470 h430 , TreeView
	Gui, Add, GroupBox, x12 y450 w470 h90 , Opcoes
	Gui, Add, TreeView, x22 y40 w450 h400 gtvest , 
	Gui, Add, Button, x272 y480 w100 h30 gsalvartv , Salvar
	Gui, Add, Button, x372 y480 w100 h30 gcancelartv, Cancelar
	;table:=args["table"]
	;loadfunc:=args.loadfunc,%loadfunc%(table,0,"","")
	TvDefinition=
	(
		%GLOBAL_TVSTRING%
	)
	CreateTreeView(TvDefinition)
	Gui, Show, w501 h559,Gerar Estruturas!	
	return

		salvartv:
		maska:=[]
		id:=TV_GetSelection()
		Loop
		{
			TV_GetText(text,id)
			if(A_Index=1)
				selected2:=text
			if hashmask[text]!=""
				maska.insert(hashmask[text])
			MsgBox, % "text do hashmask " text
			MsgBox, % "hashmask " hashmask[text]
			id:=TV_GetParent(id)
			if !id 
				Break
		}
		for,each,value in maska{
			MsgBox, % "value in maska " value
		}
		newarray := reversearray(maska)
		mask=
		for,each,value in newarray{
			MsgBox, % "values in the new array " value
			mask.=value
		} 
		scmodel:=args1["mascaraant"] . selectmodel
		MsgBox, % "mask " mask " selected2 " selected2
		dtmodel:=mask . selected2
		MsgBox, % "scmodel " scmodel " dtmodel " dtmodel 
		args1["selected1"]:=selectmodel,args1["selected2"]:=selected2
		savetvfunc:=args1["savetvfunc"],%savetvfunc%(scmodel,dtmodel,args1["mascaraant"],mask,args1)
		return 

		cancelartv:

		return 

	GuiClose:
	ExitApp
}

savetvfunc1(scmodel,dtmodel,mask1,mask2,args1){  ;Monta as Estruturas!!
	Global
	relationalhash:={} ;hash que faz a referencia entre o codigo e a descricao
	loadtabledcdt(scmodel,dtmodel)
	args["mascara1"]:=mask1
	args["mascara2"]:=mask2
	args["model1"]:=args1["selected1"]
	args["model2"]:=args1["selected2"]
	CHA1:={},CHA2:={},camposrel:=[]
	for,each,value in args["codigo1"]{
		%value%:={}
	}
	for,each,value in args["codigo2"]{
		%value%:={}
	}
	loadtablesge(args)
	progress(args["codigo1"])
	campo:=[]
	for,each,value in camposrel{
		campo.insert(value)
	}
	for,each,codigo in args["codigo1"]{
		i:=1,_ended:=0,relacionados:=args["codigo2"]
		gerarestruturas(codigo,args["codigo2"])
		for,each,value in finalreturn{
			db.query("DELETE FROM ESTRUTURAS WHERE item='" "='" finalreturn[A_Index,1] " AND componente='" finalreturn[A_Index,2] "';")
			updateprogress("Gerando Estruturas:`n" . finalreturn[A_Index,1],1)
			if(finalreturn[A_Index,1]=finalreturn[A_Index,2]){
				MsgBox, % " O codigo do item nao pode ser igual ao do pai!"
				continue
			}
			db.insert("ESTRUTURAS","(item,componente)","('" finalreturn[A_Index,1] ">>" relationalhash[finalreturn[A_Index,1]] "','" finalreturn[A_Index,2] ">>" relationalhash[finalreturn[A_Index,2]] "')")
		}
	}
	Gui,progress:destroy
	MsgBox,64,, % "Estrutura gerada com sucesso."
	loaditem()
	return
}

loadtabledcdt(scmodel,dtmodel){     ;carrega as tabelas dos dois modelos que serao comparados.
	Global db,args,relationalhash
	args:={}
	x:=[scmodel,dtmodel],y:=["codigo1","codigo2"],ocs:=["oc1","oc2"],camps:=["campo1","campo2"],i:=0
		for,each,table in x {
			i++
			result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='Codigo' AND tabela1='" . table . "'")
			For each in list:=db.getvalues("Codigos,DR",result["tabela2"]){
				relationalhash[list[A_Index,1]]:=list[A_Index,2]
				args[y[i],A_Index]:=list[A_Index,1] 
			}
			result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='oc' AND tabela1='" . table . "'")
			For each in list:=db.getvalues("Campos",result["tabela2"]){
				args[ocs[i],A_Index]:=list[A_Index,1]
			}
			result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='Campo' AND tabela1='" . table . "'")
			For each in list:=db.getvalues("Campos",result["tabela2"]){
				args[camps[i],A_Index]:=list[A_Index,1]
			}
			For each,campname in args[camps[i]]{
				StringReplace,campname,campname,%A_Space%,,All
				result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='" . campname . "' AND tabela1='" . table . "'")
				For each in list:=db.getvalues("Codigo",result["tabela2"]){
					args[campname . i,A_Index]:=list[A_Index,1]
				}
			}
	}
}

loadtablesge(args){        ;extrai os valores das tabelas no formato necessario para gerar as estruturas.
	Global
	tables:=["campo1","campo2"],cha:=["CHA1","CHA2"],i:=0
	MsgBox,64,, % args["campo1"].maxindex() 
	progress(args["campo1"].maxindex()+args["campo2"].maxindex())
	for,each,table1 in tables {
		i++
		chav:=cha[A_Index]
		for,each,value in args[table1]{
			updateprogress("Carregando tabelas:`n" . value,1)
			if(ObjHasValue(args["campo2"],value)) && (table1!="campo2"){
				camposrel.insert(value)
			}
			StringReplace,campname,value,%A_Space%,,All
			if(args[campname . i,1]) && (args[campname . i,1]!=""){
				%chav%[campname] := StrLen(args[campname . i,1])
			}Else{
				%chav%[campname] := StrLen(args[campname . i])
			}
		}
	}
	codtables:=["codigo1","codigo2"],mascaras:=["mascara1","mascara2"],i:=0
	for,each,codtable in codtables{
		i+=1
		if(codtable="codigo1")
			oc:="oc1"
		Else
			oc:="oc2"
		for,each,codigo1 in args[codtable]{
			StringTrimleft,codigo,codigo1,StrLen(args[mascaras[i]])
			for,each2,value2 in camposrel{
				StringReplace,value2,value2,%A_Space%,,All
				args["trimfield"]:=value2
				%codigo1%[value2]:=trimcode(args,codigo,cha[i],oc)   ;me retorna a lista de valores relacionados ao codigo e ao campo
			}
		}
	}
	gui,progress:destroy
}

trimcode(args,codigo,cha,oc){
	Global CHA1,CHA2,camposrel
		for,each,campo in args[oc]{
			StringReplace,campo,campo,%A_Space%,,All
			if(campo=args["trimfield"]){
				Stringleft,codigo,codigo,%cha%[campo]
				Break
			}Else{
				StringTrimleft,codigo,codigo,%cha%[campo]
			}		
		}
	returnvalue:=getreferencefield(args["trimfield"],codigo,args["model2"])   ;funcao que pega os valores na tabela de referencia.
	returnvalue.insert(codigo)
	;returnvalue:=[codigo]
	return returnvalue
}

getreferencefield(nomecamp,selectcode,selectmodel){
	Global db 
	referencias:=[]
	StringReplace,selectmodel,selectmodel,`.,,All
	for,each,value in list:=db.getvalues("Referencia",nomecamp . selectcode . selectmodel){
		referencias.insert(list[A_Index,1])
	}
	return referencias
}

gerarestruturas(codigo1,prox){
	Global relacionados,i,campo,finalreturn,_ended 
	if(campo[i])
		prox:=[]
	camp00:=campo[i]
	StringReplace,camp00,camp00,%A_Space%,,All
	For,each,value in %codigo1%[camp00]{
		if(value!=""){
			For,each2,value2 in relacionados{
				if(ObjHasValue(%value2%[camp00],value)){
					prox.insert(value2)
				}
			}
		}
	}
	i++
	if(campo[i]!=""){
		for,each,value in prox{ 
			relacionados:=prox,gerarestruturas(codigo1,prox)
		}
	}else{
		if(!_ended){
			finalreturn:=[]
			relacionados:=prox
			for,each,value in relacionados{
				finalreturn[A_Index,1]:=codigo1
				finalreturn[A_Index,2]:=value
			}
			_ended:=1
		}
	}
}

tvest:
TV_GetText(selectedsubitem,A_EventInfo)
subitem[selectedsubitem]:=A_EventInfo
return 

gettable(table,x,nivel,masc){
	Global db,GLOBAL_TVSTRING,field,hashmask
	x+=1,nivel.="`t"
	For each in list:=db.getvalues("*",table){
		GLOBAL_TVSTRING.="`n" . nivel . list[A_Index,1]
		hashmask[list[A_Index,1]] := list[A_Index,2]
		;MsgBox, % "valor do hashmask " hashmask[list[A_Index,1]] "`n para o valor " list[A_Index,1] 
		result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='" . field[x] . "' AND tabela1='" . masc . list[A_Index,1] . "'")
		newtable:=result["tabela2"]
		result.close()
		if(newtable)
			gettable(newtable,x,nivel,masc . list[A_Index,2])
	}
	return 
}


gerarcodigos:
_reload_gettable := True
if(!camptable)||(!octable)||(!odctable)||(!odrtable)||(!codtable){
	MsgBox,64,, % "Uma ou mais campos, das tabelas necessarias para gerar os codigos esta em branco!"
}
args:={}
args["codtable"]:=codtable
args["octable"]:=octable 
args["odctable"]:=odctable
args["odrtable"]:=odrtable
args["oditable"]:=oditable
args["camptable"]:=camptable
args["empmasc"]:=EmpresaMascara
args["abamasc"]:=AbaMascara
args["fammasc"]:=FamiliaMascara
args["modmasc"]:=ModeloMascara
args["mascaraant"]:=EmpresaMascara AbaMascara FamiliaMascara ModeloMascara
for,each,value in list:=db.getvalues("Campos",EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "prefixo"){
	args["mascaraant2"].=list[A_Index,1]	
} 
if(args["mascaraant2"]=""){
	MsgBox, % "Defina a ordem do prefixo antes de continuar!!!"
	return 
}
args["selecteditem"] := selectmodel
tables:=["oc","odc","odr","odi"]
tables2:=["octable","odctable","odrtable","oditable"]
fields:=["Codigo","DC","DR","DI"]
relational:={}    ;tabela usada para relacionar os valores do codigo com as descricoes no formato relational[campo,desc,value]:=valor do codigo
for,each,value in tables2
	args["ordemtable"]:=args[value],args["field"]:=fields[A_Index],args["type"]:=tables[A_Index],loadtables(args)	
finalcod:=[]
for,each,value in tables {
	codlist:=[]
	;_firsttime:=1
	args["table"]:=value,prefix:=args["mascaraant2"],global_prefix:=prefix,x:=1,gerarcodigos(args,prefix,x)
	for,each2,value2 in codlist {
		finalcod[value,A_Index]:=value2 
	}
	;args["mascaraant"]:=""
}
MsgBox,64,, % " Aguarde.... (numero total de codigos:" finalcod["oc"].maxindex() ")"
db.deletevalues(codtable,"Codigos")
db.createtable(codtable,"(Codigos,DC,DR,PRIMARY KEY(Codigos ASC))")
codes:={}
currentvalue:=GetSelectedRow("M","MODlv")
table:=db.query("SELECT descricao FROM " EmpresaMascara AbaMascara FamiliaMascara currentvalue[2] "Desc;")
descgeral:=table["descricao"]
table.close()
table2:=db.query("SELECT descricao FROM " EmpresaMascara AbaMascara FamiliaMascara currentvalue[2] "DescIngles;")
descgeralingles:=table2["descricao"]
table2.close()
db.query("ALTER TABLE " codtable " ADD COLUMN DI TEXT;")
progress(finalcod["oc"].maxindex(),parar_gerar_codigo)
_error:=0
for,each,value in finalcod["oc"]{
		;code:=""
		finalresult:=organizecode(finalcod["oc",each]) ;Funcao que organiza os codigos com as descricao correspondentes.
		updateprogress("Inserindo Codigos " finalresult.oc,1)
		code_initial_prefix := finalresult.oc
		;MsgBox, % "codigo antes " code_initial_prefix
		Stringleft,code_initial_prefix,code_initial_prefix,3
		;MsgBox, % "codigo depois " code_initial_prefix
		if(code_initial_prefix != "MPT" ){
			if(StrLen(finalresult.oc)>15){
				MsgBox,16,,% "O codigo " finalresult.oc " tem mais de 15 caracteres a insercao de codigo ira parar "
				_error:=1
				Break
			}	
		}else{
			if(StrLen(finalresult.oc)>16){
				MsgBox,16,,% "O codigo " finalresult.oc " tem mais de 15 caracteres a insercao de codigo ira parar "
				_error:=1
				Break
			}	
		}
		
		if(StrLen(descgeral " " finalresult.dc)>255){
			MsgBox,16,,% "A descricao completa do codigo " finalresult.oc " tem mais de 255 caracteres a insercao de codigo ira parar "
			_error:=1
			Break 
		}
		if(StrLen(descgeral " " finalresult.dr)>155){
			MsgBox,16,,% "A descricao resumida do codigo " finalresult.oc " tem mais de 155 caracteres a insercao de codigo ira parar "
			_error:=1
			Break 
		}
		if(StrLen(descgeralingles " " finalresult.di)>155){
			MsgBox,16,,% "A descricao em ingles do codigo " finalresult.oc " tem mais de 155 caracteres a insercao de codigo ira parar "
			_error:=1
			Break 
		}
		db.insert(codtable,"(Codigos,DC,DR,DI)","('" . finalresult.oc . "','" descgeral " " finalresult.dc . "','" descgeral " " finalresult.dr "','" descgeralingles " " finalresult.di "')")
}
Gui,progress:destroy
relmodel:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel
if(!db.exist("tipo,tabela1","tipo='Codigo' AND tabela1='" . relmodel . "'","reltable")){
		db.insert("reltable","(tipo,tabela1,tabela2)","('Codigo','" . relmodel . "','" . codtable . "')")
}
loaditem()
if(_error = 0)
	MsgBox,64,, % "codigos gerados!!"
else
	MsgBox,16,, % "Os codigos NAO foram gerados!!"
Gosub,codetable
return 

parar_gerar_codigo(){
	MsgBox, % "parar gerar codigo!"
}

organizecode(code){
	Global
	campo:={}
	StringSplit,codepiece,code,|
	x:=1
	cleancode:=""
	field2:=""
	Loop,% codepiece0 {
		if(A_Index=1){
			x+=1
			Continue
		}
		StringSplit,field,codepiece%x%,>
		campo[field1]:=field2
		cleancode.=field2
		x+=1
	}
	returndesc := {}
	returndesc.oc := codepiece1 cleancode
	returndesc.dc := getdesc(campo,"odc")
	returndesc.dr := getdesc(campo,"odr")
	returndesc.di := getdesc(campo,"odi")	
	return returndesc
}

getdesc(campo,typedesc){
	Global
	for,each,value in finalcod[typedesc]{
		value:=finalcod[typedesc,each]
		StringSplit,code,value,|
		fieldnames:=object()
		campo2:={}
		campo2withspaces:={}
		x:=1
		Loop,% code0{
			if(A_Index=1){
				x+=1
				Continue
			}
			StringSplit,field,code%x%,>
			campo2withspaces[field1]:=field2
			StringReplace,field2,field2,%A_Space%,,All
			campo2[field1]:=field2
			fieldnames.insert(field1)
			x+=1
		}
		match:=0
		desc:=""
		for,each,value in fieldnames{
			if(campo[value]=relational[value,typedesc,campo2[value]]){
				match:=1
				desc.=campo2withspaces[value] " " 
			}else{
				match:=0
				Break
			}
		}
		if(match=1)
			Break
	} 
	return desc
}

loadtables(args)
{
	Global db,oc,odc,odr,odi,relational
	type:=args["type"],%type%:=[]
	For each in list:=db.getvalues("Campos",args["ordemtable"]){
		read:=list[A_Index,1]
		StringReplace,value,read,%A_Space%,,All
		k:=[]
		result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='" . value . "' AND tabela1='" . args["mascaraant"] . args["selecteditem"] . "'")
		field:=args["field"]
		For each in list2:=db.getvalues(field,result["tabela2"])
			k.insert("|" value ">" list2[A_Index,1])
		For each in list3:=db.getvalues("Codigo,DC,DR",result["tabela2"]){  ;Loop que cria a relational table !!!
			dc1:=list3[A_Index,2],dr1:=list3[A_Index,3],di1:=list3[A_Index,4]
			StringReplace,dc1,dc1,%A_Space%,,All
			StringReplace,dr1,dr1,%A_Space%,,All
			StringReplace,di1,di1,%A_Space%,,All
			relational[value,"odc",dc1]:=list3[A_Index,1]
			relational[value,"odr",dr1]:=list3[A_Index,1]
			relational[value,"odi",di1]:=list3[A_Index,1]
		}
		result.close()
		if(k[1]!="")
			%type%.insert(k)
	}
}

gerarcodigos(args,prefix,x)
{
	Global db,oc,odc,odr,odi,codlist,_firsttime,global_prefix

	table:=args["table"]
	for,each,value in list:=%table%[x]{
		if(table="oc")
			cod:=prefix value
		if(table="odc")
			cod:=prefix " " value
		if(table="odr")
			cod:=prefix " " value
		if(table="odi")
			cod:=prefix " " value
		x+=1
		gerarcodigos(args,cod,x)
		x-=1		
	}
	if(!%table%[x]){
		if(table!="oc")
			StringReplace,prefix,prefix,% global_prefix,,All
		codlist.insert(prefix)
		return
	}
}

linkarm:
if(!selecteditem){
	MsgBox,64,, % "Selecione um item para continuar!"
	return 
}

args := {}
args["selecteditem"] := selecteditem
args["window"] := "M",args["lv"] := "MODlv",args["mascaraant"] := EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara
args["tipo"] := "Campo",args["selecteditem"] := selectmodel,args["owner"]:="M"
args["tipoquery"] := "SELECT tipo,tabela1,tabela2 FROM reltable WHERE tipo='Campo'"
linkar2(args)
return 

MODlv:
if A_GuiEvent = i
{
	Gui,submit,nohide

	info := get_item_info("M", "MODlv") 
	if(info.modelo[1] != "Modelo")
		load_image_in_main_window()	
}
return 

loaditem(){
	Global

	bloqtable := "", codtable := "", camptable := "", octable := "" , odctable := "", odrtable := ""
	prefixpt2 := ""
	for,each,value in list:=db.getvalues("Campos",EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "prefixo"){
		prefixpt2 .= list[A_Index,1]	
	} 
	StringReplace, prefixpt2, prefixpt2,% ModeloMascara,,All
	result := db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" EmpresaMascara AbaMascara FamiliaMascara ModeloMascara selectmodel "'")
	IfnotExist,% A_WorkingDir "\img\" result["tabela2"] ".png"
	{
		db.load_image_to_file("","",result["tabela2"])
	}
	;showimageandcode(A_WorkingDir "\img\" result["tabela2"] ".png",10,10,EmpresaMascara AbaMascara FamiliaMascara,ModeloMascara)
	result.close()
	Gui, M:default
	Guicontrol,, ptcode, simpleplot.png
	result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='Bloqueio' AND tabela1='" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel . "'")
	bloqtable:=result["tabela2"]
	result.close()
	if(!bloqtable)
		bloqtable:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . "Bloqueio"
	result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='Codigo' AND tabela1='" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel . "'")
	codtable:=result["tabela2"]
	result.close()
	if(!codtable)
		codtable:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . "Codigo"
	result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='Campo' AND tabela1='" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel . "'")
	camptable:=result["tabela2"]
	result.close()
	if(!camptable)
		camptable:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . "Campo"
	result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='oc' AND tabela1='" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel . "'")
	octable:=result["tabela2"]
	result.close()
	if(!octable){
		if(!db.exist("tipo,tabela1","tipo='oc' AND tabela1='" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel . "'","reltable"))
			db.insert("reltable","(tipo,tabela1,tabela2)","('oc','" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel . "','" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . "oc')")
		octable:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . "oc"
	}
	result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='odc' AND tabela1='" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel . "'")
	odctable:=result["tabela2"]
	result.close()
	if(!odctable)
		odctable:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . "odc"
	result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='odr' AND tabela1='" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel . "'")
	odrtable:=result["tabela2"]
	result.close()
	if(!odrtable)
		odrtable:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . "odr"
	result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='odi' AND tabela1='" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel . "'")
	oditable:=result["tabela2"]
	result.close()
	if(!oditable)
		oditable := EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . "odi"
	Gui,listview,CODlv
	Gui,M:default
	RowNumber:=0
	values:=getvaluesLV("M","CODlv")
	numberofitems:=0
	resultlist:=""
	for,each,value in list:=db.getvalues("Codigos,DR",EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . "Codigo"){
		numberofitems++	
		if(list[A_Index,1]!=""){
        	resultlist.="|" list[A_Index,1] ">>" list[A_Index,2] 
   		 }   
	} 
	guicontrol,,combocodes,|
  	guicontrol,,combocodes,%resultlist%
	Guicontrol,,numberofitems,Items:%numberofitems%
}

		MAM:
		if(get_tv_level("M", "main_tv") != 3){
			MsgBox,16,Erro, % " Selecione uma familia antes, para alterar modelos!"
			return 
		}

		/*
  		Pega a tabela de modelos
  	*/	
		familia := get_tv_info("Familia")
		tipo := get_tv_info("Tipo")
		empresa := get_tv_info("Empresa")

		/*
			Metodo que pega a tabela de modelos 
			linkada
		*/
		model_table := db.get_reference("Modelo",empresa.mascara tipo.mascara familia.nome)
		inserir_modelo_view(model_table)
		return
		
		reloadmodelo(){
			Global
			db.loadlv("M","MODlv",modtable,"Modelos,Mascara",1)
		}

refreshm(){
	Global _refresh 
	_refresh:=true
	gosub,M
}		
		
		MAB:
		Gui,MAB:New
		Gui,font,s%SMALL_FONT%,%FONT%
		Gui,MAB:+owner%owner%
		;Gui,MAB:+toolwindow
		Gui,color,%GLOBAL_COLOR%
		Gui,Add, Picture,w310 h50 0xE vbanner 
		banner(BANNER_COLOR,banner,"Bloqueados")
		Gui,add,edit,w300 y+5 r1 gpesquisabloq vpesquisamam uppercase,
		Gui,add,listview,w300 h400 y+5 vMABlv  checked,
		Gui,add,button,w100 h30 y+5 ginserirwindow,Inserir Bloqueios
		Gui,add,button,w100 h30 x+5 gretirarbloq,Retirar do bloqueio
		Gui,add,button,w100 h30 x+5 gfiltrarcod,Filtrar Codigos!!
		Gui,add,button,w100 h30 y+5 xm gmarctodosmab,Marc.Todos
		Gui,add,button,w100 h30 x+5 gdestodosmab,Des.Todos
		Gui,add,button,w100  h30 x+5 gexportarbloqueio,Exportar
		Gui,add,button,w100 h30 xm y+5 gimportarbloqueio,Importar
		Gui,Show,,Modelos-Bloqueados!!
		Listbloq:=[]
		table:=db.query("SELECT Codigos FROM " bloqtable ";")
		while(!table.EOF){  
		        value1:=table["Codigos"],value2:=table["DC"]
		        Listbloq[A_Index,1]:=value1 
		        Listbloq[A_Index,2]:=value2
		        table.MoveNext()
		}
		table.close()
		db.loadlv("MAB","MABlv",bloqtable,"Codigos")
		return 


				exportarbloqueio:
				result_to_export:=GetCheckedRows("MAB","MABlv")
				if(result_to_export[1,1] = ""){
					MsgBox,64,,% "Selecione os modelos a serem exportados antes de continuar"
					return 
				}
				FileDelete,listbloqtemp.csv
				for,each,value in result_to_export{
					FileAppend,% result_to_export[A_Index,1] "`n",listbloqtemp.csv
					if ErrorLevel
						MsgBox, % "O arquivo estava bloqueado!"
				}
				MsgBox,64,, % "Os items foram exportados!!!" 
				run,listbloqtemp.csv
				return 

				importarbloqueio:
				db.query("Create TABLE " bloqtable " (Codigos, PRIMARY KEY(Codigos ASC));")
				FileSelectFile,source,""
				MsgBox, % source
				x:= new OTTK(source)
				progress(Listbloq.maxindex())
				for,each,value in x{
					updateprogress("Inserindo bloqueios: " x[A_Index,1],1)
				    db.query("INSERT INTO " bloqtable " (Codigos) VALUES ('" x[A_Index,1] "');")
				}
				gui,progress:destroy
				MsgBox,64,,% "valores importados!!!!"
				return 

				marctodosmab:
				gui,listview,MABlv
				Loop, % LV_GetCount()
					LV_Modify("","+check")
				return 

				destodosmab:
				gui,listview,MABlv
				Loop, % LV_GetCount()
					LV_Modify("","-check")
				return 

				filtrarcod:
				table:=db.query("SELECT Codigos FROM " codtable ";")
				progress(Listbloq.maxindex())
				while(!table.EOF){ 
					if(MatHasValue(Listbloq,table["Codigos"])){
						updateprogress("filtrando codigos: " table["Codigos"],1)
						db.query("DELETE FROM " codtable " WHERE Codigos='" table["Codigos"] "';")
					}
        			table.MoveNext()
				}
				Gui,progress:destroy
				loaditem()
				MsgBox,64,, % "os codigos foram filtrados!!!"
				return 

				retirarbloq:
				result:=GetCheckedRows("MAB","MABlv")
				progress(result.maxindex())
				for,each,value in result{
					updateprogress("Retirando Bloqueios: " result[A_Index,1],1)
					Listbloq:=deletefromarray(result[A_Index,1],Listbloq)
					db.query("DELETE FROM " bloqtable " WHERE Codigos='" result[A_Index,1] "';")
				}
				gui,progress:destroy
				db.loadlv("MAB","MABlv",bloqtable,"Codigos")
				return 

				pesquisabloq:
				gui,submit,nohide
				pesquisalv("MAB","MABlv",pesquisamam,Listbloq)
				return 
			
			inserirwindow:
			Gui,iw:New
			Gui,font,s%SMALL_FONT%,%FONT%
			Gui,iw:+owner%owner%
			Gui,color,%GLOBAL_COLOR%
			Gui,Add, Picture,w500 h50 0xE vbanner 
			banner(BANNER_COLOR,banner,"Inserir bloqueios")
			;Gui,iw:+toolwindow
			Gui,add,edit,w500 r1 gpesquisaiw vpesquisaiw uppercase,
			Gui,add,listview,w500 h400 y+5 viwlv  checked,
			Gui,add,button,w100 h30 y+5 ginserirbloq,Inserir
			Gui,add,button,w100 h30 x+5 gmarctodosiw,Marc.Todos
			Gui,add,button,w100 h30 x+5 gdestodosiw,Des.Todos
			Gui,Show,,Inserir Bloqueios!!
			Listiw:=[]
			table:=db.query("SELECT Codigos,DC FROM " codtable ";")
			k:=0
			while(!table.EOF){
					if(!MatHasValue(Listbloq,table["Codigos"])){
				        k++
				        value1:=table["Codigos"],value2:=table["DC"]
				        Listiw[k,1]:=value1 
				        Listiw[k,2]:=value2
					}
					table.MoveNext()
			}
			db.loadlv("iw","iwlv",codtable,"Codigos,DC",1)
			return 

				marctodosiw:
				gui,listview,iwlv
				Loop, % LV_GetCount()
					LV_Modify("","+check")
				return 

				destodosiw:
				gui,listview,iwlv
				Loop, % LV_GetCount()
					LV_Modify("","-check")
				return 

				pesquisaiw:
				Gui,submit,nohide
				pesquisalv("iw","iwlv",pesquisaiw,Listiw)
				return 


				inserirbloq:
				Gui,submit,nohide
				db.query("Create TABLE " bloqtable " (Codigos, PRIMARY KEY(Codigos ASC));")
				result:=GetCheckedRows("iw","iwlv")
				for,index,value in result{
					for,each,string in Listiw{
						if (Listiw[A_Index,1]=result[index,1]){
							Listiw.Remove(each)
							Gosub,pesquisaiw
						}
					}
					db.query("INSERT INTO " bloqtable "(Codigos) VALUES ('" . result[A_Index,1] . "');")
				}
				db.loadlv("MAB","MABlv",bloqtable,"Codigos",1)
				MsgBox,64,, % "Bloqueios inseridos"

				return 


;##################################################
;#												  #
;#					Campos						  #
;#										          #
;##################################################


; O modelo antigo esta no teste7			
MAC:
Gui,MAC:New
Gui,font,s%SMALL_FONT%,%FONT%
Gui,MAC:+ownerM
Gui,color,%GLOBAL_COLOR%
Gui, Add, ListView, xm section w390 h90 vMACcamp gMACcamp altsubmit,
Gui, Add, ListView, x+5 w390 h90 vMACcod gMACcod altsubmit, 
Gui, Add, Button, xm y+5 w100 h20 vMACRC gMACREN ,Renomear Codigo
Gui, Add, Button, x+5  w60 h20 gMACEXCLUIRC, Excluir
Gui, Font, underline
Gui, Add, Text, x+5 vlink0 cblue w150 gdeslink2 ,% "@"
Gui, Font,
Gui, Add, Button, x+60 w100 h20 gMACREN vMACRCO,Renomear Campos  ;MACcamp
Gui, Add, Button, x+5  w60 h20 gMACEEXCLUIRV,Excluir
Gui, Add, Button, x+5  w120 h20 gaddreferencia,Add Referencia
Gui, Add, ListView, xm y+5 w820 h140 vMACdc, 
Gui, Add, Button, xm y+5 w100 h20 vMACRDC gMACREN,Renomear DC 
Gui, Add, ListView, xm y+5 w820 h120 vMACdr, 
Gui, Add, Button, xm y+5 w100 h20 vMACRDR gMACREN,Renomear DR
Gui, Add, ListView,xm y+5 w820 h120 vMACdi, 
Gui, Add, Button, xm y+5 w100 h20 vMACRDI gMACREN,Renomear DI
Gui, Font, underline 
Gui, Add,text, xm y+5 w200 h30 cblue vlink gdeslink,% "@" . camptable
Gui, Font,
Gui, Add, Button, x+100  w100 h30 gMACI, &Incluir
Gui, Add, Button, x+5  w100 h30 gMACC, &Copiar
Gui, Add, Button, x+5 w100 h30 gMACL, &Linkar
Gui, Add, Button, x+5 w100 h30 gdesc.geral, &Descricao Geral
Gui, Show,,Modelos-Alterar-Campos
db.loadlv("MAC","MACcamp",camptable,"campos")
result:=db.query("SELECT Campos FROM " camptable ";")
campEtable:=getreferencetable(result["Campos"],EmpresaMascara AbaMascara FamiliaMascara ModeloMascara selectmodel)
result.close()
loadcampetables(campEtable)
return

				loadcampetables(relreference){
					Global db
					;MsgBox, % " relreference " relreference
					db.loadlv("MAC","MACcod",relreference,"Codigo") 
					db.loadlv("MAC","MACdc",relreference,"DC")
					db.loadlv("MAC","MACdr",relreference,"DR")
					db.loadlv("MAC","MACdi",relreference,"DI")
					GuiControl,+ReDraw,MACcod
					GuiControl,+ReDraw,MACdc
					GuiControl,+ReDraw,MACdr
					GuiControl,+ReDraw,MACdi
				}

				desc.geral:
				Gui,descgaral:New
				Gui,font,s%SMALL_FONT%,%FONT%
				Gui,Add, Picture,w310 h50 0xE vbanner
				banner(BANNER_COLOR,banner,"Descricao Geral")
				table:=db.query("SELECT descricao FROM " EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "Desc;")
				table2:=db.query("SELECT descricao FROM " EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "DescIngles;")				
				Gui,add,text,xm y+5,Descricao Potugues:
				Gui,add,edit,r2 w310  y+5 xm  veditdg uppercase, % table["descricao"]
				Gui,add,text,xm y+5,Descricao Ingles:
				Gui,add,edit,r2 w310 y+5 xm  veditdi uppercase, % table2["descricao"]
				Gui,add,button,y+5 xm gsalvardescgeral,Salvar
				Gui,Show,,Descricao Geral
				table.close()
				table2.close()
				return 

					salvardescgeral:
					Gui,Submit,nohide
					db.query("Create TABLE " EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "Desc (descricao);")
					db.query("Create TABLE " EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "DescIngles (descricao);")
					db.deletevalues(EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "Desc","descricao")
					db.deletevalues(EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "DescIngles","descricao")
					db.insert(EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "Desc","(descricao)","('" editdg "')")
					db.insert(EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "DescIngles","(descricao)","('" editdi "')")
					MsgBox,64,, % "A descricao geral foi salva!!!" 
					return 


				MACRDI:
				return 



				deslink:
				MsgBox, 4,,Deseja desfazer o link?
				IfMsgBox Yes
				{
					SQL:="DELETE FROM reltable WHERE tipo='Campo' AND tabela1='" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel . "';"
					db.query(sql)
					for,each,value in [octable,odctable,odrtable]{
						db.deletevalues(value,"Campos")	
					}
					camptable:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . "Codigo"
					db.loadlv("MAC","MACcamp",camptable)
					MsgBox,64,, % "O link foi desfeito!"
					guicontrol,,link,
					guicontrol,hide,deslink
					loaditem()
				}else{
					return 
				}
				return 

				deslink2:
				MsgBox, 4,,Deseja desfazer o link?
				IfMsgBox Yes
				{
					desparan1:=GetSelected("MAC","MACcamp")
					desparan2:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel
					StringReplace,desparan1,desparan1,%A_Space%,,All
					MsgBox, % "DELETE FROM reltable WHERE tipo='" desparan1 "' AND tabela1='" desparan2 "';" 
					db.query("DELETE FROM reltable WHERE tipo='" desparan1 "' AND tabela1='" desparan2 "';")
					MsgBox,64,, % "O link do campo " desparan1 " foi desfeito!!!"
				}else{
					return 
				}
				return 

				loadcampetable(args){
					Global 
					campvalues:={}
					campnames:=db.query("SELECT Campos FROM " args["camptable"] ";")
					while(!campnames.EOF){
					    campname:=campnames["Campos"]
					    StringReplace,campname,campname,%A_Space%,,All
					    if(campname="")
					        Break
					    relreference:=db.query("SELECT tabela2 FROM reltable WHERE tipo='" . campname . "' AND tabela1='" . args["model"] . "'")
					    db.query("ALTER TABLE " relreference["tabela2"] " ADD COLUMN DI TEXT;")
					    result:=db.query("SELECT Codigo,DC,DR,DI FROM " relreference["tabela2"] ";")
					    while(!result.EOF){
					        if(result["Codigo"]="")
					            continue
					        referencename1:=campname . "Codigo",referencename2:=campname . "dc",referencename3:=campname . "dr",referencename4:=campname . "di"
							
							campvalues[referencename1,A_Index]:=result["Codigo"]
							campvalues[referencename2,A_Index]:=result["DC"]
							campvalues[referencename3,A_Index]:=result["DR"]
							campvalues[referencename4,A_Index]:=result["DI"]
					        result.movenext()
					    }
					    result.close()
					    campnames.movenext()
					}
					campnames.close()
					relreference.close()
				}

				MACcod:
				if A_GuiEvent = i 
				{
					gui,submit,nohide
					selecteditem9:=GetSelected("MAC","MACcod"),selectcode:=selecteditem9
				}
				return 

				addreferencia:
				if(!nomecamp) || (!selectcode) || (!selectmodel)
					MsgBox,64,, % "Nenhum dos campos pode estar em branco!!!"
				StringReplace,selectmodel,selectmodel,`.,,All
				inserir3(nomecamp . selectcode . selectmodel,"Referencia","Referencia ASC","","")
				return 

				MACREN:
				args:={}
				args["window"]:="MAC",args["table"]:=campEtable,args["camptable"]:=camptable
				args["mascaraant"]:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara
				button:=A_GuiControl
				if(button="MACRC"){
					args["lv"]:="MACcamp"
					args["field1"]:="Campos"
					args["field2"]:="Campos"
					args["func"]:="salvarr1"
					args["loadtable"]:=camptable
					args["loadfield"]:="Campos"
				}

				if(button="MACRCO"){
					args["lv"]:="MACcod"
					args["field1"]:="Codigo"
					args["field2"]:="Codigo"
					args["func"]:="salvarr2"
					args["loadtable"]:=campEtable
					args["loadfield"]:="Codigo"
				}

				if(button="MACRDC"){
					args["lv"]:="MACdc"
					args["field1"]:="DC"
					args["field2"]:="DC"
					args["func"]:="salvarr2"
					args["loadtable"]:=campEtable
					args["loadfield"]:="DC"
				}
					
				if(button="MACRDR"){
					args["lv"]:="MACdr"
					args["field1"]:="DR"
					args["field2"]:="DR"
					args["func"]:="salvarr2"
					args["loadtable"]:=campEtable
					args["loadfield"]:="DR"
				}

				if(button="MACRDI"){
					args["lv"]:="MACdi"
					args["field1"]:="DI"
					args["field2"]:="DI"
					args["func"]:="salvarr2"
					args["loadtable"]:=campEtable
					args["loadfield"]:="DI"
				}
				renomear2(args)
				return

			MACL:
			gui,submit,nohide
			if(!nomecamp){
				MsgBox,64,, % "Selecione um campo ja criado antes de continuar!"
				return 
			}
			args:={}
			args["selecteditem"]:=selectmodel
			args["tipo"]:=nomecamp,args["mascaraant"]:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara
			args["tipoquery"]:="SELECT tipo,tabela1,tabela2 FROM reltable WHERE tipo='" . nomecamp . "'"
			args["closefunc"]:="closelinkar2",args["selecteditem"]:=selectmodel
			linkar2(args)
			return

			closelinkar2(args1){
				Global
				args:={},args["camptable"]:=camptable,args["model"]:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel
				loadcampetable(args1)
			}

			MACEXCLUIRC:
			selecteditems:=getselecteditems("MAC","MACcamp")
			MsgBox, 4,,Deseja apagar os campos?
			IfMsgBox Yes
			{
				for,each,value in selecteditems{
					campEtable:=getreferencetable(value,EmpresaMascara AbaMascara FamiliaMascara ModeloMascara selectmodel)
					MsgBox, % " gonna drop table " campEtable
					db.query("DROP TABLE " campEtable ";")
					db.delete(camptable,value,"Campos")
					db.delete(octable,value,"Campos")
					db.delete(odctable,value,"Campos")
					db.delete(odrtable,value,"Campos")
					db.delete(oditable,value,"Campos")
				}
				db.loadlv("MAC","MACcamp",camptable)
			}else{
				return 
			}
			return 

			MACEEXCLUIRV:
			selecteditems:=getselecteditems("MAC","MACcod")
			MsgBox, % " selecteditems " selecteditems[1] " nomecamp " nomecamp 
			if(selecteditems[1]="" or nomecamp=""){
				MsgBox,64,, % "Selecione um campo e um item a ser excluido!"
				return 
			}
			MsgBox, 4,,Deseja apagar os items selecionados?
			IfMsgBox Yes
			{
				for,each,value in selecteditems{
					db.delete(campEtable,value,"Codigo")
					}	
				db.loadlv("MAC","MACcod",campEtable,"codigo")
				db.loadlv("MAC","MACdc",campEtable,"dc")
				db.loadlv("MAC","MACdr",campEtable,"dr")
				db.loadlv("MAC","MACdi",campEtable,"di")
			}else{
				return 
			}
			return 


			MACcamp:
			if A_GuiEvent = i 
			{
				gui,submit,nohide
				selecteditem := GetSelected("MAC","MACcamp")
				StringReplace,nomecamp,selecteditem,%A_Space%,,All
				campEtable := getreferencetable(selecteditem,EmpresaMascara AbaMascara FamiliaMascara ModeloMascara selectmodel)
				guicontrol,,link0,% "@" campEtable
				loadcampetables(campEtable)
			}
			
			return 

				MACEXCLUIR:
				selecteditem:=GetSelected("MAC","MACcamp")
				MsgBox, 4,,Deseja apagar o campo selecionado %selecteditem%?
				IfMsgBox Yes
				{
					db.delete("MAC","MACcamp",EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . "camp",selecteditem,"Campos")
					db.loadlv("MAC","MACcamp",EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . "camp")
				}else{
					return 
				}
				return 

				MACC:
				return 

				MACI:
				campname:=""
				camplist:=db.getvalues("Campos",camptable)
				campvalues:=""
				for,k,v in camplist{
			    if(A_Index=1){
			        if(camplist[A_Index,1]!="")
			            campvalues.=camplist[A_Index,1] 
			    }else{
			        if(camplist[A_Index,1]!="")
			            campvalues.="|" . camplist[A_Index,1]       
			    }
				}
				gui,MABC:New
				Gui,font,s%SMALL_FONT%,%FONT%
				Gui,MABC:+ownerM
				Gui,color,%GLOBAL_COLOR%
				Gui, Add, Text, xm w100 h20 , Campos
				Gui, Add,Dropdownlist, xm y+5 w180 gddlaction vddlvalue ,%campvalues%
				Gui, Add, Button, x+5  w100 h20 gAddCampo, Add Campo
				Gui, Add, Text, xm y+5 w100 h20 , Codigo
				Gui, Add, Edit, xm y+5 w120 h20 vcod uppercase,
				Gui, Add, Text, xm y+5 w100 h20 , Descricao Completa
				Gui, Add, Edit,  y+5 w700 h60 vdc uppercase,
				Gui, Add, Text, xm y+5 w100 h20 , Descricao Resumida
				Gui, Add, Edit,  y+5 w700 h60 vdr uppercase,
				Gui, Add, Text, xm y+5 w100 h20 , Descricao Ingles
				Gui, Add, Edit,  y+5 w700 h60 vdi uppercase,
				Gui, Add, Button, xm y+5 y+5   w100 h30 gMACISALVAR,Salvar
				Gui, Add, Button,  x+5 w100 h30 gMACIIMPORT,Importar
				Gui, Add, Button, x+5 w100 h30 gMACICANCELAR, Cancelar
				Gui, Show,,Modelos-Alterar-Campos-Incluir
				return  

					MACIIMPORT:
					Gui,submit,nohide
				  FileSelectFile,source,""
				  Stringright,_iscsv,source,3
				  if(_iscsv!="csv"){
				  	MsgBox, % "o arquivo selecionado tem que ser .csv!!!!"
				    return 
				  }
				  if(campEtable=""){
						MsgBox, % "Selecione um modelo antes de continuar!!!"
						return 
					}
					MsgBox, % campEtable
					db.query("create table if not exists " campEtable "(Codigo,DC,DR,DI, PRIMARY KEY(Codigo ASC))")
			    ;db.query("CREATE TABLE " campEtable " (Codigo,DC);")
			    MsgBox, 4,,Deseja apagar a tabela antiga?
					IfMsgBox Yes
					{
						db.query("DELETE FROM " campEtable ";")
					}
				  x:= new OTTK(source)
				  for,each,value in x{
				    db.query("INSERT INTO " campEtable " (Codigo,DC,DR,DI) VALUES ('" x[A_Index,1] "','" x[A_Index,2] "','" x[A_Index,3] "','" x[A_Index,4] "');")
				  }
				  MsgBox,64,,% "valores importados!!!!"
					return 
				

					ddlaction:
					Gui,submit,nohide
					StringReplace,value,ddlvalue,%A_Space%,,All
					result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='" . value . "' AND tabela1='" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel . "'")
					campEtable:=result["tabela2"]
					result.close()
					campname1:=value
					;MsgBox, % " valor selecionado no camp action " campname "`n valor do campEtable " campEtable
					model:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel
					return 

					AddCampo:
					gui,addcampo:New
					Gui,font,s%SMALL_FONT%,%FONT%
					Gui,color,%GLOBAL_COLOR%
					Gui, Add, Text, x7 y55 w70 h20 ,Nome:
					Gui, Add, Edit, x57 y45 w230 h30 vADDCedit1 uppercase,
					Gui, Add, GroupBox, x-3 y-5 w300 h180 , Inserir
					Gui, Add, Button, x72 y130 w100 h30 gADDCAMPOSALVAR,&Salvar
					Gui, Add, Button, x182 y130 w100 h30 gADDCAMPOCANCELAR,&Cancelar
					Gui, Show, w309 h200,Empresa-Alterar-Inserir
					return

						ADDCAMPOSALVAR:
						gui,submit,nohide
						if(ADDCedit1="")
						{
							MsgBox, % "O campo nao pode estar em branco!!"
							return 
						}
						db.createtable(camptable,"(Campos,PRIMARY KEY(Campos ASC))")
						db.createtable(octable,"(Campos,PRIMARY KEY(Campos ASC))")
						db.createtable(odctable,"(Campos,PRIMARY KEY(Campos ASC))")
						db.createtable(odrtable,"(Campos,PRIMARY KEY(Campos ASC))")
						istring:="('" . ADDCedit1 . "')"
						model:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel
						db.insert(camptable,"(Campos)",istring)
						db.insert(octable,"(Campos)",istring)
						db.insert(odctable,"(Campos)",istring)
						db.insert(odrtable,"(Campos)",istring)
						if(!db.exist("tipo,tabela1","tipo='Campo' AND tabela1='" . model . "'","reltable"))
							db.insert("reltable","(tipo,tabela1,tabela2)","('Campo','" . model . "','" . camptable . "')")
						if(!db.exist("tipo,tabela1","tipo='oc' AND tabela1='" . model . "'","reltable"))
							db.insert("reltable","(tipo,tabela1,tabela2)","('oc','" . model . "','" . octable . "')")
						if(!db.exist("tipo,tabela1","tipo='odc' AND tabela1='" . model . "'","reltable"))
							db.insert("reltable","(tipo,tabela1,tabela2)","('odc','" . model . "','" . odctable . "')")
						if(!db.exist("tipo,tabela1","tipo='odr' AND tabela1='" . model . "'","reltable"))
							db.insert("reltable","(tipo,tabela1,tabela2)","('odr','" . model . "','" . odrtable . "')")
						Gui,AddCampo:destroy
						Gosub,MACI
						args:={},args["camptable"]:=camptable,args["model"]:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel
						;MsgBox, % "addcamposalvar"
						loadcampetable(args)
						;MsgBox, % camptable
						db.loadlv("MAC","MACcamp",camptable)
						return 

						ADDCAMPOCANCELAR:
						gui,AddCampo:destroy
						return 


					MACISALVAR:
					gui,submit,nohide
					db.query("create table if not exists " campEtable "(Codigo,DC,DR,DI, PRIMARY KEY(Codigo ASC))")
					if(campname1=""){
						MsgBox,64,, % "Selecione um campo ou insira um se nao existir!"
						return
					}
					MsgBox, % " model e igual a " model " e cod e igual a " cod
					if(model = "" or dc = "" or dr = "" or di = "" or cod = ""){
						MsgBox,64,, % "Algum campo obrigatorio esta em branco!"
						return 
					}
					istring:="('" cod "','" dc "','" dr "','" di "')"
					if(campEtable = ""){
						if(!db.exist("tipo,tabela1","tipo='" . campname1 . "' AND tabela1='" . model . "'","reltable"))
						{
							db.insert("reltable","(tipo,tabela1,tabela2)","('" . campname1 . "','" . model . "','" . EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . campname1 . "')")
						}
						db.createtable(EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . campname1,"(Codigo,DC,DR,DI, PRIMARY KEY(Codigo ASC))")
						db.query("ALTER TABLE " EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . campname1 " ADD COLUMN DI TEXT;")
						db.insert(EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . campname1,"(Codigo,DC,DR,DI)",istring)
					}else{
						db.query("ALTER TABLE " campEtable " ADD COLUMN DI TEXT;")
						db.insert(campEtable,"(Codigo,DC,DR,DI)",istring)
					}
					args:={},args["camptable"]:=camptable,args["model"]:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel
					MsgBox, % "Os valores foram salvos com sucesso!!!"
					db.loadlv("MAC","MACcamp",camptable)
					return 

					MACICANCELAR:
					return 

		


			MAOC:
			args:={}
			args["camptable"]:=camptable,args["table"]:=octable,args["field"]:="Campos",args["comparar"]:=true,args["owner"]:="M"
			;MsgBox, % "octable " octable
			alterarordem(args)
			return 
			
			MAODC:
			args:={}
			args["camptable"]:=camptable,args["table"]:=odctable,args["field"]:="Campos",args["comparar"]:=true,args["owner"]:="M"
			alterarordem(args)
			return 

			MAODR:
			args:={}
			args["camptable"]:=camptable,args["table"]:=odrtable,args["field"]:="Campos",args["comparar"]:=true,args["owner"]:="M" 
			alterarordem(args)
			return 
			
;inserir1(table,field,primarykey,tipo,mascaraant="",relcondition=true,args)

inserir1(args)
{
	Global db,args1,GLOBAL_COLOR,bannerargs,TextOptions,Font,pesquisaifdb,List,BANNER_COLOR
	Static updown1,lv,foto,banner,banner99
	args1 := args
	StringSplit, value, field,`,
	field3 := value1
	Gui, inserir1:New
	Gui,font,s%SMALL_FONT%,%FONT%
	owner := args["owner"]
	if(owner != "")
		Gui, inserir1:+owner%owner%
	Gui, color, %GLOBAL_COLOR%
	Gui, Add, Picture,w600 h50 0xE vbanner 
	banner(BANNER_COLOR,banner,"Alterar")
	Gui, Add, ListView, xm w320 h290 vlv glv altsubmit  ,
	Gui, Add, UpDown, x+5  w40 h140 gupdown1 vupdown1, UpDown
	Gui, Add, Picture, x+5 w230 h250 vfoto gfoto ,%A_ScriptDir%\SGTK\Images\NoImage1.png
	Gui, Add, Button, xm y+50 w100 h30 ginserir,&Inserir
	Gui, Add, Button, x+5 wp hp grenomear, &Renomear
	Gui, Add, Button, x+5 wp hp glinkar, &Linkar
	Gui, Add, Button, x+5 wp hp gimportar,&Importar
	Gui, Add, Button, x+5 wp hp gexportar,&Exportar
	Gui, Add, Button, x+5 wp hp gexcluir, &Excluir
	Gui, Show,, Empresa-Alterar
	db.loadlv("inserir1","lv",args["table"],args["field"])
	return

	importar:
	Gui, submit, nohide
    FileSelectFile, source,""
    Stringright, _iscsv, source, 3
    MsgBox, % _iscsv
    if(_iscsv != "csv"){
    	MsgBox, % "o arquivo selecionado tem que ser .csv!!!!"
    	return 
    }
    if(args1["table"] = ""){
		MsgBox, % "Selecione um modelo antes de continuar!!!"
		return 
	}
    db.query("CREATE TABLE " args1["table"] " (" args1["field"] ");")
    MsgBox, 4,,Deseja apagar a tabela antiga?
	IfMsgBox Yes
	{
		db.query("DELETE FROM " args1["table"] ";")
	}
    x:= new OTTK(source)
    for,each,value in x{
        db.query("INSERT INTO " args1["table"] " (" args1["field"] ") VALUES ('" x[A_Index,1] "','" x[A_Index,2] "');")
    }
    MsgBox,64,,% "valores importados!!!!"
	return 

	exportar:
	FileDelete,temp.csv 
	for,each,value in list := db.getvalues(args1["field"],args1["table"]){ 
		FileAppend, % list[A_Index,1] ";" list[A_Index,2] "`n",temp.csv
	}
	Run, temp.csv		
	return 

	inserir:
	Gui, submit, nohide
	inserir2(args1)
	return

	renomear:
	renomear(args1)
	return 

	copiar:
	return 

	linkar:
	linkar(args1)
	return 

	excluir:
	selecteditem := GetSelected("inserir1","lv1")
	MsgBox, 4,, Deseja apagar a empresa %selecteditem%?
	IfMsgBox Yes
	{
		db.delete(args1["table"],selecteditem,args1["field1"])
		SQL:="DELETE FROM reltable WHERE tipo='" . args1["tipo"]  "' AND tabela1='" . args1["tabela1"] . "';"
		if (!db.Query(SQL)) {
					  Msg := "ErrorLevel: " . ErrorLevel . "`n" . SQLite_LastError() "`n`n" sQry
					  throw Exception("Query failed: " Msg)
					 ; MsgBox, 0, Query failed, %Msg%
					}
		db.loadlv("inserir1","lv1",args1["table"],args1["field"])
		closefunc:=args1["closefunc"]
		%closefunc%(args)
	}else{
		return 
	}
	return 

	updown1:
	return 

	lv:
	return 

	foto:
	result := GetSelectedRow("inserir1","lv1") 
	if(result[2] = "mascara" || result[2] = ""){
		MsgBox, % "Selecione um item antes de continuar!!"
		return 
	}
	selecteditem := result[1]
	iprefix := args1["mascaraant"] result[2]
	inserirfoto(iprefix, selecteditem, "", args1["owner"])
	return 
}

massainsertphoto(codtable){
	Global db,TextOptions,Font,picture,BANNER_COLOR,GLOBAL_COLOR
	Static lv,banner

	Gui,massaphoto:New 
	Gui,Add, Picture,w900 h50 0xE vbanner 
	banner(BANNER_COLOR,banner,"Inserir Fotos")
	Gui,color,%GLOBAL_COLOR%
	Gui,add,Listview,w500 h300 xm section checked vlv altsubmit gmassalv,Codigos
	Gui,add,picture,x+5 w300 h300 vpicture,%A_WorkingDir%\noimage.png
	Gui,add,button,xm y+5 w100 gmarcartodos,Marcar todos
	Gui,add,button,x+5 w100 gdesmarcartodos,Desmarcar todos
	Gui,add,button,x+260  w100 ginserirfotoemmassa ,Inserir
	;Gui,add,button,x+5 w100 gexcluir,Excluir dos marcados
	Gui,Show 
	db.loadlv("massaphoto","lv",codtable)
	return 

	massalv:
	if A_GuiEvent = i
	{
		selecteditem2 := GetSelected("massaphoto","lv")
		if(selecteditem2 = "" || selecteditem2 = "Codigos")
			return 
		result:=db.query("SELECT tipo,tabela1,tabela2 FROM reltable WHERE tipo='image' AND tabela1='" selecteditem2 "'")
		if(result["tabela2"]!="")
			db.loadimage("massaphoto","picture",result["tabela2"])
		Else
			guicontrol,,picture,% "noimage.png"
	}
	return 

	marcartodos:
	gui,listview,lv
	Loop, % LV_GetCount()
		LV_Modify("","+check")
	return 

	desmarcartodos:
	gui,listview,lv
	Loop, % LV_GetCount()
		LV_Modify("","-check")
	return 

	inserirfotoemmassa:  ;passa um array para o inserirfoto
	result := GetCheckedRows("massaphoto","lv")
	arrayofitems := {}
	for,each,value in result{
		arrayofitems[each] := result[each,1]
		;MsgBox, % " valores no arrayofitems " arrayofitems[each]  
	}
	inserirfoto("","",arrayofitems)
	return 

	excluirfotosemmassa:
	return 


}

inserirfoto(iprefix1="",selecteditem1="",arrayofitems1="",owner=""){ ;arrayofitems e usado no massainsertphoto
	Global GLOBAL_COLOR,db,pesquisaifdb,image_table
	Static iprefix,selecteditem,arrayofitems,owner1
	arrayofitems := arrayofitems1,owner1 := owner
	iprefix := iprefix1,selecteditem := selecteditem1
	Gui,insertimage:New 
	if(owner!="")
		Gui,insertimage:+owner%owner%
	Gui,color,%GLOBAL_COLOR%
	Gui,add,button, w150 h30 ginsertfromdb,Escolher do Banco!
	Gui,add,button,w150 h30 ginsertfromfile,Escolher Arquivo!
	Gui,Show,, 
	return 

		insertfromdb:
		Gui,insertimage:destroy
		Gui,selectfromdb:New
		if(owner1 != "")
			Gui,selectfromdb:+owner%owner1%
		Gui,add,text,,Pesquisar:
		Gui,add,edit,x+5 w150 r1 gpesquisaifdb vpesquisaifdb uppercase, 
		Gui,add,listview,xm y+5 vsblv w200 h300 altsubmit gsblv,Nome
		Gui,add,picture,x+5 w300 h300 vsbimage,
		Gui,add,button,xm y+5 gsaveselected w100 h30,Salvar
		Gui,add,button,x+5 w100 h30 gdeleteimage,Deletar
		Gui,Show,,
		image_table := []
		;Caso a tabela de imagens ainda nao tenha sido carregado
		table := db.query("SELECT Name FROM imagetable;")
		while(!table.EOF){  
      value1 := table["Name"]
      image_table.insert(value1)
     	LV_Add("",value1)  
      table.MoveNext()
		}
		table.close()
		return 

			pesquisaifdb:
			Gui,submit,nohide
			pesquisa_simple_array("selectfromdb","sblv",pesquisaifdb,image_table) 
			;pesquisalv("selectfromdb","sblv",pesquisaifdb,image_table)
			return 

			deleteimage:
			selectedimage:=GetSelected("selectfromdb","sblv")
			if(selectedimage=""){
				MsgBox, % "Selecione uma imagem antes de continuar"
				return 
			}
			if(arrayofitems!=""){
				for,each,value in arrayofitems{
					db.query("DELETE FROM imagetable WHERE Name='" value "';")		
				}
			}else{
				db.query("DELETE FROM imagetable WHERE Name='" selectedimage "';")	
			}
			db.loadlv("selectfromdb","sblv","imagetable")
			MsgBox, % "imagem deletada!!!"
			return

			saveselected:
			selectedimage:=GetSelected("selectfromdb","sblv")
			if(arrayofitems!=""){               ;se o arrayofitems nao estiver vazio insere todos os items.
				for,each,value in arrayofitems{
					db.query("DELETE FROM reltable WHERE tipo='image' AND tabela1='" value "';")
					db.queryS("INSERT INTO reltable (tipo,tabela1,tabela2) VALUES ('image','" value "','" selectedimage "');")		
				}
			}else{
				if(iprefix="" || selecteditem=""){
					MsgBox, % "As imagens nao foram inseridas pois o nome do arquivo e o `n array de items estavam em branco"
					return 
				}
				db.query("DELETE FROM reltable WHERE tipo='image' AND tabela1='" iprefix selecteditem "';")
				db.queryS("INSERT INTO reltable (tipo,tabela1,tabela2) VALUES ('image','" iprefix selecteditem "','" selectedimage "');")		
			}			
			loaditem()
			Msgbox,64,,"A imagem foi inserida no item!!!"
			return 

			sblv:
			if A_GuiEvent=i
			{
				selecteditem2 := GetSelected("selectfromdb","sblv")
				if(selecteditem2 = "" || selecteditem2 = "Name")
					return 
				db.loadimage("selectfromdb","sbimage",selecteditem2)
			}
			return 

		insertfromfile:
		Global editimage
		Gui,insertimage:destroy
		FileSelectFile,source
		if(source = ""){
			return
		}
		Gui,insertfromfile:New
		if(owner1!="")
			Gui,selectfromdb:+owner%owner1%
		Gui,add,text,w100 h30,Nome imagem:
		Gui,add,edit,r1 veditimage w150 h30 y+5 uppercase
		Gui,add,button,gifinsert w100 h30 y+5,inserir
		Gui,Show,, 
		return 

		ifinsert:
		Gui,submit,nohide
    if(editimage="" || source=""){
        MsgBox, % "Escolha o nome e a imagem antes de continuar editimage!!"
        return  
    }
    ;insere o valor na tabela de imagem caso a tabela ja tenha sido carregada
    if(image_table.maxindex())
    	image_table[1].insert(editimage)

	  if(arrayofitems!=""){               ;se o arrayofitems nao estiver vazio insere todos os items.
			for,each,value in arrayofitems{
				db.query("DELETE FROM reltable WHERE tipo='image' AND tabela1='" value "';")
				db.queryS("INSERT INTO reltable (tipo,tabela1,tabela2) VALUES ('image','" value "','" editimage "');")		
			}
		}else{
			db.query("DELETE FROM reltable WHERE tipo='image' AND tabela1='" iprefix selecteditem "';")
			db.queryS("INSERT INTO reltable (tipo,tabela1,tabela2) VALUES ('image','" iprefix selecteditem "','" editimage "');")		
		}
	    db.insertimage(source,editimage)
	    loaditem()
	   MsgBox, % "a imagem foi inserida no modelo"
	  Gui,insertfromfile:destroy
		return 
}

alterarordem(args)
{
	Global db,args1,upwindow,uplv,updownv,altlv,args1,GLOBAL_COLOR,_show_alterar_ordem
	args1:=args,upwindow:="alterar",uplv:="altlv"
	gui,alterar:New
	;Gui,alterar:+toolwindow
	owner:=args["owner"] 
	if(owner!="")
		Gui,alterar:+owner%owner%
	Gui,color,%GLOBAL_COLOR% 
	Gui, Add,text, +0x7 +0x4 center cGreen w350 h30,Alterar Ordem
	Gui, Add, ListView,y+5 w320 h290 valtlv , 
	Gui, Add, UpDown, y20 x+5  w60 h140 vupdownv gupdown range0-1, UpDown
	Gui, Add, Button,x10  y+5 w120 h30 gsalvarordem ,Salvar Ordem
	if(_show_alterar_ordem != false)
		Gui, Show,,Modelos-Alterar-Ordem-Descricao-Completa
	db.query("create table if not exists " args1["table"] "(Campos, PRIMARY KEY(Campos))")
	if(args["comparar"])
		compararcamp(args1["camptable"],args1["table"])
	if(_show_alterar_ordem != false)
		db.loadlv("alterar","altlv",args1["table"])
	return 

		
		salvarordem:
		db.deletevalues(args1["table"],args1["field"])
		values := getvaluesLV("alterar","altlv")
		for,k,v in values 
		{
		  istring:="('" . values[A_Index,1] . "')"
			db.insert(args1["table"],"(" . args1["field"] . ")",istring)
		}
		MsgBox,64,, % "A ordem foi salva com sucesso!!!"
		return

		updown:
		gui,submit,nohide
		if(updownv>0){
		 	condition:=1
		 	updownv:=0
		 }else{
		 	updownv:=0
		 	condition:=0
		 }
		LV_MoveRowfam(upwindow,uplv,condition)
		return   
}

;linkar(Tipo)

linkar(args)
{
	Global db, args1,GLOBAL_COLOR, bannerargs, TextOptions, Font
	Global lb, selecteditem, mascaraant1
	Static NewMascara, NewName, selecteditem1, tipo1, banner, pesquisarlin, PesqList

	args1 := args
	selecteditem := GetSelected("inserir1","lv")
	selecteditem1 := args["mascaraant"] . selecteditem,tipo1 := Tipo
	gui,lb:New
	owner:=args["owner"]
	if(owner != "")
		Gui, lb:+owner%owner%
	Gui, Color, %GLOBAL_COLOR%
	Gui,Add,Picture,w450 h50 0xE vbanner 
	banner(BANNER_COLOR,banner,"Linkar")
	Gui, Add, Edit, w440 r1 vpesquisarlin gpesquisarlin uppercase,
	Gui, Add, ListView, xm y+5 w440 h400 vlb glb,tipo|tabela1|tabela2 
	Gui, Add, Button, xm y+5 w100 gLinkar1, Linkar
	Gui, Add, Button, x+5  w100 gCancelarL, Cancelar
	Gui, Add, Button, x+5 w100 gundo_link, Desfazer Link
	Gui, Show,, Linkar
	PesqList := MontarLB(args["tipo"],"lb","lb")
	LV_ModifyCol(1,150), LV_ModifyCol(2,150), LV_ModifyCol(3,150)
	return

	undo_link:
	link_to_undo := GetSelectedRow("lb","lb")
	;MsgBox, % "DELETE FROM reltable WHERE tipo='" . link_to_undo[1] . "' AND tabela1='" . link_to_undo[2] . "';" 
	db.query("DELETE FROM reltable WHERE tipo='" . link_to_undo[1] . "' AND tabela1='" . link_to_undo[2] . "';")
	Gui, lb:default 
	Gui, ListView, lb
	LV_Delete(GetSelectedItems("lb", "lb", "number"))
	MsgBox, % "O link foi desfeito!"
	return 

	pesquisarlin:
	Gui, submit, nohide 
	for,each,value in PesqList{
		Break
	}
	pesquisalv3("lb", "lb", pesquisarlin, PesqList)
	return 

	lb:
	return 

	Linkar1:
		result:=GetSelectedRow("lb","lb")
		if(result="")
		{
			MsgBox,64,, % "selecione um item para continuar!"
			return 
		}
		MsgBox, 4,,Tem certeza que deseja relacionar a tabela, a tabela antiga sera perdida.
		IfMsgBox Yes
		{
			db.queryS("DELETE FROM reltable WHERE tipo='" . args1["tipo"] . "' AND tabela1='" . selecteditem1 . "';")
			if(!db.exist("tipo,tabela1","tipo='" . result[1] . "' AND tabela1='" . selecteditem1 . "'","reltable"))
				db.insert("reltable","(tipo,tabela1,tabela2)","('" . result[1] . "','" . selecteditem1 . "','" . result[3] . "')")
		}else{
			return 
		}
	return

	CancelarL:
	Gui,lb:destroy
	return 
}

linkar2(args)
{
	Global db,camptable,GLOBAL_COLOR,TextOptions,Font,BANNER_COLOR
	Static selecteditem1,lb,tipo1,args1,pesquisarlin2,PesqList2,banner
	wName:=args["window"],lvName:=args["lv"],selecteditem1:=args["mascaraant"] . args["selecteditem"],tipo1:=args["tipo"]
	args1:=args
	gui,lb:New
	owner:=args["owner"]
	if(owner!="")
		Gui,lb:+owner%owner%
	;gui,lb:+toolwindow
	Gui,color,%GLOBAL_COLOR%
	Gui,Add,Picture,w560 h50 0xE vbanner 
	banner(BANNER_COLOR,banner,"Linkar")
	Gui,add,edit,w440 r1 vpesquisarlin2 uppercase,
	Gui, add, button, w100 x+5 gpesquisarlin2, Pesquisar
	Gui, Add, ListView, w540 h320 xm vlb glb2,tipo|tabela1|tabela2 
	;Gui, Add, GroupBox, x6 y360 w460 h80 , Opcoes
	Gui, Add, Button,xm y+5 w100 h30 gLinkar2, Linkar
	Gui, Add, Button,x+5 w100 h30 gCancelar2, Cancelar
	Gui, Show, w560 h448, Linkar
	LV_ModifyCol(1,200),LV_ModifyCol(2,200),LV_ModifyCol(3,200)
	PesqList2 := MontarLB2(args)
	return

	pesquisarlin2:
	Gui,submit,nohide 
	pesquisalv3("lb","lb",pesquisarlin2,PesqList2)
	return 

	lb2:
	return 

	Linkar2:
		result:=object
		result:=GetSelectedRow("lb","lb")
		if(result="")
		{
			MsgBox,64,, % "selecione um item para continuar!"
			return 
		}
		MsgBox, 4,,Tem certeza que deseja relacionar a tabela, a tabela antiga sera perdida.
		IfMsgBox Yes
		{
			;MsgBox, % "delete from  tipo  " . tipo1 . "   tabela1 " . selecteditem1
			if(result[1]="Campo"){
				camptable:=result[3]
				;MsgBox, % "camptable se tornou " . camptable
				loador(result[3])
			}
			;MsgBox, % "DELETE FROM reltable WHERE tipo='" . result[1] . "' AND tabela1='" . selecteditem1 . "';"
			db.queryS("DELETE FROM reltable WHERE tipo='" . result[1] . "' AND tabela1='" . selecteditem1 . "';")
			if(!db.exist("tipo,tabela1","tipo='" . result[1] . "' AND tabela1='" . selecteditem1 . "'","reltable")){
				;MsgBox, % "ira inserir tipo=" result[1] " tabela1 " selecteditem1 " tabela2 " result[3]
				db.insert("reltable","(tipo,tabela1,tabela2)","('" . result[1] . "','" . selecteditem1 . "','" . result[3] . "')")
				
			}
			closefunc:=args1["closefunc"],%closefunc%(args1)
		}else{
			return 
		}
		MsgBox,64,, % "Campos linkados!!"
	return

	Cancelar2:
	Gui,lb:destroy
	return 


}

loador(camptable){      ; carrega o valor que foi inserido no linkar dos campos nas tabelas de ordem
	Global db,octable,odctable,odrtable 
	db.createtable(octable,"(Campos, PRIMARY KEY(Campos))")
	db.createtable(odctable,"(Campos, PRIMARY KEY(Campos))")
	db.createtable(odrtable,"(Campos, PRIMARY KEY(Campos))")
	for,each,value in list:=db.getvalues("Campos",camptable){
		db.insert(octable,"(Campos)","('" . list[A_Index,1] . "')")
		db.insert(odctable,"(Campos)","('" . list[A_Index,1] . "')")
		db.insert(odrtable,"(Campos)","('" . list[A_Index,1] . "')")
	}
}

MontarLB2(args)
{
	Global db
	sql:=args["tipoquery"]  ;tipo query sera um select que tera todos os tipo que podem ser escolhidos pelo usuario
	rs := db.query(sql)
	Gui,lb:default 
	Gui,listview,lb
	PesqList:=[]
	while(!rs.EOF){   
	  col1 := rs["tipo"] 
	  col2 := rs["tabela1"]  
	  col3 := rs["tabela2"]
	  PesqList[A_Index,1]:=col1 
      PesqList[A_Index,2]:=col2
      PesqList[A_Index,3]:=col3
	  LV_Add("",col1,col2,col3)
	  rs.MoveNext()
	}
	rs.Close()
	return PesqList
}

MontarLB(tipo,lb,window)
{
	Global db 
	sql:="SELECT tipo,tabela1,tabela2 FROM reltable WHERE tipo='" . tipo . "'"
	rs := db.query(sql)
	Gui,%window%:default 
	Gui,listview,%lb%
	PesqList:=[]
	while(!rs.EOF){   
	  col1 := rs["tipo"] 
	  col2 := rs["tabela1"]  
	  col3 := rs["tabela2"]
	  LV_Add("",col1,col2,col3)
	  PesqList[A_Index,1]:=col1 
      PesqList[A_Index,2]:=col2
      PesqList[A_Index,3]:=col3
	  rs.MoveNext()
	}
	rs.Close()
	return PesqList
}

chooseyourversion(){
	Global GLOBAL_COLOR,TAB_COLOR,BANNER_COLOR

	gui,chooseyourversion:New
	gui,chooseyourversion:+toolwindow -caption
	Gui,add,picture,w200 h200 gdarkversion,bad.png
	Gui,add,picture,x+5 w200 h200 glightversion,good.png
	Gui,Show,,Escolha sua versao!
	return 

	darkversion:
	TAB_COLOR:="FFFFFF"
	GLOBAL_COLOR:="000000"
	BANNER_COLOR:="purple"
	;Gosub,continuetoloadtheprogram
	return 

	lightversion:
	TAB_COLOR:="000000"
	GLOBAL_COLOR:="ffffff"
	BANNER_COLOR:="blue"
	;Gosub,continuetoloadtheprogram
	return 
}
;renomear(table,field,window,lv,mascaraant)
renomear(args)
{
	Global db,args1,GLOBAL_COLOR,bannerargs,TextOptions,Font,BANNER_COLOR
	Static NewMascara,NewName,selecteditem,banner
	args1 := args
	selecteditem := GetSelected("inserir1","lv") 
	result:=db.query("SELECT " . args["field2"] . " FROM " . args["table"] . " WHERE " . args["field1"] . "='" . selecteditem . "'")
	if(selecteditem = field1) || (selecteditem = field2){
		MsgBox,64,, % "Selecione um item antes de continuar"
		return 
	}
	Gui,renomear:New
	owner := args["owner"]
	if(owner != "")
		Gui,renomear:+owner%owner%
	Gui,color,%GLOBAL_COLOR%
	Gui,Add,Picture,w250 h50 0xE vbanner 
	banner(BANNER_COLOR,banner,"Renomear")
	Gui, Add, Text, xm y+5 w70 h20 , Nome:
	Gui, Add, Edit, xm y+5 w230 r1 vNewName uppercase,% selecteditem
	Gui, Add, Text, xm y+5 w70 h20 , Mascara:
	Gui, Add, Edit, xm y+5 w230 r1 vNewMascara uppercase,% result[args["field2"]]
	Gui, Add, Button, xm y+5 w100 h30 gsalvarr,&Salvar
	Gui, Add, Button, x+5 w100 h30 gcancelarr,&Cancelar
	Gui, Show,,Renomear
	result.close()
	return

		salvarr:
		Gui,submit,nohide
		if(!NewName) || (!NewMascara) || (!selecteditem){
			MsgBox,64,, % "O nome e a mascara nao podem estar em branco!"
			return 
		}
		db.rename(args1["field1"] . "= '" . NewName . "'," . args1["field2"] . "='" . NewMascara . "'",args1["field1"] . "='" . selecteditem . "';",args1["table"])
		nName:=args1["mascaraant"] . NewName
		StringReplace,value,nName,%A_Space%,,All
		nName2:=args1["mascaraant"] . selecteditem 
		StringReplace,value2,nName2,%A_Space%,,All
		db.rename("tabela1= '" . value . "'","tabela1='" . value2 . "';","reltable")
		db.loadlv("inserir1","lv",args1["table"])
		Gui,renomear:destroy
		return 
	
		cancelarr:
		Gui,renomear:destroy 
		return 
} 

renomear2(args)
{
	Global db 
	Global args1,selecteditem,NewName
	Static NewMascara
	args1:=args 
	selecteditem := GetSelected(args1["window"],args1["lv"])
	args1["selecteditem"] := selecteditem
	if(selecteditem = field1) || (selecteditem = field2)
	{
		MsgBox,64,, % "Selecione um item antes de continuar"
		return 
	}
	gui,renomear:New
	Gui,color,%GLOBAL_COLOR%
	Gui, Add, Text, x7 y55 w70 h20 , Nome:
	Gui, Add, Edit, x57 y45 w230 h30 vNewName uppercase,% selecteditem
	Gui, Add, GroupBox, x-3 y-5 w300 h180 , Inserir
	Gui, Add, Button, x72 y130 w100 h30 gsalvarr2,&Salvar
	Gui, Add, Button, x182 y130 w100 h30 gcancelarr2,&Cancelar
	Gui, Show,w309 h183,Renomear
	return
	
		salvarr2:
		Gui,submit,nohide
		if(!NewName) || (!selecteditem)
		{
			MsgBox,64,, % "O nome e a mascara nao podem estar em branco!"
			return 
		}
		func := args1["func"]
		%func%(args1)
		db.loadlv(args1["window"],args1["lv"],args1["loadtable"],args1["loadfield"])
		Gui,renomear:destroy
		return 
	
		cancelarr2:
		Gui,renomear:destroy 
		return 
} 

salvarr1(args1){
	Global db,NewName
	
	db.rename(args1["field2"] . "= '" . NewName . "'",args1["field2"] . "='" . args1["selecteditem"] . "';",args1["camptable"])
	;db.rename(args1["field2"] . "= '" . NewName . "'",args1["field2"] . "='" . args1["selecteditem"] . "';",args1["camptable"])
	;db.rename(args1["field2"] . "= '" . NewName . "'",args1["field2"] . "='" . args1["selecteditem"] . "';",args1["camptable"])
	nName:=args1["mascaraant"] . NewName
	StringReplace,value,nName,%A_Space%,,All   
	nName2:=args1["mascaraant"] . args1["selecteditem"] 
	StringReplace,value2,nName2,%A_Space%,,All 
	db.rename("tabela2= '" . value . "'","tabela1='" . value2 . "';","reltable")
	db.rename("tipo= '" . NewName . "'","tipo='" . args1["selecteditem"] . "';","reltable")
}

salvarr2(args1){
	Global db,NewName

	db.rename(args1["field2"] . "= '" . NewName . "'",args1["field2"] . "='" . args1["selecteditem"] . "';",args1["table"])
	MsgBox,64,, % "Modificacao salva com sucesso!!"
}


copiar()
{
}

inserir2(args)
{
	Global db,args1,GLOBAL_COLOR,bannerargs,TextOptions,Font,BANNER_COLOR,tvstring
	Static updown1,lv,foto,banner
	
	args1:=args
	Static edit1,edit2
	Gui, inserir2:New
	owner:=args["owner"]
	if(owner!="")
		Gui,inserir2:+owner%owner%
	;Gui,inserir2:+toolwindow
	Gui,color,%GLOBAL_COLOR%
	Gui,Add,Picture,w250 h50 0xE vbanner 
	banner(BANNER_COLOR,banner,"Inserir")
	Gui, Add, Text,xm y+5 w70 h20 , Nome:
	Gui, Add, Edit,xm y+5 w230 h30 vedit1 r1 uppercase,
	Gui, Add, Text, xm y+5 w70 h20 , Mascara:
	Gui, Add, Edit, xm y+5 w230 h30 vedit2 r1 uppercase,Mascara Codigo
	Gui, Add, Button, xm y+5  w100 h30 gsalvar,&Salvar
	Gui, Add, Button, x+5  w100 h30 gcancelar,&Cancelar
	Gui, Show,,Empresa-Alterar-Inserir
	return
			
		salvar:
		Gui,submit,nohide
		if(!edit1) || (edit1="Nome Empresa") || (edit2="Mascara Codigo")
		{
			MsgBox,64,, % "Nenhum dos valores podem estar em branco"
			return 
		}
		;MsgBox, % "create " . table1 . "`nfield1 " . field1 . "`nprimaryk " . primaryk1
		db.createtable(args1["table"],"(" . args1["field"] . ", PRIMARY KEY(" . args1["primarykey"] . "))")
		istring:="('" . edit1 . "','" . edit2 . "')"
		db.insert(args1["table"],"(" . args1["field"] . ")",istring)
		relcondition:=args1["relcondition"]
		if(relcondition){
			if(!db.exist("tipo,tabela1","tipo='" . args1["tipo"] . "' AND tabela1='" . args1["mascaraant"] . edit1 . "'","reltable"))
				db.insert("reltable","(tipo,tabela1,tabela2)","('" . args1["tipo"] . "','" . args1["mascaraant"] . edit1 . "','" . args1["mascaraant"] . edit2 . args1["tipo"] . "')")
		}else{
			;MsgBox,64,, % "relcondition igual a false"
		}
		db.loadlv("inserir1","lv",args1["table"])
		MsgBox,64,, % "valores inseridos com sucesso!!"
		closefunc:=args1["closefunc"]
		;MsgBox, % "closefunc "closefunc
		;tvstring:=""
		;gettable("empresa",0,"","")
		%closefunc%(args)
		;Gui,inserir2:destroy
		return 
		
		cancelar:
		Gui,inserir2:destroy
		return 
}

inserir3(table,field,primarykey,tipo,mascaraant="")
{

	Global db,GLOBAL_COLOR
	Static lv3
	Global table1,field1,primaryk1,tipo1,field3,mascaraant1
	table1:=table,field1:=field,primaryk1:=primarykey,tipo1:=tipo,mascaraant1:=mascaraant
	StringSplit,value,field,`,
	field3:=value1
	Gui,inserir3:New
	Gui,color,%GLOBAL_COLOR%
	Gui, Add, ListView, x32 y50 w320 h290 vlv3 altsubmit,
	Gui, Add, GroupBox, x22 y20 w360 h340 ,Valores
	Gui, Add, GroupBox, x12 y0 w670 h480 , Alterar
	Gui, Add, GroupBox, x22 y370 w650 h100 , Alterar
	Gui, Add, Button, x112 y410 w120 h30 ginserir3,&Incluir
	Gui, Add, Button, x+5 y410 w120 h30 glinkar3, &Linkar
	Gui, Add, Button, x+5 y410 w120 h30 gexcluir3, &Excluir
	Gui, Show, w700 h492,Incluir-Bloqueio
	db.loadlv("inserir3","lv3",table,field)
	return

	linkar3:
	linkar(tipo1)
	RETURN 

	inserir3:
	Gui,submit,nohide
	inserir4(table1,field1,primaryk1,tipo1,mascaraant1)
	return 

	excluir3:
	selecteditem:=GetSelected("inserir3","lv3")
	MsgBox, 4,,Deseja apagar a empresa %selecteditem%?
	IfMsgBox Yes
	{
		db.delete(table1,selecteditem,field3)
		db.loadlv("inserir3","lv3",table1,field1)
	}else{
		return 
	}
	return 
}

compararcamp(camptable,otable)
{
	Global db 
	;se um valor da tabela 1 nao estiver na 2 ,incluir 
	sql:="SELECT Campos FROM " . camptable
	rs := db.query(sql)
	while(!rs.EOF){   
	  campvalue := rs["Campos"]
	  _exist:=FALSE
	  sql:="SELECT Campos FROM " . otable
	  rs2 := db.query(sql) 
	  while(!rs2.EOF){
	  	if(campvalue=rs2["Campos"])
	  		_exist:=TRUE
	  	rs2.MoveNext()
 	  }
 	  rs2.Close()    
 	  if(!_exist)
 	  	db.insert(otable,"(Campos)","('" . campvalue . "')")
	  rs.MoveNext()
	}
	rs.Close()
	;se um valor da tabela 2 nao estiver na 1 ,exclui
	sql:="SELECT Campos FROM " . otable
	rs := db.query(sql)
	while(!rs.EOF){   
	  campvalue := rs["Campos"]
	  _exist:=FALSE
	  sql:="SELECT Campos FROM " . camptable
	  rs2 := db.query(sql) 
	  while(!rs2.EOF){
	  	if(campvalue=rs2["Campos"])
	  		_exist:=TRUE
	  	rs2.MoveNext()
 	  }
 	  rs2.Close()
 	  if(!_exist)
 	  	db.delete(otable,campvalue,"Campos")
	  rs.MoveNext()
	}
	rs.Close()
}

inserir4(table,field,primaryk,tipo,mascaraant="")
{
	Global db,selectmodel
	;MsgBox, % "table " . table . "`nfield " . field . "`nprimaryk " . primaryk . "`ntipo " . tipo
	Static edit1
	Global table1,field1,primaryk1,tipo1,mascaraant1
	table1:=table,field1:=field,primaryk1:=primaryk,tipo1:=tipo,mascaraant1:=mascaraant
	Gui, inserir4:New
	Gui,color,%GLOBAL_COLOR%
	Gui, Add, Text, x7 y55 w70 h20 , Nome:
	Gui, Add, Edit, x57 y45 w230 h30 vedit1 r1 uppercase,
	Gui, Add, GroupBox, x-3 y-5 w300 h180 , Inserir
	Gui, Add, Button, x72 y130 w100 h30 gsalvar4,&Salvar
	Gui, Add, Button, x182 y130 w100 h30 gcancelar4,&Cancelar
	Gui, Show, w309 h200,Inserir-Bloqueio
	return
			
		salvar4:
		Gui,submit,nohide
		if(!edit1)
		{
			MsgBox,64,, % "Nenhum dos valores podem estar em branco"
			return 
		}
		db.createtable(table1,"(" . field1 . ", PRIMARY KEY(" . primaryk1 . "))")
		istring:="('" . edit1 . "')"
		if(!db.exist("tipo,tabela1","tipo='" . tipo1 . "' AND tabela1='" . mascaraant1 . selectmodel . "'","reltable"))
		{
			db.insert("reltable","(tipo,tabela1,tabela2)","('" . tipo1 . "','" . mascaraant1 . selectmodel . "','" . mascaraant1 . edit2 . tipo1 . "')")
		}
		db.insert(table1,"(" . field1 . ")",istring)
		db.loadlv("inserir3","lv3",table1)
		Gui,inserir4:destroy
		return 
		
		cancelar4:
		Gui,inserir4:destroy
		return 
}

LV_MoveRowfam(wname,lvname,moveup = true) {
	gui,%wname%:Default
    gui,listview,%lvname%
   ; Original by diebagger (Guest) from:
   ; http://de.autohotkey.com/forum/viewtopic.php?p=58526#58526
   ; Slightly Modifyed by Obi-Wahn
   If moveup not in 1,0
      Return   ; If direction not up or down (true or false)
   while x := LV_GetNext(x)   ; Get selected lines
      i := A_Index, i%i% := x
   If (!i) || ((i1 < 2) && moveup) || ((i%i% = LV_GetCount()) && !moveup)
      Return   ; Break Function if: nothing selected, (first selected < 2 AND moveup = true) [header bug]
            ; OR (last selected = LV_GetCount() AND moveup = false) [delete bug]
   cc := LV_GetCount("Col"), fr := LV_GetNext(0, "Focused"), d := moveup ? -1 : 1
   ; Count Columns, Query Line Number of next selected, set direction math.
   Loop, %i% {   ; Loop selected lines
      r := moveup ? A_Index : i - A_Index + 1, ro := i%r%, rn := ro + d
      ; Calculate row up or down, ro (current row), rn (target row)
      Loop, %cc% {   ; Loop through header count
         LV_GetText(to, ro, A_Index), LV_GetText(tn, rn, A_Index)
         ; Query Text from Current and Targetrow
         LV_Modify(rn, "Col" A_Index, to), LV_Modify(ro, "Col" A_Index, tn)
         ; Modify Rows (switch text)
      }
      LV_Modify(ro, "-select -focus"), LV_Modify(rn, "select vis")
      If (ro = fr)
         LV_Modify(rn, "Focus")
   }
}

#include, lib\promto_sql_mariaDB.ahk
#include, models\remover_item_ETF.ahk
#include <promtolib>
#include,lib\json_parser.ahk
#include,<SQL_new>

/*
	Views
*/
#include, views/inserir_ETF_view.ahk
#include, views/inserir_modelo_view.ahk
#include, views/shared/inserir_dialogo_2_fields.ahk
#include, views/shared/inserir_imagem_view.ahk
#include, views/shared/inserir_imagem_db_view.ahk
