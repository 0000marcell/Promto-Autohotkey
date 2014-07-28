delete_item(){
	Global
	if(tv_level_menu = 1){
		delete_company()
	}else if(tv_level_menu = 2){
		delete_type()
	}else if(tv_level_menu = 3){
		delete_family()
	}else if(tv_level_menu = 4){
		delete_subfamily()
	}
	reload_hashmask_view()
}


delete_company(){
	Global db
	info := get_item_info("M", "MODlv")
	db.Empresa.excluir(info.empresa[1], info.empresa[2])
	delete_item_tv()
}

delete_type(){
	Global db
	info := get_item_info("M", "MODlv")
	db.Tipo.excluir(tipo.nome, tipo.mascara, info)
	MsgBox,64, Sucesso, % "O tipo e todos os subitems foram apagados." 
	delete_item_tv()
}

delete_family(){
	Global db
	info := get_item_info("M", "MODlv")
	db.Familia.excluir(info.familia[1], info.familia[2], info)
	MsgBox, 64, Sucesso, % "A familia e todos os subitems foram apagados." 
	delete_item_tv()
}

delete_subfamily(){
	Global db
	info := get_item_info("M", "MODlv")
	db.Subfamilia.excluir(info.subfamilia[1], info.subfamilia[2], info)
	delete_item_tv()
}

delete_item_tv(){
	Gui, M:default
	Gui, treeview, main_tv
	TV_Delete(TV_GetSelection())	 
}