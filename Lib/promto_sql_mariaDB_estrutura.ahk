class Estrutura{
	inserir(item, componente){
		Global mariaDB

		if(item = componente){
			MsgBox, 16, Erro, % " voce nao pode inserir um item nele propio!"
			return
		}

		
		if(this.exists(item, componente)){
			MsgBox, 16, Erro, % " O componente " componente " ja existia no item " item 
			return
		}
		record := {}
		record.item := item
		record.componente := componente
		record.quantidade := 1
		mariaDB.Insert(record, "estruturas")
	}

	/*
		Insere quantidade em determinado item
	*/
	inserir_quantidade(item, componente, quantidade){
		Global mariaDB

		sql :=
		(JOIN 
			" UPDATE estruturas " 
			" SET quantidade = '" quantidade "'"
			" WHERE item LIKE '" item "' AND "
			" componente LIKE '%" componente "%'" 
		)	 
		
		try{
			mariaDB.Query(sql)
		}catch e{
			MsgBox, 16, Erro, % " Erro ao tentar alterar a quantidade " ExceptionDetail(e)
		}
	}
	/*
		Verifica se 
		determinado componente 
		ja existe em determinado item
	*/
	exists(item, componente){
		Global mariaDB
		
		table := mariaDB.Query(
			(JOIN 
				" SELECT * FROM estruturas " 
				" WHERE item LIKE '" item "' AND "
				" componente LIKE '" componente "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}
	}
}