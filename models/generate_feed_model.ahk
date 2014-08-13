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
	 For each, value in list := db.get_values("*", "log"){
	 	hash := {
	 		(JOIN 
	 			"usuario": list[A_Index, 2], "item":    list[A_Index, 3],
	 			"data":    list[A_Index, 3], "hora": 	 list[A_Index, 4],
	 			"msg":     list[A_Index, 5], "validade":list[A_Index, 6],
	 			"prodkey": list[A_Index, 7]
	 		)}
	 	this.obj.log.insert(hash)	
	 }
	 this.save_file() 
	}

	save_file(){
		JSON_save(this.obj, "promto_feed_JSON.json")
	}
}
