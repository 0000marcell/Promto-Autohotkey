PromtoSQL{
	/*
		Empresa
	*/
	add_empresa(empresa_name, empresa_mascara){
		/*
		 Adiciona a empresa 
		*/
		sql:=
		(JOIN
			"DELETE FROM " aba_table " WHERE Abas ='" aba_name
			"' AND Mascara = '" aba_mascara "'"
		) 
		db.remove(table,)
		db.remove(aba_table,
		(JOIN
			"Abas ='" aba_name
			"' AND Mascara = '" aba_mascara "'" 
		))
	}

	remove_empresa(empresa_name, empresa_mascara){
		/*
		 Remove a empresa
		*/
	}

	/*
		Aba
	*/
	add_aba(tabela, aba_name, aba_mascara){
		/*
		 Adiciona o aba 
		*/


	}

	remove_aba(tabela, aba_name, aba_mascara){
		/*
			Remove o aba
		*/
	}

	/*
		Familia
	*/
	add_familia(tabela, familia_nome, familia_mascara){
		/*
			Adiciona a familia
		*/
	}

	remove_familia(tabela, familia_nome, familia_mascara){
		/*
			Remove a familia
		*/
	}

	/*
	 	Modelo
	*/
	add_modelo(tabela, modelo_nome, modelo_mascara){
		/*
			Adiciona o modelo
		*/
	}

	remove_modelo(tabela, modelo_nome, modelo_mascara){
		/*
			Remove o modelo
		*/
	}

	remove_rel(tipo, tabela1){
		/*
		 Remove a entrada da tabela de referencia
		*/
	}

}