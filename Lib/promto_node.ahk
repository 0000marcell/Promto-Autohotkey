Class PromtoNode{
	__New(){

	}

	get_tv_value(type_tv){
		if(type_tv = "subfamily"){
			if(tv_level = 4){
				TV_GetText(name, id)
				return_values.name := name
				return_values.mask := ETF_hashmask[name]	
			}
		}

		if(type_tv = "family"){
			if(tv_level = 4){
				parent_id := TV_GetParent(id)
				TV_GetText(name, parent_id)
				return_values.name := name
				return_values.mask := ETF_hashmask[name]
			}
			if(tv_level = 3){
				TV_GetText(name, id)
				return_values.name := name
				return_values.mask := ETF_hashmask[name]	
			}
		}

		if(type_tv = "type"){
			if(tv_level = 4){
				super_id := TV_GetParent(id)
				parent_id := TV_GetParent(super_id)
				TV_GetText(name, parent_id)
				return_values.name := name
				return_values.mask := ETF_hashmask[name]
			}
			if(tv_level = 3){
				parent_id := TV_GetParent(id)
				TV_GetText(name, parent_id)
				return_values.name := name
				return_values.mask := ETF_hashmask[name]
			}
			if(tv_level = 2){
				TV_GetText(name, id)
				return_values.name := name
				return_values.mask := ETF_hashmask[name]	
			}
		}

		if(type_tv = "company"){
			if(tv_level = 4){
				ultra_id := TV_GetParent(id)
				super_id := TV_GetParent(ultra_id)
				parent_id := TV_GetParent(super_id)
				TV_GetText(name, parent_id)
				return_values.name := name
				return_values.mask := ETF_hashmask[name]
			}

			if(tv_level = 3){
				parent_id := TV_GetParent(id)
				super_parent_id := TV_GetParent(parent_id)
				TV_GetText(name, super_parent_id)
				return_values.name := name
				return_values.mask := ETF_hashmask[name]
			}

			if(tv_level = 2){
				parent_id := TV_GetParent(id)
				TV_GetText(name, parent_id)
				return_values.name := name
				return_values.mask := ETF_hashmask[name]
			}

			if(tv_level = 1){
				TV_GetText(name, id)
				return_values.name := name
				return_values.mask := ETF_hashmask[name]
			}
		}
		return return_values
	}

	get_tv_info(type_tv, ignore_error = 0, window = "M", treeview = "main_tv", starting_id = "", same_window = ""){
		Global ETF_hashmask


		if(same_window != ""){
			tv_level := TV.get_tv_level(same_window, treeview)	
		}else{
			tv_level := TV.get_tv_level(window, treeview)	
		}
		

		if(tv_level = ""){
			MsgBox,16,Erro, % "Nao existia nenhum item selecionado na treeview"
			return 
		}

		return_values := []
		if(same_window = ""){
			Gui, %window%:Default
		}else{
			Gui, %same_window%:Default
		}
		
		Gui, Treeview, %treeview%

		if(starting_id = ""){
			id := TV_GetSelection()
		}else{
			id := starting_id 
			tv_level--
		}
		
		/*
			Get the determined value in the TV
		*/
		return this.get_tv_value(type_tv)
	}

	get_node_info(window = "M", lv = "MODlv", treeview = "main_tv", starting_id = "", same_window = ""){
		
		company := this.get_tv_info("company", 0, "M", treeview, starting_id, same_window)
		type := this.get_tv_info("type", 1, "M", treeview, starting_id, same_window)
		family := this.get_tv_info("family", 1, "M", treeview, starting_id, same_window)
		subfamily := this.get_tv_info("subfamily", 1, "M", treeview, starting_id, same_window)

		/*
			Get the select model in the listview
		*/
		model := LV.GetSelectedRow(window, lv)
		model := []
		model.name := model[1]
		model.mask := model[2]

		/*
			Put all the information in a single hash
		*/
		info := {}, info.company[1] := company.name, info.company[2] := company.mask
		info.type[1] := type.name, info.type[2] := type.mask
		info.family[1] := family.name, info.family[2] := family.mask
		info.subfamily[1] := "", info.subfamily[2] := ""
		info.subfamily[1] := subfamily.name, info.subfamily[2] := subfamily.mask
		info.model[1] := model.name, info.model[2] := model.mask

		return info 	
	}

	get_number_of_items(){
		Global db
		codes := db.load_table_in_array(this.prefix() "Codigo")
		return codes.MaxIndex()
	}

	get_order_table(table_type){		
		Global db
		return db.get_reference(table_type, this.id())
	}

	prefix(){
		info := this.get_node_info()
		prefix := 
		(JOIN
			info.company[2] 
			info.type[2] 
			info.family[2] 
			info.subfamily[2] 
			info.model[2] 
		)
		return prefix
	}

	prefix_in_order(){
		Global db
		
		order := db.load_table_in_array(this.prefix() "prefixo")
		
		for, each, value in order
			return_value .= order[A_Index, 2]
		
		return return_value
	}

	id(){
		info := this.get_node_info()
		id := 
		(JOIN
			info.company[2] 
			info.type[2] 
			info.family[2] 
			info.subfamily[2] 
			info.model[2]
			info.modelo[1] 
		)
		return id 
	}
}