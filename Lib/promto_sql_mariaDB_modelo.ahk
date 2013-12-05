class Modelo{
	/*
		Incluir um novo modelo
	*/
	incluir(modelo_nome = "", modelo_mascara = "", prefixo = ""){
		Global mariaDB

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
		if(this.exists(modelo_nome, modelo_mascara, prefixo)){
			MsgBox,16,Erro, % " A mascara a ser inserida ja existe!" 
			return 
		}

		/*
			Insere o valor na tabela
		*/
		record := {}
		record.Modelos := modelo_nome
		record.Mascara := modelo_mascara
		mariaDB.Insert(record, prefixo "Modelo")

		/*
			Cria a tabela de campos
			e insere na tabela de referencias.
		*/

		tables := ["Campo", "oc", "odr", "odc", "odi", "Codigo", "Desc"]

		for,each, tipo in tables{
			if(tipo != "Desc"){
				try{
				mariaDB.Query(
					(JOIN 
						"	CREATE TABLE IF NOT EXISTS " prefixo modelo_mascara tipo
						" (Campos VARCHAR(250), "
						" PRIMARY KEY (Campos)) "
					))
			}catch e
				MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Campos `n" ExceptionDetail(e)	
			}
		if(tipo = "Desc"){
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
		MsgBox,64,Sucesso, % " O valor foi inserido!" 
	}

	/*
		Excluir modelo
	*/
	excluir(modelo_nome = "", modelo_mascara = "", info = "", recursiva = 1){
		Global mariaDB

		/*
		 Excluir a entrada do modelo
		 na tabela de modelos
		*/
		prefixo := info.empresa[2] info.tipo[2] info.familia[2] 
		if(!this.exists(modelo_nome, modelo_mascara, prefixo)){
			MsgBox,16,Erro,% " O valor a ser deletado nao existia na tabela"
			return 
		}

		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM " prefixo "Modelo"
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
		Insere um nome de campo
	*/
	incluir_campo(campo_nome, info){
		Global mariaDB

		/*
			Pega a tabela de campos relacionada 
			com o modelo
		*/
		;MsgBox, % "modelo nome: " info.modelo[1] "`n modelo mascara: " info.modelo[2]
		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2] info.modelo[1] 
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
		record := {}
		record.Campos := campo_nome
		mariaDB.Insert(record, tabela_campo)


		StringReplace,campo_nome_sem_espaco,campo_nome,%A_Space%,,All

		tabela_campo_especifica := info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2] campo_nome_sem_espaco
			
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
		record.tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2] info.modelo[1] 
		record.tabela2 := info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2] campo_nome_sem_espaco
		mariaDB.Insert(record, "reltable")	
	}

	/*
		Insere um valor de campo especifico
	*/
	incluir_campo_esp(nome_campo, valores, info){
		Global mariaDB
		
		;MsgBox, % "nome_campo: " nome_campo " `n codigo " valores.codigo "`n dr " valores.dr "`n dc " valores.dc "`n di " valores.di 
		tabela_campos_especificos := get_tabela_campo_esp(nome_campo, info)
		if(this.valor_campo_existe(tabela_campos_especificos, valores.codigo)){
			MsgBox,16, Erro, % "O codigo a ser inserido ja existe na lista!"
			return
		}

		record := {}
		record.Codigo := valores.codigo
		record.DR := valores.dr
		record.DC := valores.dc
		record.DI := valores.di
		mariaDB.Insert(record, tabela_campos_especificos)
	}

	excluir_campo_esp(codigo, tabela){
		Global mariaDB

		if(codigo = "" || tabela = ""){
			MsgBox,16, Erro, % "O codigo selecionado ou a tabela estavam vaziios!" 
			return
		}
		;MsgBox, % "ira excluir o codigo " codigo " da tabela " tabela
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
			" SET Codigo='" valores.codigo "', DC='" valores.DC "', DR='" valores.DC "', DI='" valores.DI "'"
			" WHERE Codigo='" old_cod "'"
		)	 
		;MsgBox, % sql
		try{
				mariaDB.Query(sql)
			}catch e 
				MsgBox, 16, Erro, % " Erro ao tentar alterar os valores " ExceptionDetail(e)
	}

	excluir_campo(campo_nome, info){
		Global mariaDB

		/*
			-Deleta a entrada da tabela relacionada 
			 na tabela de relacionamento e armazena o seu valor.

			-verifica se nao existe mais nenhuma outra relacao com essa 
			tabela, caso nao exista, exclui a tabela.
		*/
		tabela_campo_esp := get_tabela_campo_esp(campo_nome, info)
		tabela_campo := this.get_tabela_campo_referencia(tabela1) 
		
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
	descricao_geral(descricao){
		Global mariaDB, empresa, tipo, familia, modelo

		if(modelo.mascara = ""){
			MsgBox,16,Erro, % "Selecione um modelo antes de continuar!" 
			return
		}
		

		record := {}
		record.descricao := descricao
		table := empresa.mascara tipo.mascara familia.mascara modelo.mascara "Desc"
		
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
		Pega a descricao geral
	*/

	get_desc(info){
		Global mariaDB

		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT descricao FROM " info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2] "desc"
			))
		value := rs.descricao
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
	exists(modelo_nome, modelo_mascara, prefixo){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT Modelos FROM " prefixo "Modelo"
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
}