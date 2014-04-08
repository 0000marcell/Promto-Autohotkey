Class DB {
	
	/*
	recebe um hash com os valores que serao 
	inseridos no db externo. 
	*/
	inserirdbexterno(values){
		Global 
		local itemvalue

		/*
			Pega o prefixo do codigo
		*/
		prefixbloq := ""
		prefixbloq := get_prefixbloq(info) 

		/*
			testa a conecao
		*/
		if(IsObject(sigaconnection)){
		    MsgBox,64,,% "A connexao esta funcionando!!!"
		}else{
		    MsgBox,64,,% "A conexao falhou!! confira os parametros!!"
		}

		/*
			pega o numero do ultimo registro
		*/
		rs := sigaconnection.OpenRecordSet("SELECT TOP 1 B1_COD,B1_DESC,R_E_C_N_O_ FROM " base_value " ORDER BY R_E_C_N_O_ DESC")
		R_E_C_N_O_TBI := rs["R_E_C_N_O_"]
		rs.close()

		/*
			Carrega um array com todos os items desbloqueados
			atualmente no sistema.
		*/
		if(bloquear_outros_items = True){
			bloqlist := []
			sql := 
			(JOIN
				"SELECT B1_COD FROM " base_value " WHERE B1_COD LIKE '" prefixbloq "%'"
				"AND B1_MSBLQL != '1'"
			)
			rs := sigaconnection.OpenRecordSet(sql)
			while(!rs.EOF){   
				CODIGO := rs["B1_COD"] 
				bloqlist.Insert(CODIGO)
				rs.MoveNext()
			}
			rs.close()
		}

		GARANT := 2,XCALCPR := 0,B1_LOCALIZ := "N"
		progress(values.maxindex())

		/*
		Inicia o loop que ira inserir todos 
		os novos items no dbex
		*/
		
		MsgBox, % "numero de items : " values.maxindex()

		for,each,value in values{
			itemvalue := values[A_Index,1]
			updateprogress("Inserindo valores: " itemvalue, 1)

			/*
			Confere se o item a ser inserido 
			ja existe no dbex
			*/
			table := sigaconnection.Query("Select B1_COD from " base_value " WHERE B1_COD LIKE '" itemvalue "'")
			columnCount := table.Columns.Count()
			_exists := 0
			for each,row in table.Rows{
				Loop, % columnCount{
					if(row[A_index] != "")
						_exists:=1
					else
						_exists:=0
				}
			}
			table.close()

			/*
			Caso exista cria um update
			*/

			if(_exists = 1){
				/*
					Faz a relacao entre o campo e o valor do campo 
					em um hash. 
				*/

				/*
					B1_USERLGI
				*/

				field_values := {
				(JOIN
					B1_XDESC: values[A_Index,2], B1_DESC: values[A_Index,3], B1_XDESCIN: values[A_Index,4],
					B1_POSIPI: values[A_Index,5], B1_UM: values[A_Index,6],
					B1_ORIGEM: values[A_Index,7], B1_CONTA: values[A_Index,8],
					B1_TIPO: values[A_Index,9], B1_GRUPO: values[A_Index,10], 
					B1_IPI: values[A_Index,11], B1_LOCPAD: values[A_Index,12], B1_XGRUPO: values[A_Index, 10], 
					B1_GARANT: GARANT, B1_XCALCPR: XCALCPR, B1_MSBLQL: "2", B1_USERLGI: A_UserName,
					B1_LOCALIZ: "N"
				)}
			
				/*
				Faz um loop por todos os campos e so insere os que
				tem algum valor preenchido
				*/
				if(itemvalue = ""){
					MsgBox, % "Um dos codigos estavam em branco!"
					return 
				}
				sql := "UPDATE " base_value " SET B1_COD='" itemvalue 
				for field, value in field_values{
						/*
							Se o valor para o campo nao estiver em branco 
							o nome do campo e o valor sao incluidos no update
							*/
						if(value != ""){
							sql .= "'," field "='" value
						}
				}
				sql .= "' WHERE B1_COD='" itemvalue "';"
			}else{
				/*
					Caso nao exista cria um insert
				*/
				
				R_E_C_N_O_TBI++

				sql:=
				(JOIN
					"INSERT INTO " base_value " ("
						"B1_COD,"
						"B1_XDESC,"
						"B1_DESC,"
						"B1_XDESCIN,"
						"B1_POSIPI,"
						"B1_UM,"
						"B1_ORIGEM,"
						"B1_CONTA,"
						"B1_TIPO,"
						"B1_GRUPO,"
						"B1_XGRUPO,"
						"B1_IPI,"
						"B1_LOCPAD,"
						"B1_GARANT,"
						"B1_XCALCPR,"
						"B1_LOCALIZ,"
						"B1_USERLGI,"
						"R_E_C_N_O_) VALUES ('"
						itemvalue "','"
						values[A_Index,2] "','"
						values[A_Index,3] "','"
						values[A_Index,4] "','" 
						values[A_Index,5] "','" 
						values[A_Index,6] "','" 
						values[A_Index,7] "','" 
						values[A_Index,8] "','" 
						values[A_Index,9] "','"
						values[A_Index,10] "','"
						values[A_Index,10] "','" 
						values[A_Index,11] "','" 
						values[A_Index,12] "','" 
						GARANT "','" 
						XCALCPR "','"
						"N','" 
						A_UserName "','"
						R_E_C_N_O_TBI "')"
				)
			}
			
			/*
			Roda a query
			*/
			sigaconnection.Query(sql)
		}	
		if(bloquear_outros_items = True){
			for,each,value in bloqlist{
				if(!MatHasValue(values,value)){
						sigaconnection.Query("UPDATE " base_value " SET B1_MSBLQL='1' WHERE B1_COD='" value "';")
					}else{
						sigaconnection.Query("UPDATE " base_value " SET B1_MSBLQL='2' WHERE B1_COD='" value "';")
					}
			} 
		}
		gui,progress:destroy
		MsgBox,64,,% "Os valores foram inseridos no db externo!!" 
	}

	existindb(connection,sql){  ;connection fora da classe sql 
		tableexist := connection.Query(sql)
		columnCount := tableexist.Columns.Count()
		for each,row in tableexist.Rows{
			Loop, % columnCount{
				if(row[A_index]!=""){
					returnvalue := True
					Break
				}else{
					returnvalue := False
					Break
				}
			}
		}
		tableexist.close()
		return returnvalue
	}
} ; /// DB