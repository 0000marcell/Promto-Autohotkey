class PromtoJSONStructure{
	__New(){
	}

	generate_JSON(code) {
		;TL010122956ACS
    ;AHK.reset_debug()
		this.obj := {}
		this.db := new PromtoSQLServer("TOTALLIGHT")	
		this.code := code
		if(!IsObject(this.db)){
			MsgBox, 64, , % "A conexao falhou!! confira os parametros!!"
		}
		this.generate()
	}

	generate(){
    ;AHK.append_debug("gonna query " this.code)
		items := this.db.find_items_where(" SG1060.G1_COD Like '" this.code "'", "SG1060")
    ;AHK.append_debug("returned value 3 " items[1, 3] " 4 " items[1, 4] " 5 " items[1, 5])
		this.obj.id := items[1, 2], this.obj.name := ""
		this.obj.children := []
    values := {
        (JOIN
          "id": items[1, 3],  
          "name": "",
          "children": []
        )}
    obj.children.insert(values)
    string := JSON_to(this.obj)
		;this.insert_subvalues(items[1, 3], this.obj.children[this.obj.children.maxindex()])) 
    ;AHK.append_debug("gonna try to save the obj `n `n " string )
    ;JSON_save(this.obj, "structure_JSON.json")
	}

	insert_subvalues(code, obj){
    ;AHK.append_debug("`n `n `n code " code)
    string := JSON_to(this.obj) 
    ;AHK.append_debug("gonna try to save the obj `n `n " string )
		items := this.db.find_items_where(" SG1060.G1_COD Like '" code "'", "SG1060")
		for, each, item in items{
      values := {
        (JOIN
          "id": items[1, 3],  
          "name": "",
          "children": []
        )}
      obj.insert(values)
      ;AHK.append_debug("the father was " code)
      obj.children.insert(this.insert_subvalues(items[A_Index, 3], obj.children))
		} 
		return obj
	}
}