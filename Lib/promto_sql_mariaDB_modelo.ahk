class Modelo{
	
	/*
		Incluir um novo modelo
	*/
	incluir(modelo_nome = "", modelo_mascara = "", prefixo = "", already_in_table = "", info = ""){
		Global mariaDB, ETF_hashmask

		modelo_nome := Trim(modelo_nome), modelo_mascara := Trim(modelo_mascara)
		prefixo := Trim(prefixo)

		/*
			Confere se o item a ser inserido 
			ja contem uma mascara linkada a ele
		*/
		if(ETF_hashmask[modelo_nome] != ""){
			error_msg :=
			(JOIN
				"Ja existe uma outra mascara linkada com o nome inserido!`n "
				"Voce pode usar a mesma mascara: " ETF_hashmask[modelo_nome] "`n"
				" Ou alterar o nome."  
			)
			MsgBox, 4, Item duplicado, % error_msg 
			IfMsgBox Yes
			{
				modelo_mascara := ETF_hashmask[modelo_nome]
				MsgBox, % "A mascara foi alterada para " modelo_mascara 
			}else{
				MsgBox, % "O item nao foi inserido, insira outra vez alterando o nome! "
				return
			}
		}

		/*	
			Verifica se o prefixo a inserir o item 
			esta em branco
		*/
		if(prefixo = ""){
			MsgBox, % "O prefixo nao pode estar em branco nos modelos!"
			return
		}

		if(modelo_nome = "" || modelo_mascara = ""){
			MsgBox, % "o nome e a mascara do modelo nao podem estar em brancos!"
			return			
		}

		/*
			Verifica se a mascara a ser inserida 
			ja existe
		*/
		tabela1 :=
		(JOIN
			info.empresa[2]
			info.tipo[2]
			info.familia[2]
			info.subfamilia[2]
			info.modelo[2]
			info.modelo[1] 
		)
		model_table := db.get_reference("Modelo", tabela1)
		if(model_table = ""){
			model_table := prefixo "Modelo"
		}

		if(already_in_table != 1){	
			if(this.exists(modelo_nome, modelo_mascara, prefixo, model_table)){
				MsgBox,16,Erro, % " A mascara a ser inserida ja existe!" 
				return 
			}	
		}
		
		/*
			Insere o valor na tabela
			caso o parametro de existencia na tabela nao seja verdadeiro
		*/
		if(already_in_table != 1){
			record := {}
			record.Modelos := modelo_nome
			record.Mascara := modelo_mascara
			mariaDB.Insert(record, model_table)	
		}
		

		/*
			Cria a tabela de campos
			e insere na tabela de referencias.
		*/

		tables := ["Campo", "oc", "odr", "odc", "odi", "Codigo", "Desc", "Bloqueio"]

		for, each, tipo in tables{
			if(tipo = "Codigo"){
				try{
					mariaDB.Query(
					(JOIN 
						"	CREATE TABLE IF NOT EXISTS " prefixo modelo_mascara tipo
						" (Codigos VARCHAR(250),"
						" DR VARCHAR(300), "
						" DC VARCHAR(600), "
						" DI VARCHAR(300)) "
					))
				}catch e
					MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Codigos `n" ExceptionDetail(e)

			}

			if(tipo = "Bloqueio"){
				try{
				mariaDB.Query(
					(JOIN 
						"	CREATE TABLE IF NOT EXISTS " prefixo modelo_mascara tipo
						" (Codigos VARCHAR(250)) "
					))
				}catch e
				MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Bloqueios `n" ExceptionDetail(e)
			}

			if(tipo != "Desc" && tipo != "Codigo" && tipo != "Bloqueio"){
				try{
				mariaDB.Query(
					(JOIN 
						"	CREATE TABLE IF NOT EXISTS " prefixo modelo_mascara tipo
						" (id MEDIUMINT NOT NULL AUTO_INCREMENT,"
						" Campos VARCHAR(250), "
						" PRIMARY KEY (id)) "
					))
				}catch e
				MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Campos `n" ExceptionDetail(e)	
			}
			
			if(tipo = "Desc"){
				;MsgBox, % "ira criar tabela de descriaco!"
				try{
					mariaDB.Query(
						(JOIN 
							"	CREATE TABLE IF NOT EXISTS " prefixo modelo_mascara "Desc"
							" (descricao VARCHAR(250))"
						))
				}catch e
					MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de descricao geral `n" ExceptionDetail(e)	
			}	
		
			/*
				Verifica se a relacao ja nao existe 
				na tabela de relacionamento antes de inserir
			*/
			if(!this.get_reference(prefixo, modelo_nome, modelo_mascara, tipo)){
				record := {}
				record.tipo := tipo
				record.tabela1 := prefixo modelo_mascara modelo_nome
				record.tabela2 := prefixo modelo_mascara tipo
				mariaDB.Insert(record, "reltable")
			}
		}
		;MsgBox,64,Sucesso, % " O valor foi inserido!" 
	}

	/*
		Excluir modelo
	*/
	excluir(modelo_nome = "", modelo_mascara = "", info = "", recursiva = 1){
		Global mariaDB, db

		/*
		 Excluir a entrada do modelo
		 na tabela de modelos
		*/

		prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] 
		tabela1 :=
		(JOIN
			info.empresa[2]
			info.tipo[2]
			info.familia[2]
			info.subfamilia[2]
			info.modelo[2]
			info.modelo[1] 
		)

		model_table := db.get_reference("Modelo", tabela1)
		if(model_table = ""){
			model_table := prefixo "Modelo"
		}
		if(!this.exists(modelo_nome, modelo_mascara, prefixo, model_table)){
			MsgBox, 16, Erro, % " O valor a ser deletado nao existia na tabela de modelos: " model_table
			return 
		}

		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM " model_table
				" WHERE Mascara like '" modelo_mascara "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de Modelos `n " ExceptionDetail(e)
		
		/*
			Exclui a tabela
			relacionada com esse modelo
			caso ela nao esteja mais relacionada com mais nada
			e exclui a referencia
		*/

		tables := ["Campo", "oc", "odr", "odc", "odi", "Codigo", "Desc"]

		for,each, tipo in tables{  
   	 	linked_table := this.get_reference(prefixo, modelo_nome, modelo_mascara, tipo)
			 
			if(linked_table = ""){ 
				error_msg :=
				(JOIN
					"Nenhuma tabela de " tipo " foi" 
					"retornada para o modelo: " modelo_nome 
					"`n verifique a consistencia dos dados."				
				)
				MsgBox,16,Erro, % error_msg
				return 
			}

			/*
				Deleta a entrada da 
				tabela de relacionamento
			*/
			try{
				mariaDB.Query(
				(JOIN 
					" DELETE FROM reltable "
					" WHERE tipo like '" tipo "'"
					" AND tabela1 like '" prefixo modelo_mascara modelo_nome "'"
				))	
			}catch e 
				MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de referencia " ExceptionDetail(e)
			
			/*
				verifica se ainda existe alguma tabela
				linkada com essa tabela
				se nao existir deleta a tabela. 
			*/
			this.delete_if_no_related(linked_table, tipo)
		}
		
		/*
			Apaga a referencia da imagem
		*/
		try{
				mariaDB.Query(
				(JOIN 
					" DELETE FROM reltable "
					" WHERE tipo like 'image'"
					" AND tabela1 like '" prefixo modelo_mascara modelo_nome "'"
				))	
			}catch e 
				MsgBox, 16, Erro, % " Erro ao tentar apagar a relacao da imagem " ExceptionDetail(e)
	}

	/*
		Incluir ordem
	*/
	incluir_ordem(items, tabela_ordem, codigos_omitidos = ""){
		Global mariaDB

		
		try{
			mariaDB.Query(
				(JOIN
					"TRUNCATE TABLE " tabela_ordem
				))
		}catch e 
			MsgBox,16,Erro, % "Ocorreu um erro ao apagar todos os items da tabela de ordem `n" ExceptionDetail(e)
		
		/* 
			Incluir o campo de omicao
		*/

		try{
			mariaDB.Query(
				(JOIN
					"ALTER TABLE " tabela_ordem " ADD Omitir VARCHAR(60);"
				))
		}catch e 
			MsgBox,64 , Aviso, % "A estrutura da tabela foi alterada  `n"
		
		for each, item in items{
			record := {}

			record.Campos := item

			if(MatHasValue(codigos_omitidos, item)){
				
				record.Omitir := 1	
			}else{
				
				record.Omitir := 0
			}
			
			mariaDB.Insert(record, tabela_ordem)
		}
	}

	/*
		Insere um nome de campo
	*/
	incluir_campo(campo_nome, info){
		Global mariaDB

		; Coloca o campo no formato necessario
		campo_nome := this.format_field(campo_nome)

		if(campo_nome = ""){
			MsgBox, 16, Erro, %  "Existe um erro na formatacao do campo e nao sera incluido !"
			return
		}
		/*
			Pega a tabela de campos relacionada 
			com o modelo
		*/
		;MsgBox, % "modelo nome: " info.modelo[1] "`n modelo mascara: " info.modelo[2]
		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1] 
		

		tabela_campo := this.get_tabela_campo_referencia(tabela1)

		;MsgBox, % "tabela1 " tabela1 "`n tabela_campo " tabela_campo

		if(this.campo_existe(campo_nome, tabela_campo)){
			MsgBox,16, Erro, % "O campo a ser inserido ja existia!" 
			return
		}

		/*
			-Insere o nome do novo campo na tabela de 
			campos
			
			-Cria a tabela de campos especifica
			
			-Insere o link na tabela de relacionamento 
			entre o modelo e a tabela de campo especifica
		*/
		try{
			mariaDB.Query(
				(JOIN
					"INSERT INTO " tabela_campo 
					" (Campos) VALUES ('" campo_nome "')"  				
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar o valor de campo na tabela `n" ExceptionDetail(e)

		StringReplace,campo_nome_sem_espaco,campo_nome,%A_Space%,,All

		tabela_campo_especifica := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] campo_nome_sem_espaco
			
		try{
				mariaDB.Query(
					(JOIN 
						"	CREATE TABLE IF NOT EXISTS " tabela_campo_especifica 
						" (Codigo VARCHAR(250), DC VARCHAR(250), DR VARCHAR(250), DI VARCHAR(250), "
						" PRIMARY KEY (Codigo)) "
					))
			}catch e
				MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Campos especificos `n" ExceptionDetail(e)
		
		record := {}
		record.tipo := campo_nome_sem_espaco me mt mf mm nm
		record.tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1] 
		record.tabela2 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] campo_nome_sem_espaco
		mariaDB.Insert(record, "reltable")	

		MsgBox,64, Sucesso, % "O campo foi inserido!"
	}

	/*
		Insere os codigos na tabela de codigos
	*/
	inserir_codigo(tabela, valores){
		Global mariaDB

		if(tabela = "" || valores[1] = ""){
			MsgBox,16, Erro, % "A tabela de codigos ou os valores estavam em branco `n tabela de codigos: " tabela "`n valores " valores[1] 
			return
		}
		
		record := {}
		record.Codigos := valores[1]
		record.DR := valores[2]
		record.DC := valores[3]
		record.DI := valores[4]
		mariaDB.Insert(record, tabela)
	}

	remover_codigo(valor, tabela){
		Global mariaDB
		if(tabela = "" || valor = "")
			return

		try{
				mariaDB.Query(
				(JOIN 
					" DELETE FROM " tabela 
					" WHERE Codigos like '" valor "'"
				))	
			}catch e{ 
				MsgBox, 16, Erro, % " Erro ao tentar apagar o campo especifico " ExceptionDetail(e)
				return
		}
	}

	/*
		Incluir bloqueio
	*/
	incluir_bloqueio(value, bloq_table){
		Global mariaDB

		value := Trim(value)

		if(value = ""){
			MsgBox,16, Erro, % "O valor a ser inserido nao pode estar em branco !"
			return 
		}

		if(bloq_table = ""){
			MsgBox,16, Erro, % "O a table de bloqueios estava em branco!"
			return
		}

		;MsgBox, % "tabela de items bloqueados " bloq_table
		record := {}
		record.Codigos := value
		mariaDB.Insert(record, bloq_table)
	}

	/*
	 Cria a tabela de bloqueios
	*/
	create_tabela_bloqueio(tabela, info){
		Global mariaDB

		if(tabela = "" || info.empresa[2] = ""){
			MsgBox,16, Erro, % "Alguns items necessarios para criar a tabela de bloqueio estavam em branco!" 
			return
		} 

		try{
				mariaDB.Query(
					(JOIN 
						"	CREATE TABLE IF NOT EXISTS " tabela
						" (Codigos VARCHAR(250)) "
					))
				}catch e{
					MsgBox,16, Erro, % "Ocorreu um erro ao tentar criar a tabela de bloqueios!" 
				}
		
		if(!this.get_reference(prefixo, modelo_nome, modelo_mascara, tipo)){
			record := {}
			record.tipo := "Bloqueio"
			record.tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
			record.tabela2 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "Bloqueio"
			mariaDB.Insert(record, "reltable")
		}
	}

	/*
		Cria a tabela de prefixo
	*/
	create_tabela_prefixo(tabela_prefixo){
		Global mariaDB

		try{
				mariaDB.Query(
					(JOIN 
						"	CREATE TABLE IF NOT EXISTS " tabela_prefixo
						" (id MEDIUMINT NOT NULL AUTO_INCREMENT,"
						" Campos VARCHAR(250), "
						" PRIMARY KEY (id)) "
					))
			}catch e
				MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de prefixos `n" ExceptionDetail(e)
	}

	/*
		Insere um valor de campo especifico
	*/
	incluir_campo_esp(nome_campo, valores, info){
		Global mariaDB
		
		tabela_campos_especificos := get_tabela_campo_esp(nome_campo, info)
		
		if(this.valor_campo_existe(tabela_campos_especificos, valores.codigo)){
			MsgBox,16, Erro, % "O codigo a ser inserido ja existe na lista!"
			return
		}

		record := {}
		record.Codigo := Trim(valores.codigo)
		record.DR := Trim(valores.dr)
		record.DC := Trim(valores.dc)
		record.DI := Trim(valores.di)

		mariaDB.Insert(record, tabela_campos_especificos)
	}

	excluir_campo_esp(codigo, tabela){
		Global mariaDB

		if(codigo = "" || tabela = ""){
			MsgBox,16, Erro, % "O codigo selecionado ou a tabela estavam vaziios!" 
			return
		}
		
		try{
				mariaDB.Query(
				(JOIN 
					" DELETE FROM " tabela 
					" WHERE Codigo like '" codigo "'"
				))	
			}catch e 
				MsgBox, 16, Erro, % " Erro ao tentar apagar o campo especifico " ExceptionDetail(e)
	}

	alterar_valores_campo(campo, valores, info, old_cod){
		Global mariaDB

		tabela := get_tabela_campo_esp(campo, info)
		sql :=
		(JOIN 
			" UPDATE " tabela 
			" SET Codigo='" Trim(valores.codigo) "', DC='" Trim(valores.DC) "', DR='" Trim(valores.DR) "', DI='" Trim(valores.DI) "'"
			" WHERE Codigo='" old_cod "'"
		)	 
		
		try{
				mariaDB.Query(sql)
			}catch e 
				MsgBox, 16, Erro, % " Erro ao tentar alterar os valores " ExceptionDetail(e)
	}

	excluir_campo(campo_nome, info){
		Global mariaDB

		;MsgBox, % "campo nome " campo_nome " info empresa " info.empresa[1]
		
		/*
			-Deleta a entrada da tabela relacionada 
			 na tabela de relacionamento e armazena o seu valor.

			-verifica se nao existe mais nenhuma outra relacao com essa 
			tabela, caso nao exista, exclui a tabela.
		*/

		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
		tabela_campo_esp := get_tabela_campo_esp(campo_nome, info)
		tabela_campo := this.get_tabela_campo_referencia(tabela1) 
		
		;MsgBox, % "tabela campo esp " tabela_campo_esp
		;MsgBox, % "tabela campo " tabela_campo

		/*
			Deleta a entrada na tabela de campo
		*/
		try{
				mariaDB.Query(
				(JOIN 
					" DELETE FROM " tabela_campo 
					" WHERE Campos like '" campo_nome "'"
				))	
			}catch e 
				MsgBox, 16, Erro, % " Erro ao tentar apagar o campo " ExceptionDetail(e)

		/*
			Deleta a entrada na tabela de relacao
		*/
		StringReplace, campo_nome_sem_espaco, campo_nome,%A_Space%,,All
		try{
				mariaDB.Query(
				(JOIN 
					" DELETE FROM reltable "
					" WHERE tipo like '" campo_nome_sem_espaco "'"
					" AND tabela1 like '" tabela1 "'"
				))	
			}catch e 
				MsgBox, 16, Erro, % " Erro ao tentar apagar a entrada do campo na tabela de relacionamento " ExceptionDetail(e)

		/*
			Deleta a tabela especifica caso nao exista nenhuma outra 
			tabela relacionada com ela. 
		*/
		this.delete_if_no_related(tabela_campo_esp, tipo)
	}

	/*
		Pega tabela de campo 
	*/
	get_tabela_campo_referencia(tabela1){
		Global mariaDB

		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like 'Campo' "
				" AND tabela1 like '" tabela1 "'"
			))
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}

	/*
		Pega a tabela de campo especifico
	*/
	get_tabela_campo_esp(tipo, tabela1){
		Global mariaDB

		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like '" tipo "' "
				" AND tabela1 like '" tabela1 "'"
			))
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}

	/*
		Altera a descricao geral de determinado modelo
	*/
	descricao_geral(descricao, descricao_ingles, info){
		Global mariaDB

		descricao := Trim(descricao), descricao_ingles := Trim(descricao_ingles) 
		
		if(info.modelo[2] = ""){
			MsgBox,16,Erro, % "Selecione um modelo antes de continuar!" 
			return
		}
		

		record := {}
		record.descricao := descricao "|" descricao_ingles
		table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "Desc"
		
		/*
			Deleta a descricao anterior
		*/
		mariaDB.Query(
		(JOIN 
			" DELETE FROM " table " LIMIT 1"	
		))	

		/*
			Insere a nova descricao
		*/
		mariaDB.Insert( record, table)
		MsgBox,64,Sucesso, % "A descricao geral foi alterada!" 
	}

	/*
		Insere os valores de prefixo
	*/
	inserir_valores_prefixo(tabela_prefixo, info){
		Global mariaDB

		values_tbi := [info.empresa[2], info.tipo[2], info.familia[2], info.subfamilia[2], info.modelo[2]]
		for each, value in values_tbi{
			if(value = "")
				continue
			record := {}
			record.Campos := value
			mariaDB.Insert(record, tabela_prefixo)
		}
	}
	/*
		Pega a descricao geral
	*/

	get_desc(info){
		Global mariaDB

		if(info.subfamilia[2] != ""){
			prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] 
		}else{
			prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2]
		}
		

		try{ 
			rs := mariaDB.OpenRecordSet("select descricao from " prefixo "Desc order by descricao asc limit 1;")
		}catch e{
			MsgBox,16, Erro, % "Ocorreu um erro ao tentar buscar a descricao!"
			return
		} 
		value := rs.descricao
		if(value = ""){
			value := info.familia[1] " " info.modelo[1] "|" info.familia[1] " " info.modelo[1]
		}

		rs.close()
		return value
	}

	/*
		Get tabela 
	/*

	/*
		Pega a referencia da tabela de modelos
		linkada com determinada familia
	*/
	get_reference(prefixo, modelo_nome, modelo_mascara, tipo){
		Global mariaDB
		
		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like '" tipo "' "
				" AND tabela1 like '" prefixo modelo_mascara modelo_nome "'"
			))
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}

	/*
		Verifica se determinado 
		Familia ja existe na tabela
	*/
	exists(modelo_nome, modelo_mascara, prefixo, table = ""){
		Global mariaDB
		
		if(table != ""){
			search_table := table 
		}else{
			search_table := prefixo "Modelo"
		} 
		table := mariaDB.Query(
			(JOIN 
				" SELECT Modelos FROM " search_table
				" WHERE Mascara LIKE '" modelo_mascara "'"
				" AND Modelos LIKE '" modelo_nome "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}
	}

	/*
		Verifica se um campo existe antes de inserir
	*/
	campo_existe(nome_campo, tabela){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT  Campos FROM " tabela
				" WHERE Campos LIKE '" nome_campo "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}	
	}

	/*
		Confere se o valor do campo existe
	*/
	valor_campo_existe(tabela, valor){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT  Codigo FROM " tabela
				" WHERE Codigo LIKE '" valor "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}		
	}
	/*
		deleta uma determinada tabela
		se nao existir mais nenhuma 
		tabela relacionada a ela
	*/
	delete_if_no_related(linked_table, tipo){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT tipo,tabela1,tabela2 FROM reltable "
				" WHERE tipo LIKE '" tipo "' "
				" AND tabela2 LIKE '" linked_table "'"
			))
		linked := ""
		columnCount := table.Columns.Count()
		for each, row in table.Rows{
			Loop, % columnCount
				linked .= row[A_index] "`n"
		} 

		/*
			Se nao existir mais nenhuma tabela linkada.
		*/
		if(linked = ""){
			try{
				mariaDB.Query("DROP TABLE " linked_table)	
			}catch e 
				MsgBox,16,Erro,% " Erro ao tentar deletar a tabela de " tipo " " linked_table "`n" ExceptionDetail(e)
		}
	}

	load_tables(info){
		Global mariaDB, db, camptable, octable, odctable, odrtable, oditable, codtable

		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
		camptable := db.get_reference("Campo", tabela1)
		octable := db.get_reference("oc", tabela1)
		odctable := db.get_reference("odc", tabela1)
		odrtable := db.get_reference("odr", tabela1)
		oditable := db.get_reference("odi", tabela1)
		codtable := db.get_reference("Codigo", tabela1)
	}

	format_field(field){
		return_field := Trim(field)
		_ilegal_char := 0
		IfInString, return_field, "
		{
			_ilegal_char := 1
		} 

		IfInString, return_field, '
		{
			_ilegal_char := 1
		}

		if(_ilegal_char = 1){
			MsgBox, 16, Erro, % "O campo nao pode conter aspas simples ou duplas!"
			return
		}
		return return_field
	}

	/*
		Linka uma tabela especifica
	*/
	link_specific_field(values, tabela1){
		Global mariaDB
   
		if(this.exist_relation(values.tipo, tabela1)){
			this.delete_relation(values.tipo, tabela1)
		}
		record := {}
		record.tipo := values.tipo  	
		record.tabela1 := tabela1
		record.tabela2 := values.tabela2
		mariaDB.Insert(record, "reltable")
	}

	link_models_table(values, tabela1, info){
		Global mariaDB, db
   
		if(this.exist_relation(values.tipo, tabela1)){
			this.delete_relation(values.tipo, tabela1)
		}
		record := {}
		record.tipo := values.tipo  	
		record.tabela1 := tabela1
		record.tabela2 := values.tabela2
		models_array := db.load_table_in_array(values.tabela2)
		/*
			Cria os modelos na familia
			correspondente
		*/
		this.create_models(models_array, info) 
		mariaDB.Insert(record, "reltable")	
	}

	/*
		Verifica se existe alguma tabela linkada
	*/
	exist_relation(tipo, tabela1){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT tipo,tabela1,tabela2 FROM reltable "
				" WHERE tipo LIKE '" tipo "' "
				" AND tabela1 LIKE '" tabela1 "'"
			))
		linked := ""
		columnCount := table.Columns.Count()
		for each, row in table.Rows{
			Loop, % columnCount
				linked .= row[A_index] "`n"
		} 
		
		if(linked != ""){
			return 1
		}else{
			return 0
		}
	}

	/*
		Deleta uma relacao de tabelas existente
	*/
	delete_relation(tipo, tabela1){
		Global mariaDB
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable "
				" WHERE tipo like '" tipo "'"
				" AND tabela1 like '" tabela1 "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de referencia " ExceptionDetail(e)
			
	}

	/*
		Insere todos os modelos de 
		um determinado array de valores
	*/
	create_models(models, info){
		Global mariaDB, db

		prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2]
		for, each, value in models{
			name := models[A_Index, 1]
			code := models[A_Index, 2]
			if(name = "" || code = "")
				Continue
			this.incluir(name, code, prefixo, 1)
		} 
	}

	check_data_consistency(model_table, info){
		Global mariaDB, db

		prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2]
		models_table := db.load_table_in_array(model_table)
		for, each, value in models_table{
			if(models_table[A_Index, 1] = ""){
				Continue
			}
			table_desc := 
			(JOIN
				info.empresa[2]
				info.tipo[2]
				info.familia[2]
				info.subfamilia[2]
				models_table[A_Index, 2] "Desc"
			)

			/*
				Se o modelo nao existir 
				insere as tabelas necessarias
			*/

			if(!db.table_exists(table_desc)){
				MsgBox, 16, Erro, % "O modelo " models_table[A_Index, 1] " estava inconsistente `n suas dependencias serao resolvidas!"
				this.incluir(models_table[A_Index, 1], models_table[A_Index, 2], prefixo, 1)
			}
		} 
	}

	/*
		Verifica se a tabela de 
		descricao do modelo existe 
		caso nao exista cria todas as tabelas
		necessarias pra o modelo
	*/
	model_exists(table_desc){
		Global mariaDB
		MsgBox, % "a tabela de descricao existe ? " table_desc 
		table := mariaDB.Query(
			(JOIN 
				" SELECT descricao FROM " table_desc
			))
		exists := ""
		for each, row in table.Rows{
			Loop, % columnCount
				exists .= row[A_index] "`n"
		} 
		if(exists != ""){
			return 1
		}else{
			return 0
		}
	}

	/*
		Redefine de uma tabela para o seu valor padrao
	*/
	reset_table_relation(info, native_table, field_name){
		Global mariaDB

		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable" 
				" WHERE tipo like '" field_name "' And tabela1 like '" tabela1 "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar a referencia da tabela `n " ExceptionDetail(e)
		
		record := {}
		record.tipo := field_name
		record.tabela1 := tabela1
		record.tabela2 := native_table
		mariaDB.Insert(record, "reltable")

		MsgBox, 64, Sucesso, % "A linkagem da tabela retornou para o seu valor padrao!"
	}
}