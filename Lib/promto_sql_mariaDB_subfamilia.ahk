class Subfamilia{

	/*
		Incluir uma nova subfamilia
	*/
	incluir(subfam_nome = "", subfam_mascara = "", prefixo = "", familia_nome = ""){
		Global mariaDB

		if(subfam_nome = "" || subfam_mascara = "" || prefixo = ""){
			MsgBox, 16, % "Um dos items necessarios para incluir a subfamilia estava em branco!" 
			return
		}

		/*
			Pega a mascara da empresa
		*/
		StringLeft, sub_prefixo, prefixo, 2

		/*
			Pega a referencia da tabela de items 
			linkados
		*/
		subfam_table := this.get_parent_reference(sub_prefixo, familia_nome)
		if(subfam_table = ""){
			MsgBox, 16, Erro, % "A familia selecionada nao tem subfamilia!"
			return
		}

		/*
			Insere esta subfamilia na tabela de subfamilias
		*/
		record := {}
		record.Subfamilias := subfam_nome
		record.Mascara := subfam_mascara
		mariaDB.Insert(record, subfam_table)

		/*
			Cria a tabela de modelos
		*/
		try{
			mariaDB.Query(
				(JOIN 
					"	CREATE TABLE IF NOT EXISTS " prefixo subfam_mascara "Modelo"
					" (Modelos VARCHAR(250), "
					" Mascara VARCHAR(250), "
					" PRIMARY KEY (Mascara)) "
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Modelos `n" ExceptionDetail(e)

		record := {}
		record.tipo := "Modelo"
		record.tabela1 := prefixo subfam_nome
		record.tabela2 := prefixo subfam_mascara "Modelo"
		mariaDB.Insert(record, "reltable")
		MsgBox, % "A Subfamilia foi inserida!"
		return 1
	}

	/*
		Exclui determinada subfamilia
	*/
	excluir(subfam_nome, subfam_mascara, info, recursiva = 1){
		Global mariaDB

		/*
		 Excluir a entrada da familia
		 na tabela de familias 
		*/
 
		prefixo := info.empresa[2] info.tipo[2]
		
		subfam_table := this.get_parent_reference(info.empresa[2], info.familia[1])

		if(!this.exists(subfam_nome, subfam_mascara, subfam_table)){
			MsgBox,16,Erro,% " O valor a ser deletado nao existia na tabela"
			return 
		}

		if(recursiva = 1){
			this.remove_subitems(subfam_nome, subfam_mascara, info)
			return
		}
 
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM " prefixo "Subfamilia"
				" WHERE Mascara like '" subfam_mascara "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de Familias `n " ExceptionDetail(e)
		
		/*
			Exclui a tabela de modelos
			relacionada com essa familia
			caso ela nao esteja mais relacionada com nada
		*/
		linked_table := this.get_reference(prefixo subfam_nome, "Modelo") 

		/*
		 Deleta a entrada do tipo na 
		 tabela de relacionamento.  
		*/
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable "
				" WHERE tipo like 'Modelo'"
				" AND tabela1 like '" prefixo subfam_nome "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de referencia " ExceptionDetail(e)
		
		/*
		 Verifica se a tabela de modelos 
		 nao estava linkada com mais nenhuma outra tabela
		 antes de deleta-la
		*/
		table := mariaDB.Query(
			(JOIN 
				" SELECT tipo,tabela1,tabela2 FROM reltable "
				" WHERE tipo LIKE 'Modelo' "
				" AND tabela2 LIKE '" linked_table "'"
			))
		linked := ""
		columnCount := table.Columns.Count()
		for each, row in table.Rows{
			Loop, % columnCount
				linked .= row[A_index] "`n"
		} 

		/*
			Se nao existir mais nenhuma tabela linkada.
		*/
		if(linked = ""){
			try{
				mariaDB.Query("DROP TABLE " linked_table)	
			}catch e 
				MsgBox,16,Erro,% " Erro ao tentar deletar a tabela de tipos " linked_table "`n" ExceptionDetail(e)
		}
	}

	/*
		Remove os subitems do determinado item
	*/
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