class Empresa{
	/*
		Inclui uma nova empresa
	*/
	incluir(empresa_nome, empresa_mascara){
		Global mariaDB
		/*
			Verifica se a mascara a ser inserida 
			ja existe
		*/
		if(this.exists(empresa_mascara)){
			MsgBox,16,Erro, % " A mascara a ser inserida ja existe!" 
			return 
		}

		/*
			Insere o valor na tabela
		*/
		record := {}
		record.Empresas := empresa_nome
		record.Mascara := empresa_mascara
		mariaDB.Insert(record, "empresas")

		/*
			Criar a tabela de tipos e inserir na reltable
		*/

		/*
			Verifica se a relacao a ser inserida ja existe na 
			tabela de referencia
		*/
		if(this.exists_in_reltable(empresa_nome)){
			MsgBox, % "Ja existe uma tabela de tipos relacionada com essa empresa"
			return
		}
		MsgBox, % " create tabela de tipos " empresa_mascara "Aba"
		sql :=
		(JOIN
			"	CREATE TABLE IF NOT EXISTS " empresa_mascara "Aba "
			" (Abas VARCHAR(250), "
			" Mascara VARCHAR(250), "
			" PRIMARY KEY (Mascara)) "
		)
		try{
			mariaDB.Query(sql)
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de tipos `n" ExceptionDetail(e)

		record := {}
		record.tipo := "Aba"
		record.tabela1 := empresa_nome
		record.tabela2 := empresa_mascara "Aba"
		mariaDB.Insert(record, "reltable")
		MsgBox,64,Empresa Criada,% " valor inserido"
	}

	/*
		Exclui uma empresa
	*/
	excluir(empresa_nome, empresa_mascara){
		Global mariaDB

		/*
			Deleta o valor da tabela de empresas  
		*/
		if(!this.exists(empresa_mascara)){
			MsgBox,16,Erro,% " O valor a ser deletado nao existia na tabela"
			return 
		}
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM empresas "
				" WHERE Mascara like '" empresa_mascara "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de empresas " ExceptionDetail(e)
		
		/*
			Deleta o valor da tabela de referencia
		*/
		if(!this.exists_in_reltable(empresa_nome)){
			MsgBox,16,Erro, % " O valor a ser deletado nao existia na tabela de referencia"
			return
		}
		/*
			Pega o nome da tabela de referencia de abas
		*/
		linked_table := this.get_reference(empresa_nome)

		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable "
				" WHERE tipo like 'Aba'"
				" AND tabela1 like '" empresa_nome "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de referencia " ExceptionDetail(e)
		
		/*
		 Verifica se a tabela de tipos 
		 nao estava linkada com mais nenhuma outra tabela
		 antes de deleta-la
		*/
		table := mariaDB.Query(
			(JOIN 
				" SELECT tipo,tabela1,tabela2 FROM reltable "
				" WHERE tipo LIKE 'Aba' "
				" AND tabela2 LIKE '" linked_table "'"
			))
		linked .= ""
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
		MsgBox, % " A empresa foi deletada!"
	}	

	/*
		Verifica se determinado valor
		ja existe na tabela
	*/
	exists(empresa_mascara){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT Mascara FROM empresas "
				" WHERE Mascara like '" empresa_mascara "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}
	}

	exists_in_reltable(empresa_nome){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT tabela1 FROM reltable "
				" WHERE tabela1 like '" empresa_nome "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}
	}

	get_reference(empresa_nome){
		Global mariaDB

		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like 'Aba' "
				" AND tabela1 like '" empresa_nome "'"
			))
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}
}