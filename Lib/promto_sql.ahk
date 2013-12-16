gclass PromtoSQL{
	/*
		Empresa
	*/
	add_empresa(empresa_name, empresa_mascara){
		/*
		 Adiciona a empresa 
		*/
		;sql:=
		;(JOIN
		;	"DELETE FROM " aba_table " WHERE Abas ='" aba_name
		;	"' AND Mascara = '" aba_mascara "'"
		;) 
		;db.remove(table,)
		;db.remove(aba_table,
		;(JOIN
		;	"Abas ='" aba_name
		;	"' AND Mascara = '" aba_mascara "'" 
		;))
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

	remove_aba(table, aba_name, aba_mascara){
		/*
			Remove o aba
		*/

		/*
			Antes de remover e preciso ver se 
			o valor na tabela existe.
		*/
		this.currentDB(
			(JOIN 
				" DELETE FROM " table 
				" (Abas, Mascara) "
				" SELECT ('" aba_name "','" aba_mascara "')"
				" WHERE EXIST (SELECT 1 FROM" 
			))
		;if(this.currentDB.exist(
		;	(JOIN 
		;		"Abas,Mascara",
		;		"Abas = '" aba_name,
		;		table)){
		;	MsgBox, % a tabela existia
		;}
		;"create table if not exists " tablename "(Campos,PRIMARY KEY(Campos ASC))"
		;this.currentDB.Query(
		;	(JOIN 
		;		"DELETE FROM " table 
		;		"IF EXISTS WHERE Abas = '" aba_name "'"
		;		" Mascara = '" aba_mascara "'"
		;	))
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