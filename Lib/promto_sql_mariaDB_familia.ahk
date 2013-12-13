class Familia{
	/*
		Incluir familia
	*/
	incluir(familia_nome = "", familia_mascara = "", prefixo = "", tipo_nome = ""){
		Global mariaDB

		;MsgBox, % "familia_nome: " familia_nome " `n familia_mascara: " familia_mascara " `n prefixo: " prefixo " `n tipo_nome: " tipo_nome 
		/*	
			Verifica se o prefixo a inserir o item 
			esta em branco
		*/
		if(prefixo = ""){
			MsgBox, % "O prefixo nao pode estar em branco nas familias!"
			return 0
		}

		/*
			Verifica se o nome ou a mascara da empresa esta em branco
		*/
		if(familia_nome = "" || familia_mascara = ""){
			MsgBox, % "o nome e a mascara da familia nao podem estar em brancos!"
			return 0			
		}

		/*
			Verifica se o nome da empresa esta em branco 
		*/
		if(tipo_nome = ""){
			MsgBox, % "O nome do tipo nao pode estar em branco!"
			return 0
		}

		/*
			Pega a mascara da empresa
		*/
		StringLeft, empresa_mascara, prefixo, 1


		/*
			Pega a referencia da tabela de items 
			linkados
		*/
		familia_table := this.get_parent_reference(empresa_mascara, tipo_nome)

		;MsgBox, % "familia_table: " familia_table
		/*
			Verifica se a mascara a ser inserida 
			ja existe
		*/
		if(this.exists(familia_nome, familia_mascara, familia_table)){
			MsgBox,16,Erro, % " A mascara a ser inserida ja existe!" 
			return 0
		}

		/*
			Insere o valor na tabela
		*/
		record := {}
		record.Familias := familia_nome
		record.Mascara := familia_mascara
		mariaDB.Insert(record, familia_table)

		/*
			Cria a tabela de Familias e insere a
			referencia na reltable
		*/
		

		try{
			mariaDB.Query(
				(JOIN 
					"	CREATE TABLE IF NOT EXISTS " prefixo familia_mascara "Modelo "
					" (Modelos VARCHAR(250), "
					" Mascara VARCHAR(250), "
					" PRIMARY KEY (Mascara)) "
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Modelos `n" ExceptionDetail(e)

		record := {}
		record.tipo := "Modelo"
		record.tabela1 := prefixo familia_nome
		record.tabela2 := prefixo familia_mascara "Modelo"
		mariaDB.Insert(record, "reltable")
		MsgBox, % "A Familia foi inserida!"
		return 1
	}

	/*
	 Excluir familia
	*/
	excluir(familia_nome, familia_mascara, info, recursiva = 1){
		Global mariaDB

		/*
		 Excluir a entrada da familia
		 na tabela de familias 
		*/
		;MsgBox, % "ira excluir a familia nome: " familia_nome " familia mascara: " familia_mascara "`n" 
		prefixo := info.empresa[2] info.tipo[2]
		
		familia_table := this.get_parent_reference(info.empresa[2], info.tipo[1])
		;MsgBox, % "tabela retornada @@" familia_table

		if(!this.exists(familia_nome, familia_mascara, familia_table)){
			MsgBox,16,Erro,% " O valor a ser deletado nao existia na tabela"
			return 
		}

		if(recursiva = 1){
			this.remove_subitems(familia_nome, familia_mascara, info)
			return
		}
		;MsgBox, % " ira pegar a tabela " prefixo "Familia" 

		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM " prefixo "Familia"
				" WHERE Mascara like '" familia_mascara "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de Familias `n " ExceptionDetail(e)
		/*
			Exclui a tabela de modelos
			relacionada com essa familia
			caso ela nao esteja mais relacionada com nada
		*/
		linked_table := this.get_reference(prefixo familia_nome, "Modelo")
		;MsgBox, % "tabela linkada: " linked_table 

		/*
		 Deleta a entrada do tipo na 
		 tabela de relacionamento.  
		*/
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable "
				" WHERE tipo like 'Modelo'"
				" AND tabela1 like '" prefixo familia_nome "'"
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
		Verifica se determinado 
		Familia ja existe na tabela
	*/
	exists(familia_nome, familia_mascara, table){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT Familias FROM " table
				" WHERE Mascara LIKE '" familia_mascara "'"
				" AND Familias LIKE '" familia_nome "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}
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
		if(nivel_tipo = ""){
			nivel_tipo := {1: ["familia", "Modelo"], 2: ["Modelo", "break"]}
		}

		nivel := nivel_tipo[i,1]
		tipo := nivel_tipo[i,2]

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
			;prefix := info.empresa
			;db.Modelo.incluir( nome, mascara, info.empresa)
			this.delete_subitem(nome, mascara, info, nivel)
			return
		}	

		/*
			Retorna a tabela do proximo nivel
		*/
		tabela1 := info.empresa[2] info.tipo[2] nome
		;MsgBox, % "ira busacar a tabela tipo: " tipo " tabela1: " tabela1
		table := db.get_reference(tipo, tabela1)
		;MsgBox, % "tabela retornada " table
		if(table = ""){
			this.delete_subitem(nome, mascara, info, nivel)
			return 
		}
		;MsgBox, % "tabela retornada " table
		;db.get_reference("Modelo",empresa.mascara tipo.mascara familia.nome)
		;get_reference(tipo, tabela1)

		/*
			Itera pelos items da tabela 
			pegando seu nome e mascara e 
			chando a funcao outra vez 
		*/
		table_items := this.load_table_in_array(table)
		loop, % table_items.maxindex(){
			nome_item := table_items[A_Index,1]
			mascara_item := table_items[A_Index,2]
			
			;MsgBox, % " item da tabela " nome_item " mascara item " mascara_item 
			if(nivel = "empresa"){
				info.empresa[1] := nome , info.empresa[2] := mascara  
			}else if(nivel = "tipo"){
				info.tipo[1] := nome , info.tipo[2] :=  mascara
			}else if(nivel = "familia"){
				info.familia[1] := nome , info.familia[2] :=  mascara
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
			;MsgBox, % " deletar empresa " nome "mascara " mascara
			db.Empresa.excluir(nome, mascara, 0)
			;FileAppend, % " `n ira deletar a empresa " nome, % "debug.txt"
		}else if(nivel = "tipo"){
			;MsgBox, % "ira deletar o tipo " nome " mascara " mascara
			db.Tipo.excluir(nome, mascara, info, 0)
			;FileAppend, % " `n ira deletar o tipo " nome, % "debug.txt"
		}else if(nivel = "familia"){
			;MsgBox, % "ira deletar a familia " nome " familia " mascara
			db.Familia.excluir(nome, mascara, info, 0)
			;FileAppend, % " `n ira deletar a familia " nome, % "debug.txt"
		}else if(nivel = "modelo"){
			prefixo := info.empresa[2] info.tipo[2] info.familia[2]
			;MsgBox, % "ira deletar o modelo " nome " mascara " mascara
			db.Modelo.excluir(nome, mascara, info, 0)
			;FileAppend, % " `n ira deletar o modelo " nome, % "debug.txt"
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
