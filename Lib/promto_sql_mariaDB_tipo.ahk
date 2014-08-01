class Tipo{
	/*
		Incluir um novo tipo
	*/
	incluir(tipo_nome = "", tipo_mascara = "", prefixo = "", empresa_nome = ""){
		Global db, mariaDB, ETF_hashmask		
		tipo_table := db.get_reference("Aba", empresa_nome)
		item_hash := this.check_data_consistency(tipo_nome, tipo_mascara, tipo_table, prefixo, empresa_nome)
		if(item_hash.name = "")
			throw { what: "O item_hash.name voltou vazio para tipo " tipo_nome " tipo_mascara " tipo_mascara, file: A_LineFile, line: A_LineNumber }		
		this.insert_type(item_hash.name, item_hash.mask, tipo_table)
		db.create_table(prefixo item_hash.mask "Familia ", "(Familias VARCHAR(250), Mascara VARCHAR(250), Subfamilia VARCHAR(250), PRIMARY KEY (Mascara))")
		db.insert_record({tipo: "Familia", tabela1: prefixo item_hash.name, tabela2: prefixo item_hash.mask "Familia"}, "reltable")
	}

	insert_type(type_name, type_mask, type_table){
		Global db, ETF_hashmask
		record := {}
		record.Abas := type_name
		record.Mascara := type_mask
		db.insert_record(record, type_table)
		ETF_hashmask[type_name] := type_mask
	}

	check_data_consistency(type_name, type_mask, type_table, prefix, company_name){
		parameters := [type_name, type_mask, type_table, prefix, company_name]
		check_blank_parameters(parameters, 5)
		this.exists(type_name, type_mask, type_table)
		item_hash := check_if_mask_is_unique(type_name, type_mask)
		return item_hash
	}

	excluir(tipo_nome, tipo_mascara, info, recursiva = 1){
		Global db, mariaDB
		if(recursiva = 1){
			db.init_unique_info() 
			db.remove_subitems("aba", info.empresa[2] tipo_mascara, info)
		}
		type_table := db.get_reference("Aba", info.empresa[1])
		this.delete_type(tipo_nome, tipo_mascara, type_table, info)
	}

	delete_type(type_name, type_mask, type_table, info){
		Global db 
		db.delete_items_where(" Mascara like '" type_mask "'", type_table)
		family_table := db.get_reference("Familia", info.empresa[2] type_name)
		db.delete_items_where(" tipo like 'Familia' AND tabela1 like '" info.empresa[2] type_name "'", "reltable")
		if(!db.check_if_exists(" tipo LIKE 'Familia' AND tabela2 LIKE '" family_table "'", "reltable")){
			db.drop_table(family_table)
		}
	}

	exists(tipo_nome, tipo_mascara, table){
		Global db 
		sql := 
		(JOIN
			" Mascara like '" tipo_mascara 
			"' OR Abas like '" tipo_nome "'"	 
		)
		db.exists(sql, table)
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