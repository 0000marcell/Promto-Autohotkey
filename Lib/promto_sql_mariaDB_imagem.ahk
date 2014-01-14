class Imagem{

	/*
		Incluir uma nova imagem no banco e copia o arquivo 
		para a pasta de imagems do programa
	*/
	incluir(source = "", nome_imagem = "", codigos_array = ""){
		Global mariaDB, empresa, tipo, familia, modelo, global_image_path

		if(empresa.mascara = "" || familia.mascara = "" | modelo.mascara = ""){
			MsgBox, % "empresa mascara: " empresa.mascara " tipo mascara: " tipo.mascara " familia mascara : " familia.mascara " modelo.mascara " modelo.mascara
			MsgBox,16,Erro, % "Algum valor referente ao item estava em branco(empresa, tipo, familia ou modelo)"
			return
		}

		if(source = ""){
			MsgBox,16,Erro, % "O caminho da imagem nao foi encontrado!"
			return 
		}

		if(nome_imagem = ""){
			MsgBox,16,Erro, % "O nome da imagem nao pode estar em branco!"
			Return
		}

		/*
			Verifica se o nome da determinada imagem ja existe no banco
		*/
		if(this.exists(nome_imagem)){
			MsgBox,16,Erro, % " Ja existe uma imagem no banco com este nome escolha outro nome!" 
			return 
		}

		/*
			Move a imagem inserida para a 
			pasta de imagens do programa
		*/
		FileCopy, %source%,temp\%nome_imagem%.jpg, 1

		final_image_path = %global_image_path%%nome_imagem%.jpg
		/*
			Converte a imagem para o formato necessario
		*/
		this.convert_image("temp\" nome_imagem ".jpg")
		
		/*
			Move a imagem para a pasta externa
		*/ 
		FileCopy, temp\%nome_imagem%.jpg, %global_image_path%%nome_imagem%.jpg, 1

		if(ErrorLevel){
			MsgBox,16,Erro, % "A imagem nao pode ser copiada!"
			return 
		}

		/*
			Insere o valor na tabela
		*/
		record := {}
		record.Name := nome_imagem
		mariaDB.Insert(record, "imagetable")

		/*
			Retira a entrada de referencia antiga 
			caso exista
		*/
		tabela1 := empresa.mascara tipo.mascara familia.mascara modelo.mascara modelo.nome
		this.remove_old_relation(tabela1)

		/*
			Insere a imagem na tabela de referencia
		*/
		if(codigos_array["code", 1] != ""){
			for, each, value in codigos_array["code"]{
				codigo := codigos_array["code", A_Index]
				this.remove_old_relation(codigo)
				append_debug("ira inserir a imagem tabela1 : " codigo " tabela2 " nome_imagem)
				record := {}
				record.tipo := "image"
				record.tabela1 := codigo
				record.tabela2 := nome_imagem
				mariaDB.Insert(record, "reltable")		
			}
		}else{
			record := {}
			record.tipo := "image"
			record.tabela1 := tabela1
			record.tabela2 := nome_imagem
			mariaDB.Insert(record, "reltable")	
		}		
	}

	/*
		Deleta a imagem e todas as relacoes 
		de outros items com essa imagem 
	*/
	remove(image_name){
		Global mariaDB

		if(image_name = ""){
			MsgBox,16,Erro, % "O nome da imagem nao pode estar em branco!"
			return 
		}
		MsgBox, 4,, % "Tem certeza que deseja apagar a imagem ? `n todos os items que dependem dessa imagem ficarao sem imagem."
		IfMsgBox Yes
		{
			/*
				Apaga todas as referencias com essa imagem
			*/
			try{
				mariaDB.Query(
					(JOIN 
						" DELETE FROM reltable "
						" WHERE tipo LIKE 'image' "
						"	AND tabela2 LIKE '" image_name "'"
					))
			}catch e
				MsgBox,16,Erro, % "Um erro ocorreu ao tentar remover a entrada da tabela antiga `n" ExceptionDetail(e) 	
			
			/*
				Apaga a entrada dessa imagem da tabela de 
				imagens
			*/
			try{
				mariaDB.Query(
					(JOIN 
						" DELETE FROM imagetable "
						" WHERE Name LIKE '" image_name "'"
					))
			}catch e
				MsgBox,16,Erro, % "Um erro ocorreu ao tentar remover a entrada da tabela antiga `n" ExceptionDetail(e) 	
			MsgBox,64,Sucesso!, % "A imagem e todas as suas dependencias foram removidas!" 
		}
		
	}

	/*
		Relaciona uma imagem ja existente no 
		banco com um modelo 
	*/
	link_up(info, image_name, codigo = "", convert_image = 1){
		Global mariaDB, global_image_path

		if(info.empresa[2] = "" || image_name = ""){
			MsgBox,16,Erro, % "As informacoes sobre o modelo ou o caminho da imagem esta em branco!" 
			return
		}

	
		/*
			Move a imagem para a pasta do programa para ser convertida
		*/
		FileCopy, %global_image_path%%image_name%.jpg, temp\%image_name%.jpg, 1
		
		/*
			Converte a imagem para o formato neccessario 
		*/
		if(convert_image = 1)
			this.convert_image("temp\" image_name ".jpg")

		/*
			Copia a imagem de volta para a pasta externa
		*/
		FileCopy, temp\%image_name%.jpg, %global_image_path%%image_name%.jpg, 1

		/*
			Retira a entrada de referencia antiga 
			caso exista
		*/		
		if(codigo = ""){
			tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
		}else{
			tabela1 := codigo 
		}

		this.remove_old_relation(tabela1)

		/*
			Insere a imagem na tabela de referencia
		*/
		append_debug("ira fazer a linkagem da imagem tabela1 : " tabela1 " image_name : " image_name)
		record := {}
		record.tipo := "image"
		record.tabela1 := tabela1
		record.tabela2 := image_name
		mariaDB.Insert(record, "reltable")

		;MsgBox,64,Sucesso, % "A imagem foi inserida!"
	}

	/*
		Verifica se determinado 
		Familia ja existe na tabela
	*/
	exists(nome_imagem){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT Name FROM imagetable "
				" WHERE Name LIKE '" nome_imagem "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}
	}

	/*
		Funcao que pega o caminho da
		imagem relacionada com esse modelo
	*/
	get_image_path(tabela1){
		Global mariaDB

		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like 'image' "
				" AND tabela1 like '" tabela1 "'"
			))
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}

	/*
		Remove a entrada antiga
	*/
	remove_old_relation(tabela1){
		Global mariaDB

		try{
			mariaDB.Query(
				(JOIN 
					" DELETE FROM reltable "
					" WHERE tipo LIKE 'image' "
					"	AND tabela1 LIKE '" tabela1 "'"
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar remover a entrada da tabela antiga `n" ExceptionDetail(e) 
	}
	
	/*
		Convert image determinada imagem para jpg e coloca a imagem no mesmo lugar
	*/
	convert_image(image_path){
		FileDelete, % "temp\image_info.txt"
		;MsgBox, % "caminho da imagem antes da conversao " image_path
	  StringReplace, image_path, image_path, \, /,All
	  ;MsgBox, % "caminho da imagem apos a conversao " image_path
		FileAppend, % image_path, % "temp\image_info.txt"
		RunWait, % "Lib\ConvertImage.jar"
	}
}