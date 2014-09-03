printer_config_view(){
	Global
	col_1 := 20, col_2 := 90, col_3 := 150, col_4 := 210
	row_1 := 25, row_2 := 55, row_3 := 75, row_4 := 95, row_5 := 115
	s_edit_w 	:= 50, b_edit_w := 150
	text_w := 150, gb_w := 300, gb_h := 80 
  Gui, printer_config_view:New
  Gui, printer_config_view:+ownerM
  Gui, Font, s%SMALL_FONT%, %FONT%
  Gui, Color, %GLOBAL_COLOR%
	Gui, Add, Groupbox, x10 y10 w%gb_w% h%gb_h%, % "Fonte"
	Gui, Add, Text, x%col_1% y%row_1% w%text_w%, % "Codigo:"
	Gui, Add, Edit, x%col_2% y%row_1% w%s_edit_w% vcode_font,
	Gui, Add, Text, x%col_3% y%row_1% w%text_w%, % "Descricao:"
	Gui, Add, Edit, x%col_4% y%row_1% w%s_edit_w% vdesc_font,
	Gui, Add, Text, x%col_1% y%row_2% w%text_w%, % "Titulo Codigo:"
	Gui, Add, Edit, x%col_2% y%row_2% w%s_edit_w% vtitle_code_font,

	Gui, Add, Groupbox, xm yp+30 w%gb_w%, % "Painel Codigo"
	Gui, Add, Text, x%col_1% y%row_5% w%text_w%, % "Altura:"
	Gui, Add, Edit, x%col_2% y%row_5% w%s_edit_w% vcode_panel_height,
	Gui, Add, Text, x%col_3% y%row_5% w%text_w%, % "Largura:"
	Gui, Add, Edit, x%col_4% y%row_5% w%s_edit_w% vcode_panel_width,
	Gui, Add, Button, xm y+10 w150 gsave_tag_prop_values, % "Salvar"
  Gui, Add, Button, x+5 yp w150 gdefault, % "Padrao"
  load_tag_prop()
	Gui, Show,,Configurar impressao plaquetas
	return

  default:
  load_tag_prop_default()
  return 

	save_tag_prop_values:
	Gui, Submit, Nohide
  try{
    save_tag_values()
  }catch e{
    MsgBox,16, Error, % ExceptionDetail(e)
  }
	return
}

load_tag_prop(){
  Global
  file_path := "node\printer\public\printer_tag_settings.json"
  IfNotExist, % file_path
  {
    JSON_save(get_prop_default_hash(), file_path)
  }
  $$ := JSON_load(file_path)
  jsonString := JSON_to($$) 
  tag_prop := JSON_from(jsonString)   
  GuiControl,, code_font, % tag_prop.code_font
  GuiControl,, desc_font, % tag_prop.desc_font
  GuiControl,, title_code_font, % tag_prop.title_code_font
  GuiControl,, code_panel_height, % tag_prop.code_panel_height
  GuiControl,, code_panel_width, % tag_prop.code_panel_width
}

get_prop_default_hash(){
  hash := { 
    (JOIN 
      "code_font": 10,
      "desc_font": 20,
      "title_code_font": 10,
      "code_panel_height": 80,
      "code_panel_width": 80
    )}
  return hash
}

load_tag_prop_default(){
  Global
  GuiControl,, code_font, % "10"
  GuiControl,, desc_font, % "20"
  GuiControl,, title_code_font, % "10"
  GuiControl,, code_panel_height, % "80"
  GuiControl,, code_panel_width, % "80"
}

save_tag_values(){
	Global 
  check_if_value_is_blank()
  FileDelete, % file_path
	obj := { 
    (JOIN 
      "code_font": code_font, "desc_font": desc_font,
      "title_code_font": title_code_font, "code_panel_height": code_panel_height,
      "code_panel_width": code_panel_width
    )}
  JSON_save(obj, file_path)
  MsgBox, % "As alteracoes foram salvas!"
}

check_if_value_is_blank(){
  Global 
  if(code_font = "" || desc_font = "" || title_code_font = "" || code_panel_height = "" || code_panel_width = "")
    throw { what: "Nenhum campo pode estar em branco!!", file: A_LineFile, line: A_LineNumber }    
}

;printer_config_view()
