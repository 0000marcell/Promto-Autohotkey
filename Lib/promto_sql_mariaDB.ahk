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
			;MsgBox, % " a conexao foi estabelecida!"
		} catch e {
			MsgBox,16, Error, % "A conexao nao foi estabelecida. Verifique os parametros da conexao!`n`n" ExceptionDetail(e)
		}
		/*
			Verifica se existe uma estrutura
			de dados coerente com o programa
		*/
		this.schema()
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
		Funcao que carrega a string da
		treeview da janela principal
	*/
	get_treeview(table,x,nivel,masc){
		Global mariaDB,ETF_TVSTRING, field, ETF_hashmask

		x+=1, nivel.="`t"
		For each, value in list := this.get_values("*", table){
			if(field[x] = ""){
				Break
			}
			ETF_TVSTRING .= "`n" . nivel . list[A_Index, 1]		
			ETF_hashmask[list[A_Index, 1]] := list[A_Index, 2] 	
			new_table := this.get_reference(field[x], masc . list[A_Index,1])
			if(new_table)
				this.get_treeview(new_table, x, nivel, masc . list[A_Index, 2])
		}
		return
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
		Global mariaDB

		if(window_name = "" || lv_name = ""){
			MsgBox, % "O handle da janela e o nome do listview sao obrigatorios!!!"
			return  
		}
		rs := mariaDB.OpenRecordSet("SELECT * FROM " table)
		Gui,%window_name%:default 
		Gui,listview,%lv_name%
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
		Get reference global
	*/
	get_reference(tipo, tabela1){
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
	#include lib\promto_sql_mariadb_empresa.ahk
	#include lib\promto_sql_mariadb_tipo.ahk
	#include lib\promto_sql_mariadb_familia.ahk
	#include lib\promto_sql_mariadb_modelo.ahk
	#include lib\promto_sql_mariadb_campo.ahk
}