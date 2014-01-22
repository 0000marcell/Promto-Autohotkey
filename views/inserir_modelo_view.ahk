inserir_modelo_view(model_table){
	Global

	tabela_de_modelo := model_table 
	;Global db, desc_, SMALL_FONT, descricao_geral_ingles_edit, GLOBAL_COLOR, descricao_geral_edit,inserir_modelo_view, fonte_imagem_radio, empresa, tipo, familia, input_name, input_mascara,importar_button, inserir_modelo_lv, exportar_button,more_options_button,opcoes_groupbox, modelos_foto_control, modelo 
 
	/*
		Gui init
	*/
	Gui, M:+disabled
	Gui, inserir_modelo_view:New
	Gui, inserir_modelo_view:+ownerM
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%
	
	/*
		Listview
	*/
	Gui, Add, Groupbox, w300 h400, Lista de modelos
	Gui, Add, Listview, xp+5 yp+15 w280 h380 vinserir_modelo_lv ginserir_modelo_lv altsubmit,Modelos|Mascara

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm y+20 w300 h60 vopcoes_groupbox,Opcoes
	Gui, Add, Button, xp+30 yp+15 w100 h30 ginserir_modelo_button,Inserir
	Gui, Add, Button, x+5 w100 h30 gexcluir_modelo_button,Excluir
	Gui, Add, Button, x+5 w30 h30 ginserir_modelo_more_options vmore_options_button,+
	Gui, Add, Button, x40 y+5 w100 h30 vimportar_button gimportar_button,Importar
	Gui, Add, Button, x+5 w100 h30 vexportar_button gexportar_button, Exportar
	GuiControl, Hide, importar_button
	GuiControl, Hide, exportar_button 

	/*
		Foto
	*/
	Gui, Add, Groupbox, x+70 ym w200 h200 , Fotos
	Gui, Add, Picture, xp+5 yp+15 w180 h180  vmodelos_foto_control,

	/*
		Fonte da Imagem
	*/
	Gui, Add, Groupbox, xp-5 y+10 w200 h90 , Fonte da Imagem
	Gui, Add, Radio, xp+5 yp+15 vfonte_imagem_radio Checked, Arquivo no computador
	Gui, Add, Radio, y+10, Banco de dados
	Gui, Add, Button, y+10 w100 h20 ginserir_modelo_imagem_button,Inserir/Alterar

	/*
		Descricao Geral
	*/
	Gui, Add, Groupbox,xp-5 y+10 w200 h180, Descricao
	Gui, Add, Text, xp+10 yp+15 w100, Portugues
	Gui, Add, Edit, y+5 w180 h40 vdescricao_geral_edit uppercase,
	Gui, Add, Text, y+5 w100 ,Ingles
	Gui, Add, Edit, y+5 w180 h40 vdescricao_geral_ingles_edit uppercase,
	Gui, Add, Button, y+5 w100 h20 gsalvar_descricao_geral_button, Salvar 

	Gui, Show, Autosize, Inserir Modelo
	db.load_lv("inserir_modelo_view", "inserir_modelo_lv", model_table)
	LV_ModifyCol(1), LV_ModifyCol(2,200) 
	return 

	salvar_descricao_geral_button:
	Gui, Submit, Nohide
	db.Modelo.descricao_geral(descricao_geral_edit, descricao_geral_ingles_edit)
	return

	inserir_modelo_viewguiclose:
	Gui, M:-disabled
	Gui, inserir_modelo_view:destroy
	return 

	inserir_modelo_lv:
	if A_GuiEvent = i
	{
		v_info := get_item_info("inserir_modelo_view", "inserir_modelo_lv")
		if(v_info.modelo[1] = "Modelos" || v_info.modelo[1] = "")
			Return
		tabela1 := v_info.empresa[2] v_info.tipo[2] v_info.familia[2] v_info.subfamilia[2] v_info.modelo[2] v_info.modelo[1]
		tabela2_value := db.get_reference("image", tabela1)
		image_name_value := tabela2_value
		if(image_name_value = ""){
			image_name_value := "sem_foto" 
		}
		image_source := global_image_path image_name_value ".jpg"
		Gui, inserir_modelo_view:default 
		GuiControl,, modelos_foto_control,%image_source%
		
		/*
			Pega a descricao garal do modelo
		*/
		s_info := change_info(v_info)
		desc_ := db.Modelo.get_desc(s_info) 
		StringSplit, desc_, desc_ ,|,
		descgeral := desc_1
		descgeralingles := desc_2
		GuiControl,, descricao_geral_edit,%descgeral%
		GuiControl,, descricao_geral_ingles_edit,%descgeralingles% 
	}
	return 

	inserir_modelo_button:
	/*
	 Parcial que cria uma janela de insercao com 2 edits
	*/
	inserir_dialogo_2_view("salvar_modelo_button", "inserir_modelo_view")
	return

	inserir_modelo_imagem_button:
	Gui, Submit, Nohide
	if(fonte_imagem_radio = 1){
		model := GetSelectedRow("inserir_modelo_view", "inserir_modelo_lv")
		modelo := []
		modelo.nome := model[1]
		modelo.mascara := model[2]

		if(modelo.nome = "" || modelo.mascara = ""){
			MsgBox,16,Erro, % "Selecione um modelo antes de continuar!"
			return
		}
		inserir_imagem_view("inserir_modelo_view", "modelos_foto_control")
	}else if (fonte_imagem_radio = 2){
		/*
			Ira carregar uma outra view onde sera possivel escolher a 
			imagem do banco de dados
		*/
		info := get_item_info("inserir_modelo_view", "inserir_modelo_lv")
		if(info.modelo[1] = "Modelos" || info.modelo[1] = ""){
			MsgBox,16,Erro, % "Selecione um modelo antes de continuar!"
			Return
		}
		inserir_imagem_db_view("inserir_modelo_view", "modelos_foto_control")
	}
	return

	/*
		Funcao lancada pela janela de insercao
	*/
	salvar_modelo_button:
	Gui, Submit, Nohide
	Gui, insert_dialogo_2:destroy
	prefixo := empresa.mascara tipo.mascara familia.mascara subfamilia.mascara
	/*
		Verifica se algum dos valores necessarios esta em branco
	*/
	if(input_name = "" || input_mascara = "" || prefixo = ""){
		MsgBox,16,Erro, % "Nehum dos valores para inserir o modelo pode estar em branco!"
		Gui, inserir_modelo_view:destroy
		return
	}

	/*
		Insere os valores na tabela 
	*/
	db.Modelo.incluir(input_name, input_mascara, prefixo)

	/*
		Insere o novo valor nas listviews
	*/
	Gui, inserir_modelo_view:default
	Gui, Listview, inserir_modelo_lv
	LV_Add("", input_name, input_mascara)
	LV_ModifyCol(), LV_ModifyCol(2, 100) 
	Gui, M:default
	Gui, Listview, MODlv
	LV_Add("", input_name, input_mascara)
	LV_ModifyCol(), LV_ModifyCol(2, 100)
	return

	excluir_modelo_button:
	info_inserir_modelo := get_item_info("inserir_modelo_view", "inserir_modelo_lv")
	info := get_item_info("M", "MODlv")
	MsgBox, 4,, % "Deseja apagar o modelo " info_inserir_modelo.modelo[1] "e todas as suas dependencias?"
	IfMsgBox Yes
	{
		select_number := GetSelected("inserir_modelo_view","inserir_modelo_lv","number")
		db.Modelo.excluir(info_inserir_modelo.modelo[1], info_inserir_modelo.modelo[2], info)	
		LV_Delete(select_number) 
		select_number_main := GetSelected("M","MODlv","number")
		Gui, M:default
		Gui, listview, MODlv 
		LV_Delete(select_number_main)
	}
	return

	importar_button: 
	info_inserir_modelo := get_item_info("inserir_modelo_view", "inserir_modelo_lv")
  info := get_item_info("M", "MODlv")
	tabela1 := info.empresa[2] info.tipo[2] info.familia[1]
	table_model := db.get_reference("Modelo", tabela1)
	FileSelectFile,source,""
	Stringright,_iscsv,source,3
  if(_iscsv!="csv"){
  	MsgBox, % "o arquivo selecionado tem que ser .csv!!!!"
  	return 
  }
  MsgBox, 4,, Deseja apagar os items atuais?
  IfMsgBox Yes
  {
  	db.clean_table(table_model)
  }
  x := new OTTK(source)
  prefixo_local := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2]
  progress(x.maxindex())
  FileDelete, % "temp\debug.csv"
  items_inseridos := {}
  for,each,value in x{
  	updateprogress("Inserindo Items da Lista: " x[A_Index, 1] " codigo " x[A_Index, 2] " prefixo_local: " prefixo_local,1)
    nome := x[A_Index, 1]
    codigo := x[A_Index, 2]
    if(nome = "")
    	continue
    items_inseridos[nome] := codigo
    db.Modelo.incluir(nome, codigo, prefixo_local)
  }
  db.load_lv("inserir_modelo_view", "inserir_modelo_lv", tabela_de_modelo, 1)
  db.load_lv("M", "MODlv", tabela_de_modelo, 1)
  Gui,progress:destroy
  MsgBox,64,,% "valores importados!"
	return

	exportar_button:
	export_value := get_lv_in_array("inserir_modelo_view", "inserir_modelo_lv", 2)
	if(export_value.max_index() != 0 || export_value.max_index() != "")
		FileDelete, % "temp\export_model.csv"
	for, each, value in export_value{
		if(export_value[A_Index, 1] = "")
			Continue
		FileAppend, % export_value[A_Index, 1] ";" export_value[A_Index, 2] "`n", % "temp\export_model.csv"
	}
	MsgBox, 64, Sucesso, % "Os valores foram exportados com sucesso!" 
	run, % "temp\export_model.csv" 
	return 


	inserir_modelo_more_options:
	if(_plus = 1 || _plus = ""){
		GuiControl,Move, opcoes_groupbox, h100
		GuiControl, Show,	importar_button
		GuiControl, Show, exportar_button
		GuiControl,, more_options_button,- 
		Gui, Show, Autosize,
		_plus := 0	
	}else if(_plus = 0){
		GuiControl,Move, opcoes_groupbox, h60
		GuiControl, Hide,	importar_button
		GuiControl, Hide, exportar_button
		GuiControl,, more_options_button, +
		Gui, Show, Autosize,
		_plus := 1
	}
	return
}


