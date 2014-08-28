generate_JSON_view(){
	Global 

	Gui, generate_JSON_view:New
	Gui, Add, Text, xm , % "Gera o arquivo JSON da estrutura de dados do programa"
	Gui, Add, Button, xm y+15 w100 h30 ggenerate_JSON , % "Gerar"
	Gui, Add, Progress, xm y+5 vprogress  -Smooth 0x8 w300 h18
	Gui, Show, AutoSize, Carregando...
	return 

	generate_JSON:
	undetermine_progress_window := "generate_JSON_view"
	SetTimer, undetermine_progress_action, 45
	json := new PromtoJSON()
	json.get_companies()
	Gui, generate_JSON_view:destroy
	return
}