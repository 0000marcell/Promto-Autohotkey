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
	try{
		db.Empresa.excluir(info.empresa[1], info.empresa[2])
	}catch e{
		MsgBox, 16, Erro, % "Erro ao deletar empresa `n " e.what " arquivo " e.file " linha " e.line 
	}
	delete_item_tv()
}

delete_type(){
	Global db
	info := get_item_info("M", "MODlv")
	try{
		db.Tipo.excluir(info.tipo[1], info.tipo[2], info)
	}catch e{
		MsgBox, 16, Erro, % "Erro ao deletar o tipo `n " e.what " arquivo " e.file " linha " e.line  
	} 
	delete_item_tv()
}

delete_family(){
	Global db
	info := get_item_info("M", "MODlv")
	try{
		db.Familia.excluir(info.familia[1], info.familia[2], info)
	}catch e{
		MsgBox, 16, Erro, % "Erro ao deletar a familia `n " e.what " arquivo " e.file " linha " e.line   
	} 
	delete_item_tv()
}

delete_subfamily(){
	Global db
	info := get_item_info("M", "MODlv")
	try{
		db.Subfamilia.excluir(info.subfamilia[1], info.subfamilia[2], info)
	}catch e{
		MsgBox, 16, Erro, % "Erro ao deletar a subfamilia `n " e.what " arquivo " e.file " linha " e.line 
	}
	delete_item_tv()
}

delete_item_tv(){
	Gui, M:default
	Gui, treeview, main_tv
	TV_Delete(TV_GetSelection())	 
}