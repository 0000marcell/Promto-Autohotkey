class PromtoSQL{
	
	/*
		Conecta no DB
	*/
	__New(databaseType,connectionString){
		/*
		 Tenta Conectar
		*/
		try {
			Global mariaDB := DBA.DataBaseFactory.OpenDataBase(databaseType, connectionString)
		} catch e {
			MsgBox,16, Error, % "A conexao nao foi estabelecida. Verifique os parametros da conexao!`n`n" ExceptionDetail(e)
		}
		
		/*
			Verifica se existe uma estrutura
			de dados coerente com o programa
		*/
		this.schema()
	}
	
	/*
		Insere um nova conexao
	*/
	inserir_conexao(name, string, type){
		Global
		if(name = "" || string = "" || type = ""){
			MsgBox,16, Erro, % "Um dos valores necessarios para inserir `n uma nova conexao estava em branco" 
			return
		}
		record := {}
		record.name := name	
		record.connection := string 
		record.type := type
		mariaDB.Insert(record, "connections")
	}

	/*
		retorna uma lista com todos os valores de determinada query
		where_statement item like 'codigo'
	*/
	find_items_where(where_statement, table){
		Global mariaDB  
		items := this.find_items("SELECT * FROM " table " WHERE " where_statement)
		return items
	}

	/*
		Pega todos os items 
		de determinada tabela
	*/
	find_all(table){
		Global mariaDB  
		items := this.find_items("SELECT * FROM " table)
		return items	
	}

	/*
		Find items
	*/
	find_items(sql){
		Global mariaDB  
		try{
				rs := mariaDB.OpenRecordSet(sql)		
		}catch e{
			throw { what: "Occoreu um erro ao buscar os valores! `n " sql, file: A_LineFile, line: A_LineNumber }		
			return
		}
		columns := rs.getColumnNames()
		columnCount := columns.Count()
		return_value := []
		while(!rs.EOF){	
			r := A_Index
			Loop, % columnCount{
				return_value[r, A_Index] := rs[A_Index]
			}
			rs.MoveNext()
		}
		rs.close()
		return return_value
	}

	update_items_set_where(set, where, table) {
		Global mariaDB
		try{
			sql := "UPDATE " table " SET " set " WHERE " where
			mariaDB.Query(sql)
		}catch e {
			throw { what: "Erro ao tentar alterar os valores da tabela: " table "`n " set " `n" where "`n " ExceptionDetail(e), file: A_LineFile, line: A_LineNumber }		
		}
	}

	delete_items_where(where_statement, table){
		Global mariaDB
		try{
			mariaDB.Query("DELETE FROM " table " WHERE " where_statement)
		}catch e {
			throw { what: "Erro ao tentar deletar o valor da tabela " table "`n " where_statement "`n " ExceptionDetail(e), file: A_LineFile, line: A_LineNumber }		
		}
	}

	drop_table(table){
		Global mariaDB
		try{
			mariaDB.Query("DROP TABLE " table)	
		}catch e{
			throw { what: " Erro ao tentar deletar a tabela " table "`n" ExceptionDetail(e), file: A_LineFile, line: A_LineNumber }		
		} 
	}

	/*
		Abre um record set e retorna os valores
		de determinada tabela em um hash com o nome do 
		campo e o valor value.name := name
	*/
	query_table(table, field_value, columns){
		Global mariaDB 
		try{
				rs := mariaDB.OpenRecordSet("SELECT * FROM " table " WHERE " field_value[1] " LIKE '" field_value[2] "'")		
			}catch e{
				MsgBox, % "Ocorreu um erro ao buscar o valor do campo!"
				return
		}
		return_value := []
		for, each, value in columns{
			return_value[value] := rs[value]
		}
		rs.close()
		return return_value 
	}

	schema(){
		Global mariaDB, global_image_path
		/*
			Verifica se as tabelas 
			empresas, reltable, imagetable, connections
			existem
		*/
		/*
			empresas
		*/
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS empresas "
					" (Empresas VARCHAR(250), "
					" Mascara VARCHAR(250), "
					" PRIMARY KEY (Mascara))"
				))
		}catch e 
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela empresas `n" ExceptionDetail(e)
		
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS estruturas "
					" (item VARCHAR(250), "
					" componente VARCHAR(250), "
					" quantidade VARCHAR(250)) "
				))
		}catch e 
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de estruturas `n" ExceptionDetail(e)
		
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS reltable "
					" (tipo VARCHAR(250), "
					" tabela1 VARCHAR(250), "
					" tabela2 VARCHAR(250)) "				
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela reltable `n" ExceptionDetail(e)

		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS imagetable "
					" (Id MEDIUMINT NOT NULL AUTO_INCREMENT, "
					" Name VARCHAR(250), "
					" PRIMARY KEY (Id))"
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela imagetable `n" ExceptionDetail(e)

		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS connections "
					" (name VARCHAR(250), "
					" connection VARCHAR(250),"
					" type VARCHAR(250))"
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela connections `n" ExceptionDetail(e)

		/*
			TCONTA MACCOMEVAP
		*/
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS TCONTA_MACCOMEVAP "
					" (valor VARCHAR(250), "
					" descricao VARCHAR(250))"
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de contas MACCOMEVAP `n" ExceptionDetail(e)

		/*
			LOCPAD MACCOMEVAP
		*/
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS LOCPAD_MACCOMEVAP "
					" (valor VARCHAR(250), "
					" descricao VARCHAR(250))"
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela connections `n" ExceptionDetail(e)

		/*
			Usuarios
		*/
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS usuarios "
					" (Nome VARCHAR(250), "
					" Senha VARCHAR(250), "
					" Privilegio VARCHAR(250), "
					" PRIMARY KEY (Nome))"
				))
		}catch e 
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de usuarios `n" ExceptionDetail(e)

		;try{
		;	mariaDB.Query(
		;		(JOIN
		;			"	Drop table certificado_verificacao "
		;		))
		;}catch e 
		;	MsgBox,16,Erro, % "Ocorreu um erro ao apagar a tabela de verificacao de certificados `n" ExceptionDetail(e)
		

		/*
			Certificacao
			Tabela usada para verificar conferencia com certificacao
		*/
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS certificado_verificacao "
					"(Usuario VARCHAR(250), "
					" Data VARCHAR(250), "
					" Hora VARCHAR(250), "
					" Prodkey VARCHAR(250), "
					" PRIMARY KEY (Prodkey))"
				))
		}catch e 
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de verificacao de certificados `n" ExceptionDetail(e)
		
		/*
			Certificados
		*/
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS certificados "
					"( modelo VARCHAR(250), "
					"  comp_info VARCHAR(250), "
					" Usuario VARCHAR(250), "
					" data_emissao VARCHAR(250), "
					" data_vencimento VARCHAR(250), "
					" caminho_arquivo VARCHAR(250), "
					" PRIMARY KEY (modelo))"
				))
		}catch e 
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de certificados `n" ExceptionDetail(e)
		

		/*
			Log
		*/
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS log "
					"(Id MEDIUMINT NOT NULL AUTO_INCREMENT,"
					" Usuario VARCHAR(250), "
					" Item VARCHAR(250), "
					" Data VARCHAR(250), "
					" Hora VARCHAR(250), "
					" Mensagem VARCHAR(250), "
					" Validade VARCHAR(250), "
					" Prodkey VARCHAR(250), "
					" PRIMARY KEY (id))"
				))
		}catch e 
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de log `n" ExceptionDetail(e)
		
		/*
			Status
		*/
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS status "
					"(Id MEDIUMINT NOT NULL AUTO_INCREMENT,"
					" Usuario VARCHAR(250), "
					" Status VARCHAR(250), "
					" Mensagem VARCHAR(250), "
					" Prodkey VARCHAR(250), "
					" PRIMARY KEY (id))"
				))
		}catch e 
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela de status `n" ExceptionDetail(e)
		

		/*
			CRUD - log
		*/
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS CRUD "
					"(Id MEDIUMINT NOT NULL AUTO_INCREMENT,"
					" Usuario VARCHAR(250), "
					" Tipo VARCHAR(250), "
					" Item VARCHAR(250), "
					" Data VARCHAR(250), "
					" Hora VARCHAR(250), "
					" Mensagem VARCHAR(250), "
					" Prodkey VARCHAR(250), "
					" PRIMARY KEY (id))"
				))
		}catch e 
			MsgBox, 16, Erro, % "Um erro ocorreu ao tentar criar a tabela de CRUD `n" ExceptionDetail(e)
		

		/*
			reference_table 		
		*/
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS reference_table "
					"(codigo1 VARCHAR(250), "
					" codigo2 VARCHAR(250), "
					" PRIMARY KEY (codigo1))"
				))
		}catch e 
			MsgBox, 16, Erro, % "Um erro ocorreu ao tentar criar a tabela de referencia `n" ExceptionDetail(e)
		
	}

	/*
		Carrega uma determinada tabela 
		em um determinado combobox ou dropdownlist
	*/
	load_combobox(control , tabela){
		Global mariaDB

		window := control.window
		cbcontrol := control.combobox
		list := ""
		Gui, %window%:default 
		GuiControl,, %cbcontrol%,|
		table_items := this.load_table_in_array(tabela)
		loop, % table_items.maxindex(){
			item := table_items[A_Index,2]
			if(A_Index = 1){
				list.= item
			}else{
				list.= "|" item
			}
		}
		GuiControl,, %cbcontrol%, %list%
	}

	load_codigos_combobox(tabela){
		Global mariaDB
		window := "M"
		cbcontrol := "combocodes"
		list := ""
		Gui, %window%:default 
		GuiControl,, %cbcontrol%,|
		table_items := this.load_table_in_array(tabela)
		loop, % table_items.maxindex(){
			codigo := table_items[A_Index,1]
			dr := table_items[A_Index,3]
			if(A_Index = 1){
				list.= codigo " >> " dr
			}else{
				list.= "|" codigo " >> " dr
			}
		}
		GuiControl,, %cbcontrol%, %list%
	}

	/*
		Deleta todos os items da tabela
	*/
	clean_table(tabela){
		Global mariaDB

		try{
			mariaDB.Query(
				(JOIN
					"TRUNCATE TABLE " tabela
				))
		}catch e{
			
		}
	}

	/*
		Altera a tabela de codigos
	*/
	change_columns_to_text(tabela){
		Global mariaDB

		try{
			mariaDB.Query("ALTER TABLE "	tabela " MODIFY DR TEXT;")
		}catch e{
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar alterar o valor do campo na tabela DR`n" ExceptionDetail(e)
		}


		try{
			mariaDB.Query("ALTER TABLE "	tabela " MODIFY DC TEXT;")
		}catch e{
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar alterar o valor do campo na tabela DC`n" ExceptionDetail(e)
		}


		try{
			mariaDB.Query("ALTER TABLE "	tabela " MODIFY DI TEXT;")
		}catch e{
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar alterar o valor do campo na tabela DI`n" ExceptionDetail(e)
		}
	}

	/*
		Remove os subitems de 
		determinado item
	*/
	remove_subitems(nivel, mask, info, subfamily = 0, prev_mask = ""){
		Global db

		nt := this.get_next_table(nivel, mask, subfamily, prev_mask)
		items := this.find_all(nt.next_table)
		for, each, item in items{ 
			if(nt.next_nivel = "modelo"){
				info := this.get_unique_info()
				db.Modelo.excluir(items[A_Index, 1], items[A_Index, 2], info, 0)
				Continue
			}
			hash := {name: items[A_Index, 1], mask: items[A_Index, 2]}
			this.remove_subitems(nt.next_nivel, mask items[A_Index, 2], info, items[A_Index, 3], hash)
			this.remove_item(nt.next_nivel, items[A_Index, 1], items[A_Index, 2])
		}
	}

	remove_item(nivel, nome, mascara){
		Global db
		info := this.get_unique_info()
		if(nivel = "empresa"){
			db.Empresa.excluir(nome, mascara, 0)
		}else if(nivel = "aba"){
			db.Tipo.excluir(nome, mascara, info, 0)
		}else if(nivel = "familia"){
			db.Familia.excluir(nome, mascara, info, 0)
		}else if(nivel = "subfamilia"){
			db.Subfamilia.excluir(nome, mascara, info, 0)
		}
	}

	/*
		Essa funcao nao considera LINK
		Pega a proxima tabela e a 
		do determinado item
	*/
	get_next_table(nivel, prefix, subfamily, prev_mask = ""){
		Global mariaDB
		if(nivel = "empresa"){
			nt := {next_table: prefix "aba", next_nivel: "aba"} 
		}else if(nivel = "aba"){ 
			nt := {next_table: prefix "familia", next_nivel: "familia"}
		}else if(nivel = "familia"){
			nt := this.check_if_have_subfamily(subfamily, prefix)
		}else if(nivel = "subfamilia"){
			nt := {next_table: prefix "modelo", next_nivel: "modelo"}
		}
		this.update_unique_info(nivel, prev_mask)
		return nt
	}

	check_if_have_subfamily(subfamily, prefix){
		if(subfamily){
			nt := {next_table: prefix "subfamilia", next_nivel: "subfamilia"}
		}else{
			nt := {next_table: prefix "modelo", next_nivel: "modelo"}
		}
		return nt
	}

	
	init_unique_info(){
		Global 
		unique_info := get_item_info("M", "MODlv")
	}
	/*
		Usada para atualizar o info 
		quando precisa deletar items que estao em nivel inferior a selecao
	*/
	update_unique_info(type, hash){
		Global 
		if(hash.name = "")
			return
		if(type = "aba"){
			unique_info.tipo[1] := hash.name, unique_info.tipo[2] := hash.mask
		}else if(type = "familia"){
			unique_info.familia[1] := hash.name, unique_info.familia[2] := hash.mask
		}else if(type = "subfamilia"){
			unique_info.subfamilia[1] := hash.name, unique_info.subfamilia[2] := hash.mask
		}
	}

	get_unique_info(){
		Global 
		return unique_info
	}

	/*
		Verifica se determinado item existe ou nao 
		e retorna true ou false
	*/
	exists(sql, table){
		Global db
		items := db.find_items_where(sql, table)
		if(items[1, 1] != ""){
			throw { what: "O item a ser inserido ja existe na tabela " table , file: A_LineFile, line: A_LineNumber }
		}
		return
	}

	check_if_exists(sql, table){
		Global db

		items := db.find_items_where(sql, table)
		if(items[1, 1] != ""){	
			return 1
		}else{
			return 0
		}	
	}


	/*
		Retorna determinada 
		tabela em um array
	*/
	load_table_in_array(table){
		Global mariaDB

		if(table = ""){
			MsgBox, % "Passe o nome de uma tabela para carregar em um array!"
			return  
		}
		if(!this.table_exists(table)){
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

	/*
		Funcao que carrega a string da
		treeview da janela principal
	*/
	get_treeview(table, x, nivel, masc){
		Global mariaDB, ETF_TVSTRING, field, ETF_hashmask  

		x += 1, nivel .= "`t"
		For each, value in list := this.get_values("*", table){
			if(field[x] = ""){
				Break
			}
			ETF_TVSTRING .= "`n" . nivel . list[A_Index, 1] . " > " . list[A_Index, 2]		
			ETF_hashmask[list[A_Index, 1]] := list[A_Index, 2] 	
			new_table := this.get_reference(field[x], masc . list[A_Index, 1])
			if(new_table)
				this.get_treeview(new_table, x, nivel, masc . list[A_Index, 2])
		}
		return
	}
	
	/*
		Verifica se uma determinada tabela ja existe
	*/
	table_exists(tabela){
		Global mariaDB

		try{
			mariaDB.Query(
				(JOIN
					"	SELECT * FROM " tabela
				))
			return 1
		}catch e 
			return 0
	}

	/*
	 Funcao que retorna um array de valores 
	 da query no formato value[r,c]
	*/
	get_values(field,table){
		Global mariaDB

		SQL:="SELECT " . field . " FROM " . table
		try {
			mariaDB.resultSet := mariaDB.OpenRecordSet(SQL)	
		} catch e
			MsgBox,16, Error, % "Erro ao ler a tabela " table ".`n`n" ExceptionDetail(e) ;state := "!# " e.What " " e.Message
		
		columns := mariaDB.resultSet.getColumnNames()
		columnCount := columns.Count()
		r := 1
		c := 1
		values := object()
		while(!mariaDB.resultSet.EOF){	
			Loop, % columnCount{
				if(mariaDB.resultSet[A_Index] != ""){
					values[r,c] := mariaDB.resultSet[A_Index]	
					c += 1
				}
			}
			r += 1
			c := 1
			mariaDB.resultSet.MoveNext()
		}
		mariaDB.resultSet.close()
		return values 
	}

	/*
		Carrega a lista de modelos em determinada 
		Listview 
	*/
	load_lv(window_name, lv_name, table, modifycol = 0){
		Global mariaDB, db

		if(window_name = "" || lv_name = ""){
			MsgBox, % "O handle da janela e o nome do listview sao obrigatorios!!!"
			return  
		}

		try{
			rs := mariaDB.OpenRecordSet("SELECT * FROM " table)	
		}catch e{
			return 
		} 
		
		Gui, %window_name%:default 
		Gui, listview, %lv_name%
		LV_Delete()
		GuiControl,-ReDraw,%lv_name%
		Loop, % LV_GetCount("Column")
	   		;LV_DeleteCol(1)
		columns := rs.getColumnNames()
		columnCount := columns.Count()
		for each, value in columns{
			;LV_InsertCol(A_Index, "", value)
		}
		while(!rs.EOF){	
			rowNum := LV_Add("","")
			Loop, % columnCount{
				LV_Modify(rowNum, "Col" . A_index, rs[A_index])
			}
			rs.MoveNext()
		}
		if(modifycol = 1){
			LV_ModifyCol(1), LV_ModifyCol(2), LV_ModifyCol(3), LV_ModifyCol(4), LV_ModifyCol(5)		
		}
		GuiControl,+ReDraw,%lv_name%
		rs.close() 
	}

	/*
		Conserta todas as ordems
	*/
	correct_todas_ordems(info){
		Global mariaDB,db

		for, each, tipo in ["prefixo", "oc", "odc", "odr", "odi"]{
			tabela_ordem := get_tabela_ordem(tipo, info) 
			db.correct_tabela_ordem(tipo, info)
		}
	}

	create_table(table_name, fields){
		Global mariaDB
		sql := " CREATE TABLE IF NOT EXISTS " table_name " " fields
		try{
			mariaDB.Query(sql)
		}catch e{
			throw { what: "Um erro ocorreu ao tentar criar a tabela ", file: A_LineFile, line: A_LineNumber}	
		}
	}

	/*
		Insere os novos campos na tabela de prefixo
	*/
	correct_tabela_ordem(tipo, info){
		Global mariaDB,db

		tabela_prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] tipo

		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
		
		tabela_campos := this.get_reference("Campo", tabela1) 
		
		/*
			Cria a tabela caso ela nao exista!
		*/	
		;MsgBox, % "ira testar se a tabela existe " tabela_prefixo 
		if(!this.table_exists(tabela_prefixo)){
			;MsgBox, % " A tabela de prefixos nao existia e sera criada."
			db.Modelo.create_tabela_prefixo(tabela_prefixo)
			
			/*
				Se o tipo for igual ao prefixo insere os valores de 
				prefixo
			*/
			if(tipo = "prefixo"){
				db.Modelo.inserir_valores_prefixo(tabela_prefixo, info)
				return
			}
		}

		if(tipo = "prefixo")
			return
		

		prefixos := []
		prefixos := this.load_table_in_array(tabela_prefixo)
		campos := 	this.load_table_in_array(tabela_campos)

		prefixos := singledim_array(prefixos, 2)
		campos := singledim_array(campos, 2)

		for each,campo in campos{
			if(!objHasValue(prefixos, campo)){
				prefixos.insert(campo)
			}
		}

		/*
			Depois retira os item do array de prefixos 
			que nao existem no array de campos
		*/
		for each,prefixo in prefixos{
			if(!objHasValue(campos,prefixo)){
				deletefromarray(prefixo, prefixos)
			}
		}


		try{
			mariaDB.Query(
				(JOIN
					"TRUNCATE TABLE " tabela_prefixo
				))
		}catch e 
			MsgBox,16,Erro, % "Ocorreu um erro ao apagar todos os items da tabela de ordem `n" ExceptionDetail(e)
		
		for each,prefixo in prefixos{
			record := {}
			record.Campos := prefixo	
			mariaDB.Insert(record, tabela_prefixo)
		}
	}	

	/*
		Cria uma tabela de valores
		utilizada na insercao do dbex
	*/
	create_val_table(table){
		Global mariaDB

		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS " table 
					" (valor VARCHAR(250), "
					" descricao VARCHAR(250))"
				))
		}catch e 
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela valores dbex `n" ExceptionDetail(e)
	}

	insert_record(record, table){
		Global mariaDB
		try{
			mariaDB.Insert(record, table)
		}catch e{
			throw { what: "Um erro ocorreu ao tentar inserir valores na tabela " table, file: A_LineFile, line: A_LineNumber }		
		}
	}

	/*
		Insere um valor na tabela de valores 
		do db ex
	*/
	insert_val(valor, descricao, tabela){
		Global mariaDB

		if(valor = ""){
			MsgBox, 16, Erro, % "O valor a ser inserido nao pode estar em branco!" 
			return
		} 

		if(descricao = ""){
			MsgBox, 16, Erro, % "A descricao a ser inserida nao pode estar em branco!" 
			return
		}

		try{
			record := {}
			record.valor := valor	
			record.descricao := descricao 
			mariaDB.Insert(record, tabela)
		}catch e{
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar inserir um valor na tabela de db ex `n" ExceptionDetail(e)
		}
	}

	/*
		Verifica se determinada familia 
		tem subfamilia
	*/
	have_subfamilia(tabela1){
		Global db
		items := db.find_items_where(" tipo like 'Subfamilia' AND tabela1 like '" tabela1 "'", "reltable")
		if(items[1, 1] != ""){
			return 1
		}else{
			return 0
		}
	}

	get_reference(tipo, tabela1){
		Global mariaDB
		try{
			rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like '" tipo "' "
				" AND tabela1 like '" tabela1 "'"
			))
		}catch e{
			throw { what: "Erro ao pegar a referencia da tabela tipo: " tipo "`n tabela1: " tabela1, file: A_LineFile, line: A_LineNumber }		
		}
		reference_table := rs.tabela2
		rs.close()
		return reference_table
	}

	/*
		carrega uma lista de subitems em determinado item
		de uma treeview
	*/
	load_subitems_tv(id, table){
		Global S_ETF_hashmask

		if(TV_GetChild(id))
			return 	

		valores := this.load_table_in_array(table)

		for each, value in valores{
			if(valores[A_Index, 1] = "")
				continue
			TV_Add(valores[A_Index, 1], id)	
			S_ETF_hashmask[valores[A_Index, 1]] := valores[A_Index, 2] 
		} 
	}

	/*
		Carrega uma estrutura em determinada treeview
	*/
	load_estrut(window, treeview, codigo){
		Global tvstring

		tvstring := "", nivel := "", ownercode := "", prev_inserted := ""
		this.get_tv_string(codigo, "")
	

		TvDefinition =
			(
				%tvstring%
			)
		Gui, %window%:default
		Gui, Treeview, %treeview%
		TV_Delete()
		CreateTreeView(TvDefinition)
	}

	/*
		Carrega a string com a estrutura do 
		determinado item
	*/
	get_tv_string(item, nivel, ownercode = "", semUN = 1, quantidade = "", prev_inserted = ""){
		Global tvstring
 		
		if item =
			return
		nivel .= "`t"

		table := this.get_estrut_items(item)
		
		if(table[1, 2] = ""){
			if(ownercode != ""){
					if(ownercode = item)
						return
					descricao_item := this.get_desc_from_item(item)
					IfNotInString,%ownercode%,%item%
				 	{
				 		%ownercode% .= "`n" item . descricao_item 
				 		if(semUN = 1){
				 			tvstring .= "`n" . nivel . item . descricao_item
				 		}else{
				 			tvstring .= "`n" . nivel . item . descricao_item . "|UN:" quantidade
				 		} 
				 	}
			}
		}
		for each, value in table{
			table_item := table[A_Index, 1]
			table_componente := table[A_Index, 2]
			table_quantidade := table[A_Index, 3]
			if(table_item = "")
				Continue
			if(ownercode != ""){
				
					if(ownercode = table_item)
						return
					descricao_item := this.get_desc_from_item(table_item)
					IfNotInString,%ownercode%,%table_item%
				 	{
				 		%ownercode% .= "`n" table_item . descricao_item 
				 		if(semUN = 1){
				 			tvstring .= "`n" . nivel . table_item . descricao_item
				 		}else{
				 			tvstring .= "`n" . nivel . table_item . descricao_item . "|UN:" quantidade
				 		} 
				 	}
			}else{
				descricao_item := this.get_desc_from_item(table_item)
				IfNotInString, maincodes, %table_item%
			 	{
					maincodes .= "`n" table_item
					if(semUN=1)
						tvstring .= "`n" . nivel . table_item
					else 
						tvstring .= "`n" . nivel . table_item . "|UN:" quantidade
			 	}
			}
			this.get_tv_string(table_componente, nivel, table_item, semUN, table_quantidade, table_componente)
		}
	}

	/*
		Retorna a lista de subitems imediatos do item passado
	*/
	get_estrut_items(item){
		Global mariaDB

		return_value := []
		return_value := this.find_items_where("item like '" item "'", "estruturas")
		return return_value
	}

	add_item_strut_with_owner(item, nivel, ownercode, semUN = 1){
		Global 

		if(ownercode = item)
			return
		;Funcao que busca a descricao do item
		owner_to_return := ""
		descricao_item := this.get_desc_from_item(item)
		IfNotInString,%ownercode%,%item%
	 	{
	 		%ownercode% .= "`n" item . descricao_item 
	 		if(semUN = 1){
	 			tvstring .= "`n" . nivel . item . descricao_item
	 		}else{
	 			tvstring .= "`n" . nivel . item . descricao_item . "|UN:" quantidade
	 		} 
	 			
	 		owner_to_return := ownercode
	 	}
	 	if(owner_to_return != ""){
	 		return owner_to_return
	 	}
	}

	add_item_strut(item, nivel,  semUN = 1){
		Global 
		;Funcao que busca a descricao do item
		descricao_item := this.get_desc_from_item(item)
		IfNotInString, maincodes, %item%
	 	{
			maincodes .= "`n" item
			if(semUN=1)
				tvstring .= "`n" . nivel . item
			else 
				tvstring .= "`n" . nivel . item . "|UN:" quantidade
	 	}
	}

	get_desc_from_item(item){
		/*
			Fazer todas as tabelas de codigos do reltable
		*/
	}

	/*
		Retorna o prefixo do determinado item 
		pela ordem feita pelo usuario
	*/
	get_ordened_prefix(info){
		table_prefix := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "prefixo"
		table := this.load_table_in_array(table_prefix)
		prefix := []
		i := 0
		for each, value in table{
			i++
			if(table[A_Index, 2] = "" or table[A_Index, 3] = 1){
				i--
				Continue
			}
			prefix[i] := table[A_Index, 2] 
		}
		return prefix
	}
		
	#include lib\promto_sql_mariadb_empresa.ahk
	#include lib\promto_sql_mariadb_tipo.ahk
	#include lib\promto_sql_mariadb_familia.ahk
	#include lib\promto_sql_mariadb_subfamilia.ahk
	#include lib\promto_sql_mariadb_modelo.ahk
	#include lib\promto_sql_mariadb_campo.ahk
	#include lib\promto_sql_mariadb_imagem.ahk
	#include lib\promto_sql_mariadb_estrutura.ahk
	#include lib\promto_sql_mariadb_usuario.ahk
	#include lib\promto_sql_mariadb_log.ahk
	#include lib\promto_sql_mariadb_status.ahk
	#include lib\promto_sql_mariadb_certificado.ahk
}