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
			MsgBox, 16, Erro, % " Erro ao deletar a verificacao da certificacao! "
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
	insert_cert(a, info){
		Global mariaDB, USER_NAME, global_cert_path

		insert_result := 0
		if(this.check_args(a)){

			/*
				Copia o certificado para a pasta de certificados
			*/ 
			FileCopy, % a.file_path_cert, % global_cert_path a.mod_cert ".pdf", 1
			
			if(ErrorLevel){
				MsgBox, 16, Erro, % "O certificado nao pode ser copiado!"
				return 
			}

			/*
				verifica se ja existe uma entrada pro determinado modelo
			*/
			if(this.cert_exists(a.mod_cert)){
				MsgBox, 4, , O certificado a ser inserido ja existia na lista, deseja substituir?
				IfMsgBox YES
				{
					this.delete_cert(a.mod_cert)
				}else{
					MsgBox, % " O item nao foi inserido!"
					return
				}
			}

			record := {}
		  record.Usuario := USER_NAME
		  record.data_emissao := a.emission_date
		  record.data_vencimento := a.expiration_date
		  record.comp_info := a.comp_info
		  record.caminho_arquivo := a.mod_cert ".pdf"
		  record.modelo := a.mod_cert

		  try{
	  		mariaDB.Insert(record, "certificados")
	  		insert_result := 1
	  	}catch e{
	  		MsgBox, 16, Erro, % " Houve um erro ao gravar o novo certificado `n" ExceptionDetail(e)
	  		return
	  	} 		 
		}

		/*
			Relaciona o determinado 
			modelo com o certificado na reltable caso
			o info noa esteja em branco
		*/

		
		if(!insert_result || info.empresa[1] = ""){
			MsgBox, 64, Sucesso, % "O certificado foi incluido!"
			return
		}

		this.insert_relation(a.mod_cert, info)	
		MsgBox, 64, Sucesso, % "O certificado foi incluido e linkado com o item!"
		return
	}

	/*
		Deleta o certificado da lista e a da pasta 
	*/
	delete_cert(modelo){
		Global db

		if(modelo = ""){
			MsgBox, % "O modelo do certificado a ser deletado nao pode estar em branco!"
			return
		}

		db.delete_items_where(" modelo = '" modelo "'", "certificados")
	}

	/*
		Deleta a relacao da reltable
	*/
	delete_rel(tabela1){
		Global db
		if(!db.delete_items_where(" tipo = 'certificado' AND tabela1 = '" tabela1 "'", "reltable")){
			MsgBox, 16, Erro, % " Erro ao deletar a relacao do item com o certificado!"
			return
		}
	}

	/*
		Relacione o certificado na reltable
	*/
	insert_relation(modelo, info){
		Global mariaDB

		if(modelo = "" || info.empresa[1] = ""){
			MsgBox, 16, Erro, % "Valores necessarios para fazer a relacao entre o certificado e o modelo estavam em branco!" 
			return
		}

		/*
			Verifica se a relacao ja existe
			na tabela de relacionamento
		*/
		tabela1 := get_prefix_from_info(info) info.modelo[1]
		if(this.rel_exists(tabela1)){
			MsgBox, 4, , % "O item a ser inserido ja esta relacionado na tabela, deseja substituir?"
			IfMsgBox YES
			{
				this.delete_rel(tabela1)
			}else{
				return
			}
		}
		try{
			record := {}
			record.tipo := "certificado"
			record.tabela1 := tabela1
			record.tabela2 := modelo
			mariaDB.Insert(record, "reltable")
		}catch e{
			MsgBox, 16, Erro, % " Houve um erro ao inserir a relacao do certificado com o modelo `n" ExceptionDetail(e)
		}
	}

	/*
		verifica se a relacao ja existe na reltable
	*/
	rel_exists(tabela1){
		Global db 

		items := db.find_items_where(" tipo = 'certificado' AND tabela1 = '" tabela1 "'", "reltable")
		if(items[1, 1] != ""){
			return 1
		}else{
			return 0 
		}		
	}

	/*
		Verifica se o certificado ja existe na lista
	*/
	cert_exists(model){
		Global db

		items := db.find_items_where("modelo = '" model "'", "certificados")
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
		ed := a.emission_date
		vd := a.expiration_date
		StringLeft, emission_date, ed, 8
		StringLeft, expiration_date, vd, 8
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