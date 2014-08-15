class Log{
	
	insert_mod_info(info, user, msg){
		 global mariaDB
		 
		 if(msg = ""){
		 		MsgBox, 16, Erro, % "Digite uma mensagem antes de continuar"
		 		return
		 }
		 
		 if(info.empresa[1] = "" || info.tipo[1] = "" || info.familia[1] = "" || info.modelo[1] = ""){
		 	MsgBox, 16, Erro, % "Umas das informacoes sobre o item estava em falta por isso as informacoes nao foram gravadas no log!"
		 	return
		 }
		record := {}
	  record.Usuario := user
	  record.Item := this.get_item(info)
	  record.Data := A_DD "/" A_MM "/" A_YYYY
	  record.Hora := A_Hour ":" A_Min
	  record.Mensagem := msg
	  record.Validade := "nao validado"
	  record.Prodkey := this.get_prodkey(info)
	  mariaDB.Insert(record, "log")
	}

	get_mod_info(info, Prodkey = "blank"){
		Global db

		if(Prodkey = "blank"){
			Prodkey := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2]	
		}
		items := db.find_items_where("Prodkey like '" Prodkey "' ORDER BY id DESC limit 5", "log")
		return items 
	}

	insert_CRUD(info, tipo, msg){
		Global mariaDB, USER_NAME
		record := {}
    record.Usuario := USER_NAME 
    record.tipo := tipo
    record.Item := this.get_item(info)
    record.Data := A_DD "/" A_MM "/" A_YYYY
    record.Hora := A_Hour ":" A_Min
    record.Mensagem := msg
    record.Prodkey := this.get_prodkey(info)
    mariaDB.Insert(record, "CRUD") 
	}

	get_prodkey(info){
		if(info.empresa[1] = "")
			return "..."
		prodkey :=
			(JOIN 
				info.empresa[2] 
				info.tipo[2] 
				info.familia[2] 
				info.subfamilia[2] 
				info.modelo[2]
			)
		return prodkey
	}

	get_item(info){
		if(info.empresa[1] = "")
			return "..."
		item := 
			(JOIN 
				"|empresa|" info.empresa[1]
				"|tipo|" info.tipo[1]
				"|familia|" info.familia[1]
				"|subfamilia|" info.subfamilia[1]
				"|modelo|" info.modelo[1]
			)
		return item	
	}
}