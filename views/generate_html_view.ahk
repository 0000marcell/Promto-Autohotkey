
generate_html_view(){
	Global

	Gui, generate_html_view:New
	Gui, Add, Text, xm , % "Gera uma pagina da estrutura de dados do produto`n Pode levar alguns minutos, a pagina ficara na pasta html do diretorio padrao do programa."
	Gui, Add, Button, xm y+15 w100 h30 ggenerate_html, % "Gerar"
	Gui, Add, Progress, xm y+5 vprogress  -Smooth 0x8 w300 h18
	Gui, Show, AutoSize, Carregando...
	return 	


	generate_html:
	HTML := new PromtoHTML()
	undetermine_progress_window := "generate_html_view"
	SetTimer, undetermine_progress_action, 45
	HTML.generate(ETF_TVSTRING, ETF_hashmask)
	Gui, generate_html_view:destroy
	return 


}
