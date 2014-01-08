inserir_imagem_db_view(owner_name, picture_control){
	Global
	Static s_picture_control, s_owner_name

	s_picture_control := picture_control 
	s_owner_name := owner_name 

	/*
		Gui init
	*/
	Gui, inserir_imagem_db_view:New
	Gui, inserir_imagem_db_view:+owner%owner_name%
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Imagens
	*/
	Gui, Add, Groupbox, xm  w250 h45, Pesquisa
	Gui, Add, Edit, xp+5 yp+15 w230 gpesquisa_inserir_imagem_db_view vpesquisa_inserir_imagem_db_view,
	Gui, Add, Groupbox, xp-5 y+5 w250 h300, Imagens
	Gui, Add, Listview, xp+5 yp+15 w230 h280 ginserir_imagem_db_lv vinserir_imagem_db_lv altsubmit,Imagens

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xp-5 y+5 w250 h60, Opcoes
	Gui, Add, Button, xp+5 yp+15 w100 h30 gsalvar_imagem_db_button, Salvar 
	Gui, Add, Button, x+5 w100 h30 gexcluir_imagem_db_button, Excluir
	
	/*
		Fotos
	*/
	Gui, Add, Groupbox, x+45 ym w250 h250, Foto
	Gui, Add, Picture, xp+5 yp+15 w200 h200 vinserir_imagem_db_picture,
	Gui, Show,, Inserir Imagem do DB
	Lista_de_pesquisa := db.get_values("*", "imagetable")
	db.load_lv("inserir_imagem_db_view", "inserir_imagem_db_lv", "imagetable")
	return

	pesquisa_inserir_imagem_db_view:
	Gui,submit,nohide
	any_word_search("inserir_imagem_db_view", "inserir_imagem_db_lv", pesquisa_inserir_imagem_db_view, Lista_de_pesquisa)
	return

	salvar_imagem_db_button:
	/*
		relaciona o caminho da imagem selecionada no 
		momento com o modelo selecionado
	*/
	valor_selecionado := GetSelected("inserir_imagem_db_view", "inserir_imagem_db_lv")
	info := get_item_info("inserir_modelo_view", "inserir_modelo_lv")
	db.Imagem.link_up(info, valor_selecionado)
	Gui, %s_owner_name%:default
	GuiControl,, s_picture_control,%global_image_path%%valor_selecionado%.jpg 
	return

	excluir_imagem_db_button:
	valor_selecionado := GetSelected("inserir_imagem_db_view", "inserir_imagem_db_lv")
	db.Imagem.remove(valor_selecionado)
	Gui, %s_owner_name%:default
	Gui, listview, inserir_imagem_db_lv
	LV_Delete(GetSelected("inserir_imagem_db_view", "inserir_imagem_db_lv", "number"))
	return  

	inserir_imagem_db_lv:
	if A_GuiEvent = i
	{
		valor_selecionado := GetSelected("inserir_imagem_db_view", "inserir_imagem_db_lv")
		;MsgBox, % "ira carregar a imagem " global_image_path valor_selecionado
		Gui, inserir_imagem_db_view:default 
		GuiControl,, inserir_imagem_db_picture,%global_image_path%%valor_selecionado%.jpg
	}
	return 

}
	