class Modelo{
	
	/*
		Incluir um novo modelo
	*/
	incluir(model_name = "", model_mask = "", prefixo = "", tabela1 = "", info = ""){
		Global db, mariaDB, ETF_hashmask		
		this.name := model_name, this.mask := model_mask
		this.prefix := prefixo, this.tabela1 := tabela1
		this.model_table := db.get_reference("Modelo", this.tabela1)
		item_hash := this.check_data_consistency()
		if(item_hash.name = "")
			throw { what: "O item_hash voltou em branco do familia ", file: A_LineFile, line: A_LineNumber }
		this.name := item_hash.name, this.mask := item_hash.mask 
		this.insert_model()
		this.insert_model_tables(item_hash.name, item_hash.mask, prefixo)
		db.Log.insert_CRUD(info, "Criado", "O Modelo " this.name " e mascara " this.mask " foi criado!")
	}

	insert_model_tables(){
		this.create_code_table()
		this.create_bloq_table()
		this.create_descricao_geral()
		this.create_field_tables(["Campo", "oc", "odr", "odc", "odi"])
	}

	create_field_tables(tables){
		Global db
		for, each, item in tables{
			db.create_table(this.prefix this.mask item, " (id MEDIUMINT NOT NULL AUTO_INCREMENT, Campos VARCHAR(250), PRIMARY KEY (id))")
			db.insert_record({tipo: item, tabela1: this.prefix this.mask this.name, tabela2: this.prefix this.mask item}, "reltable")
		} 
	}

	create_descricao_geral(){
		Global db
		db.create_table(this.prefix this.mask "Desc", " (descricao VARCHAR(250))")
		db.insert_record({tipo: "Desc", tabela1: this.prefix this.mask this.name, tabela2: this.prefix this.mask "Desc"}, "reltable")
	}

	create_bloq_table(){
		Global db
		db.create_table(this.prefix this.mask "Bloqueio", " (Codigos VARCHAR(250)) ")
		db.insert_record({tipo: "Bloqueio", tabela1: this.prefix this.mask this.name, tabela2: this.prefix this.mask "Bloqueio"}, "reltable")
	}

	create_code_table(){
		Global db
		fields :=
		(JOIN
		  " (Codigos VARCHAR(250),"
			" DR VARCHAR(300), "
			" DC VARCHAR(600), "
			" DI VARCHAR(300)) "
		)
		db.create_table(this.prefix this.mask "Codigo", fields)
		db.insert_record({tipo: "Codigo", tabela1: this.prefix this.mask this.name, tabela2: this.prefix this.mask "Codigo"}, "reltable")
	}

	insert_model(){
		Global db, ETF_hashmask
		record := {}
		record.Modelos := this.name
		record.Mascara := this.mask
		db.insert_record(record, this.model_table)
		ETF_hashmask[model_name] := this.mask
	}

	check_data_consistency(){
		parameters := [this.name, this.mask, this.model_table, this.prefix]
		check_blank_parameters(parameters, 4)
		this.exists()
		item_hash := check_if_mask_is_unique(this.name, this.mask)
		return item_hash
	}

	exists(){
		Global db
		sql := 
		(JOIN
			" Mascara like '" this.mask 
			"' OR Modelos like '" this.name "'"	 
		)
		db.exists(sql, this.model_table)
	}

	get_model_tabela1(info){
		if(info.subfamilia[1] = ""){
			tabela1 := info.empresa[2] info.tipo[2] info.familia[1]
		}else{
			tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[1]
		}
		return tabela1 
	}

	excluir(model_name = "", model_mask = "", info = "", recursiva = 1){
		Global db, mariaDB
		this.name := model_name, this.mask := model_mask
		this.info := info
		this.model_table := db.get_reference("Modelo", this.get_model_tabela1(this.info))
		this.delete_model()
		db.Log.insert_CRUD(info, "Removido", "O modelo " this.name " e mascara " this.mask " foi removido!")	
	}

	delete_model(){
		Global db 
		db.delete_items_where(" Mascara like '" this.mask "'", this.model_table)
		this.delete_relationed_tables()
	}

	delete_relationed_tables(){
		Global db
		tables := ["oc", "odr", "odc", "odi", "Codigo", "Desc", "Bloqueio"]
		for, each, item in tables{ 
      db.delete_items_where(" tipo like '" item "' AND tabela1 like '" this.get_prefix() this.mask this.name "'", "reltable")
			this.drop_table_if_not_related(this.get_prefix() this.mask item, item)	
		}
		this.delete_field_table_and_subfields()
	}

	delete_field_table_and_subfields(){
		Global db
		field_table := db.get_reference("Campo", this.get_prefix() this.mask this.name)
		items := db.find_all(field_table)
		for, each, item in items{
		  subfield_table := db.get_reference(items[A_Index, 2], this.get_prefix() this.mask this.name)
      db.delete_items_where(" tipo like '" items[A_Index, 2] "' AND tabela1 like '" this.get_prefix() this.mask this.name "'", "reltable") 
      this.drop_table_if_not_related(subfield_table, items[A_Index, 2])
      this.drop_own_field_table(this.get_prefix() this.mask items[A_Index, 2], subfield_table, items[A_Index, 2])
		} 
    db.delete_items_where(" tipo like 'Campo' AND tabela1 like '" this.get_prefix() this.mask this.name "'", "reltable")
    this.drop_table_if_not_related(field_table, "Campo")    
	}

  drop_own_field_table(tabela2, related_table, tipo){
    Global db 
    if(tabela2 != related_table){
      this.drop_table_if_not_related(tabela2, tipo)  
    }
  }

	drop_table_if_not_related(tabela2, tipo){
    Global db
    sql := " tabela2 like '" tabela2 "' AND tipo like '" tipo "'" 
		if(!db.check_if_exists(sql, "reltable")){
			db.drop_table(tabela2)	
		}
	}

	get_prefix(){
		return_value := this.info.empresa[2] this.info.tipo[2] this.info.familia[2] this.info.subfamilia[2] 
		return return_value
	}

	incluir_ordem(items, tabela_ordem, codigos_omitidos = "", info = ""){
		Global mariaDB, db
		try{
			mariaDB.Query(
				(JOIN
					"TRUNCATE TABLE " tabela_ordem
				))
		}catch e 
			MsgBox,16,Erro, % "Ocorreu um erro ao apagar todos os items da tabela de ordem `n" ExceptionDetail(e)
		try{
			mariaDB.Query(
				(JOIN
					"ALTER TABLE " tabela_ordem " ADD Omitir VARCHAR(60);"
				))
		}catch e 
			MsgBox,64 , Aviso, % "A estrutura da tabela foi alterada  `n"
		
		for each, item in items{
			record := {}
			record.Campos := item
			if(MatHasValue(codigos_omitidos, A_Index)){
				record.Omitir := 1	
			}else{
				record.Omitir := 0
			}
			mariaDB.Insert(record, tabela_ordem)
		}
		db.Log.insert_CRUD(info, "Alterado", "A ordem foi alterada!")
	}

	/*
		Insere um nome de campo
	*/
	incluir_campo(campo_nome, info){
		Global mariaDB, db
		; Coloca o campo no formato necessario
		campo_nome := this.format_field(campo_nome)
		if(campo_nome = ""){
			MsgBox, 16, Erro, %  "Existe um erro na formatacao do campo e nao sera incluido !"
			return
		}
		/*
			Pega a tabela de campos relacionada 
			com o modelo
		*/
		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1] 
		tabela_campo := this.get_tabela_campo_referencia(tabela1)
		if(this.campo_existe(campo_nome, tabela_campo)){
			MsgBox,16, Erro, % "O campo a ser inserido ja existia!" 
			return
		}
		/*
			-Insere o nome do novo campo na tabela de 
			campos
			
			-Cria a tabela de campos especifica
			
			-Insere o link na tabela de relacionamento 
			entre o modelo e a tabela de campo especifica
		*/
		try{
			mariaDB.Query(
				(JOIN
					"INSERT INTO " tabela_campo 
					" (Campos) VALUES ('" campo_nome "')"  				
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar o valor de campo na tabela `n" ExceptionDetail(e)

		StringReplace, campo_nome_sem_espaco, campo_nome, %A_Space%,,All

		tabela_campo_especifica := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] campo_nome_sem_espaco

		 ;Altera o tamanho da descricao completa e em ingles 
		this.alterar_tamanho_DC_DI(tabela_campo_especifica)
				;	MsgBox, 16,Erro, % "Houve um erro ao tentar alterar o tamanho da tabela de descricao em ingles `n" ExceptionDetail(e)
		
		try{
				mariaDB.Query(
					(JOIN
						"	CREATE TABLE IF NOT EXISTS " tabela_campo_especifica 
						" (Codigo VARCHAR(250), DC VARCHAR(65536), DR VARCHAR(250), DI VARCHAR(65536), "
						" PRIMARY KEY (Codigo)) "
					))
			}catch e
				MsgBox, 16,Erro, % "Um erro ocorreu ao tentar criar a tabela de Campos especificos `n" ExceptionDetail(e)
		
		record := {}
		record.tipo := campo_nome_sem_espaco me mt mf mm nm
		record.tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1] 
		record.tabela2 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] campo_nome_sem_espaco
		mariaDB.Insert(record, "reltable")	

		MsgBox,64, Sucesso, % "O campo foi inserido!"
		db.Log.insert_CRUD(info, "Criado", "O Campo " campo_nome " foi criado!")
	}

	alterar_tamanho_DC_DI(tabela_campo_especifica){
		Global mariaDB, db
		
		MsgBox, % " alterando tamanho da tabela! 3000" tabela_campo_especifica 
		try{
			;"ALTER TABLE " tabela_campo_especifica " CHANGE COLUMN DC DC" <colname> <colname> VARCHAR(65536);
			mariaDB.Query("ALTER TABLE "	tabela_campo_especifica " MODIFY DC VARCHAR(3000);")
		}catch e{
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar o valor de campo na tabela `n" ExceptionDetail(e)
		}
		;	MsgBox, 16,Erro, % "Houve um erro ao tentar alterar o tamanho da tabela de descricao completa `n" ExceptionDetail(e)

		;MsgBox, % " ira tentar alterar o tamanho da tabela descricao ingles!"
		try{
			mariaDB.Query("ALTER TABLE "	tabela_campo_especifica " MODIFY DI VARCHAR(3000);")
		}catch e{
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar o valor de campo na tabela `n" ExceptionDetail(e)
		}
	}
		
	insert_columns_in_table(columns, table) {
		Global 
		for, each, item in columns{
			column_number := A_Index + 4
			this.add_fiscal_column(column_number, table)
		} 
	}

	/*
		Insere os codigos na tabela de codigos
	*/
	inserir_codigo(tabela, valores){
		Global mariaDB

		if(tabela = "" || valores[1] = ""){
			MsgBox,16, Erro, % "A tabela de codigos ou os valores estavam em branco `n tabela de codigos: " tabela "`n valores " valores[1] 
			return
		}
		
		record := {}
		record.Codigos := valores[1]
		record.DR := valores[2]
		record.DC := valores[3]
		record.DI := valores[4]
		mariaDB.Insert(record, tabela)
	}

	remover_codigo(valor, tabela){
		Global mariaDB
		if(tabela = "" || valor = "")
			return

		try{
				mariaDB.Query(
				(JOIN 
					" DELETE FROM " tabela 
					" WHERE Codigos like '" valor "'"
				))	
			}catch e{ 
				MsgBox, 16, Erro, % " Erro ao tentar apagar o campo especifico " ExceptionDetail(e)
				return
		}
	}

	/*
		Incluir bloqueio
	*/
	incluir_bloqueio(value, bloq_table){
		Global mariaDB

		value := Trim(value)

		if(value = ""){
			MsgBox,16, Erro, % "O valor a ser inserido nao pode estar em branco !"
			return 
		}

		if(bloq_table = ""){
			MsgBox,16, Erro, % "A tabela de bloqueios estava em branco!"
			return
		}
		record := {}
		record.Codigos := value
		mariaDB.Insert(record, bloq_table)
	}

	/*
	 Cria a tabela de bloqueios
	*/
	create_tabela_bloqueio(tabela, info){
		Global mariaDB

		if(tabela = "" || info.empresa[2] = ""){
			MsgBox,16, Erro, % "Alguns items necessarios para criar a tabela de bloqueio estavam em branco!" 
			return
		} 

		try{
				mariaDB.Query(
					(JOIN 
						"	CREATE TABLE IF NOT EXISTS " tabela
						" (Codigos VARCHAR(250)) "
					))
				}catch e{
					MsgBox,16, Erro, % "Ocorreu um erro ao tentar criar a tabela de bloqueios!" 
				}
		
		if(!this.get_reference(prefixo, modelo_nome, modelo_mascara, tipo)){
			record := {}
			record.tipo := "Bloqueio"
			record.tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
			record.tabela2 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "Bloqueio"
			mariaDB.Insert(record, "reltable")
		}
	}

	/*
		Cria a tabela de prefixo
	*/
	create_tabela_prefixo(tabela_prefixo){
		Global mariaDB

		try{
				mariaDB.Query(
					(JOIN 
						"	CREATE TABLE IF NOT EXISTS " tabela_prefixo
						" (id MEDIUMINT NOT NULL AUTO_INCREMENT,"
						" Campos VARCHAR(250), "
						" PRIMARY KEY (id)) "
					))
			}catch e
				MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de prefixos `n" ExceptionDetail(e)
	}

	/*
		Insere um valor de campo especifico
	*/
	incluir_campo_esp(nome_campo, valores, info){
		Global mariaDB, db
		
		tabela_campos_especificos := get_tabela_campo_esp(nome_campo, info)
		
		if(this.valor_campo_existe(tabela_campos_especificos, valores.codigo)){
			MsgBox,16, Erro, % "O codigo a ser inserido ja existe na lista!"
			return
		}
		record := {}
		record.Codigo := Trim(valores.codigo)
		record.DR := Trim(valores.dr)
		record.DC := Trim(valores.dc)
		record.DI := Trim(valores.di)

		mariaDB.Insert(record, tabela_campos_especificos)
		db.Log.insert_CRUD(info, "Criado", "O item " valores.codigo " descricao resumida " valores.dr " foi incluido no campo " nome_campo)
	}

	excluir_campo_esp(codigo, tabela, info = ""){
		Global mariaDB, db

		if(codigo = "" || tabela = ""){
			MsgBox,16, Erro, % "O codigo selecionado ou a tabela estavam vaziios!" 
			return
		}
		
		try{
				mariaDB.Query(
				(JOIN 
					" DELETE FROM " tabela 
					" WHERE Codigo like '" codigo "'"
				))	
			}catch e 
				MsgBox, 16, Erro, % " Erro ao tentar apagar o campo especifico " ExceptionDetail(e)
		db.Log.insert_CRUD(info, "Removido", "O item " codigo " foi removido da tabela de campos " tabela)	
	}

	alterar_valores_campo(campo, valores, info, old_cod){
		Global mariaDB, db

		tabela := get_tabela_campo_esp(campo, info)
		this.alterar_tamanho_DC_DI(tabela)
		sql :=
		(JOIN 
			" UPDATE " tabela 
			" SET Codigo='" Trim(valores.codigo) "', DC='" Trim(valores.DC) "', DR='" Trim(valores.DR) "', DI='" Trim(valores.DI) "'"
			" WHERE Codigo='" old_cod "'"
		)	 
		
		try{
				mariaDB.Query(sql)
			}catch e 
				MsgBox, 16, Erro, % " Erro ao tentar alterar os valores " ExceptionDetail(e)
		db.Log.insert_CRUD(info, "Alterado", "O item " old_cod " foi alterado para codigo: " valores.codigo " descricao completa: " valores.DC " descricao resumida " valores.DR " descricao ingles " valores.DI)			
	}

	excluir_campo(campo_nome, info){
		Global mariaDB, db

		;MsgBox, % "campo nome " campo_nome " info empresa " info.empresa[1]
		
		/*
			-Deleta a entrada da tabela relacionada 
			 na tabela de relacionamento e armazena o seu valor.

			-verifica se nao existe mais nenhuma outra relacao com essa 
			tabela, caso nao exista, exclui a tabela.
		*/

		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
		tabela_campo_esp := get_tabela_campo_esp(campo_nome, info)
		tabela_campo := this.get_tabela_campo_referencia(tabela1) 
		
		;MsgBox, % "tabela campo esp " tabela_campo_esp
		;MsgBox, % "tabela campo " tabela_campo

		/*
			Deleta a entrada na tabela de campo
		*/
		try{
				mariaDB.Query(
				(JOIN 
					" DELETE FROM " tabela_campo 
					" WHERE Campos like '" campo_nome "'"
				))	
			}catch e 
				MsgBox, 16, Erro, % " Erro ao tentar apagar o campo " ExceptionDetail(e)

		/*
			Deleta a entrada na tabela de relacao
		*/
		StringReplace, campo_nome_sem_espaco, campo_nome,%A_Space%,,All
		try{
				mariaDB.Query(
				(JOIN 
					" DELETE FROM reltable "
					" WHERE tipo like '" campo_nome_sem_espaco "'"
					" AND tabela1 like '" tabela1 "'"
				))	
			}catch e 
				MsgBox, 16, Erro, % " Erro ao tentar apagar a entrada do campo na tabela de relacionamento " ExceptionDetail(e)

		/*
			Deleta a tabela especifica caso nao exista nenhuma outra 
			tabela relacionada com ela. 
		*/
		this.delete_if_no_related(tabela_campo_esp, tipo)
		db.Log.insert_CRUD(info, "Removido", "O campo " campo_nome " foi removido!")
	}

	/*
		Pega tabela de campo 
	*/
	get_tabela_campo_referencia(tabela1){
		Global mariaDB

		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like 'Campo' "
				" AND tabela1 like '" tabela1 "'"
			))
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}

	/*
		Pega a tabela de campo especifico
	*/
	get_tabela_campo_esp(tipo, tabela1){
		Global mariaDB

		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like '" tipo "' "
				" AND tabela1 like '" tabela1 "'"
			))
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}

	/*
		Altera a descricao geral de determinado modelo
	*/
	descricao_geral(descricao, descricao_ingles, info){
		Global mariaDB, db
		descricao := Trim(descricao), descricao_ingles := Trim(descricao_ingles) 
		if(info.modelo[2] = ""){
			MsgBox,16,Erro, % "Selecione um modelo antes de continuar!" 
			return
		}
		record := {}
		record.descricao := descricao "|" descricao_ingles
		table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "Desc"
		mariaDB.Query(
		(JOIN 
			" DELETE FROM " table " LIMIT 1"	
		))	
		mariaDB.Insert( record, table)
		MsgBox, 64, Sucesso, % "A descricao geral foi alterada!" 
		db.Log.insert_CRUD(info, "Alterado", "A descricao geral foi alterada")
	}

	inserir_valores_prefixo(tabela_prefixo, info){
		Global mariaDB

		values_tbi := [info.empresa[2], info.tipo[2], info.familia[2], info.subfamilia[2], info.modelo[2]]
		for each, value in values_tbi{
			if(value = "")
				continue
			record := {}
			record.Campos := value
			mariaDB.Insert(record, tabela_prefixo)
		}
	}
	/*
		Pega a descricao geral
	*/

	get_desc(info){
		Global mariaDB

		if(info.subfamilia[2] != ""){
			prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] 
		}else{
			prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2]
		}
		

		try{ 
			rs := mariaDB.OpenRecordSet("select descricao from " prefixo "Desc order by descricao asc limit 1;")
		}catch e{
			MsgBox,16, Erro, % "Ocorreu um erro ao tentar buscar a descricao!"
			return
		} 
		value := rs.descricao
		if(value = ""){
			value := info.familia[1] " " info.modelo[1] "|" info.familia[1] " " info.modelo[1]
		}

		rs.close()
		return value
	}

	/*
		Get tabela 
	/*

	/*
		Pega a referencia da tabela de modelos
		linkada com determinada familia
	*/
	get_reference(prefixo, modelo_nome, modelo_mascara, tipo){
		Global mariaDB
		
		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like '" tipo "' "
				" AND tabela1 like '" prefixo modelo_mascara modelo_nome "'"
			))
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}

	/*
		Verifica se um campo existe antes de inserir
	*/
	campo_existe(nome_campo, tabela){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT  Campos FROM " tabela
				" WHERE Campos LIKE '" nome_campo "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}	
	}

	/*
		Confere se o valor do campo existe
	*/
	valor_campo_existe(tabela, valor){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT  Codigo FROM " tabela
				" WHERE Codigo LIKE '" valor "'"
			))
		if(table.Rows.maxindex()){
			return True 
		}else{
			return False
		}		
	}
	/*
		deleta uma determinada tabela
		se nao existir mais nenhuma 
		tabela relacionada a ela
	*/
	delete_if_no_related(linked_table, tipo){
		Global mariaDB

		table := mariaDB.Query(
			(JOIN 
				" SELECT tipo,tabela1,tabela2 FROM reltable "
				" WHERE tipo LIKE '" tipo "' "
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
				MsgBox,16,Erro,% " Erro ao tentar deletar a tabela de " tipo " " linked_table "`n" ExceptionDetail(e)
		}
	}

	load_tables(info){
		Global mariaDB, db, camptable, octable, odctable, odrtable, oditable, codtable

		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
		camptable := db.get_reference("Campo", tabela1)
		octable := db.get_reference("oc", tabela1)
		odctable := db.get_reference("odc", tabela1)
		odrtable := db.get_reference("odr", tabela1)
		oditable := db.get_reference("odi", tabela1)
		codtable := db.get_reference("Codigo", tabela1)
	}

	format_field(field){
		return_field := Trim(field)
		_ilegal_char := 0
		IfInString, return_field, "
		{
			_ilegal_char := 1
		} 

		IfInString, return_field, '
		{
			_ilegal_char := 1
		}

		if(_ilegal_char = 1){
			MsgBox, 16, Erro, % "O campo nao pode conter aspas simples ou duplas!"
			return
		}
		return return_field
	}

	/*
		Linka uma tabela especifica
	*/
	link_specific_field(values, tabela1, info = ""){
		Global mariaDB, db
		if(this.exist_relation(values.tipo, tabela1)){
			this.delete_relation(values.tipo, tabela1)
		}
		record := {}
		record.tipo := values.tipo  	
		record.tabela1 := tabela1
		record.tabela2 := values.tabela2
		mariaDB.Insert(record, "reltable")
		db.Log.insert_CRUD(info, "Linkagem", "A tabela " tabela1 " foi linkada a tabela " values.tabela2)
	}

	link_models_table(values, tabela1, info){
		Global mariaDB, db
		if(this.exist_relation(values.tipo, tabela1)){
			this.delete_relation(values.tipo, tabela1)
		}
		record := {}
		record.tipo := values.tipo  	
		record.tabela1 := tabela1
		record.tabela2 := values.tabela2
		models_array := db.load_table_in_array(values.tabela2)
		this.create_models(models_array, info) 
		mariaDB.Insert(record, "reltable")	
		db.Log.insert_CRUD(info, "Linkagem", "A tabela de modelos " tabela1 " foi linkada a tabela " values.tabela2)
	}

	exist_relation(tipo, tabela1){
		Global mariaDB
		table := mariaDB.Query(
			(JOIN 
				" SELECT tipo,tabela1,tabela2 FROM reltable "
				" WHERE tipo LIKE '" tipo "' "
				" AND tabela1 LIKE '" tabela1 "'"
			))
		linked := ""
		columnCount := table.Columns.Count()
		for each, row in table.Rows{
			Loop, % columnCount
				linked .= row[A_index] "`n"
		} 
		
		if(linked != ""){
			return 1
		}else{
			return 0
		}
	}

	delete_relation(tipo, tabela1){
		Global mariaDB
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable "
				" WHERE tipo like '" tipo "'"
				" AND tabela1 like '" tabela1 "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar o valor da tabela de referencia " ExceptionDetail(e)
	}

	create_models(models, info){
		Global mariaDB, db

		prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2]
		for, each, value in models{
			name := models[A_Index, 1]
			code := models[A_Index, 2]
			if(name = "" || code = "")
				Continue
			this.incluir(name, code, prefixo, 1)
		} 
	}

	model_exists(table_desc){
		Global mariaDB
		MsgBox, % "a tabela de descricao existe ? " table_desc 
		table := mariaDB.Query(
			(JOIN 
				" SELECT descricao FROM " table_desc
			))
		exists := ""
		for each, row in table.Rows{
			Loop, % columnCount
				exists .= row[A_index] "`n"
		} 
		if(exists != ""){
			return 1
		}else{
			return 0
		}
	}

	reset_table_relation(info, native_table, field_name){
		Global mariaDB, db

		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
		try{
			mariaDB.Query(
			(JOIN 
				" DELETE FROM reltable" 
				" WHERE tipo like '" field_name "' And tabela1 like '" tabela1 "'"
			))	
		}catch e 
			MsgBox,16,Erro,% " Erro ao tentar deletar a referencia da tabela `n " ExceptionDetail(e)
		
		record := {}
		record.tipo := field_name
		record.tabela1 := tabela1
		record.tabela2 := native_table
		mariaDB.Insert(record, "reltable")

		MsgBox, 64, Sucesso, % "A linkagem da tabela retornou para o seu valor padrao!"
		db.Log.insert_CRUD(info, "Removido", "A tabela " tabela1 " foi linkada a tabela " values.tabela2)
	}

	insert_reference(codigo1, codigo2){
		Global db 
		if(codigo1 = "" || codigo2 = "")
			throw { what: "Um dos items a serem referenciados estava em branco!", file: A_LineFile, line: A_LineNumber }		
		sql := 
			(JOIN
				" codigo1 LIKE '" codigo1 "' OR codigo2 LIKE '" codigo1 "'"
				" OR codigo1 LIKE '" codigo2 "' OR codigo2 LIKE '" codigo2 "'"  
			)
		if(!db.check_if_exists(sql, "reference_table")){
			this.insert_new_reference(codigo1, codigo2)	
		}else{
			sql := 
				(JOIN 
					" codigo1 LIKE '" codigo1 "' OR codigo2 LIKE '" codigo1 "' "
					" OR codigo1 LIKE '" codigo2 "' OR codigo2 LIKE '" codigo2 "'"
				)
			db.delete_items_where(sql, "reference_table")
			this.insert_new_reference(codigo1, codigo2)
		}
	}

	insert_new_reference(codigo1, codigo2){
		Global db
		record := {}
		record.codigo1 := codigo1
		record.codigo2 := codigo2
		db.insert_record(record, "reference_table")
	}

	get_product_reference(codigo) {
		Global db
		sql := 
			(JOIN 
				" codigo1 LIKE '" codigo "' OR codigo2 LIKE '" codigo "'"
			)
		items := db.find_items_where(sql, "reference_table")
		if(items[1, 1] != codigo) {
			return_value := items[1, 1]
		}else if(items[1, 2] != codigo) {
			return_value := items[1, 2]
		}
		return return_value
	}

	get_model_table_with_reference(model_table) {
		Global db
		table := db.load_table_in_array(model_table)	
		for, each, item in table{
			if(table[A_Index, 1] = "")
				Break
			table[A_Index, 3] := db.Modelo.get_product_reference(table[A_Index, 1]) 
		} 
		return table
	}

	insert_fiscal_value(code, number, value, table){
		Global db
		column_name := this.get_column_name(number)
		this.update_fiscal_info(code, column_name, value, table)	
	}

	add_fiscal_column(number, table) {
		Global mariaDB
		column_name := this.get_column_name(number)
		try{
			mariaDB.Query(" ALTER TABLE " table " ADD COLUMN " column_name " TEXT;")
		}catch e{
		}
		return column_name
	}

	get_column_name(number) {
		if(number = 5) {
			column_name := "ncm"
		}else if(number = 6) {
			column_name := "um"
		}else if(number = 7) {
			column_name := "origem"
		}else if(number = 8) {
			column_name := "conta"
		}else if(number = 9) {
			column_name := "tipo"
		}else if(number = 10) {
			column_name := "grupo"
		}else if(number = 11) {
			column_name := "ipi"
		}else if(number = 12) {
			column_name := "locpad"
		}
		return column_name 
	}

	update_fiscal_info(code, column, value, table){
		Global mariaDB
		sql :=
		(JOIN 
			" UPDATE " table 
			" SET " column "='" value "' "
			" WHERE Codigos='" code "'"
		)	
		try{
			mariaDB.Query(sql)
		}catch e 
			MsgBox, 16, Erro, % " Erro ao tentar atualizar os valores fiscais " ExceptionDetail(e)
	}
}