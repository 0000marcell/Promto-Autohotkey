inserir_modelo_view(model_table){
	Global db, SMALL_FONT, GLOBAL_COLOR, descricao_geral_edit,inserir_modelo_view, fonte_imagem_radio, empresa, tipo, familia, input_name, input_mascara,importar_button, inserir_modelo_lv, exportar_button,more_options_button,opcoes_groupbox, modelos_foto_control, modelo 
 
	/*
		Gui init
	*/
	Gui, inserir_modelo_view:New
	Gui, inserir_modelo_view:+ownerM
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%
	Gui, Color, white
	
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
	Gui, Add, Button, x40 y+5 w100 h30 vimportar_button,Importar
	Gui, Add, Button, x+5 w100 h30 vexportar_button, Exportar
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
	Gui, Add, Groupbox, xp-5 y+35 w200 h90 , Fonte da Imagem
	Gui, Add, Radio, xp+5 yp+15 vfonte_imagem_radio Checked, Arquivo no computador
	Gui, Add, Radio, y+10, Banco de dados
	Gui, Add, Button, y+10 w100 h20 ginserir_modelo_imagem_button,Inserir/Alterar

	/*
		Descricao Geral
	*/
	Gui, Add, Groupbox,xp-5 y+15 w200 h100, Descricao
	Gui, Add, Edit, xp+5 yp+15 w180 h50 vdescricao_geral_edit,
	Gui, Add, Button, y+5 w100 h20 gsalvar_descricao_geral_button, Salvar 

	Gui, Show, Autosize, Inserir Modelo
	db.load_lv("inserir_modelo_view", "inserir_modelo_lv", model_table)
	LV_ModifyCol(1), LV_ModifyCol(2,200) 
	return 

	salvar_descricao_geral_button:
	Gui, Submit, Nohide
	db.Modelo.descricao_geral(descricao_geral_edit)
	return

	inserir_modelo_lv:
	if A_GuiEvent = i
	{
		info := get_item_info("inserir_modelo_view", "inserir_modelo_lv")
		if(info.modelo[1] = "Modelos")
			Return
		;MsgBox, % "info empresa : " info.empresa[1] " `n empresa mascara " info.empresa[2] " `n tipo nome: " info.tipo[1] "`n tipo mascara: " info.tipo[2] "`n familia nome " info.familia[1] "`n familia mascara " info.familia[2] " `n modelo nome " info.modelo[1] "`n modelo mascara " info.modelo[2] 

		/*
			Pega a foto linkada com o determinado modelo
		*/
		tabela2_value := empresa.mascara tipo.mascara familia.mascara modelo.mascara modelo.nome
		image_name_value := db.Imagem.get_image_path(tabela2_value)
		if(image_name_value = ""){
			image_name_value := "sem_foto" 
		}
		image_source := "img\" image_name_value ".jpg"
		Gui, inserir_modelo_view:default 
		GuiControl,, modelos_foto_control,%image_source%
		
		/*
			Pega a descricao garal do modelo
		*/
		descricao_model := db.Modelo.get_desc(info)
		GuiControl,, descricao_geral_edit,%descricao_model% 
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
	prefixo := empresa.mascara tipo.mascara familia.mascara

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
	Gui, M:default
	Gui, Listview, MODlv
	LV_Add("", input_name, input_mascara)
	return

	excluir_modelo_button:
	info := get_item_info("inserir_modelo_view", "inserir_modelo_lv")
	;MsgBox, % "ira deletar o modelo"
	;MsgBox, % "info empresa : " info.empresa[1] " `n empresa mascara " info.empresa[2] " `n tipo nome: " info.tipo[1] "`n tipo mascara: " info.tipo[2] "`n familia nome " info.familia[1] "`n familia mascara " info.familia[2] " `n modelo nome " info.modelo[1] "`n modelo mascara " info.modelo[2]
	MsgBox, 4,, % "Deseja apagar o modelo " info.modelo[1] "e todas as suas dependencias?"
	IfMsgBox Yes
	{
		db.Modelo.excluir(info.modelo[1], info.modelo[2], info.empresa[2] info.tipo[2] info.familia[2])	
	}
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


