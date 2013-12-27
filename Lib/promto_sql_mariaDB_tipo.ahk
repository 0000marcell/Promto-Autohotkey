class Tipo{
		/*
		Incluir um novo tipo
	*/
	incluir(tipo_nome = "", tipo_mascara = "", prefixo = "", empresa_nome = ""){
		Global mariaDB

		/*
			Se o nome estiver em branco
		*/
		if(tipo_nome = ""){
			MsgBox, % "O nome do tipo nao pode estar em branco"
			return 0
		}

		/*
			Verifica se a tabela a inserir o item 
			esta em branco
		*/
		if(prefixo = ""){
			MsgBox, % "Os prefixos que determinam o parente deste item nao podem estar em branco!"
			return 0
		}

		/*
			Verifica se o nome da empresa esta em branco
		*/
		if(empresa_nome = ""){
			MsgBox, % "O nome da empresa nao pode estar em branco!"
			return 0
		}

		/*
			Verifica se o tipo_mascara esta em branco
			caso esteja mostra uma msg de aviso
		*/
		if(tipo_mascara = ""){
			MsgBox, 4,, % "Nao e recomendavel deixar a mascara em branco! `n deixar assim mesmo?"
			IfMsgBox No
			{
				return 0
			}
		}

		/*
			Pega a referencia da tabela de items 
			linkados
		*/
		tipo_table := this.get_parent_reference(empresa_nome)

		/*
			Verifica se a mascara a ser inserida 
			ja existe
		*/
		if(this.exists(tipo_nome, tipo_mascara, tipo_table)){
			MsgBox,16,Erro, % " A mascara a ser inserida ja existe!" 
			return 0
		}

		/*
			Insere o valor na tabela
		*/
		record := {}
		record.Abas := tipo_nome
		record.Mascara := tipo_mascara
		mariaDB.Insert(record, tipo_table)

		/*
			Cria a tabela de Familias e insere a
			referencia na reltable
		*/
		
		/*
		 Pega a mascara da empresa
		*/

		try{
			mariaDB.Query(
				(JOIN 
					"	CREATE TABLE IF NOT EXISTS " prefixo tipo_mascara "Familia "
					" (Familias VARCHAR(250), "
					" Mascara VARCHAR(250), Subfamilia VARCHAR(250), "
					" PRIMARY KEY (Mascara)) "
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Familias `n" ExceptionDetail(e)

		record := {}
		record.tipo := "Familia"
		record.tabela1 := prefixo tipo_nome
		record.tabela2 := prefixo tipo_mascara "Familia"
		mariaDB.Insert(record, "reltable")
		MsgBox, 64,Sucesso!, % "O tipo foi inserido!"
		Return 1
	}

	/*
		Excluir tipo
	*/
	excluir(tipo_nome, tipo_mascara, info, recursiva = 1){
		Global mariaDB

		/*
		 Excluir a entrada do tipo 
		 na tabela de tipos 
		*/
		prefixo := info.empresa[2]

		;MsgBox, % "ira a apagar o tipo: " tipo_nome "`n tipo_mascara: " tipo_mascara " `n prefixo: " prefixo

		tipo_table := this.get_parent_reference(info.empresa[1])
		if(!this.exists(tipo_nome, tipo_mascara, tipo_table)){
			MsgBox,16,Erro,% " O valor a ser deletado nao existia na tabela"
			return 
		}
		
		;MsgBox, % "voltou da verificacao de existencia!"
		/*
			Funcao recursiva que exclui todas os
			tipos familias e modelos dessa 
			empresa
		*/
		if(recursiva = 1){
			this.remove_subitems(tipo_nome, tipo_mascara, info)
			return
		}
		;MsgBox, % "voltou da recursividade!"
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM " prefixo "Aba"
				" WHERE Mascara like '" tipo_mascara "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de Tipos `n " ExceptionDetail(e)
		
		/*
			Exclui a tabela de familias 
			relacionada com esse tipo 
			caso ela nao esteja mais relacionada com nada
		*/
		linked_table := this.get_reference(prefixo tipo_nome, "Familia") 

		/*
		 Deleta a entrada do tipo na 
		 tabela de relacionamento.  
		*/
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable "
				" WHERE tipo like 'Familia'"
				" AND tabela1 like '" prefixo tipo_nome "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de referencia " ExceptionDetail(e)
		
		/*
		 Verifica se a tabela de tipos 
		 nao estava linkada com mais nenhuma outra tabela
		 antes de deleta-la
		*/

		table := mariaDB.Query(
			(JOIN 
				" SELECT tipo,tabela1,tabela2 FROM reltable "
				" WHERE tipo LIKE 'Familia' "
				" AND tabela2 LIKE '" linked_table "'"
			))
		
		linked .= ""
		
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
		Verifica se determinado 
		tipo ja existe na tabela
	*/
	exists(tipo_nome, tipo_mascara, table){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT Abas FROM " table
				" WHERE Mascara LIKE '" tipo_mascara "'"
				" AND Abas LIKE '" tipo_nome "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}
	}

	/*
		Pega a tabela de referencia do pai 
		ao qual o item atual sera inserido
	*/
	get_parent_reference(empresa_nome){
		global mariaDB

		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like 'Aba' "
				" AND tabela1 like '" empresa_nome "'"
			))
		reference_table := rs.tabela2
		rs.close()
		return reference_table
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