class Empresa{

	/*
		Inclui uma nova empresa
	*/
	incluir(empresa_nome, empresa_mascara){
		Global db, mariaDB, ERROR_CODE
		this.name := empresa_nome, this.mask := empresa_mascara
		this.check_data_consistency() 
		this.insert_company()
		this.exists_in_reltable()
		db.create_table(this.mask "Aba ", "(Abas VARCHAR(250), Mascara VARCHAR(250), PRIMARY KEY (Mascara))")
		db.insert_record({tipo: "Aba", tabela1: this.name, tabela2: this.mask "Aba"}, "reltable")
		db.Log.insert_CRUD("", "Criado", "A empresa " this.name " e mascara " this.mask " foi criada!")
		MsgBox, 64, Empresa Criada, % " valor inserido"
		item_hash := {name: this.name, mask: this.mask}
		return item_hash
	}

	insert_company(){
		Global db, ETF_hashmask
		record := {}
		record.Empresas := this.name
		record.Mascara := this.mask
		db.insert_record(record, "empresas")
		ETF_hashmask[this.name] := this.mask
	}

	check_data_consistency(){
		this.exists()
		return
	}

	exists(){
		Global  db
		sql :=
		(JOIN
			" Mascara like '" this.mask 
			"' OR Empresas like '" this.name "'" 
		)  
		db.exists(sql, "empresas")
		return 
	}

	excluir(empresa_nome, empresa_mascara, recursiva = 1){
		Global db, mariaDB	
		this.name := empresa_nome, this.mask := empresa_mascara 
		if(recursiva = 1){
			this.info := get_item_info("M", "MODlv")
			db.init_unique_info()
			db.remove_subitems("empresa", this.mask, this.info)
		}
		this.delete_company()
		db.Log.insert_CRUD("", "Removido", "A empresa " this.name " e mascara " this.mask " foi removida!")
	}	

	delete_company(){
		Global db 
		db.delete_items_where(" Mascara like '" this.mask "'", "empresas")		
		linked_table := db.get_reference("Aba", this.name)
		db.delete_items_where(" tipo like 'Aba' AND tabela1 like '" this.name "'", "reltable")
		if(!db.check_if_exists(" tipo LIKE 'Aba' AND tabela2 LIKE '" linked_table "'", "reltable")){
			db.drop_table(linked_table)
		}
		return
	}
	
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
	
	exists_in_reltable(){
		Global db
		items := db.find_items_where(" WHERE tabela1 like '" this.name "'")
		if(items[1, 1] != ""){
			throw { what: "A empresa a ser inserida ja existe na tabela de relacionamento!", file: A_LineFile, line: A_LineNumber }		
		}
		return
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