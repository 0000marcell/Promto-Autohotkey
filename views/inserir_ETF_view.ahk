inserir_ETF_view(window, treeview, current_id, columns){
	Global db, edit_name_ETF, edit_mask_ETF, SMALL_FONT, GLOBAL_COLOR, ETF_hashmask
	Static s_window, s_treeview, s_current_id, s_type

	s_window := window
	s_treeview := treeview
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
	if(s_type = "Empresas"){
		insert_company(edit_name_ETF, edit_mask_ETF)
	}else if(s_type = "Abas"){
		insert_type(edit_name_ETF, edit_mask_ETF)
	}else if(s_type = "Familias" ){
		insert_family(edit_name_ETF, edit_mask_ETF)
	}else if(s_type = "Subfamilias"){
		insert_subfamily(edit_name_ETF, edit_mask_ETF)
	}
	return 
}

insert_company(edit_name_ETF, edit_mask_ETF){
	Global db, ETF_hashmask

	item_hash := db.Empresa.incluir(edit_name_ETF, edit_mask_ETF) 
	if(item_hash){
		item_hash.mask := ETF_hashmask[item_hash.name] 
		update_main_tv(item_hash.name, item_hash.mask, 0)
	}else{
		MsgBox, 16, Erro, % " Algo deu errado ao tentar inserir a empresa!" 
		return
	}
}

insert_type(edit_name_ETF, edit_mask_ETF){
	Global db, ETF_hashmask
	info := get_item_info("M", "MODlv")
	if(db.Tipo.incluir(edit_name_ETF, edit_mask_ETF, info.empresa[2], info.empresa[1])){
		ETF_hashmask[edit_name_ETF] := edit_mask_ETF
		update_main_tv(edit_name_ETF, edit_mask_ETF)
	}else{
		MsgBox,16,Erro, % " Algo deu errado ao tentar inserir a aba!" 
		return
	}
}

insert_family(edit_name_ETF, edit_mask_ETF){
	Global db, ETF_hashmask
	info := get_item_info("M", "MODlv")
	prefix := info.empresa[2] info.tipo[2]
	if(db.Familia.incluir(edit_name_ETF, edit_mask_ETF, prefix, info)){
		ETF_hashmask[edit_name_ETF] := edit_mask_ETF
		update_main_tv(edit_name_ETF, edit_mask_ETF)
	}else{
		MsgBox,16,Erro, % " Algo deu errado ao tentar inserir a Familia!" 
		return
	}
}

insert_subfamily(edit_name_ETF, edit_mask_ETF){
	Global db, ETF_hashmask
	Gui, %s_window%:Default
	Gui, Treeview, %s_treeview%
	familia_nome := get_item_from_tv(s_current_id)
	tipo_id := TV_GetParent(s_current_id)
	tipo_nome := get_item_from_tv(tipo_id)
	empresa_id := TV_GetParent(tipo_id)
	empresa_nome := get_item_from_tv(empresa_id)
	subfam_prefix := ETF_hashmask[empresa_nome] ETF_hashmask[tipo_nome] ETF_hashmask[familia_nome]
	old_edit_mask := edit_mask_ETF
	edit_mask_ETF := check_if_ETF_exist(edit_name_ETF, edit_mask_ETF) 
	if(old_edit_mask != edit_mask_ETF)
		MsgBox, % "Ja existia uma mascara para o nome inserido `n por isso a mascara inserida foi trocada de " old_edit_mask " para " edit_mask_ETF 
	
	if(db.Subfamilia.incluir(edit_name_ETF, edit_mask_ETF, subfam_prefix, familia_nome)){
		ETF_hashmask[edit_name_ETF] := edit_mask_ETF
		update_main_tv(edit_name_ETF, edit_mask_ETF)
	}else{
		MsgBox,16,Erro, % " Algo deu errado ao tentar inserir a Subfamilia!" 
		return
	}	
}

update_main_tv(edit_name_ETF, edit_mask_ETF, parent = 1){
	Gui, M:Default
	Gui, Treeview, main_tv
	parent_id := (parent = 1) ? TV_GetSelection() : 0 
	ETF_name := edit_name_ETF " > " edit_mask_ETF
	id := TV_Add(ETF_name , parent_id)
	Gui, insert_ETF:destroy
	TV_Modify(id , "visFirst")
	TV_Modify(id)
}




