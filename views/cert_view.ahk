cert_view(v_info){
	Global SMALL_FONT, GLOBAL_COLOR
	Static s_info

	s_info := v_info

	/*
		Gui init
	*/
	Gui, cert_view:New
	Gui, cert_view:+ownerinserir_modelo_view
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Pesquisa
	*/
	Gui, Add, Groupbox, xm  w250 h45, Pesquisa
	Gui, Add, Edit, xp+5 yp+15 w230 gpesquisa_inserir_imagem_db_view vpesquisa_inserir_imagem_db_view,
	Gui, Add, Groupbox, xp-5 y+5 w250 h300, Imagens
	Gui, Add, Listview, xp+5 yp+15 w230 h280 ginserir_imagem_db_lv vinserir_imagem_db_lv altsubmit, id| Imagens

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xp-5 y+5 w250 h60, Opcoes
	Gui, Add, Button, xp+5 yp+15 w100 h30 gsalvar_imagem_db_button, Salvar 
	Gui, Add, Button, x+5 w100 h30 gexcluir_imagem_db_button, Excluir
	
	/*
		Fotos
	*/
	Gui, Add, Groupbox, x+45 ym w310 h320, Foto
	Gui, Add, Picture, xp+5 yp+15 w300 h300 vinserir_imagem_db_picture,
	Gui, Show,, Inserir Imagem do Banco de dados
	Lista_de_pesquisa := db.get_values("*", "imagetable")
	db.load_lv("inserir_imagem_db_view", "inserir_imagem_db_lv", "imagetable")
	return
}