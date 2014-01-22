class Empresa{

	/*
		Inclui uma nova empresa
	*/
	incluir(empresa_nome, empresa_mascara){
		Global mariaDB, ETF_hashmask
		
		/*
			Verifica se a mascara a ser inserida 
			ja existe
		*/
		if(this.exists(empresa_mascara)){
			MsgBox,16,Erro, % " A mascara a ser inserida ja existe!" 
			return 
		}

		if(ETF_hashmask[empresa_nome] != ""){
			MsgBox, % "empresa " empresa_nome " empreas mascara " ETF_hashmask[empresa_nome]
			MsgBox, 4, Item duplicado, % "Ja existe uma outra empresa com o mesmo nome `n Nesse caso a mascara a ser inserida deve ser a mesma `n deseja mudar a mascara do item para a mascara ja existente ou abortar a operacao!" 
			IfMsgBox Yes
			{
				empresa_mascara := ETF_hashmask[empresa_nome]
			}	
		}
		/*
			Insere o valor na tabela
		*/
		record := {}
		record.Empresas := empresa_nome
		record.Mascara := empresa_mascara
		mariaDB.Insert(record, "empresas")

		/*
			Criar a tabela de tipos e inserir na reltable
		*/

		/*
			Verifica se a relacao a ser inserida ja existe na 
			tabela de referencia
		*/
		if(this.exists_in_reltable(empresa_nome)){
			MsgBox, % "Ja existe uma tabela de tipos relacionada com essa empresa"
			return
		}
		
		sql :=
		(JOIN
			"	CREATE TABLE IF NOT EXISTS " empresa_mascara "Aba "
			" (Abas VARCHAR(250), "
			" Mascara VARCHAR(250), "
			" PRIMARY KEY (Mascara)) "
		)

		try{
			mariaDB.Query(sql)
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de tipos `n" ExceptionDetail(e)

		
		record := {}
		record.tipo := "Aba"
		record.tabela1 := empresa_nome
		record.tabela2 := empresa_mascara "Aba"
		mariaDB.Insert(record, "reltable")
		MsgBox,64,Empresa Criada,% " valor inserido"
		return 1
	}

	/*
		Exclui uma empresa
	*/
	excluir(empresa_nome, empresa_mascara, recursiva = 1){
		Global mariaDB

		/*
			Deleta o valor da tabela de empresas  
		*/
		if(!this.exists(empresa_mascara)){
			MsgBox,16,Erro,% " O valor a ser deletado nao existia na tabela"
			return 
		}

		/*
			Funcao recursiva que exclui todas os
			tipos familias subfamilias e modelos dessa 
			empresa
		*/
		if(recursiva = 1){
			this.remove_subitems(empresa_nome, empresa_mascara)
			return
		}

		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM empresas "
				" WHERE Mascara like '" empresa_mascara "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de empresas " ExceptionDetail(e)
		
		/*
			Deleta o valor da tabela de referencia
		*/
		if(!this.exists_in_reltable(empresa_nome)){
			MsgBox,16,Erro, % " O valor a ser deletado nao existia na tabela de referencia"
			return
		}
		/*
			Pega o nome da tabela de referencia de abas
		*/
		linked_table := this.get_reference(empresa_nome, "Aba")


		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable "
				" WHERE tipo like 'Aba'"
				" AND tabela1 like '" empresa_nome "'"
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
				" WHERE tipo LIKE 'Aba' "
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
		MsgBox, % " A empresa foi deletada!"
	}	

	/*
		Funcao que exclui todos os 
		subitems dessa empresa
	*/

	remove_subitems(nome, mascara, info = "", nivel_tipo = "", i = 0){
		Global mariaDB, db

		i++
		if(nivel_tipo = ""){
			info := []
			nivel_tipo := {1: ["empresa", "Aba"], 2: ["tipo", "Familia"], 3: ["familia", "Modelo"], 4: ["subfamilia", "Modelo"], 5: ["Modelo", "break"]}
		}

		nivel := nivel_tipo[i,1]

		/*
			Funcao que verifica no nivel de familias 
			se a proxima tabela e de subfamilias ou de modelos
		*/
		if(nivel = "familia"){
			tabela1 := info.empresa[2] info.tipo[2] info.familia[1]
			if(db.have_subfamilia()){
				tipo := "Subfamilia"
			}else{
				tipo := nivel_tipo[i,2]		
			}
		}

		
		;MsgBox, % "nome> " nome "`n mascara> " mascara "`n nivel> " nivel "`n tipo> " tipo "`n i> " i
		
		/*
			Pega a tabela de referencias que 
			contems os subitems do item atual
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
		if(nivel = "empresa"){
			tabela1 := nome
		}else if(nivel = "tipo"){
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
		;FileAppend, % "#DELETE fim do loop nome: " nome " mascara: " mascara "`n", % "debug.txt"
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
		}else if(nivel = "familia"){
			db.Familia.excluir(nome, mascara, info, 0)
		}else if(nivel = "subfamilia"){
			db.Subfamilia.excluir(nome, mascara, info, 0)
		}else if(nivel = "modelo"){
			prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2]
			db.Modelo.excluir(nome, mascara, info, 0)
		}
	}

	/*
		Verifica se determinado valor
		ja existe na tabela
	*/
	exists(empresa_mascara){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT Mascara FROM empresas "
				" WHERE Mascara like '" empresa_mascara "'"
			))

		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}
	}

	exists_in_reltable(empresa_nome){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT tabela1 FROM reltable "
				" WHERE tabela1 like '" empresa_nome "'"
			))

		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}
	}

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