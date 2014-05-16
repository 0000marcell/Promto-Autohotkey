class Status{

	change_status(info, status_value, user, msg){
		Global mariaDB

		if(msg = ""){
			MsgBox, 16, Erro, % "Escreva uma mensagem antes de prosseguir!"
			return				
		}

		if(status_value = ""){
			MsgBox, 16, Erro, % "O status estava em branco por isso nao sera atualizado !"
			return
		}

		if(info.empresa[1] = "" || info.tipo[1] = "" || info.familia[1] = "" || info.modelo[1] = ""){
		 	MsgBox, 16, Erro, % "Umas das informacoes sobre o item estava em falta por isso as informacoes nao foram gravadas no status!"
		 	return
		 }
     
		Prodkey := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2]

		if(!this.status_exists(Prodkey)){
			record := {}
	    record.Usuario := user
	    record.Status := status_value
	    record.Mensagem := msg
	    record.Prodkey := Prodkey
	    mariaDB.Insert(record, "status")	
		}else{
  		try{
    		mariaDB.Query(
    			(JOIN
    				"	UPDATE status SET Usuario='" user "' "
    				", Status='" status_value "' "
    				", Mensagem='" msg "' "
    				" WHERE Prodkey like '" Prodkey "'"
    			))
    	}catch e 
    		MsgBox,16,Erro, % "Um erro ocorreu ao tentar alterar o status do item " Prodkey " `n" ExceptionDetail(e)
		}
	}
	
	/*
		Pega o status 
		de determinado item
	*/
	get_status(info, ProdKey = "blank"){
		Global mariaDB, db

		if(ProdKey = "blank"){
			Prodkey := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2]	
		}
		items := db.find_items_where("Prodkey like '" Prodkey "'", "status")
    return items
	}

  /*
    Pega todos os items da lista de status com determinada 
    condicao
  */
  get_items(condition){
    Global mariaDB, db
    items := db.find_items_where(condition, "status")
    return items
  }


	/*
		Verifica se ja existe status para o item
	*/
	status_exists(Prodkey){
		Global db

		items := db.find_items_where("ProdKey like '" Prodkey "'", "status")
		if(items[1, 1] != ""){
			return 1
		}else{
			return 0 
		}
	}
}
