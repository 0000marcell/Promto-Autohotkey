class Estrutura{
	inserir(item, componente){
		Global mariaDB

		if(item = componente){
			MsgBox, 16, Erro, % " voce nao pode inserir um item nele propio!"
			return
		}

		FileAppend, % "ira comferir se o item " item " existe no componente " componente " `n ", % "debug.txt"
		
		if(this.exists(item, componente)){
			MsgBox, 16, Erro, % " O componente " componente " ja existia no item " item 
			return
		}
		FileAppend, % "ira inserir o componente `n", % "debug.txt"
		record := {}
		record.item := item
		record.componente := componente
		record.quantidade := 1
		mariaDB.Insert(record, "estruturas")
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