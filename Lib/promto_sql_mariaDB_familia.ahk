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
		append_debug("ira buscar a tabela de familias empresa mascara " empresa_mascara " tipo nome " tipo_nome)
		familia_table := this.get_parent_reference(empresa_mascara, tipo_nome)
		append_debug("tabela de familias retornada " familia_table)
		;MsgBox, % "familia_table: " familia_table
		
		/*
			Verifica se a mascara a ser inserida 
			ja existe
		*/
		;MsgBox, % "ira verificar se a mascara ja existe `n familia nome : " familia_nome " familia mascara : " familia_mascara " familia table " familia_table
		
		if(this.exists(familia_nome, familia_mascara, familia_table)){
			MsgBox,16,Erro, % " A mascara a ser inserida ja existe!" 
			return 0
		}
		
		/*
			Cria a tabela de subfamilias e insere 1 no campo subfamilia
		*/
		MsgBox, 4,,Esta familia tera subfamilias? 
		IfMsgBox Yes
		{
			this.inserir_com_subfamilias(familia_nome, familia_mascara, prefixo, familia_table)
		}else{
			this.inserir_com_modelo(familia_nome, familia_mascara, prefixo, familia_table)
		}
		return 1
	}

	/*
		Insere a familia com modelo (sem subfamilias)
	*/
	inserir_com_modelo(familia_nome, familia_mascara, prefixo, familia_table){
		Global mariaDB

		append_debug("ira inserir a familia com modelo ")
		/*
			Insere o campo subfamilia na tabela de familias
		*/
		try{
			mariaDB.Query(
				(JOIN
					"ALTER TABLE " familia_table " ADD Subfamilia VARCHAR(60);"
				))
			}catch e{
				;MsgBox,16, Erro, % "Um erro ocorreu ao tentar inserir o valor de campo Subfamilia!"
				;return 
			}
			
		/*
			Insere o valor na tabela
		*/
		record := {}
		record.Familias := familia_nome
		record.Mascara := familia_mascara
		record.Subfamilia := 0
		mariaDB.Insert(record, familia_table)

		/*
			Cria a tabela de Familias e insere a
			referencia na reltable
		*/
		append_debug("ira criar a tabela de modelos case nao exista " prefixo familia_mascara "Modelo")
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

		append_debug("ira inserir a referencia da tabela de modelos")
		record := {}
		record.tipo := "Modelo"
		record.tabela1 := prefixo familia_nome
		record.tabela2 := prefixo familia_mascara "Modelo"
		mariaDB.Insert(record, "reltable")
		MsgBox, % "A Familia foi inserida!"

	}

	inserir_com_subfamilias(familia_nome, familia_mascara, prefixo, familia_table){
		Global mariaDB

		check_if_blank({
			(JOIN
				"nome da familia": familia_nome, 
				"mascara da familia": familia_mascara,
				"prefixo": prefixo,
				"tabela de familia": familia_table
			)})

		
		/*
			Insere o campo subfamilia na tabela de familias
		*/
		try{
			mariaDB.Query(
				(JOIN
					"ALTER TABLE " familia_table " ADD Subfamilia VARCHAR(60);"
				))
			}catch e{
				;MsgBox,16, Erro, % "Um erro ocorreu ao tentar inserir o valor de campo Subfamilia!"
				;return 
			}
		
		record := {}
		record.Familias := familia_nome
		record.Mascara := familia_mascara
		record.Subfamilia := 1
		mariaDB.Insert(record, familia_table)

		try{
			mariaDB.Query(
				(JOIN 
					"	CREATE TABLE IF NOT EXISTS " prefixo familia_mascara "Subfamilia "
					" (Subfamilias VARCHAR(250), "
					" Mascara VARCHAR(250), "
					" PRIMARY KEY (Mascara)) "
				))
		}catch e{
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Subfamilia `n" ExceptionDetail(e)
			return
		}

		record := {}
		record.tipo := "Subfamilia"
		record.tabela1 := prefixo familia_nome
		record.tabela2 := prefixo familia_mascara "Subfamilia"
		mariaDB.Insert(record, "reltable")
		MsgBox, % "A Familia foi inserida!"
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

		prefixo := info.empresa[2] info.tipo[2]
		
		familia_table := this.get_parent_reference(info.empresa[2], info.tipo[1])
		append_debug("tabela de familia retornada " familia_table "`n familia nome " familia_nome "`n familia mascara " familia_mascara)
		
		if(!this.exists(familia_nome, familia_mascara, familia_table)){
			MsgBox,16,Erro,% " O valor a ser deletado nao existia na tabela"
			return 
		}

		append_debug("ira deletar recursivamente !")
		if(recursiva = 1){
			tabela1 := info.empresa[2] info.tipo[2] info.familia[1]
			
			if(db.have_subfamilia(tabela1)){
				nivel_tipo := {1: ["Familia", "Subfamilia"], 2: ["Subfamilia", "Modelo"], 3: ["Modelo", "break"]}
			}else{
				nivel_tipo := {1: ["Familia", "Modelo"], 2: ["Modelo", "break"]}
			}
			this.remove_subitems(familia_nome, familia_mascara, info, nivel_tipo)
			return
		}
 		append_debug("ira deletar a entrada da mascara na tabela : " prefixo "Familia `n familia mascara : " familia_mascara)
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM " prefixo "Familia"
				" WHERE Mascara like '" familia_mascara "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de Familias `n " ExceptionDetail(e)
		
		if(recursiva = 1){
			this.remove_subitems(familia_nome, familia_mascara, info)
			return
		}

		/*
			Exclui a tabela de modelos
			relacionada com essa familia
			caso ela nao esteja mais relacionada com nada
		*/
		linked_table := this.get_reference(prefixo familia_nome, "Modelo") 

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
			Deleta a entrada de subfamilia na tabela de 
			relacionamento
		*/
		;MsgBox, % "ira deletar a entrada da tabela de relacionamento tabela1 " prefixo familia_nome 
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable "
				" WHERE tipo like 'Subfamilia'"
				" AND tabela1 like '" prefixo familia_nome "'"
			))	
		}catch e 
			;MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de referencia " ExceptionDetail(e)
		
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

		append_debug("tipo " tipo)

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

		append_debug("ira buscar a referencia da tabela ")
		table := db.get_reference(tipo, tabela1)
		append_debug("referencia da tabela retornada " table)

		if(table = ""){
			append_debug("ira deletar os subitems nome " nome "`n mascara " mascara " nivel " nivel)
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
