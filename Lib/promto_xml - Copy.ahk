class PromtoXML{
	__New(){
		this.file_path := "promto_data.xml"
		FileDelete, % this.file_path

		try{
			; create an XMLDOMDocument object
			; set its top-level node
			this.XML := new xml("<root/>")
		}catch pe{
			; catch parsing error(if any)
			MsgBox, 16, PARSE ERROR
			, % "Exception thrown!!`n`nWhat: " pe.What "`nFile: " pe.File
			. "`nLine: " pe.Line "`nMessage: " pe.Message "`nExtra: " pe.Extra
		} 
		
		if this.XML.documentElement {
			this.XML.addElement("promto", "root")
		}
		this.companies := []
		this.start_company()
		this.hash_mask := {}
		this.prev_prefix := [] ; String containing the previous prefixes
		this.fields := []
	}

	generate(string, hash_mask){
		this.hash_mask := hash_mask
		StringSplit, items, string, `n,
		prev_item_tab_count := 0
		blanks_items := 0

		Loop, % items0
		{
			if(items%A_Index% = ""){
				blanks_items++
				Continue
			}
			StringSplit, tab_count, items%A_Index%, `t,
			this_item_tab_count := tab_count0 - 1 - blanks_items
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
				}else if(this_item_tab_count = 2){
					this.models := []
					this.subfamilies := []
				}else if(this_item_tab_count = 1){
					this.families := []
				}else if(this_item_tab_count = 0){
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
				this.get_item_prop(this_item_tab_count, items%A_Index%, item%next_item%)
			}

			prev_item_tab_count := this_item_tab_count
		}
		this.XML.transformXML()
		this.XML.viewXML()
		this.XML.save(this.file_path)
		Run, % this.file_path
	}

	/*
		Get the properties of the elements.
	*/
	get_item_prop(count, current_value, next_value){
		item := {}
		/*
			Company
		*/
		if(count = 0){
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
		}else if(count = 1){
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
		}else if(count = 2){
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
		}else if(count = 3){
			/*
				Subfamily
			*/
			if(next_value != ""){
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
			/*
				Model
			*/
			}else{
				item.name := current_value
				item.father := "models"
				item.child :=  "model"
				if(this.subfamilies.MaxIndex() != 0){
					item.path := 
					(JOIN 
						"//promto/companies/company[" this.companies.MaxIndex() "]/"
						"types/type[" this.types.MaxIndex() "]/"
						"families/family[" this.families.MaxIndex() "]"
					)	
				}else{
					item.path := 
					(JOIN 
						"//promto/companies/company[" this.companies.MaxIndex() "]/"
						"types/type[" this.types.MaxIndex() "]/"
						"families/family[" this.families.MaxIndex() "]/"
						"families/subfamily[" this.subfamilies.MaxIndex() "]"
					)	
				}
				item.max_index := this.models.MaxIndex()
				item.name := current_value
				this.add_item(item)
				this.models.insert(current_value)
				this.add_model(item)
			}
		}
	}

	add_item(item){
		if(item.max_index = 0 || item.max_index = ""){
			MsgBox, % "gonna append first element "
			this.XML.addElement(item.father, item.path)
			MsgBox, % " after first element "
		}
		this.prev_prefix.insert(this.hash_mask[item.name])
		xpath := item.path "/" item.father
		prop_hash :=  {mask: this.hash_mask[item.name], prefix: this.stringify(this.prev_prefix)} 
		this.XML.addElement(item.child, xpath, prop_hash, item.name)
	}

	add_model(item){
		global field_list, field_value
		this.fields := []
		xpath := item.path "/" item.father "/model[" this.models.MaxIndex() "]"
		
		;MsgBox, % xpath
		/*
			Insert the code list
		*/
		this.add_code_list(item, xpath)
		
		/*
			Insert the fields and the values of the 
			fields
		*/
		this.add_field_list(item, xpath)
	}

	add_code_list(item, xpath){
		Global code_list 

		this.XML.addElement("code_list", xpath)
		for, each, value in code_list{
			hash_prop := {dc: code_list[A_Index, 2], dr: code_list[A_Index, 3], di: code_list[A_Index, 4] }
			this.XML.addElement("code", xpath "/code_list",hash_prop, code_list[A_Index, 1])	
		}
	}

	add_field_list(item, xpath){
		Global field_list 

		this.XML.addElement("field_list", xpath)
		for, each, value in field_list{
			this.XML.addElement("field", xpath "/field_list", "", value)
			this.fields.insert(value)
			this.add_field_value(itemm, value, xpath)	
		}
	}

	add_field_value(item, value, xpath){
		Global

		/*
			Insert the fields values 
		*/
		for, each, value in %value%{
			field_value := %value%[A_Index]
			this.XML.addElement("field_value", xpath "/field_list/field[" this.fields.MaxIndex() "]", "", field_value)
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
