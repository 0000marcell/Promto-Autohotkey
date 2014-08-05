class Subfamilia{

	incluir(subfam_name = "", subfam_mask = "", info = ""){
		Global db, mariaDB, ETF_hashmask	
		this.name := subfam_name, this.mask := subfam_mask 
		this.info := info
		this.subfam_table := db.get_reference("Subfamilia", this.info.empresa[2] this.info.tipo[2] this.info.familia[1])
		item_hash := this.check_data_consistency()
		this.name := item_hash.name, this.mask := item_hash.mask  
		this.prefix := this.info.empresa[2] this.info.tipo[2] this.info.familia[2]
		if(item_hash.name = "")
			throw { what: "O item_hash voltou em branco da subfamilia ", file: A_LineFile, line: A_LineNumber }		
		this.insert_subfamily()
		db.create_table(this.prefix this.mask "Modelo ", "(Modelos VARCHAR(250), Mascara VARCHAR(250), PRIMARY KEY (Mascara))")
		db.insert_record({tipo: "Modelo", tabela1: this.prefix this.name, tabela2: this.prefix this.mask "Modelo"}, "reltable")
	}

	insert_subfamily(){
		Global db, ETF_hashmask
		record := {}
		record.Subfamilias := this.name
		record.Mascara := this.mask
		db.insert_record(record, this.subfam_table)
		ETF_hashmask[this.name] := this.mask
	}

	check_data_consistency(){
		parameters := [this.name, this.mask, this.subfam_table]
		check_blank_parameters(parameters, 3)
		this.exists()
		item_hash := check_if_mask_is_unique(this.name, this.mask)
		return item_hash
	}

	exists(){
		Global db
		sql :=
		(JOIN
			" Mascara like '" this.mask 
			"' OR Subfamilias like '" this.name "'" 
		)  
		db.exists(sql, this.subfam_table)
	}

	excluir(subfam_name, subfam_mask, info, recursiva = 1){
		Global db, mariaDB
		this.name := subfam_name, this.mask := subfam_mask
		this.info := info
		MsgBox, % "gonna start recursive subfamily!"
		if(recursiva = 1){
			db.init_unique_info() 
			db.remove_subitems("subfamilia", this.full_prefix(), this.info)
		}
		MsgBox, % "returned from recursive subfamily!"
		this.subfam_table := db.get_reference("Subfamilia", this.info.empresa[2] this.info.tipo[2] this.info.familia[1])
		this.delete_subfam()
	}

	delete_subfam(){
		Global db 
		MsgBox, % "gonna delete mask " this.mask " subfam_table " this.subfam_table
		db.delete_items_where(" Mascara like '" this.mask "'", this.subfam_table)
		this.delete_model_table_if_not_related()		
	}

	delete_model_table_if_not_related(){
		Global db
		model_table := db.get_reference("Modelo", this.get_prefix() this.name) 
		db.delete_items_where(" tipo like 'Modelo' AND tabela1 like '" this.get_prefix() this.name "'", "reltable")
		if(!db.check_if_exists(" tipo LIKE 'Modelo' AND tabela2 LIKE '" model_table "'", "reltable")){
			db.drop_table(model_table)
		}
	}

	get_prefix(){
		return_value := this.info.empresa[2] this.info.tipo[2] this.info.familia[2]
		return return_value
	}

	full_prefix(){
		return_value := this.info.empresa[2] this.info.tipo[2] this.info.familia[2] this.info.subfamilia[2]
		return return_value 
	}

	remove_subitems(nome, mascara, info = "", nivel_tipo = "", i = 0){
		Global mariaDB, db
		i++
		if(nivel_tipo = ""){
			nivel_tipo := {1: ["Subfamilia", "Modelo"], 2: ["Modelo", "break"]}
		}
		nivel := nivel_tipo[i,1]
		tipo := nivel_tipo[i,2]	
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
		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] nome

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
			this.remove_subitems(nome_item, mascara_item, info, nivel_tipo, i)
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

	get_parent_reference(prefixo, familia_nome){
		global mariaDB

		;MsgBox, % "get parent reference empresa mascara " prefixo " tipo nome " tipo_nome
		;MsgBox, % "tabela1: " prefixo familia_nome
		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like 'Subfamilia' "
				" AND tabela1 like '" prefixo familia_nome "'"
			))
		reference_table := rs.tabela2
		rs.close()
		;MsgBox, % "tabela retornada " reference_table
		return reference_table
	}
}