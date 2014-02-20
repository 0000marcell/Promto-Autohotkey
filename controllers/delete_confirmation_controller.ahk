delete_item(){
	Global

	if(tv_level_menu = 1){
		/*
			Apaga a empresa selecionada e todos 
			os seus subitems
		*/
		
		empresa := get_tv_info("Empresa")
		
		db.Empresa.excluir(empresa.nome, empresa.mascara)
		
		TV_Delete(current_id)
		
		/*
			Limpa a listview da janela principal
		*/
		Gui,M:default
		Gui,Listview, MODlv
		LV_Delete()
	}else if(tv_level_menu = 2){
		/*
			Apaga o tipo selecionada e todos
			os seus subitems
		*/
		info := get_item_info("M", "MODlv")

		;MsgBox, % "info empresa: " info.empresa[1] " mascara " info.empresa[2]
		db.Tipo.excluir(tipo.nome, tipo.mascara, info)
		MsgBox,64, Sucesso, % "O tipo e todos os subitems foram apagados." 
		TV_Delete(current_id)
		/*
			Limpa a listview da janela principal
		*/
		Gui,M:default
		Gui,Listview, MODlv
		LV_Delete()
	}else if(tv_level_menu = 3){
		/*
			Apaga a familia selecionada e todos 
			os seus subitems
		*/
		
		info := get_item_info("M", "MODlv")
		db.Familia.excluir(info.familia[1], info.familia[2], info)
		MsgBox, 64, Sucesso, % "A familia e todos os subitems foram apagados." 
		TV_Delete(current_id)
		
		/*
			Limpa a listview da janela principal
		*/
		Gui,M:default
		Gui,Listview, MODlv
		LV_Delete()
	}else if(tv_level_menu = 4){
		
		/*
			Apaga a familia selecionada e todos 
			os seus subitems
		*/
		info := get_item_info("M", "MODlv")
		db.Subfamilia.excluir(info.subfamilia[1], info.subfamilia[2], info)
		TV_Delete(current_id)

		/*
			Limpa a listview da janela principal
		*/
		Gui,M:default
		Gui,Listview, MODlv
		LV_Delete()
	}
}