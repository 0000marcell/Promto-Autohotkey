class Familia{
	/*
		Incluir familia
	*/
	incluir(familia_nome = "", familia_mascara = "", prefixo = "", tipo_nome = ""){
		Global mariaDB

		MsgBox, % "familia_nome: " familia_nome " `n familia_mascara: " familia_mascara " `n prefixo: " prefixo " `n tipo_nome: " tipo_nome 
		/*	
			Verifica se o prefixo a inserir o item 
			esta em branco
		*/
		if(prefixo = ""){
			MsgBox, % "O prefixo nao pode estar em branco nas familias!"
			return 0
		}

		/*
			Verifica se o nome ou a mascara da empresa esta em branco
		*/
		if(familia_nome = "" || familia_mascara = ""){
			MsgBox, % "o nome e a mascara da familia nao podem estar em brancos!"
			return 0			
		}

		/*
			Verifica se o nome da empresa esta em branco 
		*/
		if(tipo_nome = ""){
			MsgBox, % "O nome do tipo nao pode estar em branco!"
			return 0
		}

		/*
			Pega a mascara da empresa
		*/
		StringLeft, empresa_mascara, prefixo, 1


		/*
			Pega a referencia da tabela de items 
			linkados
		*/
		familia_table := this.get_parent_reference(empresa_mascara, tipo_nome)

		MsgBox, % "familia_table: " familia_table
		/*
			Verifica se a mascara a ser inserida 
			ja existe
		*/
		if(this.exists(familia_nome, familia_mascara, familia_table)){
			MsgBox,16,Erro, % " A mascara a ser inserida ja existe!" 
			return 0
		}

		/*
			Insere o valor na tabela
		*/
		record := {}
		record.Familias := familia_nome
		record.Mascara := familia_mascara
		mariaDB.Insert(record, familia_table)

		/*
			Cria a tabela de Familias e insere a
			referencia na reltable
		*/
		

		try{
			mariaDB.Query(
				(JOIN 
					"	CREATE TABLE IF NOT EXISTS " prefixo familia_mascara "Modelo "
					" (Modelos VARCHAR(250), "
					" Mascara VARCHAR(250), "
					" PRIMARY KEY (Mascara)) "
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Modelos `n" ExceptionDetail(e)

		record := {}
		record.tipo := "Modelo"
		record.tabela1 := prefixo familia_nome
		record.tabela2 := prefixo familia_mascara "Modelo"
		mariaDB.Insert(record, "reltable")
		MsgBox, % "A Familia foi inserida!"
		return 1
	}

	/*
	 Excluir familia
	*/
	excluir(familia_nome, familia_mascara, prefixo){
		Global mariaDB

		/*
		 Excluir a entrada da familia
		 na tabela de familias 
		*/
		if(!this.exists(familia_nome, familia_mascara, prefixo)){
			MsgBox,16,Erro,% " O valor a ser deletado nao existia na tabela"
			return 
		}

		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM " prefixo "Familia"
				" WHERE Mascara like '" familia_mascara "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de Familias `n " ExceptionDetail(e)
		/*
			Exclui a tabela de modelos
			relacionada com essa familia
			caso ela nao esteja mais relacionada com nada
		*/
		linked_table := this.get_reference(prefixo, familia_nome)
		MsgBox, % "tabela linkada: " linked_table 

		/*
		 Deleta a entrada do tipo na 
		 tabela de relacionamento.  
		*/
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable "
				" WHERE tipo like 'Modelo'"
				" AND tabela1 like '" prefixo familia_nome "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de referencia " ExceptionDetail(e)
		
		/*
		 Verifica se a tabela de modelos 
		 nao estava linkada com mais nenhuma outra tabela
		 antes de deleta-la
		*/
		table := mariaDB.Query(
			(JOIN 
				" SELECT tipo,tabela1,tabela2 FROM reltable "
				" WHERE tipo LIKE 'Modelo' "
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
				MsgBox,16,Erro,% " Erro ao tentar deletar a tabela de tipos " linked_table "`n" ExceptionDetail(e)
		}
		MsgBox, % " O tipo foi deletado!"
	}

	/*
		Verifica se determinado 
		Familia ja existe na tabela
	*/
	exists(familia_nome, familia_mascara, table){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT Familias FROM " table
				" WHERE Mascara LIKE '" familia_mascara "'"
				" AND Familias LIKE '" familia_nome "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}
	}

	/*
	 Pega a referencia da tabela onde 
	 as familias estao sendo incluidas
	*/
	get_parent_reference(empresa_mascara, tipo_nome){
		global mariaDB

		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like 'Familia' "
				" AND tabela1 like '" empresa_mascara tipo_nome "'"
			))
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}

	/*
		Pega a referencia da tabela de modelos
		 linkada com determinada familia
	*/
	get_reference(prefixo, familia_nome){
		Global mariaDB

		MsgBox, % "prefixo: " prefixo " familia_nome: " familia_nome
		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like 'Modelo' "
				" AND tabela1 like '" prefixo familia_nome "'"
			))
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}
}
