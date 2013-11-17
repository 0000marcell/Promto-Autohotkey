inserir_ETF_view(window, treeview, current_id, columns){
	Global db, edit_name_ETF, edit_mask_ETF, SMALL_FONT, GLOBAL_COLOR, ETF_hashmask
	Static s_window, s_treeview, s_current_id, s_type

	s_window := window
	s_treeview := treeview
	s_current_id := current_id
	s_type := columns

	/*
		Gui init
	*/
	Gui, insert_ETF:New
	Gui, insert_ETF:+ownerM
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Campos
	*/
	Gui, Add, Groupbox, w230 h130, Campos
	Gui, Add, Text,xp+10 yp+15, Item:
	Gui, Add, Edit, y+10 w200 vedit_name_ETF uppercase,
	Gui, Add, Text, y+10, Mascara:
	Gui, Add, Edit, y+10 w200 vedit_mask_ETF uppercase,

	/*
		Opcoes
	*/
	Gui, Add, Groupbox,xm y+20 w230 h60, Opcoes
	Gui, Add, Button, xp+113 yp+19 w100 h30 ginsert_values_ETF Default, Inserir
	Gui, Show,,Inserir 
	return 

	insert_values_ETF:
	Gui, Submit, nohide

	/*
	 Insere o valor na determinada tabela
	*/
	record := {}

	/*
		Se for insercao de empresa
	*/
	if(s_type = "Empresas"){
		/*
			Verifica se existe correspondencia da mascara 
			para o determinado nome
			caso exista substitui pelo que ja existe
		*/
		edit_mask_ETF := check_if_ETF_exist(edit_name_ETF, edit_mask_ETF)
		if(db.Empresa.incluir(edit_name_ETF, edit_mask_ETF)){
			ETF_hashmask[edit_name_ETF] := edit_mask_ETF
		}else{
			MsgBox,16,Erro, % " Algo deu errado ao tentar inserir a empresa!" 
			return
		}
	}

	/*
		Se for insercao de Aba
	*/
	if(s_type = "Abas"){
		/*
			Pega o nome e a mascara 
			da empresa que detem esse tipo
		*/
		Gui, %s_window%:Default
		Gui, Treeview, %s_treeview%
		TV_GetText(empresa_nome, s_current_id)  
		/*
			Verifica se existe correspondencia da mascara 
			para o determinado nome
			caso exista substitui pelo que ja existe
		*/
		edit_mask_ETF := check_if_ETF_exist(edit_name_ETF, edit_mask_ETF)
		if(db.Tipo.incluir(edit_name_ETF, edit_mask_ETF, ETF_hashmask[empresa_nome], empresa_nome)){
			ETF_hashmask[edit_name_ETF] := edit_mask_ETF
		}else{
			MsgBox,16,Erro, % " Algo deu errado ao tentar inserir a aba!" 
			return
		}
		
	}

	/*
		Se for insercao de Familia
	*/
	if(s_type = "Familias"){
		/*
			Para inserir uma familia e preciso
			alem do nome e da mascara e preciso
			do prefixo e do nome do tipo
		*/
		/*
			Pega o nome do tipo 
			a mascara do tipo e a mascara da empresa 
		*/
		Gui, %s_window%:Default
		Gui, Treeview, %s_treeview%
		TV_GetText(tipo_nome, s_current_id)
		parent_id := TV_GetParent(s_current_id)
		TV_GetText(empresa_nome, parent_id)
		fam_prefix := ETF_hashmask[empresa_nome] ETF_hashmask[tipo_nome]
		/*
			Verifica se existe correspondencia da mascara 
			para o determinado nome
			caso exista substitui pelo que ja existe
		*/
		edit_mask_ETF := check_if_ETF_exist(edit_name_ETF, edit_mask_ETF) 
	
		if(db.Familia.incluir(edit_name_ETF, edit_mask_ETF, fam_prefix, tipo_nome)){
			ETF_hashmask[edit_name_ETF] := edit_mask_ETF
		}else{
			MsgBox,16,Erro, % " Algo deu errado ao tentar inserir a Familia!" 
			return
		}
	}
	Gui, %s_window%:Default
	Gui, Treeview, %s_treeview% 
	id := TV_Add(edit_name_ETF , s_current_id)
	Gui,insert_ETF:destroy
	TV_Modify(id ,"visFirst")
	TV_Modify(id)
	return 
}

