inserir_campos_view(info){
	Global db, input_name, numero_items, SMALL_FONT,GLOBAL_COLOR, campos_combobox, valores_de_campo_lv,empresa, tipo, familia, input_name, input_mascara,importar_button, inserir_modelo_lv, exportar_button,more_options_button,opcoes_groupbox, modelos_foto_control, modelo 
 	Static s_info
	
	s_info := info

 	if(s_info.modelo[2] = ""){
 		MsgBox,16, Erro, % "Selecione um modelo antes de continuar!"
 		return
 	}
	
	/*
		Gui init
	*/
	Gui, inserir_campos_view:New
	Gui, inserir_campos_view:+ownerM
	;Gui, Font, s%SMALL_FONT%, %FONT%
	;Gui, Color, %GLOBAL_COLOR%
	Gui, Color, white

	/*
		Campos
	*/
	Gui, Add, Groupbox, w200 h45, Campos
	Gui, Add, Combobox, xp+5 yp+15 w180 vcampos_combobox gcampos_combobox,

	/*
		Opcoes campo
	*/
	Gui, Add, Groupbox, x+20 yp-15 w220 h45, Opcoes campo
	Gui, Add, Button, xp+5 yp+15 w100 h20 gincluir_campo_button, Incluir
	Gui, Add, Button, x+5  w100 h20 gexcluir_campo_button, Excluir

	/*
		Quantidade de items
	*/
	Gui, Add, Groupbox, x+20 yp-15 w150 h45, Quantidade de items
	Gui, Add, Text, xp+50 yp+15 w100 vnumero_items cblue, 0

	/*
		Valores de campo
	*/
	Gui, Add, Groupbox, xm y+20 w700 h300, Valores de campo
	Gui, Add, Listview, xp+5 yp+15 w680 h280 vvalores_de_campo_lv gvalores_de_campo_action,Codigo|Descricao Completa|Descricao Resumida|Descricao Ingles

	/*
		Opcoes
	*/
	Gui, Add, Groupbox, xm y+5 w400 h60, Campos
	Gui, Add, Button, xp+15 yp+15 w100 h30 ginserir_valores_campo_button Default,Inserir 
	Gui, Add, Button, x+5 w100 h30 galterar_valores_campo_button , Alterar
	Gui, Add, Button, x+5 w100 h30 gexcluir_valores_campo_button, Excluir

	/*
		Importar
	*/
	Gui, Add, Groupbox, x+180 yp-15 w180 h60, Importacao
	Gui, Add, Button, xp+10 yp+15 w60 h30 gimportar_valores_camp_esp, Importar 
	Gui, Add, Button, x+5 w60 h30 gexportar_valores_camp_esp, Exportar
	;ILButton(impbutton, "promtoshell.dll:" 10, 32, 32, 0)
	;ILButton(expbutton, "promtoshell.dll:" 20, 32, 32, 0)
	Gui, Show, Autosize, Inserir campos e valores
	
	/*
		Carrega o combobox
	*/
	tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
	tabela := db.Modelo.get_tabela_campo_referencia(tabela1)
	control := {window: "inserir_campos_view", combobox: "campos_combobox"}
	db.load_combobox(control, tabela)
	return

	importar_valores_camp_esp:
	Gui, Submit, Nohide
	if(campos_combobox = "" || s_info.empresa[1] = ""){
		MsgBox,16, % "Um dos valores necessarios para a insercao estava em branco"
		return
	}
	tabela1 := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.subfamilia[2] s_info.modelo[2] s_info.modelo[1]
	tabela_tbi := db.Modelo.get_tabela_campo_esp( campos_combobox, tabela1)
	codigo_esp_table := tabela_tbi 
	FileSelectFile, source, ""
	Stringright,_iscsv,source,3
  if(_iscsv!="csv"){
  	MsgBox, % "o arquivo selecionado tem que ser .csv!!!!"
  	return 
  }

  MsgBox, 4,, Deseja apagar os items atuais?
  IfMsgBox Yes
  {
  	db.clean_table(tabela_tbi)
  }
  x:= new OTTK(source)
  prefixo := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.subfamilia[2]
  progress(x.maxindex())
  for,each,value in x{
  	updateprogress("Inserindo Items da Lista: " x[A_Index, 1],1)
    codigo_value := x[A_Index, 1]
    dc_value := x[A_Index, 2]
    dr_value := x[A_Index, 3]
    di_value := x[A_Index, 4]
    if(codigo_value = "" || dr_value = "" || dc_value = ""){
    	continue
    }
    valores := {codigo: codigo_value, dr: dr_value, dc: dc_value, di: di_value}
    db.Modelo.incluir_campo_esp(campos_combobox ,valores, s_info)
  }
  db.load_lv("inserir_campos_view", "valores_de_campo_lv", codigo_esp_table)
  LV_ModifyCol(1, 150), LV_ModifyCol(2, 150), LV_ModifyCol(3, 150), LV_ModifyCol(4, 150)
  Gui,progress:destroy
  MsgBox,64,,% "valores importados!"
	return

	exportar_valores_camp_esp:
	Gui, Submit, Nohide
	if(campos_combobox = "" || s_info.empresa[1] = ""){
		MsgBox,16, % "Um dos valores necessarios para a insercao estava em branco"
		return
	}
	tabela1 := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.subfamilia[2] s_info.modelo[2] s_info.modelo[1]
	StringReplace,campos_combobox,campos_combobox,%A_Space%,,All
	tabela_tbe := db.Modelo.get_tabela_campo_esp(campos_combobox, tabela1)
	values_tbe := db.load_table_in_array(tabela_tbe)
	FileDelete, % "temp\temp_export.csv"
	IfNotExist, % "temp"
	{
		FileCreateDir, % "temp"
	}
	for, each, value in values_tbe{
		if(values_tbe[A_Index, 1] = "")
			Continue
		FileAppend, % values_tbe[A_Index, 1] ";" values_tbe[A_Index, 2] ";" values_tbe[A_Index, 3] ";" values_tbe[A_Index, 4] "`n", % "temp\temp_export.csv"
	}
	run, % "temp\temp_export.csv"
	MsgBox,64, Sucesso, % "Os valores foram exportados!" 
	return

	alterar_valores_campo_button:
	Gui, Submit, Nohide
	currentvalue := GetSelectedRow("inserir_campos_view", "valores_de_campo_lv")
	alterar_valores_campo_view(currentvalue, campos_combobox, s_info)
	return 

	incluir_campo_button:
	Gui, Submit, Nohide
	inserir_dialogo_2_view("incluir_campo_action", "inserir_campos_view", 1) 
	return

	incluir_campo_action: 
	Gui, Submit, Nohide
	if(input_name = ""){
		MsgBox,16, Erro, % "O nome do campo estava em branco!"
		return
	}
	tabela1 := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.subfamilia[2] s_info.modelo[2] s_info.modelo[1]
	db.Modelo.incluir_campo(input_name, s_info)
	tabela1 := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.subfamilia[2] s_info.modelo[2] s_info.modelo[1]
	tabela := db.Modelo.get_tabela_campo_referencia(tabela1)
	control := {window: "inserir_campos_view", combobox: "campos_combobox"}
	db.load_combobox(control, tabela)
	return

	excluir_campo_button: 
	Gui, Submit, Nohide
	if(campos_combobox = "" || s_info.modelo[2] = ""){
		MsgBox,16, Erro, % "Selecione um campo antes de continuar!"
		return
	}
	db.Modelo.excluir_campo(campos_combobox, s_info)
	tabela1 := s_info.empresa[2] s_info.tipo[2] s_info.familia[2] s_info.subfamilia[2] s_info.modelo[2] s_info.modelo[1]
	tabela := db.Modelo.get_tabela_campo_referencia(tabela1)
	control := {window: "inserir_campos_view", combobox: "campos_combobox"}
	db.load_combobox(control, tabela)
	MsgBox, 64, Sucesso, % "O campo foi excluido com sucesso!"
	Gui, inserir_campos_view:default
	Gui, listview, valores_de_campo_lv
	LV_Delete()
	return

	inserir_valores_campo_button:
	Gui, Submit, Nohide
	if(campos_combobox = "" || s_info.modelo[2] = ""){
		MsgBox,16, Erro, % "Selecione um campo antes de continuar!"
		return
	}
	inserir_campo_esp_view(campos_combobox, s_info)
	return

	excluir_valores_campo_button:
	Gui, Submit, Nohide
	/*
		Pega o codigo selecionado na listview
		passa a tabela de campo esp e o codigo para o excluir
	*/
	selected_item := GetSelected("inserir_campos_view","valores_de_campo_lv")
	tabela_campos_especificos := get_tabela_campo_esp(campos_combobox, s_info)
	db.Modelo.excluir_campo_esp(selected_item, tabela_campos_especificos)
	db.load_lv("inserir_campos_view", "valores_de_campo_lv", tabela_campos_especificos)
	MsgBox,64,Sucesso, % "O valor foi excluido!" 
	return

	campos_combobox:
	Gui, Submit, Nohide
	if(campos_combobox = "" || s_info.modelo[2] = ""){
		MsgBox,16, Erro, % "Selecione um campo antes de continuar!"
		return
	} 
	tabela_campos_especificos := get_tabela_campo_esp(campos_combobox, s_info)
	values_in_table := db.load_table_in_array(tabela_campos_especificos)
	GuiControl,, numero_items, % values_in_table.maxindex()
	db.load_lv("inserir_campos_view", "valores_de_campo_lv", tabela_campos_especificos)
	LV_ModifyCol(1, 150), LV_ModifyCol(2, 150), LV_ModifyCol(3, 150), LV_ModifyCol(4, 150)	
	return

	valores_de_campo_action:

	return
}
	