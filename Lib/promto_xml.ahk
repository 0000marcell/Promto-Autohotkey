class PromtoXML{
	__New(){
		AHK.reset_debug()
		this.file_path := "promto_data.xml"
		FileDelete, % this.file_path
		try
			; create an XMLDOMDocument object
			; set its top-level node
			this.XML := new xml("<root/>")
		catch pe ; catch parsing error(if any)
			MsgBox, 16, PARSE ERROR
			, % "Exception thrown!!`n`nWhat: " pe.What "`nFile: " pe.File
			. "`nLine: " pe.Line "`nMessage: " pe.Message "`nExtra: " pe.Extra
		
		if this.XML.documentElement {
			this.XML.addElement("promto", "root")
		}
		this.companies := []
		this.start_company()
		this.hash_mask := {}
		this.prev_prefix := [] ; String containing the previous prefixes
		this.fields := []
		this.count := ""
	}

	generate(string, hash_mask){
		this.hash_mask := hash_mask
		AHK.append_debug("string " string "`n hash mask " hash_mask["MACCOMEVAP"])
		StringSplit, items, string, `n,
		prev_item_tab_count := 0
		Loop, % items0
		{
			if(items%A_Index% = "")
				Continue
			AHK.append_debug("item : " items%A_Index%)
			StringSplit, tab_count, items%A_Index%, `t,
			this_item_tab_count := tab_count0 -1
			StringReplace, items%A_Index%, items%A_Index%, `t,, All
			/*
				If the current item is bigger than the previous one
				or equal to 0(first item)
			*/
			if(this_item_tab_count > prev_item_tab_count || prev_item_tab_count = 0){
				next_item := A_Index + 1 ; used to check if it is the last item
				this.get_item_prop(this_item_tab_count, items%A_Index%, item%next_item%)
				/*
					If the current item is smaller than the previous one
				*/	
			}else if(this_item_tab_count < prev_item_tab_count){
				if(this_item_tab_count = 3){
					this.models := []
					this.subfamilies := []
				}else if(this_item_tab_count = 2){
					this.families := []
				}else if(this_item_tab_count = 1){
					this.start_company()
				}
				diference := prev_item_tab_count - this_item_tab_count
				this.prev_prefix.Remove(this.prev_prefix.MaxIndex())
				Loop, % diference
					this.prev_prefix.Remove(this.prev_prefix.MaxIndex())		
				next_item := A_Index + 1 ; used to check if it is the last item
				this.get_item_prop(this_item_tab_count, items%A_Index%, item%next_item%)
				/*
					If the current item is equal to the previous one
				*/	
			}else if(this_item_tab_count = prev_item_tab_count){
				this.prev_prefix.Remove(this.prev_prefix.MaxIndex())
				next_item := A_Index + 1 ; used to check if it is the last item
				this.models := []
				this.get_item_prop(this_item_tab_count, items%A_Index%, item%next_item%)
			}
			prev_item_tab_count := this_item_tab_count
		}
		this.XML.transformXML()
		this.XML.save(this.file_path)
		Run, % this.file_path
	}

	/*
		Get the properties of the elements.
	*/
	get_item_prop(count, current_value, next_value){
		item := {}
		current_value := this.strip_mask(current_value)
		AHK.append_debug("current value after strip " current_value " numero de carac " StrLen(current_value))
		/*
			Company
		*/
		if(count = 1){
			item.name := current_value 
			item.father := "companies"
			item.child :=  "company"
			this.companies.insert(current_value)
			item.path := "//promto"
			this.start_company() ; reset all elements array
			this.add_item(item)
		/*
			Type
		*/
		}else if(count = 2){
			item.name := current_value
			item.father := "types"
			item.child :=  "type"
			item.path := 
			(JOIN 
				"//promto/companies/company[" this.companies.MaxIndex() "]"
			)
			item.max_index := this.types.MaxIndex()
			item.name := current_value
			this.add_item(item)
			this.types.insert(current_value)
		/*
			Family
		*/
		}else if(count = 3){
			this.count := count
			item.name := current_value
			item.father := "families"
			item.child :=  "family"
			item.path := 
			(JOIN 
				"//promto/companies/company[" this.companies.MaxIndex() "]/"
				"types/type[" this.types.MaxIndex() "]"
			)
			item.max_index := this.families.MaxIndex()
			item.name := current_value
			this.add_item(item)
			this.families.insert(current_value)
			prefix_without_last := this.get_prefix_without_last()
			tabela1 := this.stringify(prefix_without_last) item.name
			this.check_if_has_model(item, tabela1)
		}else if(count = 4){
			this.count := count
			item.name := current_value
			item.father := "subfamilies"
			item.child :=  "subfamily"
			item.path := 
			(JOIN 
				"//promto/companies/company[" this.companies.MaxIndex() "]/"
				"types/type[" this.types.MaxIndex() "]/"
				"families/family[" this.families.MaxIndex() "]"
			)
			item.max_index := this.subfamilies.MaxIndex()
			item.name := current_value
			this.add_item(item)
			this.subfamilies.insert(current_value)
			prefix_without_last := this.get_prefix_without_last()
			tabela1 := this.stringify(prefix_without_last) item.name
			this.check_if_has_model(item, tabela1)
		}
	}

	strip_mask(name){
		StringSplit, name, name, >
		StringTrimRight, name, name1, 1
		return name
	}

	add_item(item){
		Global db 
		if(item.max_index = 0 || item.max_index = ""){
			this.XML.addElement(item.father, item.path)
		}
		AHK.append_debug("gonna insert prev prefix " this.hash_mask[item.name])
		AHK.append_debug("item name in prev prefix "	this.hash_mask[item.name])
		this.prev_prefix.insert(this.hash_mask[item.name])
		AHK.append_debug("item path " item.path " item father " item.father)
		xpath := item.path "/" item.father
		if(item.child = "model"){
			prefix := this.stringify(this.prev_prefix)
			img := db.Imagem.get_image_path(prefix item.name) 
			log := this.get_log(prefix)
			status := this.get_status(prefix)
			prop_hash :=  {mask: this.hash_mask[item.name], prefix: prefix, img: img, log: log, status: status} 
		}else{
			prop_hash :=  {mask: this.hash_mask[item.name], prefix: this.stringify(this.prev_prefix)} 
		}
		this.XML.addElement(item.child, xpath, prop_hash, item.name)
	}

	get_log(prefix){
		Global db
		items := db.Log.get_mod_info("", prefix)
		for, each, item in Items{
		  usuario := items[A_Index, 2]
		  hash := hashify(items[A_Index, 3])
		  data := items[A_Index, 4]
		  hora := items[A_Index, 5]
		  msg := items[A_Index, 6]
			string .= usuario " alterou o item " hash.modelo " em " data " as " hora " " msg "`n"
		}
		return string 
	}

	get_status(prefix){
		Global db 
		items := db.Status.get_status("", prefix)
		if(items[1, 1] = ""){
			return " nao foi feito "
		}

		usuario := items[1, 2]
		status := items[1, 3]
		mensagem := items[1, 4]

		if(status = 1){
			current_status := "OK"
		}else if(status = 2){
			current_status := "Em andamento"
		}else if(status = 3){
			current_status := " Com problemas"
		}else if(status = 4){
			current_status := " Nao foi feito"
		}
		status_msg := current_status " " mensagem " `n Usuario: " usuario
		return status_msg
	}

	/*
		Verifies if the item has a model
	*/
	check_if_has_model(item, tabela1){
		Global db

		if(this.count != 3 && this.count != 4)
			return 
		model_table := db.get_reference("Modelo", tabela1)
		if(model_table = "")
			return
		
		model_list := db.load_table_in_array(model_table)

		for, each, value in model_list{
			if(model_list[A_Index, 1] = "")
				Continue

			item.name := model_list[A_Index, 1]
			this.hash_mask[item.name] := model_list[A_Index, 2]
			item.father := "models"
			item.child :=  "model"	 
			if(this.count = 3){
				item.path := 
				(JOIN 
					"//promto/companies/company[" this.companies.MaxIndex() "]/"
					"types/type[" this.types.MaxIndex() "]/"
					"families/family[" this.families.MaxIndex() "]"
				)	
			}else if(this.count = 4){
				item.path := 
				(JOIN 
					"//promto/companies/company[" this.companies.MaxIndex() "]/"
					"types/type[" this.types.MaxIndex() "]/"
					"families/family[" this.families.MaxIndex() "]/"
					"subfamilies/subfamily[" this.subfamilies.MaxIndex() "]"
				)	
			}

			item.max_index := this.models.MaxIndex()	
			this.add_item(item)
			this.models.insert(current_value)
			this.add_model(item)
			this.prev_prefix.Remove(this.prev_prefix.MaxIndex())
		} 
	}

	add_model(item){
		Global db
		this.fields := []
		xpath := item.path "/" item.father "/model[" this.models.MaxIndex() "]"
		/*
			Insert the code list
		*/
		this.add_code_list(item, xpath)
		
		/*
			Insert the fields and the values of the 
			fields
		*/
		this.add_prefix(item)

		this.add_field_list(item, xpath)
	}

	/*
		Adds the prefix in the model page
	*/
	add_prefix(item){
		xpath := item.path "/" item.father "/model[" this.models.MaxIndex() "]"
		this.XML.addElement("prefix_list", xpath)
		prefix_in_order := this.get_prefix_list_in_order()
		for, each, value in prefix_in_order{
			if(value = "")
				Continue
			this.XML.addElement("prefix", xpath "/prefix_list", value)
		}
	}

	add_code_list(item, xpath){
		Global db 

		code_table := this.stringify(this.prev_prefix) "codigo"
		if(code_table = "")
			return
		code_list := db.load_table_in_array(code_table)
		this.XML.addElement("code_list", xpath)
		for, each, value in code_list{
			if(code_list[A_Index, 1] = "")
				return
			hash_prop := {dr: code_list[A_Index, 2], dc: code_list[A_Index, 3], di: code_list[A_Index, 4] }
			this.XML.addElement("code", xpath "/code_list",hash_prop, code_list[A_Index, 1])	
		}
	}

	add_field_list(item, xpath){
		Global db

		tabela1 := this.stringify(this.prev_prefix) item.name
		field_table := db.get_reference("Campo", tabela1)
		if(field_table = "")
			Return

		field_list := db.load_table_in_array(field_table)
		this.XML.addElement("field_list", xpath)
		for, each, value in field_list{
			if(field_list[A_Index, 2] = "")
				Continue
			hash_prop := {field_name: field_list[A_Index, 2]}
			this.XML.addElement("field", xpath "/field_list", hash_prop,"")
			this.fields.insert(field_list[A_Index, 2])
			this.add_field_value(item, field_list[A_Index, 2], xpath)	
		}
	}

	add_field_value(item, field, xpath){
		Global db 

		/*
			Insert the fields values 
		*/
		tabela1 := this.stringify(this.prev_prefix) item.name
		especific_fields_table := db.get_reference(AHK.rem_space(field), tabela1)
		if(especific_fields_table = "")
			return
		specific_list := db.load_table_in_array(especific_fields_table)
		for, each, value in specific_list{
			if(specific_list[A_Index, 1] = "")
				Continue
			hash_prop := {dc: specific_list[A_Index, 2], dr: specific_list[A_Index, 3], di: specific_list[A_Index, 4]}
			this.XML.addElement("field_value", xpath "/field_list/field[" this.fields.MaxIndex() "]", hash_prop, specific_list[A_Index, 1])
		}
	}


	start_company(){
		this.types := []
		this.families := []
		this.subfamilies := []
		this.models := []
	}

	stringify(array){
		stirng := ""
		for, each, value in array{
			string .= value
		}
		return string
	}

	get_prefix_list_in_order(){
		Global db

		order_table := this.stringify(this.prev_prefix) "prefixo"
		order_list := db.load_table_in_array(order_table)
		return_value := []
		for, each, value in order_list{
			if(order_list[A_Index, 2] = "")
				Continue
			return_value.insert(order_list[A_Index, 2]) 
		}
		Return return_value
	}

	get_prefix_without_last(){
		return_value := []
		for, each, value in this.prev_prefix{
			if(A_Index = this.prev_prefix.MaxIndex())
				Break

			return_value.insert(value)
		}
		return return_value 
	}
}

;tree_structure :=
;(JOIN
;	"Totallight`n"
;	"`tProdutos acabados`n"
;	"`t`tLuminaria`n"
;	"`t`t`tTL.L.EXE.010`n"
;)
;hash_mask := {}
;hash_mask["Totallight"] := "T"
;hash_mask["Produtos acabados"] := ""
;hash_mask["Luminaria"] := "L"
;hash_mask["TL.L.EXE.010"] := "010"

;code_list := []
;field_list := []
;loop, % 4
;{
;	code_list[A_Index, 1] := "TL010122956ACS"
;	code_list[A_Index, 2] := "Luminaria TL.L.EXE.010"
;	code_list[A_Index, 3] := "Luminaria TL.L.EXE.010"
;	code_list[A_Index, 4] := "Lighting TL.L.EXE.010"	
;	field_list[A_Index] := "Campo_" A_Index
;}

;Campo_1 := ["1", "2", "3"]
;Campo_2 := ["1", "2", "3", "4"]
;Campo_3 := ["1", "2", "3", "4", "5"]
;Campo_4 := ["1", "2", "3", "4", "5", "6"]



;promtoXML := new PromtoXML()
;promtoXML.generate(tree_structure, hash_mask)

#Include, XML\xml.ahk 
#Include, lib\general_funcs.ahk
