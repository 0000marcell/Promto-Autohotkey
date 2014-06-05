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

	/*
	 Remover
	*/
	remover(item, componente){
		Global mariaDB
		
		if(item = ""){
			MsgBox, 16, Erro, % " O item a ser excluido nao pode estar em branco !"
			return
		}

		if(componente = ""){
			MsgBox, 16, Erro, % " O componente nao pode estar em branco !"
			return
		}

		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM estruturas "
				" WHERE item like '" item "' AND "
				" componente like '%" componente "%'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o  " ExceptionDetail(e)
	}

	/*
		Remove todos os items de determinada 
		estrutura
	*/
	remove_strut(item){
		Global mariaDB

		if(item = ""){
			MsgBox, 16, Erro, % " O item a ser excluido nao pode estar em branco !"
			return
		}

		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM estruturas "
				" WHERE item like '" item "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o item das tabelas de estrutura " ExceptionDetail(e)
	}

	/*
	 Remove 
	*/
	remove_componente(item, componente){
		Global mariaDB
		
		if(item = ""){
			MsgBox, 16, Erro, % " O item a ser excluido nao pode estar em branco !"
			return
		}

		if(componente = ""){
			MsgBox, 16, Erro, % " O componente nao pode estar em branco !"
			return
		}

		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM estruturas "
				" WHERE item like '" item "' AND "
				" componente like '" componente "'"
			))	
			return true
		}catch e {
			MsgBox, 16, Erro, % " Erro ao tentar deletar o componente " componente " do item " item " erro: `n" ExceptionDetail(e)
			return false
		}
			
	}

	/*
	 Exportar estrutrua para arquivo .csv
	*/
	export_strut(item){
		Global db
		
		subitems := db.get_estrut_items(item)
		for, each, value in subitems{
			if(subitems[A_Index, 2] = "")
				Continue 
			FileAppend, % item ";" subitems[A_Index, 2] ";" subitems[A_Index, 3] "`n", % "temp/export_strut.csv"
			this.export_strut(subitems[A_Index, 2])
		}
	}
}