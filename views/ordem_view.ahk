ordem_view(tipo, info){
	Global db, SMALL_FONT, GLOBAL_COLOR, updownv, ordem_lv

	;MsgBox, % "ordem view"

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
	Gui, Add, Listview, xp+10 yp+15 w230 h280 vordem_lv,Campos

	/*
		Handle
	*/
	 ;Gui, Add, Groupbox, x+15 ym w100 h150,
	 Gui, Add, UpDown,  x+5 w60 h140 vupdownv gupdown range0-1

	 /*
	 	Opcoes
	 */
	 Gui, Add, Groupbox, xm y+5 w250 h60, Opcoes
	 Gui, Add, Button, xp+10 yp+15 w100 h30 gsalvar_ordem_prefixo_button, Salvar
	 tabela_ordem := get_tabela_ordem(tipo, info)
	 ;MsgBox, % "tabela ordem " tabela_ordem
	 
	 /*
	 	Insere os novos campos na tabela de prefixo
	 */
	 db.correct_tabela_ordem(tipo, info)
	 db.load_lv("ordem_view", "ordem_lv", tabela_ordem)
	 Gui, Show,, Alterar Ordem
	 return
	 
	 salvar_ordem_prefixo_button:
	 
	 return


	 updown:
		gui,submit,nohide
		if(updownv>0){
		 	condition:=1
		 	updownv:=0
		 }else{
		 	updownv:=0
		 	condition:=0
		 }
		LV_MoveRowfam("ordem_view", "ordem_lv", condition)
	 return 
}

