/*
	dbex checker(DBEC)
*/

Class DBEC{
	
	codes(info, connection, base_value, code_list){
		Global db
		
		if(!IsObject(connection)){
		 	MsgBox,16, Erro,% "A conexao falhou, confira os parametros"
		 	return
		}

		missing_codes := []
		codes_missing := false

		for, each, value in code_list{
			if(!code_list[A_Index, 1])
				Continue
			if(!this.check_if_exist(code_list[A_Index, 1], connection, base_value)){
				missing_codes.Insert(code_list[A_Index, 1])
				codes_missing := true
			}
		}
		/*
			Retorna os codigos 
			que nao existem
		*/
		return missing_codes
	}

	check_if_exist(code, connection, base_value){
		Global db

		AHK.append_debug("check if exist code " code)

		sql :=
		(JOIN 
			"Select B1_COD "  
			"from " base_value " WHERE B1_COD = '" code "'"
		)
		AHK.append_debug("sql passed " sql)
		_exist_in_dbex := existindb(connection, sql)
		AHK.append_debug("exist result " _exist_in_dbex)
		if(_exist_in_dbex = 1){
			return true
		}else{
			return false
		}
	}

	/*
		Muda a condicao dos codigos na pagina principal
	*/
	change_code_status(status, hwd){
		Global

		if(status){
			img_path := "img\green_glossy_ball.png"
		}else{
			img_path := "img\red_glossy_ball.png"
		}
		AHK.append_debug("gonna change status in main window to " status)
		GuiControl, , %hwd% , % img_path
	}
}