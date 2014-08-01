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
global_image_path := settings.image_folder_path 
global_cert_path := settings.cert_folder_path
lv_grid := settings.lv_grid
MARIADB_PATH := settings.mariaDB_path
HOST := settings.host
StringReplace, global_image_path, global_image_path, /,\, All
StringReplace, global_cert_path, global_cert_path, /,\, All
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

GLOBAL_TVSTRING := ""
ETF_TVSTRING := ""
S_ETF_hashmask := {}
hashmask:={},field:=["Aba", "Familia", "Subfamilia", "Modelo"]
_reload_gettable := True

E:
/*
	Gui init
*/
Gui, initialize:New
Gui, Font, s%SMALL_FONT%, %FONT%
Gui, Color, %GLOBAL_COLOR%
Gui, Add, Picture, x30 ym, img\promtologo.png

/*
	Nome do usuario
*/
Gui, Add, Groupbox, xp-20 y+10 w300 h110, Usuario
Gui, Add, Text, xp+5 yp+15, Nome:
Gui, Add, Edit, w280 vuser_name, 
Gui, Add, Text, , Senha:
Gui, Add, Edit, w280 vuser_password password,
;Gui, Add, Button, w150 h20 y+10 gmanager_users, Gerenciar usuarios

/*
	Localizacao
*/
Gui, Add, Groupbox, xm y+10 w300 h80 , Localizacao DB
Gui, Add, Edit, xp+25 yp+25 w250 vdb_location_to_save , %db_location%

/*
	Opcoes
*/
Gui, Add, Groupbox, xm y+25 w300 h60, Opcoes
Gui, Add, Button, xp+45 yp+20 w100 h30 gloading_main vloading_main Default, Iniciar
Gui, Add, Button, x+5 w100 h30 gedit_config_file vedit_config_file, Editar Configuracao
Gui, Show,,	Inicializacao 
Return

	edit_config_file:
	Return

	loading_main:
	Gui, Submit, Nohide
	USER_NAME := user_name
	Gui, initialize:default
	GuiControl, Disable, loading_main,
	GuiControl, Disable, edit_config_file
	Gui, Add, Text, xm y+10, Carregando...
	Gui, Add, Progress, xm y+5 vprogress  -Smooth 0x8 w300 h18
	Gui, Show, AutoSize, Carregando...
	undetermine_progress_window := "initialize"
  SetTimer, undetermine_progress_action, 45
  load_ETF(db)
  Gui, initialize:destroy
  Gosub, M
	Return 

		undetermine_progress_action:
		Gui, %undetermine_progress_window%:default
		GuiControl,, progress, 1
		Return

manager_users:
manager_users_view()
return

M:
/*
	Gui init	
*/
Gui, M:New
Gui, Font, s%SMALL_FONT%, %FONT%
Gui, Color, %GLOBAL_COLOR%

/*
	Logo tipo
*/
Gui, Add, Picture, xm ym,img\promtologo.png

;/*
;	Familias
;*/
;Gui, Add, Groupbox, xm y+10 w230 h40,Pesquisa
;Gui, Add, Edit, xp+5 yp+15 w220,

/*
	Empresas/Tipos/Familias
*/
Gui, Add, Groupbox, xp-5 y+10 w290 h450, Empresas/Tipos/Familias
Gui, Add, TreeView, xp+5 yp+15 w280 h430 vmain_tv gmain_tv
load_main_tv()

/*
	Opcoes
*/
Gui, Add, Groupbox, xm y+10 w230 h60, Opcoes
Gui, Add, Button, xp+25 yp+15 w100 h30 ginsert_empresa, Criar Empresa 
Gui, Add, Button, x+5 w40 h30 hwndhBtn grecarregar_main_tv

;Gui, Add, Button, x+t w40 h30 gHTML, HTML
ILButton(hBtn, "promtoshell.dll:" 5, 32, 32, 0)

/*
	Modelos 
*/
Gui, Add, Groupbox, xm+300 ym w220 h290, Modelos 
Gui, Add, Listview, xp+5 yp+15 w200 h270 section  vMODlv gMODlv altsubmit %lv_grid%, Modelo|Mascara
Gui, Add, Groupbox, xm+300 y+10 w220 h60, Numero de items:
Gui, Font, s15
Gui, Add,	Text, xp+75 yp+15 w100 vnumberofitems cblue,
Gui, Font, s8

/*
	Opcoes
*/
Gui, Add, Groupbox, xm+300 y+20 w220 h300, Opcoes 
Gui, Add, Button, hwndhMod xp+5 yp+15 w100 h30 gMAM, Modelos
glabels := ["MAB", "MAC", "ordemprefix", "MAOC", "MAODC", "MAODR", "MAODI"]
for,each,value in ["Bloqueados", "Campos", "Ordem Prefixo", "Ordem Codigo", "Ordem Desc Completa", "Ordem Desc Resumida", "Ordem Desc Ingles"]{
	glabel := glabels[A_Index]
	Gui, Add, Button, wp hp g%glabel%,% "&" value
}
Gui, Add, Button, x+5 y380 wp hp ggerarcodigos, Gerar Codigos
glabels := ["gerarestruturas","linkarm","dbex", "massaestrut", "codetable", "plotcode", "certificados"]
for,each,value in ["Gerar Estruturas", "Linkar", "Add db Externo", "Estrutura", "Lista de Codigos", "Imprimir", "Certificados"]{
	glabel := glabels[A_Index]
	Gui, Add, Button, wp hp g%glabel%,% "&" value
}

/*
	Status
*/
Gui, Add, Groupbox, x540 ym w315 h90, Status
Gui, Add, Picture, xp+5 yp+15 vstatus_picture, % "img\gray_glossy_ball.png"
Gui, Add, Text, x+5 w220 h60 vstatus_info,
Gui, Add, Button, x540 y+15 w80 h20 gchange_status , Alterar status

/*
	Info
*/
Gui, Add, Picture, xp y+15 w268 h156 vptcode gfotoindividual, % "img\promtologo.png"
Gui, Add, Listview, x+5 yp w540 h300 vall_mod_lv gall_mod_lv altsubmit %lv_grid%,
_loading := 1

/*
	Certificacao
*/
Gui, Add, Groupbox, x540 y+20 w815 h60, Certificacao:
Gui, Font, cgreen s20
Gui, Add, Text, xp+5 yp+15 w400 h30 vcert_status, 
Gui, Font, cblack s8

/*
	Ultimas atualizacoes
*/
Gui, Add, Groupbox, x540 y+20 w815 h150, Ultimas atualizacoes:
Gui, Font, cgreen
Gui, Add, Text, xp+5 yp+15 w365 h80 vmod_info,
Gui, Font, cblue 
Gui, Add, Text, x+2 w300 h80 vmsg_info,
Gui, Font, cblack

;/*
;	Formacao codigo
;*/
;Gui, Add, Groupbox, x480 y+10 w815 h200, Formacao do codigo:
;Gui, Add, Picture, xp+5 yp+50 w790 h190 vfmcode,

/*
	Consistencia DBEX Totallight
*/
Gui, Add, Groupbox, x860 ym w150 h90, Totallight
Gui, Add, Picture,  xp+5 yp+15 vconsistency_picture_tot, % "img\gray_glossy_ball.png"
Gui, Add, Button,   x865 y+15 w80 h20 gverify_tot, Verificar

/*
	Consistencia DBEX Maccomevap
*/
Gui, Add, Groupbox, x1020 ym w150 h90, Maccomevap
Gui, Add, Picture, xp+5 yp+15 vconsistency_picture_mac, % "img\gray_glossy_ball.png"
Gui, Add, Button, x1025 y+15 w80 h20 gverify_mac, Verificar

/*
	Menu de backup
*/
Menu, update_menu,   Add, Atualizar, make_update
Menu, backup_menu,   Add, Fazer Back up, make_back_up
Menu, users_menu,    Add, Usuarios, manager_users
Menu, list_menu,     Add, Listas, list_options
Menu, xml_menu,      Add, XML, xml
Menu, imagem_menu,   Add, Redimensionar, resize_image_folder 
Menu, backup_menu,   Add, Carregar Back up, load_back_up
Menu, main_menu_bar, Add, &Atualizar, :update_menu
Menu, main_menu_bar, Add, &Back up, :backup_menu
Menu, main_menu_bar, Add, &Usuarios, :users_menu
Menu, main_menu_bar, Add, &XML, :xml_menu
Menu, main_menu_bar, Add, &Imagem, :imagem_menu
Menu, main_menu_bar, Color, White
Gui, Menu, main_menu_bar
Gui, Show,, %FamiliaName%

Gui, Listview, MODlv
LV_ModifyCol(2,300) 
LV_Modify(2, "+Select")
_loading := 0
return	

certificados:
cert_view("", "M")
return

resize_image_folder:
resize_image_folder_view()
return

all_mod_lv:
if A_GuiEvent = I
{
	if(ErrorLevel = "")
		return
	Gui, Submit, Nohide
	info := get_item_info("M", "MODlv") 
	selected_mod := GetSelectedRow("M", "all_mod_lv")
	if(selected_mod[1] = "" || selected_mod[1] = "Codigos")
		return 
	image_path := db.Imagem.get_image_full_path(selected_mod[1])
	if(image_path != ""){
		change_ptcode := 1
		Guicontrol,, ptcode, % image_path 
	}else{
		change_ptcode := 1
		Guicontrol,, ptcode, % "img\sem_foto.jpg"
	}	
}
return



verify_tot:
info := get_item_info("M", "MODlv")
tot_connection := get_connection("TOTALLIGHT")
base_value := get_data_base_value("TOTALLIGHT")
if(base_value = "")
	return
code_table :=
(JOIN
	info.empresa[2]
	info.tipo[2] 
	info.familia[2] 
	info.subfamilia[2] 
	info.modelo[2] "Codigo"
)
current_code_list := db.load_table_in_array(code_table)
missing_codes := DBEC.codes(info, tot_connection, base_value, current_code_list) 
if(missing_codes.maxindex() > 0){
  DBEC.change_code_status(0, "consistency_picture_tot")
}else{
	DBEC.change_code_status(1, "consistency_picture_tot")
}
return 

verify_mac:
info := get_item_info("M", "MODlv")
mac_connection := get_connection("MACCOMEVAP")
base_value := get_data_base_value("MACCOMEVAP")
if(base_value = "")
	return
code_table :=
(JOIN
	info.empresa[2]
	info.tipo[2] 
	info.familia[2] 
	info.subfamilia[2] 
	info.modelo[2] "Codigo"
)
current_code_list := db.load_table_in_array(code_table)
missing_codes := DBEC.codes(info, mac_connection, base_value, current_code_list) 
if(missing_codes.maxindex() > 0){
  DBEC.change_code_status(0, "consistency_picture_mac")
}else{
	DBEC.change_code_status(1, "consistency_picture_mac")
}
return

MGuiClose:
ExitApp
return

list_options:
list_options_view()
return

xml:
generate_xml_view()
return 

HTML:
generate_html_view()
return

insert_empresa:
inserir_ETF_view("M", "main_tv", "", "Empresas")
return

recarregar_main_tv:
Gui, M:default
Gui, Treeview, main_tv
TV_Delete() 
ETF_TVSTRING := ""
load_ETF(db)
load_main_tv()
return

change_status:
info := get_item_info("M", "MODlv")
change_status_view(info)
return

MGuiContextMenu:
if A_GuiControl = main_tv
{
	/*
		verifica em que nivel a selecao esta
		caso esteja no nivel tres somente
		a opcao de remover aparecera, a menos que a familia 
		selecionada tenha uma subfamilia.
	*/
	tv_level_menu := get_tv_level("M", "main_tv") 
	Menu, main_tv_menu, Add, Adicionar, adicionar_item
	Menu, main_tv_menu, Add, Remover, remover_item	
	Menu, remover_menu, Add, Remover, remover_item
	/* 
		Pega a tabela onde serao inseridos 
		os valores
	*/
	current_selected_name := get_item_from_tv(A_EventInfo)
	current_id := A_EventInfo
	/*
		Caso a selecao esteja no nivel de insercao 
		de tipos
	*/

	if(tv_level_menu = 1){
		current_columns := "Abas"
		info := get_item_info("M", "MODlv")
		tabela1 := info.empresa[1] 
		Menu, main_tv_menu, Show, x%A_GuiX% y%A_GuiY%
	}

	/*
		Caso a insercao esteja no nivel 
		de familias
	*/

	if(tv_level_menu = 2){
		current_columns := "Familias"
		info := get_item_info("M", "MODlv")
		tabela1 := info.empresa[2] info.tipo[1]
		Menu, main_tv_menu, Show, x%A_GuiX% y%A_GuiY%
	}

	if(tv_level_menu = 3){
		current_columns := "Subfamilias"
	}

	/*
		Caso esteja no nivel das familias e a familia nao tenha subfamilia nao existe opcao de incluir
	*/
	if(tv_level_menu = 3){
		info := get_item_info("M", "MODlv")
		tabela1 := info.empresa[2] info.tipo[2] info.familia[1]
		if(db.have_subfamilia(tabela1)){
			Menu, main_tv_menu, Show, x%A_GuiX% y%A_GuiY%		
		}else{
			Menu, remover_menu, Show, x%A_GuiX% y%A_GuiY%
		}	
	}
	
	if(tv_level_menu = 4){
		info := get_item_info("M", "MODlv")
		tabela1 := info.empresa[2] info.tipo[2] info.familia[1] info.subfamilia[1]
		Menu, remover_menu, Show, x%A_GuiX% y%A_GuiY%
	}
}
return

	adicionar_item:
	inserir_ETF_view("M", "main_tv", current_id, current_columns)
	return 

	remover_item:
	Gui, M:default
	Gui, Treeview, main_tv
	selected_name := get_item_from_tv(current_id)
	MsgBox, 4,,Deseja apagar o item %selected_name% e todos os seus subitems? 
	IfMsgBox No
	{
		return
	}
	delete_confirmation_view(selected_name)
	return

	main_tv:
  /*
  	funcao que busca o nivel 
  	que a selecao esta
  */
  tv_level := get_tv_level("M", "main_tv")

  /*
   Limpa todas as informacoes deixadas pela ultima selecao
  */
  clear_main_info()

  if(tv_level = 3 || tv_level = 4){
  	/*
  		Se estiver no nivel das 
  		familias ira buscar a tabela de modelos
  		e carrega-la na listview ao lado. 
  	*/
  		
  	/*
  		Verifica se o nivel atual tem um subnivel
  		se tiver retorna sem carregar tabela de modelo
  	*/
  	if(tv_level = 3){
  		info := get_item_info("M", "MODlv")
  		tabela1 := info.empresa[2] info.tipo[2] info.familia[1]
			if(db.have_subfamilia(tabela1)){
				;load_logo_in_main()
				return
			}else{
				/*
  			Pega a tabela de modelos
  			*/	 
  			info := get_item_info("M", "MODlv")
				model_table := db.get_reference("Modelo", info.empresa[2] info.tipo[2] info.familia[1])
			}
  	}
  	
  	if(tv_level = 4){
  		info := get_item_info("M", "MODlv")
			model_table := db.get_reference("Modelo", info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[1])
  	}
		/*
			Metodo que carrega a lista de modelos
			em determinada listview
		*/
		;db.Modelo.check_data_consistency(model_table, info) ;verifica se todos os elementos na lista tem as tabela necessarias.
		db.load_lv("M", "MODlv", model_table)
		LV_ModifyCol(1)
		;load_logo_in_main()	
  }else{
  	/*
  		Funcao que substui a imagem que foi gerada
  		no load_image... pelo logo do programa
  	*/
  	;load_logo_in_main()
  }
	return 

	fotoindividual:
	foto_individual_view()
	;Gui,submit,nohide
	;massainsertphoto(codtable) 
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
	;Guicontrol,, ptcode, simpleplot.png
	return  

	plotcode:
	info := get_item_info("M", "MODlv")
	Print.product_list(info)

	/*
	Gui,escolha_plotcode:New
	Gui,font,s%SMALL_FONT%,%FONT% 
	Gui,add,button,w100 gplotar_esse_item,Imprimir item marcado
	Gui,add,button,x+5 w100 gplotar_todos_os_items,Imprimir todos os items 
	Gui,add,button,xm y+5 w100 gplotar_todos_os_items_em_lista,Imprimir lista com todos os items 
	Gui,Show,,Imprimir Escolha
	*/
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
	selecteditem:=GetSelected("M", "MODlv")
	currentvalue:=GetSelectedRow("M", "MODlv")
	selectmodel:=selecteditem
	result:=db.query("SELECT Mascara FROM " . modtable . " WHERE Modelos='" . selecteditem . "'")
	ModeloMascara:=result["Mascara"]
	prefixpt2:=""
	for,each,value in list := db.getvalues("Campos",EmpresaMascara AbaMascara FamiliaMascara ModeloMascara "prefixo"){
		prefixpt2 .= list[A_Index,1]	
	} 
	StringReplace,prefixpt2,prefixpt2,% currentvalue[2],,All
	_showcode:=1
	MsgBox, % "currentvalue: " currentvalue[2] "  modelpt: " modelpt 
	plotptcode(EmpresaMascara AbaMascara FamiliaMascara,prefixpt2,currentvalue[2],1,900,6000)
	return 

;MGuiSize:
;GuiSize:
;	UpdateScrollBars(A_Gui, A_GuiWidth, A_GuiHeight)
;return

	codetable:
	info := get_item_info("M", "MODlv")
	lista_de_codigos(info)
	return  

	massaestrut:
	estruturas_view()
	return

		exportarparaarquivo:
		checkeditems := GetCheckedRows2("massaestrut","estrutlv")
		filedelete, dadosestrutura.csv
		MsgBox, % checkeditems["code"].maxindex()
		FileAppend,% "G1_COD;G1_COMP;G1_QUANT;G1_INI;G1_FIM;G1_FIXVAR;G1_REVFIM;G1_NIV;G1_NIVINV`n", dadosestrutura.csv
		already_in_structure := ""
		number_of_parents := 0
		for,each,value in checkeditems["code"]{
			loadestruturatofile(checkeditems["code",A_Index] ">>" checkeditems["desc",A_Index])
		}
		run,dadosestrutura.csv
		Gui,progress:destroy
		MsgBox, % "As estruturas foram exportadas"
		return 

		

		exportarparadb:
		checkeditems:=GetCheckedRows2("massaestrut","estrutlv")
		rs:=sigaconnection.OpenRecordSet("SELECT TOP 1 G1_COD,G1_COMP,R_E_C_N_O_ FROM SG1010 ORDER BY R_E_C_N_O_ DESC")
		R_E_C_N_O_TBI := rs["R_E_C_N_O_"]
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


			

			pesquisaraddmass:
			Gui,submit,nohide
			any_word_search("addmassa","lvaddmass",pesquisaraddmass,Listaddmass)
			return 


			remmassabutton:
			Gui,submit,nohide 	
			count:=0
			for,each,value in checkedremmassa["code"]{
				count++
				table := db.iquery("SELECT item,componente FROM ESTRUTURAS WHERE item LIKE '" checkedremmassa["code",A_Index] "%' AND componente LIKE '" remedit "%';")
				if(table.Rows.Count()=0){
					MsgBox, % "O item a ser deletado nao existia na estrutura: " checkedremmassa["code",A_Index] 
					count -= 1
				}
				db.query(db.query("DELETE FROM ESTRUTURAS WHERE item like '" checkedremmassa["code",A_Index] "%' AND componente like '" remedit "%';"))
			}

			if(count = 0){
				MsgBox, % "Nenhum item foi removido"
			}else{
				MsgBox,64,, % "o item " remedit " foi removido de " count " estruturas!!!"
			}
			return

	ordemprefix:
	info := get_item_info("M", "MODlv")
	ordem_view("prefixo", info)
	return 

	dbex:
	config_db_ex_view()
	return 
	

CODlv:
if A_GuiEvent = DoubleClick
{
	LV_GetText(selected,A_EventInfo)
	tvstring := ""
	loadestrutura(selected, "")
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
					tvstring .= "`n" . nivel . item
				else 
					tvstring .= "`n" . nivel . item . "|UN:" quantidade
		 	}
		}
	 }
	while(!table.EOF){
		tableitem:=table["item"]	
		if(ownercode!=""){
			IfNotInString,%ownercode%,%tableitem%
			{
				%ownercode% .= "`n" table["item"]
				if(semUN=1)
					tvstring .= "`n" . nivel . table["item"]
				else 
				 	tvstring .= "`n" . nivel . table["item"] . "|UN:" quantidade
			}
		}else{
			IfNotInString,maincodes,%tableitem%
		 	{
				maincodes .= "`n" tableitem
				if(semUN=1)
					tvstring .= "`n" . nivel . table["item"]
				Else
					tvstring .= "`n" . nivel . table["item"] . "|UN:1" 
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
		}
		IfNotInString,already_in_structure,%itemtbi1%;%componentetbi1%
		{
			if(testprefix="TL0"){
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
			sigaconnection.query(sql)
		}
		exist := existindb(sigaconnection,"Select B1_COD from SB1010 WHERE B1_COD LIKE '" itemtbi1 "%'")
		if(exist=false){
			FileAppend, % itemtbi1 "`n",missingitems.csv
		}
		exist := existindb(sigaconnection,"Select B1_COD from SB1010 WHERE B1_COD LIKE '" componentetbi1 "%'")
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
args["table"] := "empresa", args["loadfunc"] := "gettable", args["mascaraant"] := EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara,args["savetvfunc"] := "savetvfunc1"
field := ["Aba","Familia", "Subfamilia", "Modelo"], args["owner"] := "M"
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
subitem[selectedsubitem] := A_EventInfo
return 

gettable(table,x,nivel,masc){
	Global db,GLOBAL_TVSTRING,field,hashmask
	x+=1,nivel.="`t"
	For each in list := db.getvalues("*",table){
		GLOBAL_TVSTRING .= "`n" . nivel . list[A_Index,1] 
		hashmask[list[A_Index,1]] := list[A_Index,2]
		;MsgBox, % "valor do hashmask " hashmask[list[A_Index,1]] "`n para o valor " list[A_Index,1] 
		result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='" . field[x] . "' AND tabela1='" . masc . list[A_Index,1] . "'")
		newtable := result["tabela2"]
		result.close()
		if(newtable)
			gettable(newtable,x,nivel,masc . list[A_Index,2])
	}
	return 
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
if A_GuiEvent = I
{
	Gui,submit,nohide
	info := get_item_info("M", "MODlv") 
	if(info.modelo[1] != "Modelo"){	
		clear_prev_status()
		load_model_image_in_main_window(info)
		load_mod_info(info)
		load_all_mod(info)
		load_status_in_main_window(info)
		load_cert_status(info)
	}
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
	;Guicontrol,, ptcode, simpleplot.png
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
		info := get_item_info("M", "MODlv")
		if(get_tv_level("M", "main_tv") != 3 && get_tv_level("M", "main_tv") != 4){
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
			Verifica se a familia e uma subfamilia ou nao
		*/
		;MsgBox, % "info subfamilia " info.subfamilia[2]
		if(info.subfamilia[2] != ""){
			model_table := db.get_reference("Modelo",info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[1])	
		}else{
			;MsgBox, % "ira buscar a tabela de modelos sem subfamilia " info.empresa[2] info.tipo[2] info.familia[1]
			model_table := db.get_reference("Modelo", info.empresa[2] info.tipo[2] info.familia[1])
		}
		inserir_modelo_view(model_table)
		return
		
		reloadmodelo(){
			Global
			db.loadlv("M","MODlv",modtable,"Modelos,Mascara",1)
		}

refreshm(){
	Global _refresh 
	_refresh := true
	gosub,M
}		
		
		MAB:
		info := get_item_info("M", "MODlv")
		
		if(info.modelo[2] = ""){
			MsgBox, 16, Erro, % "Selecione um modelo antes de continuar!"
			return 
		}
		
		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1] 
		bloq_table := db.get_reference("Bloqueio", tabela1)
		if(bloq_table = "")
			bloq_table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "Bloqueio"
		
		/*
			Cria a tabela de bloqueios caso ela nao exista
		*/ 
		db.Modelo.create_tabela_bloqueio(bloq_table, info)
		inserir_bloqueio_view()
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
				Gui, progress:destroy
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
;#												  
;#					Campos						  
;#										          
;##################################################


; O modelo antigo esta no teste7			
MAC:
info := get_item_info("M", "MODlv")
if(info.modelo[2] = "" || info.modelo[1] = "Modelo" ){
	MsgBox,16,Erro, % "Selecione um modelo antes de continuar!" 
	return
}
	
inserir_campos_view(info)
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
					desparan1 := GetSelected("MAC","MACcamp")
					desparan2 := EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel
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
					campvalues := {}
					campnames := db.query("SELECT Campos FROM " args["camptable"] ";")
					while(!campnames.EOF){
					    campname := campnames["Campos"]
					    StringReplace,campname,campname,%A_Space%,,All
					    if(campname="")
					        Break
					    relreference:=db.query("SELECT tabela2 FROM reltable WHERE tipo='" . campname . "' AND tabela1='" . args["model"] . "'")
					    db.query("ALTER TABLE " relreference["tabela2"] " ADD COLUMN DI TEXT;")
					    result:=db.query("SELECT Codigo,DC,DR,DI FROM " relreference["tabela2"] ";")
					    while(!result.EOF){
					        if(result["Codigo"] = "")
					            continue
					        referencename1 := campname . "Codigo",referencename2:=campname . "dc",referencename3:=campname . "dr",referencename4:=campname . "di"
							
							campvalues[referencename1, A_Index] := result["Codigo"]
							campvalues[referencename2, A_Index] := result["DC"]
							campvalues[referencename3, A_Index] := result["DR"]
							campvalues[referencename4, A_Index] := result["DI"]
					        result.movenext()
					    }
					    result.close()
					    campnames.movenext()
					}
					campnames.close()
					relreference.close()
				}

				MACcod:
				if A_GuiEvent = I 
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
			if A_GuiEvent = I 
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
			info := get_item_info("M", "MODlv")
			ordem_view("oc", info)
			
			;args:={}
			;args["camptable"]:=camptable,args["table"]:=octable,args["field"]:="Campos",args["comparar"]:=true,args["owner"]:="M"
			;MsgBox, % "octable " octable
			;alterarordem(args)
			return 
			
			MAODC:
			info := get_item_info("M", "MODlv")
			ordem_view("odc", info)
			
			;args:={}
			;args["camptable"]:=camptable,args["table"]:=odctable,args["field"]:="Campos",args["comparar"]:=true,args["owner"]:="M"
			;alterarordem(args)
			return 

			MAODR:
			info := get_item_info("M", "MODlv")
			ordem_view("odr", info)

			;args:={}
			;args["camptable"]:=camptable,args["table"]:=odrtable,args["field"]:="Campos",args["comparar"]:=true,args["owner"]:="M" 
			;alterarordem(args)
			return 

			MAODI:
			info := get_item_info("M", "MODlv")
			ordem_view("odi", info)
			
			;args:={}
			;args["camptable"] := camptable, args["table"] := oditable, args["field"] := "Campos", args["comparar"] := true, args["owner"] := "M"
			;alterarordem(args)
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
		db.delete(args1["table"], selecteditem, args1["field1"])
		SQL:="DELETE FROM reltable WHERE tipo='" . args1["tipo"]  "' AND tabela1='" . args1["tabela1"] . "';"
		if (!db.Query(SQL)) {
					  Msg := "ErrorLevel: " . ErrorLevel . "`n" . SQLite_LastError() "`n`n" sQry
					  throw Exception("Query failed: " Msg)
					}
		db.loadlv("inserir1", "lv1", args1["table"], args1["field"])
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
	Gui, Add, Picture,w900 h50 0xE vbanner 
	banner(BANNER_COLOR,banner,"Inserir Fotos")
	Gui, Color,%GLOBAL_COLOR%
	Gui, Add, Listview,w500 h300 xm section checked vlv altsubmit gmassalv,Codigos
	Gui, Add, Picture,x+5 w300 h300 vpicture,%A_WorkingDir%\noimage.png
	Gui, Add, Button,xm y+5 w100 gmarcartodos,Marcar todos
	Gui, Add, button,x+5 w100 gdesmarcartodos,Desmarcar todos
	Gui, Add, button,x+260  w100 ginserirfotoemmassa ,Inserir
	;Gui,add,button,x+5 w100 gexcluir,Excluir dos marcados
	Gui, Show 
	db.loadlv("massaphoto","lv",codtable)
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
			if A_GuiEvent = I
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
		%closefunc%(args)
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
	  _exist := FALSE
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

#include, lib\print_funcs.ahk
#include, lib\promto_xml.ahk
#include, lib\gdip_all.ahk
#include, lib\promto_sql_mariaDB.ahk
#include, models\remover_item_ETF.ahk
#include <promtolib>
#include,lib\json_parser.ahk
#include,<SQL_new>
#include, lib\gerar_codigos.ahk
#Include lib\Crypt.ahk
#Include lib\CryptConst.ahk
#Include lib\CryptFoos.ahk
#include, lib\html-parser.ahk

/*
	Views
*/
#Include, views/reload_hashmask_view.ahk
#Include, views/insert_cert_from_file_view.ahk
#Include, views/cert_view.ahk
#Include, views/rem_massa_view.ahk
#Include, views/resize_image_folder_view.ahk
#include, views/generate_xml_view.ahk
#include, views/inserir_campos_view.ahk
#include, views/inserir_ETF_view.ahk
#include, views/inserir_modelo_view.ahk
#include, views/shared/inserir_dialogo_2_fields.ahk
#include, views/shared/inserir_imagem_view.ahk
#include, views/shared/inserir_imagem_db_view.ahk
#include, views/inserir_campo_esp_view.ahk
#include, views/alterar_valores_campo_view.ahk
#include, views/ordem_view.ahk
#include, views/lista_de_codigos_view.ahk
#include, views/inserir_bloqueio_view.ahk
#include, views/db_ex_view.ahk
#include, views/config_db_ex_view.ahk
#include, views/inserir_db_ex_view.ahk
#include, views/inserir_todos_view.ahk
#include, views/inserir_valores_view.ahk
#include, views/nova_conexao_view.ahk
#include, views/inserir_val_view.ahk
#include, views/estruturas_view.ahk 
#include, views/foto_individual_view.ahk
#include, views/selecionar_campo_externo_view.ahk
#include, views/linkar_modelos_view.ahk
#include, views/delete_confirmation_view.ahk
#include, views/manager_users_view.ahk
#include, views/insert_user_view.ahk
#include, views/edit_user_view.ahk
#include, views/insert_mod_msg_view.ahk
#include, views/change_status_view.ahk
#include, views/list_options_view.ahk
#include, views/show_status_result_view.ahk
#include, views/generate_html_view.ahk



/*
	Controllers
*/
#Include, controllers/db_ex_checker_controller.ahk
#Include, controllers/status_controller.ahk
#Include, controllers/rem_massa_controller.ahk
#include, controllers/db_ex_controller.ahk
#include, controllers/inserir_valores_controller.ahk
#include, controllers/inserir_bloqueio_controller.ahk
#include, controllers/estruturas_controller.ahk
#include, controllers/foto_individual_controller.ahk
#include, controllers/delete_confirmation_controller.ahk
#include, controllers/back_up_controller.ahk
#include, controllers/update_controller.ahk
#include, controllers/inserir_campos_controller.ahk
#include, controllers/manager_users_controller.ahk
