class Log{
	/*
		Insere informacoes de modificacao de produto de certo usuario
	*/
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

		 data :=  A_DD "/" A_MM "/" A_YYYY
		 hora :=  A_Hour ":" A_Min
		 item := "|empresa|" info.empresa[1] "|tipo|" info.tipo[1] "|familia|" info.familia[1] "|subfamilia|" info.subfamilia[1] "|modelo|" info.modelo[1]
		
		Prodkey := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] 
		
		record := {}
    record.Usuario := user
    record.Item := item
    record.Data := data
    record.Hora := hora
    record.Mensagem := msg
    record.Validade := "nao validado"
    record.Prodkey := Prodkey
    mariaDB.Insert(record, "log")
	}

	get_mod_info(info){
		Global db

		Prodkey := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2]
		items := db.find_items_where("Prodkey like '" Prodkey "' ORDER BY id DESC limit 5", "log")
		return items 
	}
}