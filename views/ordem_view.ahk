ordem_view(tipo, info){
	Global db, SMALL_FONT, GLOBAL_COLOR, updownv, ordem_lv, ordem_view
	Static tabela_ordem, s_tipo

	if(info.modelo[2] = "" or info.modelo[2] = "Mascara"){
		MsgBox, 16, Erro, % "Selecione um modelo antes de continuar!"
		return
	}
	s_tipo := tipo

	/*
		Gui init
	*/
	Gui, ordem_view:New
	Gui, ordem_view:+ownerM
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Items
	*/
	Gui, Add, Groupbox, w250 h300, Items
	if(tipo = "prefixo")
		Gui, Add, Listview, xp+10 yp+15 w230 h280 vordem_lv checked, Id|Campos
	Else
		Gui, Add, Listview, xp+10 yp+15 w230 h280 vordem_lv , Id|Campos

	/*
		Handle
	*/
	 Gui, Add, UpDown,  x+5 w60 h140 vupdownv gupdown range0-1

	 /*
	 	Opcoes
	 */
	 Gui, Add, Groupbox, xm y+5 w250 h60, Opcoes
	 Gui, Add, Button, xp+10 yp+15 w100 h30 gsalvar_ordem_prefixo_button, Salvar 
	 tabela_ordem := get_tabela_ordem(tipo, info)
	 
	 /*
	 	Insere os novos campos na tabela de prefixo
	 */
	 tabela_ordem_array := db.load_table_in_array(tabela_ordem)
	 db.correct_tabela_ordem(tipo, info) 
	 db.load_lv("ordem_view", "ordem_lv", tabela_ordem)
	 Gui, Show,, Alterar Ordem
	 check_omited_items(tabela_ordem_array)
	 return
	 
	 salvar_ordem_prefixo_button:
	 Gui, ordem_view:default
	 Gui, listview, ordem_lv
	 nova_ordem := []
	 
	 Loop % LV_GetCount(){
  	LV_GetText(RetrievedText, A_Index, 2)

  	nova_ordem.insert(RetrievedText)
	 }
	 /* ######## PEGAR OS ITEMS QUE ESTAO MARCADOS 
	 	CRIAR UM NOVO CAMPO NA TABELA DE ORDEM E INSERIR 1 QUANDO O ITEM ESTIVER
	 	MARCADO E 0 QUANDO NAO ESTIVER
	 */
	 if(s_tipo = "prefixo"){
	 	
	 	codigos_omitidos := GetCheckedRows("ordem_view", "ordem_lv")	
	 }else{
	 	
	 	codigos_omitidos := ""
	 }
	 
	 db.Modelo.incluir_ordem(nova_ordem, tabela_ordem, codigos_omitidos)
	 MsgBox,64, Sucesso, % "Todos os items foram inseridos com sucesso!"
	 Gui, ordem_view:destroy 
	 return


	 updown:
	 Gui, Submit, Nohide
	 if(updownv > 0){
	 	condition := 1
	 	updownv := 0
	 }else{
	 	updownv := 0
	 	condition := 0
	 }
	 LV_MoveRowfam("ordem_view", "ordem_lv", condition)
	 return 
}


check_omited_items(table){
	Gui, ordem_view:default
	Gui, listview, ordem_lv

	for, each, value in table{
		if(table[A_Index, 3] = 1){
			LV_Modify(A_Index, "+Check")
		}
	}

}

