class PromtoPrinter{
	create_tag(info){
		Global db
		AHK.reset_debug()
		AHK.append_debug("starting the debug ")
		this.info := info
		this.obj := {}, this.obj.items := []
    code_table := get_prefix_from_info(this.info) "Codigo" 
    this.tabela1 := get_prefix_from_info(this.info) this.info.modelo[1]
    this.camp_table := db.get_reference("oc", this.tabela1)
    AHK.append_debug("code table " code_table " tabela1 " this.tabela1 " camp table " this.camp_table) 
    for each, value in list := db.get_values("*", code_table){
    	this.code := list[A_Index, 1]
    	this.desc := list[A_Index, 3]
    	AHK.append_debug("codigo " this.code " desc " this.desc)
    	this.insert_item()
    }
    JSON_save(this.obj, "print_JSON.json")
	}

	insert_item(){
		Global db
		code := this.code
		imagepath := db.Imagem.get_image_full_path(code)
		StringReplace, imagepath, imagepath, \, /, All
		prefix_length := this.get_prefix_length(this.info)
		StringTrimleft, code, code, prefix_length
		prefix_formation := this.get_prefix_formation(this.info)
		fields := this.get_fields(code)
		hash := {
			(JOIN 
				"code": this.code, 
				"desc": this.desc, 
				"image_path": imagepath,
				"prefix":	prefix_formation,
				"fields": fields
			)}
		this.obj.items.insert(hash)	
	}

	get_prefix_formation(info) {
		Global db
		prefix := db.get_ordened_prefix(this.info)
		prefix_return := []	
		for, each, item in prefix{
			prefix_return.insert("prefixo|" item)
		} 
		return prefix_return
	}

	get_fields(code) {
		Global db
		fields := []
		this.code := code
		for, each, item in list := db.get_values("*", this.camp_table) {
			camp_name := AHK.rem_space(list[A_Index, 2])
			camp_esp_table := db.get_reference(camp_name, this.tabela1)
			code_piece := this.get_code_piece(camp_esp_table, camp_name)
			fields.insert(list[A_Index, 2] "|" code_piece)
		}
		return fields 
	}

	get_code_piece(camp_esp_table, camp_name) {
		Global db
		for, each, value in list := db.get_values("*", camp_esp_table){
			code_piece := list[A_Index, 1]
			AHK.append_debug("code piece " code_piece)
			StringLen, length, code_piece
			if(length != ""){
				AHK.append_debug("length " length " code " this.code)
				code := this.code
				StringLeft, code_piece, code, length
				AHK.append_debug("code piece after " code_piece)
				StringTrimLeft, code, code, length
				this.code := code
				AHK.append_debug("code after " this.code)
				Break
			}
		}
		return_value := code_piece 
		return return_value
	}

	get_prefix_length(info){
		Global db
		AHK.append_debug("gonna get the prefix length")
		prefix := get_prefix_from_info(info)
		AHK.append_debug("prefix " prefix)
		StringLen, prefix_length, prefix	
		return prefix_length
	}
}