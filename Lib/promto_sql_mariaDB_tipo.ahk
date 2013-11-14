class Tipo{
	/*
		Incluir um novo tipo
	*/
	incluir(tipo_nome = "", tipo_mascara = "", prefixo = ""){
		Global mariaDB

		/*
			Se o nome estiver em branco
		*/
		if(tipo_nome = ""){
			MsgBox, % "O nome do tipo nao pode estar em branco"
			return
		}

		/*
			Verifica se a tabela a inserir o item 
			esta em branco
		*/
		if(prefixo = ""){
			MsgBox, % "Os prefixos que determinam o parente deste item nao podem estar em branco!"
			return
		}

		/*
			Verifica se o tipo_mascara esta em branco
			caso esteja mostra uma msg de aviso
		*/
		if(tipo_mascara = ""){
			MsgBox, 4,, % "Nao e recomendavel deixar a mascara em branco! `n deixar assim mesmo?"
			IfMsgBox No
			{
				return
			}
		}
		/*
			Verifica se a mascara a ser inserida 
			ja existe
		*/
		if(this.exists(tipo_mascara, prefixo)){
			MsgBox,16,Erro, % " A mascara a ser inserida ja existe!" 
			return 
		}

		/*
			Insere o valor na tabela
		*/
		record := {}
		record.Abas := tipo_nome
		record.Mascara := tipo_mascara
		mariaDB.Insert(record, prefixo "Aba")

		/*
			Cria a tabela de Familias e insere a
			referencia na reltable
		*/
		
		/*
		 Pega a mascara da empresa
		*/

		try{
			mariaDB.Query(
				(JOIN 
					"	CREATE TABLE IF NOT EXISTS " prefixo tipo_mascara "Familia "
					" (Familias VARCHAR(250), "
					" Mascara VARCHAR(250), "
					" PRIMARY KEY (Mascara)) "
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Familias `n" ExceptionDetail(e)

		record := {}
		record.tipo := "Familia"
		record.tabela1 := prefixo tipo_nome
		record.tabela2 := prefixo tipo_mascara "Familia"
		mariaDB.Insert(record, "reltable")
		MsgBox, % "O tipo foi inserido!"
	}

	/*
		Excluir tipo
	*/
	excluir(tipo_nome, tipo_mascara, prefixo){
		Global mariaDB

		/*
		 Excluir a entrada do tipo 
		 na tabela de tipos 
		*/
		if(!this.exists(tipo_nome, tipo_mascara, prefixo)){
			MsgBox,16,Erro,% " O valor a ser deletado nao existia na tabela"
			return 
		}
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM " prefixo "Aba"
				" WHERE Mascara like '" tipo_mascara "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de Tipos `n " ExceptionDetail(e)
		/*
			Exclui a tabela de familias 
			relacionada com esse tipo 
			caso ela nao esteja mais relacionada com nada
		*/
			linked_table := this.get_reference(prefixo, tipo_nome)
			MsgBox, % "tabela linkada: " linked_table 

		/*
		 Deleta a entrada do tipo na 
		 tabela de relacionamento.  
		*/

		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable "
				" WHERE tipo like 'Familia'"
				" AND tabela1 like '" prefixo tipo_nome "'"
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
				" WHERE tipo LIKE 'Familia' "
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
		MsgBox, % " O tipo foi deletado!"
	}

	/*
		Verifica se determinado 
		tipo ja existe na tabela
	*/
	exists(tipo_nome, tipo_mascara, prefixo){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT Abas FROM " prefixo "Aba"
				" WHERE Mascara LIKE '" tipo_mascara "'"
				" AND Abas LIKE '" tipo_nome "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}
	}

	get_reference(prefixo, tipo_nome){
		Global mariaDB

		MsgBox, % "prefixo: " prefixo " tipo_nome: " tipo_nome
		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like 'Familia' "
				" AND tabela1 like '" prefixo tipo_nome "'"
			))
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}
}