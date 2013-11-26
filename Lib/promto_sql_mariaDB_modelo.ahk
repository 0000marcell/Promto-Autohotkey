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
		tables := ["Campo", "oc", "odr", "odc", "odi", "Codigo"]
		for,each, tipo in tables{
			try{
				mariaDB.Query(
					(JOIN 
						"	CREATE TABLE IF NOT EXISTS " prefixo modelo_mascara tipo
						" (Campos VARCHAR(250), "
						" PRIMARY KEY (Campos)) "
					))
			}catch e
				MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Campos `n" ExceptionDetail(e)

		try{
				mariaDB.Query(
					(JOIN 
						"	CREATE TABLE IF NOT EXISTS " prefixo modelo_mascara "Desc"
						" (descricao VARCHAR(250))"
					))
			}catch e
				MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de descricao geral `n" ExceptionDetail(e)
			
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
	excluir(modelo_nome = "", modelo_mascara = "", prefixo = ""){
		Global mariaDB

		/*
		 Excluir a entrada do modelo
		 na tabela de modelos
		*/

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
		tables := ["Campo", "oc", "odr", "odc", "odi", "Codigo"]
		for,each, tipo in tables{
   	 	linked_table := this.get_reference(prefixo, modelo_nome, modelo_mascara, tipo)
			;MsgBox, % "tabela linkada: " linked_table 

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
			Deleta a tabela que contem a descricao 
			geral do determinado item
		*/
		try{
			mariaDB.Query(
			(JOIN 
				" DROP TABLE " prefixo modelo_mascara "Desc" 
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar excluir a tabela de descricao geral! " ExceptionDetail(e)
		
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
				MsgBox,16,Erro,% " Erro ao tentar apagar a relacao da imagem " ExceptionDetail(e)
			
		MsgBox,64,Sucesso,% "O modelo foi deletado!"
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