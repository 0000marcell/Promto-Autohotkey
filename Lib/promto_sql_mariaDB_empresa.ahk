class Empresa{

	/*
		Inclui uma nova empresa
	*/
	incluir(empresa_nome, empresa_mascara){
		Global db, mariaDB
		item_hash := this.check_data_consistency(empresa_nome, empresa_mascara) 
		if(item_hash.name = "")
			return 0
		if(!this.insert_company(item_hash.name, item_hash.mask))
			return 0
		if(!this.exists_in_reltable(item_hash.name))
			return 0
		if(!db.create_table(item_hash.mask "Aba ", "(Abas VARCHAR(250), Mascara VARCHAR(250), PRIMARY KEY (Mascara))"))
			return 0
		if(!db.insert_record({tipo: "Aba", tabela1: item_hash.name, tabela2: item_hash.mask "Aba"}, "reltable"))
			return 0
		MsgBox, 64, Empresa Criada, % " valor inserido"
		return item_hash
	}

	insert_company(empresa_nome, empresa_mascara){
		Global db, ETF_hashmask
		record := {}
		record.Empresas := empresa_nome
		record.Mascara := empresa_mascara
		if(db.insert_record(record, "empresas")){
			ETF_hashmask[empresa_nome] := empresa_mascara
			return 1
		}else{
			return 0 
		}
	}

	check_data_consistency(empresa_nome, empresa_mascara){
		if(!this.exists(empresa_nome, empresa_mascara))
			return 0
		item_hash := {name: empresa_nome, mask: empresa_mascara}
		return item_hash
	}

	excluir(empresa_nome, empresa_mascara, recursiva = 1){
		Global db, mariaDB	
		if(recursiva = 1){
			info := get_item_info("M", "MODlv")
			db.init_unique_info()
			db.remove_subitems("empresa", empresa_mascara, info)
		}
		if(!this.delete_company(empresa_nome, empresa_mascara))
			return 0
		return 1
	}	

	delete_company(empresa_nome, empresa_mascara){
		Global db 
		if(!db.delete_items_where(" Mascara like '" empresa_mascara "'", "empresas"))
			return 0		
		linked_table := db.get_reference("Aba", empresa_nome)
		if(!db.delete_items_where(" tipo like 'Aba' AND tabela1 like '" empresa_nome "'", "reltable"))
			return 0
		; Se a tabela de tipo nao estiver linkada deleta
		if(!db.check_if_exists(" tipo LIKE 'Aba' AND tabela2 LIKE '" linked_table "'", "reltable")){
			db.drop_table(linked_table)
		}
		return 1
	}

	/*
		Funcao que deleta os subitems
	*/
	delete_subitem(nome, mascara, info, nivel){
		Global db
		if(nivel = "empresa"){
			db.Empresa.excluir(nome, mascara, 0)
		}else if(nivel = "tipo"){
			db.Tipo.excluir(nome, mascara, info, 0)
		}else if(nivel = "familia"){
			db.Familia.excluir(nome, mascara, info, 0)
		}else if(nivel = "subfamilia"){
			db.Subfamilia.excluir(nome, mascara, info, 0)
		}else if(nivel = "modelo"){
			prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2]
			db.Modelo.excluir(nome, mascara, info, 0)
		}
	}

	/*
		Verifica se determinado valor
		ja existe na tabela
	*/
	exists(empresa_nome, empresa_mascara){
		Global  db
		sql :=
		(JOIN
			" Mascara like '" empresa_mascara 
			"' OR Empresas like '" empresa_nome "'" 
		)  
		return db.exists(sql, "empresas")
	}

	exists_in_reltable(empresa_nome){
		Global db
		items := db.find_items_where(" WHERE tabela1 like '" empresa_nome "'")
		return (items[1, 1] != "") ? error_msg("Ja existe esse item na tabela de relacionamento ") : True
	}

	/*
		Retorna determinada 
		tabela em um array
	*/
	load_table_in_array(table){
		Global mariaDB

		if(table = ""){
			MsgBox, % "Passe o nome de uma tabela antes de carregar em um array (empresa)!"
			return  
		}

		rs := mariaDB.OpenRecordSet("SELECT * FROM " table)
		columns := rs.getColumnNames()
		columnCount := columns.Count()

		table_array := []
		table_array.column_count := columnCount
		while(!rs.EOF){	
			line := A_Index
			Loop, % columnCount{
				table_array[line, A_Index] := rs[A_index]
			}
			rs.MoveNext()
		}
		rs.close()

		return table_array 
	}
}