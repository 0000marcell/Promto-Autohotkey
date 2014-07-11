class Imagem{

	/*
		Incluir uma nova imagem no banco e copia o arquivo 
		para a pasta de imagems do programa
	*/
	incluir(source = "", nome_imagem = "", codigos_array = ""){
		Global mariaDB, info, global_image_path

		if(info.empresa[2] = "" || info.familia[2] = "" | info.modelo[2] = ""){
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

		FileCopy, %source%, temp\image_to_convert.jpg, 1

		/*
			Converte a imagem para o formato necessario
		*/
		this.convert_image("temp\image_to_convert.jpg")
		
		/*
			Insere o valor na tabela
		*/
		record := {}
		record.Name := nome_imagem
		mariaDB.Insert(record, "imagetable")

		image_id := this.get_image_id(nome_imagem)

		/*
			Move a imagem para a pasta externa
		*/ 
		FileCopy, temp\image_to_convert.jpg, %global_image_path%promto_imagens\promto_%image_id%.jpg, 1

		if(ErrorLevel){
			MsgBox,16,Erro, % "A imagem nao pode ser copiada!"
			return 
		}

		/*
			Retira a entrada de referencia antiga 
			caso exista
		*/

		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2] info.modelo[1]
		
		this.remove_old_relation(tabela1)

		/*
			Insere a imagem na tabela de referencia
		*/
		if(codigos_array["code", 1] != ""){
			for, each, value in codigos_array["code"]{
				codigo := codigos_array["code", A_Index]
				this.remove_old_relation(codigo)
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
		Global mariaDB, global_image_path

		image_id := image_name[1]
		image_name := image_name[2]

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
			
			FileDelete, %global_image_path%promto_imagens\promto_%image_id%.jpg 
			MsgBox,64,Sucesso!, % "A imagem e todas as suas dependencias foram removidas!" 
		}
		
	}

	/*
		Relaciona uma imagem ja existente no 
		banco com um modelo 
	*/
	link_up(info, image, codigo = "", convert_image = 1){
		Global mariaDB, global_image_path

		image_id := image[1]
		image_name := image[2]

		if(info.empresa[2] = "" || image_name = ""){
			MsgBox,16,Erro, % "As informacoes sobre o modelo ou o caminho da imagem esta em branco!" 
			return
		}

	
		/*
			Move a imagem para a pasta do programa para ser convertida
		*/
		FileCopy, %global_image_path%promto_imagens\promto_%image_id%.jpg, temp\%image_name%.jpg, 1
		
		/*
			Converte a imagem para o formato neccessario 
		*/
		if(convert_image = 1)
			this.convert_image("temp\" image_name ".jpg")

		/*
			Copia a imagem de volta para a pasta externa
		*/
		FileCopy, temp\%image_name%.jpg, %global_image_path%promto_imagens\promto_%image_id%.jpg, 1

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

		image_id := this.get_image_id(reference_table)
		if(image_id = "")
			image_id := 0

		image_path := "promto_" image_id
		return image_path
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
		IfNotExist, % image_path
		{
			MsgBox, 16, Erro, % "A imagem a ser convertida nao existia na pasta."
			return
		}
		FileDelete, % "temp\image_info.txt"
		;MsgBox, % "caminho da imagem antes da conversao " image_path
	  StringReplace, image_path, image_path, \, /,All
	  ;MsgBox, % "caminho da imagem apos a conversao " image_path
		FileAppend, % image_path, % "temp\image_info.txt"
		RunWait, % "Lib\ConvertImage.jar"
	}

	get_image_id(image_name){
		Global mariaDB, db

		if(image_name = ""){
			return 
		}

		items := db.find_items_where("Name like '" image_name "'", "imagetable")
		id := items[1, 1]
		return id
	}

	get_image_full_path(tabela1){
		Global mariaDB, global_image_path
		
		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like 'image' "
				" AND tabela1 like '" tabela1 "'"
			))
		reference_table := rs.tabela2
		rs.close()

		image_id := this.get_image_id(reference_table)
		if(image_id = "")
			image_id := 0

		image_source := global_image_path "promto_imagens\promto_" image_id  ".jpg"
		return image_source
	}

	get_html_image_full_path(tabela1){
		Global mariaDB, global_image_path

		
		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like 'image' "
				" AND tabela1 like '" tabela1 "'"
			))
		reference_table := rs.tabela2
		rs.close()

		image_id := this.get_image_id(reference_table)
		if(image_id = "")
			image_id := 0

		image_source := "promto_imagens\promto_" image_id  ".jpg"
		return image_source
	}
}