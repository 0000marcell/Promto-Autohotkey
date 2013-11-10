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
		MsgBox, % " valor inserido"
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

		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable "
				" WHERE tipo like 'Aba'"
				" AND tabela1 like '" empresa_nome "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de referencia " ExceptionDetail(e)
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
}