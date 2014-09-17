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
	undetermine_progress_window := "generate_xml_view"
	SetTimer, undetermine_progress_action, 45
	promtoXML.generate(ETF_TVSTRING, ETF_hashmask)
	promto_web := new PromtoWebFTP()
	promto_web.upload_xml()
	promto_web.upload_images()
	Gui, generate_xml_view:destroy
	return 
}
