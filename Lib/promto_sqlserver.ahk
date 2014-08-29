class PromtoSQLServer{
	
	__New(connection_name){
		this.SQLSdb := get_connection(connection_name)
	}

	find_items_where(where_statement, table){ 
		items := this.find_items("SELECT * FROM " table " WHERE " where_statement)
		return items
	}

	find_items(sql){
		try{
			rs := this.SQLSdb.OpenRecordSet(sql)		
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
}