remover_item_ETF(){
	Global 

	/*
		Removendo Abas
	*/
	if(tv_level_menu = 2){
		/*
			preciso remover a entrada 
			da aba na tabela (TAba)
			remover a tabela da propia aba (TCJFamilia)
			e a referencia da tabela da aba na tabela de 
			referencia.
		*/

		/*
			pega a mascara da empresa
		*/
		parent_id := TV_GetParent(current_id)
		parent_name := get_item_from_tv(parent_id)
		empresa_mascara := ETF_hashmask[parent_name]

		/* 
			pega a mascara da empresa
		*/
		aba_name := get_item_from_tv(current_id)
		aba_mascara := ETF_hashmask[aba_name]

		/*
			remove a aba da tabela de abas
		*/
		aba_table := empresa_mascara "Aba"
		/*
		 Falta implementar os metodos abaixo
		*/
		db.remove_aba(aba_table, aba_name, aba_mascara)
		db.drop_table(empresa_mascara aba_mascara "Familia")
		db.remove_rel()

		;db.query("DELETE FROM ESTRUTURAS WHERE item='" "='" finalreturn[A_Index,1] " AND componente='" finalreturn[A_Index,2] "';")
		;db.query("")
	}

	/*
		Removendo Familias
	*/
	if(tv_level_menu = 3){
		/*
		*/
	}
}