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

	/*
		Insere um novo certificado no banco 
		de certificados
	*/
	insert_cert(a){
		Global mariaDB

		if(!this.check_args(a)){
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
			return
		}else{

		}

		/*
			Verifica se o modelo ja esta na lista de certificados
		*/
		if(!this.cert_exists(a.model)){

		}else{

		}
	}

	/*
		Verifica se o certificado ja existe na lista
	*/
	cert_exists(model){
		Global db

		items := db.find_items_where("Prodkey = '" prodkey "'", "certificado_verificacao")
		if(items[1, 1] != ""){
			return 1
		}else{
			return 0 
		}
	}

	/*
		Verifica se todos os 
		argumentos para inserir o certificado estao corretos
	*/
	check_args(a){
		if(a.file_path_cert = ""){
			MsgBox, % "Selecione um arquivo de certificado." 
			return 0
		}

		if(a.mod_cert = ""){
			MsgBox, % " Escreva o modelo do produto ao qual o produto sera associado."
			return 0
		}

		if(a.comp_info = ""){
			MsgBox, % " Escreva uma descricao complementar sobre o certificado."
			return 0
		}

		if(a.emission_date = ""){
			return 0
		}

		if(a.expiration_date = ""){			  
			return 0
		}

		/*
			Verifica se a data de vencimento e maior que a data de emissao
		*/
		StringLeft, emission_date, a.emission_date, 8
		StringLeft, expiration_date, a.expiration_date, 8
		if(emission_date > expiration_date){
			MsgBox, 16, Erro, % "A data de emissao e posterior a data de vencimento!"
			return 0
		}
		/*
			Verifica se a data de emissao e de vencimento sao iguais
		*/
		if(emission_date = expiration_date){
			MsgBox, 16, Erro, % " A data de emissao nao pode ser igual a data de vencimento!"
			return 0 
		}
		return 1
	}
}