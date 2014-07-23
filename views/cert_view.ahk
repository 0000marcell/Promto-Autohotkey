cert_view(v_info, owner){
	Global db, SMALL_FONT, GLOBAL_COLOR, search_cert_list, global_cert_path
	Static s_info, search_cert, lv_cert

	s_info := v_info

	/*
		Gui init
	*/
	Gui, cert_view:New
	Gui, cert_view:+owner%owner%
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Pesquisa
	*/
	Gui, Add, Groupbox, xm  w250 h45, Pesquisa
	Gui, Add, Edit, xp+5 yp+15 w230 gsearch_cert vsearch_cert,
	
	Gui, Add, Groupbox, xp-5 y+5 w550 h300, Certificados
	Gui, Add, Listview, xp+5 yp+15 w530 h280 vlv_cert altsubmit, Modelo|Complemento|Usuario|Emissao|Vencimento|Arquivo

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xp-5 y+5 w250 h60, Opcoes
	Gui, Add, Button, xp+5 yp+15 w100 h30 gopen_cert, Abrir
	/*
		Botao pra relacionar o certificado 
		cado o info nao esteja vazio
	*/
	if(s_info.empresa[1]!= ""){
		Gui, Add, Button, x+5  w100 h30 glink_cert, Linkar		
	}
	Gui, Show,, Lista de certificados
	search_cert_list := db.get_values("*", "certificados")
	db.load_lv("cert_view", "lv_cert", "certificados")
	return

	open_cert:
	selected_cert := GetSelectedRow("cert_view", "lv_cert")
	run, % global_cert_path selected_cert[6]
	return

	link_cert:
	selected_cert := GetSelectedRow("cert_view", "lv_cert")
	if(db.Certificado.insert_relation( selected_cert[1], s_info)){
		MsgBox, 64, Sucesso, % "O certificado foi relacionado com sucesso!" 
	}
	return

	search_cert:
	Gui, Submit, Nohide
	any_word_search("cert_view", "lv_cert", search_cert, search_cert_list)
	return
}