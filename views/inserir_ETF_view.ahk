inserir_ETF_view(window, treeview, table, current_id, columns){
	Global db, edit_name_ETF, edit_mask_ETF, SMALL_FONT, GLOBAL_COLOR, ETF_hashmask
	Static s_window, s_treeview, s_table, s_current_id, s_type

	s_window := window
	s_treeview := treeview
	s_table := table
	s_current_id := current_id
	s_type := columns

	/*
		Gui init
	*/
	Gui, insert_ETF:New
	Gui, insert_ETF:+ownerM
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Campos
	*/
	Gui, Add, Groupbox, w230 h130, Campos
	Gui, Add, Text,xp+10 yp+15, Item:
	Gui, Add, Edit, y+10 w200 vedit_name_ETF uppercase,
	Gui, Add, Text, y+10, Mascara:
	Gui, Add, Edit, y+10 w200 vedit_mask_ETF uppercase,

	/*
		Opcoes
	*/
	Gui, Add, Groupbox,xm y+20 w230 h60, Opcoes
	Gui, Add, Button, xp+113 yp+19 w100 h30 ginsert_values_ETF Default, Inserir
	Gui, Show,,Inserir 
	return 

	insert_values_ETF:
	Gui, Submit, nohide

	/*
	 Insere o valor na determinada tabela
	*/
	record := {}

	/*
		Se for insercao de Aba
	*/
	if(s_type = "Abas"){
		record.Abas := edit_name_ETF 
		record.Mascara := edit_mask_ETF
		db.insert(record, s_table)
		ETF_hashmask[edit_name_ETF] := edit_mask_ETF
		
		/*
			cria a tabela do item que acabou de ser 
			inserido e insere a referencia no reltable
		*/
		Gui, %s_window%:Default
		Gui, Treeview, %s_treeview%
		TV_GetText(parent_name, s_current_id)  
		empresa_mascara := ETF_hashmask[parent_name]
		db.query("create table if not exists " empresa_mascara edit_mask_ETF "Familia (Familias, Mascara,PRIMARY KEY(Mascara ASC))")
		record_rel := {}	
		record_rel.tipo := "Familia"
		record_rel.tabela1 := empresa_mascara edit_name_ETF
		record_rel.tabela2 := empresa_mascara edit_mask_ETF "Familia"
		db.insert(record_rel, "reltable")
	}

	/*
		Se for insercao de Familia
	*/
	if(s_type = "Familias"){
		record.Familias := edit_name_ETF 
		record.Mascara := edit_mask_ETF
		return_insert_value := db.insert(record, s_table)
		ETF_hashmask[edit_name_ETF] := edit_mask_ETF
		
		/*
			cria a tabela do item que acabou de ser 
			inserido e insere a referencia no reltable
		*/
		Gui, %s_window%:Default
		Gui, Treeview, %s_treeview%
		
		/*
			pega a mascara da aba 
		*/
		TV_GetText(aba_name, s_current_id)
		aba_mascara := ETF_hashmask[aba_name]
		
		/*
			pega a mascara da empresa
		*/
		empresa_id := TV_GetParent(s_current_id)
		TV_GetText(empresa_name, empresa_id)
		empresa_mascara := ETF_hashmask[empresa_name] 

		db.query("create table if not exists " empresa_mascara aba_mascara edit_mask_ETF "Modelo (Modelos, Mascara,PRIMARY KEY(Mascara ASC))")
		record_rel := {}
		record_rel.tipo := "Modelo"
		record_rel.tabela1 := empresa_mascara aba_mascara edit_name_ETF
		record_rel.tabela2 := empresa_mascara aba_mascara edit_mask_ETF "Modelo"
		return_insert_value := db.insert(record_rel, "reltable")
		
	}
	Gui, %s_window%:Default
	Gui, Treeview, %s_treeview% 
	id := TV_Add(edit_name_ETF , s_current_id)
	Gui,insert_ETF:destroy
	TV_Modify(id ,"visFirst")
	TV_Modify(id)
	return 
}

