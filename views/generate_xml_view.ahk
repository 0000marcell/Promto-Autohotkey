generate_xml_view(){
	Global

	Gui, generate_xml_view:New
	Gui, Add, Text, xm , % "Gera o arquivo xml utilizado na visualizacao pela internet."
	Gui, Add, Button, xm y+15 w100 h30 ggenerate_xml, % "Gerar"
	Gui, Add, Progress, xm y+5 vprogress  -Smooth 0x8 w300 h18
	Gui, Show, AutoSize, Carregando...
	return 	

	generate_xml:
	promtoXML := new PromtoXML()
	promtoFTP := new PromtoFTP(
		(JOIN 
			"ftp.promto-maccomevap.url.ph",
			"u832722944", "Recovergun"
		))
	undetermine_progress_window := "generate_xml_view"
	SetTimer, undetermine_progress_action, 45
	promtoXML.generate(ETF_TVSTRING, ETF_hashmask)
	promtoFTP.upload_file("promto_data.xml")
	promtoFTP.update_folder(global_image_path "promto_imagens\", "promto_imagens")
	Gui, generate_xml_view:destroy
	return 
}
