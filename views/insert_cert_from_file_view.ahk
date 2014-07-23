insert_cert_from_file_view(info){
	Global
	
	/*
		Gui init
	*/
	s_info := info
	Gui, insert_cert_from_file_view:New
	Gui, insert_cert_from_file_view:+ownerinserir_modelo_view
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%
	
	/*
		Escolher arquivo
	*/
	Gui, Add, Groupbox, xm ym w180 h330 , Escolha o arquivo
	Gui, Add, Edit, xp+5 yp+15 w150 vfile_path_cert, 
	Gui, Add, Button, w150 h20 ginsert_cert_file, Adicionar Arquivo 
	Gui, Add, Text, w150 , Data de emissao
	Gui, Add, DateTime, w150 vemission_date,
	Gui, Add, Text, w150 , Data de vencimento
	Gui, Add, DateTime, w150 vexpiration_date,
	Gui, Add, Text, w150 , Modelo(EX: TL.L.EXE.010) 
	Gui, Add, Edit, w150 vmod_cert,
	Gui, Add, Text, w150 , Informacoes complementares
	Gui, Add, Edit, w150 h50 vcomp_info, 
	Gui, Add, Button, w150 h30 gsave_cert, Salvar 
	Gui, Show, , Certificacao
	return

	insert_cert_file:
	FileSelectFile, source, ""
	if(source != ""){
		Gui, insert_cert_from_file_view:default
		GuiControl,, file_path_cert, % source
	}
	return

	save_cert:
	Gui, Submit, Nohide 
	db.Certificado.insert_cert(
		(JOIN
		  { file_path_cert: file_path_cert,
		  	mod_cert: mod_cert,
		  	comp_info: comp_info,
		  	emission_date: emission_date,
		  	expiration_date: expiration_date 
		  }
		), s_info)
	return
}