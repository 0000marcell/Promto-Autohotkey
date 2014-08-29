printer_config_view(){
	Global
	col_1 := 20, col_2 := 90, col_3 := 150, col_4 := 210
	row_1 := 25, row_2 := 55, row_3 := 75, row_4 := 95
	s_edit_w 	:= 50, b_edit_w := 150
	text_w := 150, gb_w := 300, gb_h := 80 
	Gui, Add, Groupbox, x10 y10 w%gb_w% h%gb_h%, % "Fonte"
	Gui, Add, Text, x%col_1% y%row_1% w%text_w%, % "Codigo:"
	Gui, Add, Edit, x%col_2% y%row_1% w%s_edit_w% vcode_font,
	Gui, Add, Text, x%col_3% y%row_1% w%text_w%, % "Descricao:"
	Gui, Add, Edit, x%col_4% y%row_1% w%s_edit_w% vdesc_font,
	
	Gui, Add, Text, x%col_1% y%row_2% w%text_w%, % "Titulo Codigo:"
	Gui, Add, Edit, x%col_2% y%row_2% w%s_edit_w% vtitle_code_font,

	Gui, Add, Groupbox, xp yp+10 w%gb_w% h%gb_h%, name
	;Gui, Add, Groupbox, x10 y100 w300 h200, % "Painel Codigo"
	;Gui, Add, Text, xp+5 yp+15 w150 h50, % "Altura:"
	;Gui, Add, Edit, x+5 yp w100 h50 vcode_panel_height,
	;Gui, Add, Text, xp+5 yp+15 w150 h50, % "Largura:"
	;Gui, Add, Edit, x+5 yp w100 h50 vcode_panel_width,
	Gui, Show,,Configurar impressao plaquetas
	return
}

printer_config_view()
