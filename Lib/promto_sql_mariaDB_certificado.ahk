class Certificado{
	
	/*
		Muda a verificacao do certificado
	*/
	insert_verification(info, user){
		Global mariaDB

		if(info.empresa[1] = ""){
			MsgBox, 16, Erro, % "O hash de informacoes estava em branco"  
			return
		}

		if(user = ""){
			MsgBox, 16, Erro, % " Usuario nao cadastrado a alteracao nao pode ser feita!"
			return 
		}
		

		Prodkey := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] 
		
		if(!this.verification_exists(Prodkey)){
			record := {}
		  record.Usuario := user
		  record.Data := A_DD "/" A_MM "/" A_YYYY
		  record.Hora := A_Hour ":" A_Min
		  record.Prodkey := Prodkey
		  try{
	  		mariaDB.Insert(record, "certificado_verificacao")
	  	}catch e{
	  		MsgBox, 16, Erro, % "Houve um erro ao gravar a verificacao da certificacao `n" ExceptionDetail(e)
	  	} 		
		}
	}

	/*
		Delete a veficacao do certificado
	*/
	delete_verification(info){
		Global db

		Prodkey := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] 
		if(!db.delete_items_where(" Prodkey = '" Prodkey "'", "certificado_verificacao")){
			MsgBox, 13, Erro, % " Erro ao deletar a verificacao da certificacao! "
			return
		}
	}

	/*
		Checa se a verificacao 
		da certificacao ja existe
	*/
	verification_exists(prodkey){
		Global db

		items := db.find_items_where("Prodkey = '" prodkey "'", "certificado_verificacao")
		if(items[1, 1] != ""){
			return 1
		}else{
			return 0 
		}
	}	
}