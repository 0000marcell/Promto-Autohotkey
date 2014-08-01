class Subfamilia{

	incluir(subfam_name = "", subfam_mask = "", info = ""){
		Global db, mariaDB, ETF_hashmask	

		subfam_table := db.get_reference("Subfamilia", info.empresa[2] info.tipo[2] info.familia[1])
		item_hash := this.check_data_consistency(subfam_name, subfam_mask, subfam_table, info)
		prefix := info.empresa[2] info.tipo[2] info.familia[2]
		if(item_hash.name = "")
			return 0
		if(!this.insert_subfamily(item_hash.name, item_hash.mask, subfam_table))
			return 0
		if(!db.create_table(prefix item_hash.mask "Modelo ", "(Modelos VARCHAR(250), Mascara VARCHAR(250), PRIMARY KEY (Mascara))"))
			return 0
		if(!db.insert_record({tipo: "Modelo", tabela1: prefix item_hash.name, tabela2: prefix item_hash.mask "Modelo"}, "reltable"))
			return 0
		Return 1
	}

	insert_subfamily(subfam_name, subfam_mask, subfam_table){
		Global db, ETF_hashmask
		record := {}
		record.Subfamilias := subfam_name
		record.Mascara := subfam_mask
		if(db.insert_record(record, subfam_table)){
			ETF_hashmask[subfam_name] := subfam_mask
			return 1
		}else{
			return 0 
		}
	}

	check_data_consistency(subfam_name, subfam_mask, subfam_table, info){
		parameters := [subfam_name, subfam_mask, subfam_table]
		if(!check_blank_parameters(parameters, 3))
			return 0
		if(!this.exists(subfam_name, subfam_mask, subfam_table))
			return 0
		item_hash := check_if_mask_is_unique(subfam_name, subfam_mask)
		return item_hash
	}

	exists(subfam_name, subfam_mask, subfam_table){
		Global db
		sql :=
		(JOIN
			" Mascara like '" subfam_mask 
			"' OR Subfamilias like '" subfam_name "'" 
		)  
		return db.exists(sql, subfam_table)
	}

	excluir(subfam_name, subfam_mask, info, recursiva = 1){
		Global db, mariaDB
		; Funcao recursiva que exclui todos os subitems
		if(recursiva = 1){
			db.init_unique_info() 
			db.remove_subitems("subfamilia", this.full_prefix(info), info)
		}
		subfam_table := db.get_reference("Subfamilia", this.prefix(info) subfam_name)
		if(!this.delete_subfam(subfam_name, subfam_mask, subfam_table, info))
			return 0
		return 1
	}

	delete_subfam(subfam_name, subfam_mask, subfam_table, info){
		Global db 
		if(!db.delete_items_where(" Mascara like '" subfam_mask "'", subfam_table))
			return 0
		this.delete_model_table_if_not_related(subfam_name, subfam_mask, info)		
	}

	delete_model_table_if_not_related(subfam_name, subfam_mask, info){
		Global db
		model_table := db.get_reference("Modelo", this.prefix(info) subfam_name)
		if(!db.delete_items_where(" tipo like 'Subfamilia' AND tabela1 like '" this.prefix(info) subfam_name "'", "reltable"))
			return 0
		if(!db.check_if_exists(" tipo LIKE 'Modelo' AND tabela2 LIKE '" model_table "'", "reltable")){
			db.drop_table(model_table)
		}
	}

	prefix(info){
		return_value := info.empresa[2] info.tipo[2] info.familia[2]
		return return_value
	}

	full_prefix(info){
		return_value := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2]
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