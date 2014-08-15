class Tipo{
	/*
		Incluir um novo tipo
	*/
	incluir(tipo_nome = "", tipo_mascara = "", prefixo = "", empresa_nome = ""){
		Global db, mariaDB, ETF_hashmask		
		this.name := tipo_nome, this.mask := tipo_mascara, this.prefix := prefixo
		this.com_name := empresa_nome 
		this.type_table := db.get_reference("Aba", this.com_name)
		item_hash := this.check_data_consistency()
		this.name := item_hash.name, this.mask := item_hash.mask  
		if(item_hash.name = "")
			throw { what: "O item_hash.name voltou vazio para tipo " tipo_nome " tipo_mascara " tipo_mascara, file: A_LineFile, line: A_LineNumber }		
		this.insert_type()
		db.create_table(this.prefix this.mask "Familia ", "(Familias VARCHAR(250), Mascara VARCHAR(250), Subfamilia VARCHAR(250), PRIMARY KEY (Mascara))")
		db.insert_record({tipo: "Familia", tabela1: this.prefix this.name, tabela2: this.prefix this.mask "Familia"}, "reltable")
		info := {}, info.empresa[1] := empresa_nome
		db.Log.insert_CRUD(info, "Criado", "O tipo " this.name " e mascara " this.mask " foi criado!")
	}

	insert_type(){
		Global db, ETF_hashmask
		record := {}
		record.Abas := this.name
		record.Mascara := this.mask
		db.insert_record(record, this.type_table)
		ETF_hashmask[this.name] := this.mask
	}

	check_data_consistency(){
		parameters := [this.name, this.mask, this.type_table, this.prefix, this.com_name]
		check_blank_parameters(parameters, 5)
		this.exists()
		item_hash := check_if_mask_is_unique(this.name, this.mask)
		return item_hash
	}

	excluir(tipo_nome, tipo_mascara, info, recursiva = 1){
		Global db, mariaDB
		this.name := tipo_nome, this.mask := tipo_mascara 
		this.info := info
		if(recursiva = 1){
			db.init_unique_info() 
			db.remove_subitems("aba", this.info.empresa[2] this.mask, this.info)
		}
		this.type_table := db.get_reference("Aba", this.info.empresa[1])
		this.delete_type()
		db.Log.insert_CRUD(info, "Removido", "O tipo " this.name " e mascara " this.mask " foi removido!")
	}

	delete_type(){
		Global db 
		db.delete_items_where(" Mascara like '" this.mask "'", this.type_table)
		this.family_table := db.get_reference("Familia", this.info.empresa[2] this.name)
		db.delete_items_where(" tipo like 'Familia' AND tabela1 like '" this.info.empresa[2] this.name "'", "reltable")
		if(!db.check_if_exists(" tipo LIKE 'Familia' AND tabela2 LIKE '" this.family_table "'", "reltable")){
			db.drop_table(this.family_table)
		}
	}

	exists(){
		Global db 
		sql := 
		(JOIN
			" Mascara like '" this.mask 
			"' OR Abas like '" this.name "'"	 
		)
		db.exists(sql, this.type_table)
	}

	/*
		Pega as tabelas de referencia.
	*/
	get_reference(tabela1, tipo){
		Global mariaDB
		try {
			rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like '" tipo "' "
				" AND tabela1 like '" tabela1 "'"
			))
		} catch e {
				MsgBox,16, Error, % "OpenRecordSet Failed.`n`n" ExceptionDetail(e) ;state := "!# " e.What " " e.Message
		}
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}

	remove_subitems(nome, mascara, info = "", nivel_tipo = "", i = 0){
		Global mariaDB, db

		i++
		if(nivel_tipo = ""){
			nivel_tipo := {1: ["tipo", "Familia"], 2: ["familia", "Modelo"], 3: ["subfamilia", "Modelo"], 4: ["Modelo", "break"]}
		}

		nivel := nivel_tipo[i,1]

		/*
			Funcao que verifica no nivel de familias 
			se a proxima tabela e de subfamilias ou de modelos
		*/
		if(nivel = "familia"){
			tabela1 := info.empresa[2] info.tipo[2] info.familia[1]
			if(db.have_subfamilia(tabela1)){
				tipo := "Subfamilia"
			}else{
				tipo := nivel_tipo[i,2]		
			}
		}

		;MsgBox, % "nome> " nome "`n mascara> " mascara "`n nivel> " nivel "`n tipo> " tipo "`n i> " i
		
		/*
			Pega a tabela de referencia que 
			contem o subitem do item atual
			se o item nao tiver uma tabela 
			de referencia, excluir o item atual e 
			retorna para a iteracao anterior
		*/

		/*
			Se o tipo for break esta 
			no nivel dos modelos e apagara o modelo
			atual.
		*/
		if(tipo = "break"){
			this.delete_subitem(nome, mascara, info, nivel)
			return
		}	

		/*
			Retorna a tabela do proximo nivel
		*/

		if(nivel = "tipo"){
			tabela1 := info.empresa[2] nome
		}else if(nivel = "familia"){
			tabela1 := info.empresa[2] info.tipo[2] nome
		}else if(nivel = "subfamilia"){
			tabela1 := info.empresa[2] info.tipo[2] info.familia[2] nome
		}

		table := db.get_reference(tipo, tabela1)
		if(table = ""){
			this.delete_subitem(nome, mascara, info, nivel)
			return 
		}
		
		/*
			Itera pelos items da tabela 
			pegando seu nome e mascara e 
			chando a funcao outra vez 
		*/
		table_items := this.load_table_in_array(table)
		loop, % table_items.maxindex(){
			nome_item := table_items[A_Index,1]
			mascara_item := table_items[A_Index,2]
			
			if(nivel = "empresa"){
				info.empresa[1] := nome , info.empresa[2] := mascara  
			}else if(nivel = "tipo"){
				info.tipo[1] := nome , info.tipo[2] :=  mascara
			}else if(nivel = "familia"){
				info.familia[1] := nome , info.familia[2] :=  mascara
			}else if(nivel = "subfamilia"){
				info.subfamilia[1] := nome , info.subfamilia[2] := mascara
			}else if(nivel = "modelo"){
				info.modelo[1] := nome , info.modelo[2] :=  mascara
			}else{
				MsgBox, 16, Erro, % "O valor de nivel passado nao existe : " nivel
			}
			this.remove_subitems( nome_item, mascara_item, info, nivel_tipo, i)
		}
		/*
			Quando voltar da iteracao de todos os subitems
			excluir o item pai (este item)
		*/
		this.delete_subitem(nome, mascara, info, nivel)
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
		}else if(nivel = "subfamilia"){
			db.Subfamilia.excluir(nome, mascara, info, 0)
		}else if(nivel = "familia"){
			db.Familia.excluir(nome, mascara, info, 0)
		}else if(nivel = "modelo"){
			prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2]
			db.Modelo.excluir(nome, mascara, info, 0)
		}
	}

	/*
		Retorna determinada 
		tabela em um array
	*/
	load_table_in_array(table){
		Global mariaDB

		if(table = ""){
			MsgBox, % "Passe o nome de uma tabela antes de continuar tipo!"
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