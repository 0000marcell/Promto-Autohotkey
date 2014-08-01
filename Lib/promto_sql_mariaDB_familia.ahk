class Familia{
	/*
		Incluir familia
	*/
	incluir(familia_nome = "", familia_mascara = "", prefixo = "", info = ""){
		Global db, mariaDB, ETF_hashmask
		family_table := db.get_reference("Familia", info.empresa[2] info.tipo[1])
		item_hash := this.check_data_consistency(familia_nome, familia_mascara, family_table, prefixo, info.tipo[1])
		if(item_hash.name = "")
			throw { what: "O item_hash voltou em branco do familia ", file: A_LineFile, line: A_LineNumber }		
		this.insert_family(item_hash.name, item_hash.mask, family_table, prefixo)
	}

	insert_family(family_name, family_mask, family_table, prefix){
		Global db, ETF_hashmask
		MsgBox, 4,,Esta familia tera subfamilias? 
		IfMsgBox Yes
		{
			this.insert_with_subfamily(family_name, family_mask, prefix, family_table)
		}else{
			this.insert_with_model(family_name, family_mask, prefix, family_table)
		}
	}

	insert_with_subfamily(family_name, family_mask, prefix, family_table){
		Global db
		this.insert_family_record(family_name, family_mask, 1, family_table)
		ETF_hashmask[family_name] := family_mask
		this.create_model_or_subfam_table(prefix family_mask "Subfamilia", "(Subfamilias VARCHAR(250), Mascara VARCHAR(250), PRIMARY KEY (Mascara))")
		db.insert_record({tipo: "Subfamilia", tabela1: prefix family_name, tabela2: prefix family_mask "Subfamilia"}, "reltable")	
	}

	insert_with_model(family_name, family_mask, prefix, family_table){
		Global db
		this.insert_family_record(family_name, family_mask, 0, family_table)
		ETF_hashmask[family_name] := family_mask
		this.create_model_or_subfam_table(prefix family_mask "Modelo", "(Modelos VARCHAR(250), Mascara VARCHAR(250), PRIMARY KEY (Mascara))")
		db.insert_record({tipo: "Modelo", tabela1: prefix family_name, tabela2: prefix family_mask "Modelo"}, "reltable")
	}

	create_model_or_subfam_table(table, sql){
		Global db
		db.create_table(table, sql)
	}

	insert_family_record(family_name, family_mask, subfamily, family_table){
		Global db
		record := {}
		record.Familias := family_name
		record.Mascara := family_mask
		record.Subfamilia := subfamily
		db.insert_record(record, family_table)
	}

	check_data_consistency(family_name, family_mask, family_table, prefix){
		parameters := [family_name, family_mask, family_table, prefix]
		check_blank_parameters(parameters, 4)
		this.exists(family_name, family_mask, family_table)
		item_hash := check_if_mask_is_unique(family_name, family_mask)
		return item_hash
	}

	excluir(familia_nome, familia_mascara, info, recursiva = 1){
		Global db, mariaDB
		if(recursiva = 1){
			db.init_unique_info()
			db.remove_subitems("familia", info.empresa[2] info.tipo[2] familia_mascara, info)
		}
		family_table := db.get_reference("Familia", info.empresa[2] info.tipo[1])
		this.delete_family(familia_nome, familia_mascara, family_table, info)
	}

	delete_family(family_name, family_mask, family_table, info){
		Global db
		db.delete_items_where(" Mascara like '" family_mask "'", family_table)		  
		if(db.have_subfamilia(info.empresa[2] info.tipo[2] family_name)){
			sub_table := db.get_reference("Subfamilia", info.empresa[2] info.tipo[2] family_name)	
			this.delete_subtitems_if_subfamily(info, family_name, sub_table)
		}else{
			sub_table := db.get_reference("Modelo", info.empresa[2] info.tipo[2] family_name)
			this.delete_subitems_if_model(info, family_name, sub_table)
		}
	}

	delete_subitems_if_model(info, family_name, model_table){
		sql_table1 := " tipo like 'Modelo' AND tabela1 like '" info.empresa[2] info.tipo[2] family_name "'"
		sql_table2 := " tipo LIKE 'Modelo' AND tabela2 LIKE '" model_table "'"
		this.delete_subtable(sql_table1, sql_table2, model_table)
	}

	delete_subtitems_if_subfamily(info, family_name, subfamily_table){
		sql_table1 := " tipo like 'Subfamilia' AND tabela1 like '" info.empresa[2] info.tipo[2] family_name "'"
		sql_table2 := " tipo LIKE 'Subfamilia' AND tabela2 LIKE '" subfamily_table "'"
		this.delete_subtable(sql_table1, sql_table2, subfamily_table)
	}

	delete_subtable(sql_table1, sql_table2, table){
		Global db
		db.delete_items_where(sql_table1 , "reltable")
		if(!db.check_if_exists(sql_table2, "reltable")){
			db.drop_table(table)
		}
	}

	exists(familia_nome, familia_mascara, table){
		Global db 
		sql := 
		(JOIN
			" Mascara like '" familia_mascara 
			"' OR Familias like '" familia_nome "'"	 
		)
		db.exists(sql, table)
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
		if(nivel = "familia"){
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
			MsgBox, % "Passe o nome de uma tabela antes de continuar familia!"
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
