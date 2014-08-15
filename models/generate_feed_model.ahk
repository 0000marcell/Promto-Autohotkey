class GenerateJSONFeed{
	generate_feed(){
		Global db
		FileDelete, % "promto_feed_JSON"
		this.obj := {}
		this.load_log()		
	}

	load_log(){
	 Global db
	 this.obj.log := []
	 this.insert_CRUD()
	 this.obj.max_index := this.obj.log.maxindex()
	 MsgBox, % "max index " this.obj.log.maxindex()
	 this.save_file() 
	}

	insert_CRUD(){
		Global db
		For each, value in list := db.get_values("*", "CRUD"){
			hash := {
		 		(JOIN 
		 			"usuario": list[A_Index, 2], "tipo":    list[A_Index, 3],
		 			"item":    list[A_Index, 4], "data": 	 list[A_Index, 5],
		 			"hora":     list[A_Index, 6], "msg":list[A_Index, 7],
		 			"prodkey": list[A_Index, 8]
		 		)}
		 	this.obj.log.insert(hash)
		}
	}

	save_file(){
		JSON_save(this.obj, "promto_feed_JSON.json")
	}
}
