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
		Abre um record set e retorna os valores
		de determinada tabela em um hash com o nome do 
		campo e o valor value.name := name
	*/
	query_table(table, field_value, columns){
		Global mariaDB 

		try{
				;MsgBox, % "SELECT * FROM " table " WHERE " field_value[1] " LIKE '" field_value[2] "'"
				rs := mariaDB.OpenRecordSet("SELECT * FROM " table " WHERE " field_value[1] " LIKE '" field_value[2] "'")		
			}catch e{
				MsgBox, % "Ocorreu um erro ao buscar o valor do campo!"
				return
		}
		
		return_value := []
		
		for, each, value in columns{
			;MsgBox, % "nome da coluna : " value
			;MsgBox, % "valor do record set " rs[value]
			return_value[value] := rs[value]
		}
		rs.close()
		return return_value 
	}

	schema(){
		Global mariaDB

		/*
			Verifica se as tabelas 
			empresas, reltable, imagetable, connections
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
		

		/*
			reltable
		*/
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

		/*
			imagetable
		*/
		try{
			mariaDB.Query(
				(JOIN
					"	CREATE TABLE IF NOT EXISTS imagetable "
					" (Name VARCHAR(250))"
				))
		}catch e
			MsgBox,16,Erro, % "Um erro ocorreu ao tentar criar a tabela imagetable `n" ExceptionDetail(e)

		/*
		connections
		*/
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
		}catch e 
			MsgBox,16,Erro, % "Ocorreu um erro ao apagar todos os items da tabela " tabela " `n" ExceptionDetail(e)		
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
		Global mariaDB,ETF_TVSTRING, field, ETF_hashmask  

		x += 1, nivel .= "`t"
		For each, value in list := this.get_values("*", table){
			if(field[x] = ""){
				Break
			}
			ETF_TVSTRING .= "`n" . nivel . list[A_Index, 1]		
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
	load_lv(window_name, lv_name, table){
		Global mariaDB, db

		if(window_name = "" || lv_name = ""){
			MsgBox, % "O handle da janela e o nome do listview sao obrigatorios!!!"
			return  
		}

		try{
			rs := mariaDB.OpenRecordSet("SELECT * FROM " table)	
		}catch e{
			MsgBox,16,Erro, % "Ainda nao existe tabela de codigos para o modelo selecionado!"
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
		;LV_ModifyCol(1),LV_ModifyCol(2),LV_ModifyCol(3),LV_ModifyCol(4),LV_ModifyCol(5)
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

		;MsgBox, % "max index prefixos " prefixos.maxindex()
		;MsgBox, % "max index campos " campos.maxindex()
		
		/*
			Transforma os arrays de multipla para 
			uma so dimensao
		*/
		prefixos := singledim_array(prefixos, 2)
		campos := singledim_array(campos, 2)

		;for each, value in prefixos{
		;	MsgBox, % "Lista de prefixos antes" value
		;}

		/*
			-Quando um item da tabela de campos nao existir 
			na tabela de modelos esse item sera inserido
		*/ 
		
		
		/*
			Primeiro faz um loop inserindo tudo o que
			nao tem em um array no outro
		*/
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
		
		;MsgBox, % "max index final " prefixos.maxindex()
		
		for each,prefixo in prefixos{
			;MsgBox, % "Lista de prefixos depois " prefixo
			record := {}
			record.Campos := prefixo	
			mariaDB.Insert(record, tabela_prefixo)
		}

		;MsgBox, % "terminou o correct table!"
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
		Global mariaDB

		rs := mariaDB.OpenRecordSet(
			(JOIN 
				" SELECT tabela2 FROM reltable "
				" WHERE tipo like 'Subfamilia' "
				" AND tabela1 like '" tabela1 "'"
			))
		
		reference_table := rs.tabela2

		rs.close()
		if(reference_table != ""){
			return 1
		}else{
			return 0
		}
	}

	/*
		Get reference global
	*/
	get_reference(tipo, tabela1){
		Global mariaDB
		;MsgBox, % "get reference tipo " tipo " tabela1 " tabela1
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
	
	#include lib\promto_sql_mariadb_empresa.ahk
	#include lib\promto_sql_mariadb_tipo.ahk
	#include lib\promto_sql_mariadb_familia.ahk
	#include lib\promto_sql_mariadb_subfamilia.ahk
	#include lib\promto_sql_mariadb_modelo.ahk
	#include lib\promto_sql_mariadb_campo.ahk
	#include lib\promto_sql_mariadb_imagem.ahk
}