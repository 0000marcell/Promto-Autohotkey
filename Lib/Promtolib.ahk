

/*
	get_lv_in_array(window_name, lv_name, number_of_columns = 1)
	pega todos os items de uma determinada listview em
	um array 
*/

Class OTTK
{
	__New(filePath){
		file:=FileOpen(filePath,"r")

		value:=file.Read()
		this.path:=filePath
		StringSplit,fileLine,value,`n,%A_Space%%A_Tab%`r
		Loop,%fileLine0%
		{
			i+=1
			if(fileLine%A_Index%!="")
			{
					StringSplit,value,fileLine%A_Index%,;
					Loop,%value0%
					{
						this[i,A_Index]:=value%A_Index%
					}
			}
		}
	}
	
	delete(value)
	{
		for,k,v in this
		{
			for,w,z in this[k]
			{
				if(this[k,w]=value)
				{
				  this[k].remove(w)	
				}	
			}
		}
		this.write()
	}

	deleterow(row){
		this.remove(row)
		this.write()
	}
	deletevalue(row,column){
		this[row].remove(column)
		this.write()
	}
	
	rename(ovalue,nvalue)
	{
		i:=0
		while(this[A_Index,1]!="")
		{
			i+=1
			while(this[i,A_Index]!="")
			{
				if(this[i,A_Index]=ovalue)
				{
					this[i,A_Index]:=nvalue
				}
			}
		}
		this.write()
	}
	
	append(value)
	{
		i=0
		while(this[A_Index,1]!="")
		{
			i+=1
		}
		this[i+1,1]:=value
		this.write()
	}
	
	write()
	{
		fPath:=this.path
		FileDelete,% this.path
		write:=FileOpen(fPath,"w")
		for,k,v in this
		{
			for,w,z in this[k]
			{
				if(w=1)
				{
						write.Write(this[k,w])
				}else{
						write.Write(";" . this[k,w])
				}
			}
			write.Write("`r`n")	
		}
		write.close()
	}

	exist(value,column)
	{
		returnValue:=0
		while(this[A_Index,column]!="")
			{
				if(value=this[A_Index,column])
					{
						returnValue:=1
					}
			}	
			return returnValue
	}

	clear()
	{
		while(this[A_Index,1]!="")
		{
			this.remove(A_Index)
		}
	}

	checkduplicated()
	{
		MsgBox, % "CheckDuplicated"
		valores:=object()
		duplicatedValues:=""

		i:=0
		while(this[A_Index,1]!="")
		{
			i+=1	
			while(this[i,A_Index]!="")
			{
				_naoinserir:=0
				for,index,k in valores
				{
					if(k=this[i,A_Index])
					{
						_naoinserir:=1
						if(duplicatedValues="")
						{
							duplicatedValues.=k	
						}Else{
							duplicatedValues.=";" . k
						}
							
					}
				}
				if(_naoinserir=0)
				{
					valores.insert(this[i,A_Index])	
				}
			}
				
		}
		return duplicatedValues
	}
}

/*
	Funcao que conta o numero de codigos de determinado modelo 
	e insere a quantidade na janela principal
*/
number_of_items(info){
 	Global db
	
	codigos := db.load_table_in_array(get_prefix_from_info(info) "Codigo")
	Gui, M:default
	GuiControl,, numberofitems, % codigos.maxindex()
}

/*
 Retorna o prefixo 
 baseada nas informacoes do info
*/
get_prefix_from_info(info){
	prefixo := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2]
	return prefixo
}

/*
	Carrega todos os modelo na listview da janela principal
*/
load_all_mod(info){
	Global db 

	code_table := get_prefix_from_info(info) "codigo"
	code_list_array := db.find_items_where("codigos like '%" info.modelo[2]  "%'", code_table)
	Gui, M:default
	GuiControl,, numberofitems, % code_list_array.maxindex() 
	load_lv_from_array(["codigo", "descricao", "descricao completa", "descricao em ingles"], code_list_array, "M", "all_mod_lv", ["100", "200"])	
}

/*
	Removes determinadas colunas de um array 
	multidimensional
*/
trim_array(array, columns_to_keep, number_of_columns){
	new_array := []
	new_array_column := 0
	loop, % number_of_columns{
		column := A_Index
		for, each, column_to_keep in columns_to_keep{
			if(column = column_to_keep ){
				new_array_column++
				loop, % array.maxindex(){
					if(array[A_Index, column] = "")
						Continue
					new_array[A_Index, new_array_column] := array[A_Index, column]
				}
			}
		}
	}
	Return new_array
}

/*
	Limpa as informacoes sobre o 
	modelo da tabela principal
*/
clear_main_info(){
	Global change_ptcode
	Gui, M:default
	Gui, Listview, MODlv
	LV_Delete()
	GuiControl,, numberofitems,
	GuiControl,, status_picture, % "img\gray_glossy_ball.png"
	GuiControl,, status_info, 
	if(change_ptcode){
		change_ptcode := 0
		GuiControl, , ptcode, % "img\promtologo.png"
	}
	Gui, Listview, all_mod_lv
	LV_Delete()
	GuiControl,, mod_info,
	GuiControl,, msg_info,
}

/*
	Funcao que muda a imagem de 
	determinado controle 
*/


LV_MoveRowfam(wname,lvname,moveup = true) {
	gui,%wname%:Default
    gui,listview,%lvname%
   ; Original by diebagger (Guest) from:
   ; http://de.autohotkey.com/forum/viewtopic.php?p=58526#58526
   ; Slightly Modifyed by Obi-Wahn
   If moveup not in 1,0
      Return   ; If direction not up or down (true or false)
   while x := LV_GetNext(x)   ; Get selected lines
      i := A_Index, i%i% := x
   If (!i) || ((i1 < 2) && moveup) || ((i%i% = LV_GetCount()) && !moveup)
      Return   ; Break Function if: nothing selected, (first selected < 2 AND moveup = true) [header bug]
            ; OR (last selected = LV_GetCount() AND moveup = false) [delete bug]
   cc := LV_GetCount("Col"), fr := LV_GetNext(0, "Focused"), d := moveup ? -1 : 1
   ; Count Columns, Query Line Number of next selected, set direction math.
   Loop, %i% {   ; Loop selected lines
      r := moveup ? A_Index : i - A_Index + 1, ro := i%r%, rn := ro + d
      ; Calculate row up or down, ro (current row), rn (target row)
      Loop, %cc% {   ; Loop through header count
         LV_GetText(to, ro, A_Index), LV_GetText(tn, rn, A_Index)
         ; Query Text from Current and Targetrow
         LV_Modify(rn, "Col" A_Index, to), LV_Modify(ro, "Col" A_Index, tn)
         ; Modify Rows (switch text)
      }
      LV_Modify(ro, "-select -focus"), LV_Modify(rn, "select vis")
      If (ro = fr)
         LV_Modify(rn, "Focus")
   }
}





loadlv(hash){
	Global Listiv
	Gui, inserirval:default
	Gui, Listview, lviv2
	LV_Delete()
	Listiv := []
	for, each, value in %hash%["valor"]{
		if(%hash%["valor",A_Index] = "")
			Continue
		Listiv[A_Index,1] := %hash%["valor",A_Index]
		Listiv[A_Index,2] := %hash%["descricao",A_Index]
		LV_Add("", %hash%["valor",A_Index], %hash%["descricao", A_Index])
	}
	lv_modifycol(1,200)
}

pesquisalvmod(wname, lvname, string, List){    ;funcao de pesquisa na listview modificada!!!!
	Global 

	Gui,%wname%:default
  Gui, Listview, %lvname%
  GuiControl, -Redraw, %lvname%
  Gui, Submit, NoHide
  resultsearch := [] 
  If (string=""){ 
      LV_Delete()
	for,each,value in List{
      	codname:=List[A_Index,1]
      	if(codname = "")
      		continue
          LV_Add("",List[A_Index,1],List[A_Index,2],List[A_Index,3], List[A_Index, 4], %codname%["NCM"], %codname%["UM"], %codname%["ORIGEM"], %codname%["TCONTA"], %codname%["TIPO"], %codname%["GRUPO"], %codname%["IPI"], %codname%["LOCPAD"])
      }    
  }Else{
      for,each,value in List{
          i++
          string2:=List[A_Index,1] List[A_Index,2]
          IfInString,string2,%string%
          {
              resultsearch.insert(i)
          }
      }
      i:=0
      LV_Delete()
      for,each,value in resultsearch{
      	codname := List[value,1]
    	  if(codname = "")
    		 continue
        
        LV_Add("", List[value,1], List[value,2], List[A_Index,3], List[A_Index, 4], %codname%["NCM"], %codname%["UM"], %codname%["ORIGEM"], %codname%["TCONTA"], %codname%["TIPO"], %codname%["GRUPO"], %codname%["IPI"], %codname%["LOCPAD"])
      }
  }
  GuiControl, +Redraw,%lvname%
  LV_Modify(1, "+Select")
}

/*
	Carrega a verificacao do certificado 
	na janela de mudanca de status
*/
load_verification_cert(info){
	Global db, checked_with_cert

	if(db.Certificado.verification_exists(get_prefix_from_info(info))){
		Gui, change_status_view:default
		GuiControl,, checked_with_cert, 1
	}
}

/*
	Pega os items de determinada listview em um 
	array 
*/
get_lv_in_array(window_name, lv_name, number_of_columns = 1){
	Gui, %window_name%:default
	GUi, listview, %lv_name%
	returned_array := []
	Loop, % LV_GetCount()
	{
    row := A_Index
    loop, % number_of_columns{
    	LV_GetText(Text, row, A_Index)
    	returned_array[row, A_Index] := Text	
    }
	}
	return returned_array
}
/*
	Funcao que forma a arvore de items ate 
	a familia 
*/
get_tree(table,x,nivel,masc){
	Global db, ETF_TVSTRING, field, ETF_hashmask

	x+=1, nivel.="`t"
	For each, value in list := db.getvalues("*", table){
		if(field[x] = ""){
			Break
		}
		ETF_TVSTRING .= "`n" . nivel . list[A_Index, 1] "			" list[A_Index, 2] 		
		ETF_hashmask[list[A_Index, 1]] := list[A_Index, 2] 	
		result := db.query("SELECT tabela2 FROM reltable WHERE tipo='" . field[x] . "' AND tabela1='" . masc . list[A_Index,1] . "'")
		new_table := result["tabela2"]
		result.close()
		if(new_table)
			get_tree := get_tree(new_table, x, nivel, masc . list[A_Index, 2])
	}
	return
}

get_tabela_campo_esp(campo, info){
	Global db

	tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
	StringReplace,s_campo_sem_espaco, campo,%A_Space%,,All
	tabela_campos_especificos := db.Modelo.get_tabela_campo_esp(s_campo_sem_espaco, tabela1)
	return tabela_campos_especificos
}


get_tabela_ordem(tipo, info){
	Global db
	;MsgBox, % "get tabela ordem"
	if(tipo = "prefixo"){
		tabela_ordem := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "prefixo"
	}else if(tipo = "oc"){
		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
	 	tabela_ordem := db.get_reference(tipo, tabela1)
	}else if(tipo = "odr"){
		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
	 	tabela_ordem := db.get_reference(tipo, tabela1)
	}else if(tipo = "odi"){
		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
	 	tabela_ordem := db.get_reference(tipo, tabela1)
	}else if(tipo = "odc"){
		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
	 	tabela_ordem := db.get_reference(tipo, tabela1)
	}
	return tabela_ordem 
}

/*
	funcao que pega o prefix da 
	tabela
*/
get_promto_mask(){
	Global ETF_hashmask
	
	maska := []
	Gui, Treeview, main_tv
	id := TV_GetSelection()
	TV_GetText(selected_in_tv, id)  
	Loop
	{
		TV_GetText(text, id)
		if(A_Index = 1)
			selected2 := text
		if ETF_hashmask[text] != ""
			maska.insert(ETF_hashmask[text])	
		id := TV_GetParent(id)
		if !id 
			Break
	}
	newarray := reversearray(maska)
	mask := ""
	for,each,value in newarray{
		if(A_Index < newarray.maxindex())
			mask .= value
	} 
	return mask
}

/*
	Funcao que pega valores 
	referentes a treeview da janela principal
*/
get_tv_info(type, ignore_error = 0, window = "M", treeview = "main_tv", starting_id = "", same_window = ""){
	Global ETF_hashmask


	if(same_window != ""){
		tv_level := get_tv_level(same_window, treeview)	
	}else{
		tv_level := get_tv_level(window, treeview)	
	}
	

	if(tv_level = ""){
		MsgBox,16,Erro, % "Nao existia nenhum item selecionado na treeview"
	}
	if(type = "Subfamilia" && tv_level != 4){
		if(ignore_error = 0)
			MsgBox,16,Erro, % "a selecao nao esta em nivel suficiente para retornar valores de familia"
	}
	if(type = "Familia" && tv_level != 3 && tv_level != 4){
		if(ignore_error = 0)
			MsgBox,16,Erro, % "a selecao nao esta em nivel suficiente para retornar valores de familia"
	}
	if(type = "Tipo" && tv_level < 2){
		if(ignore_error = 0)
			MsgBox,16,Erro, % "a selecao nao esta em nivel suficiente para retornar valores de tipo"
	}

	return_values := []
	if(same_window = ""){
		Gui, %window%:Default
	}else{
		Gui, %same_window%:Default
	}
	
	Gui, Treeview, %treeview%

	if(starting_id = ""){
		id := TV_GetSelection()
	}else{
		id := starting_id 
		tv_level--
	}
	

	if(type = "Subfamilia"){
		if(tv_level = 4){
			nome := get_item_from_tv(id, treeview)
			return_values.nome := nome
			return_values.mascara := ETF_hashmask[nome]	
		}
	}

	if(type = "Familia"){

		if(tv_level = 4){
			parent_id := TV_GetParent(id)
			nome := get_item_from_tv(parent_id, treeview)
			return_values.nome := nome
			return_values.mascara := ETF_hashmask[nome]
		}
		if(tv_level = 3){
			nome := get_item_from_tv(id, treeview)
			return_values.nome := nome
			return_values.mascara := ETF_hashmask[nome]	
		}
	}

	if(type = "Tipo"){
		
		if(tv_level = 4){
			super_id := TV_GetParent(id)
			parent_id := TV_GetParent(super_id)
			nome := get_item_from_tv(parent_id, treeview)
			return_values.nome := nome
			return_values.mascara := ETF_hashmask[nome]
		}

		if(tv_level = 3){
			parent_id := TV_GetParent(id)
			nome := get_item_from_tv(parent_id, treeview)
			nome := get_item_from_tv(parent_id, treeview)
			return_values.nome := nome
			return_values.mascara := ETF_hashmask[nome]
		}

		if(tv_level = 2){
			nome := get_item_from_tv(id, treeview)
			return_values.nome := nome
			return_values.mascara := ETF_hashmask[nome]	
		}
	}

	if(type = "Empresa"){
		if(tv_level = 4){
			ultra_id := TV_GetParent(id)
			super_id := TV_GetParent(ultra_id)
			parent_id := TV_GetParent(super_id)
			nome := get_item_from_tv(parent_id, treeview)
			return_values.nome := nome
			return_values.mascara := ETF_hashmask[nome]
		}

		if(tv_level = 3){
			parent_id := TV_GetParent(id)
			super_parent_id := TV_GetParent(parent_id)
			nome := get_item_from_tv(super_parent_id, treeview)
			return_values.nome := nome
			return_values.mascara := ETF_hashmask[nome]
		}

		if(tv_level = 2){
			parent_id := TV_GetParent(id)
			nome := get_item_from_tv(parent_id, treeview)
			return_values.nome := nome
			return_values.mascara := ETF_hashmask[nome]
		}

		if(tv_level = 1){
			nome := get_item_from_tv(id, treeview)
			return_values.nome := nome
			return_values.mascara := ETF_hashmask[nome]
		}
	}
	return return_values
}

/*
	Pega o item da treeview 
	e da parse no texto para pegar o nome
*/
get_item_from_tv(id, treeview = "main_tv", window = "M"){ 
	Gui, TreeView, %treeview%
	TV_GetText(nome, id)
	StringSplit, nome, nome, >, >
	StringTrimRight, nome, nome1, 1
	return nome
}


/*
	Retorna o prefixo do determinado
	modelo na ordem devida
*/
get_prefixbloq(info){
	Global db 

	table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "prefixo"
	ordem_a := db.load_table_in_array(table)
	return_value := ""
	for, each, value in ordem_a{
		return_value .= ordem_a[A_Index, 2]
	}
	return return_value
}
	
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
	    ;MsgBox,64,,% "A connexao esta funcionando!!!"
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
				B1_LOCALIZ: "N", B1_CODBAR: itemvalue
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
					"B1_CODBAR,"
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
					itemvalue "','"
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
	info := get_item_info("M", "MODlv")
	change_status_view(info)
}

get_tv_id(window, treeview){
	Gui, %window%:Default
	Gui, Treeview, %treeview%
	id := TV_GetSelection()
	return id
}

clear_prev_status(){
	Gui, M:default
	GuiControl, , consistency_picture_tot , % "img\gray_glossy_ball.png"
	GuiControl, , consistency_picture_mac , % "img\gray_glossy_ball.png"
}

;#############GETREFERENCE################################################
getreferencetable(tipo,table){
	Global db

	StringReplace, tipo, tipo, %A_Space%,,All
	result := db.query("SELECT tabela2 FROM reltable WHERE tipo='" . tipo . "' AND tabela1='" . table . "'")
	returnvalue := result["tabela2"]
	result.close()
	return	returnvalue
}

/*
	Verifica se ja existe conexao de um 
	determinado nome com uma mascara
*/
check_if_ETF_exist(nome, mascara_antiga){
	Global ETF_hashmask
	mascara := ETF_hashmask[nome]
	if(mascara != ""){
		return mascara
	}else{
		return mascara_antiga
	}
}

/*
	Pega todas as informacoes sobre determinado item
	baseado no valor de uma listview
*/

get_item_info(window, lv, treeview = "main_tv", starting_id = "", same_window = ""){
	Global empresa, tipo, familia, modelo
	
	empresa := get_tv_info("Empresa", 0, "M", treeview, starting_id, same_window)
	tipo := get_tv_info("Tipo", 1, "M", treeview, starting_id, same_window)
	familia := get_tv_info("Familia", 1, "M", treeview, starting_id, same_window)
	subfamilia := get_tv_info("Subfamilia", 1, "M", treeview, starting_id, same_window)


	/*
		Pega o modelo selecionado na listview
	*/

	model := GetSelectedRow(window, lv)
	modelo := []
	modelo.nome := model[1]
	modelo.mascara := model[2]

	;MsgBox, % "## modelo " model[1] " mascara " model[2]

	/*
		Coloca todas as informacoes em 
		um unico hash 
	*/
	info := {}
	info.empresa[1] := empresa.nome
	info.empresa[2] := empresa.mascara
	info.tipo[1] := tipo.nome
	info.tipo[2] := tipo.mascara
	info.familia[1] := familia.nome
	info.familia[2] := familia.mascara
	info.subfamilia[1] := subfamilia.nome
	info.subfamilia[2] := subfamilia.mascara
	info.modelo[1] := modelo.nome
	info.modelo[2] := modelo.mascara

	return info 	
}

/*
	Funcao que verifica se existe algum valor em branco em um
	hash de valores
*/
check_if_blank(hash){
	for, each, value in hash{
		if(value = ""){
			MsgBox, 16, Erro, % "O valor " each " estava em branco!"
			return	
		}
	}
}
	

/*
 Carrega a imagem do modelo na janela principal
*/
load_model_image_in_main_window(info){
	Global db, change_ptcode

	code := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
	image_name_value := db.Imagem.get_image_full_path(code)
	if(image_name_value = ""){
		image_name_value := "img\sem_foto.jpg" 
	}
	change_ptcode := 1
	GuiControl,, ptcode, % image_name_value  
}

/*
	Carrega a formacao do codigo na janela principal
*/
load_formation_in_main_window(info){
	Global db
	
	/*
		Inicia o gdi
	*/
	newgdi({w:710,h:350})

	/*
	 Cria os blocos com os nomes dos prefixos
	*/
	panel_color := "coolblue" 
	text_panel_color := "00ff00"
	bloq_w := 65
	bloq_h := 50
	prefix_table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "prefixo"
	prefix_values := db.load_table_in_array(prefix_table)
	x := 10
	y := 10 
	if(prefix_values.maxindex() = 3){
		fields := ["Empresa", "Familia" , "Modelo"]
	}else{
		fields := ["Tipo", "Empresa", "Familia" , "Modelo"]
	}

	for, each, value in fields{
		if(value = "")
			Continue
		panel({x:x, y:y, w: bloq_w, h: bloq_h, color: panel_color, text: value, textsize: 12, boardsize: 0})
		x += bloq_w + 5
	}

	/*
		Cria os blocos com os nomes dos campos
	*/
	tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
	oc_table := db.get_reference("oc", tabela1)
	;MsgBox, % "oc table " oc_table
	oc_values := db.load_table_in_array(oc_table)
	campos_sem_espaco := []
	for, each, value in oc_values{
		oc_name := oc_values[A_Index, 2]
		if(oc_name = "")
			Continue
		panel({x:x, y:y, w: bloq_w, h: bloq_h, color: panel_color, text: oc_name, textsize: 8, boardsize: 0})
		StringReplace, oc_name, oc_name, %A_Space%,, All
		campos_sem_espaco.insert(oc_name)
		x += bloq_w + 5
	} 
 	
	/*
		Cria os blocos com os valores dos prefixos
	*/
	x := 10
	y += 80
	for, each, value in prefix_values{
		current_prefix := prefix_values[A_Index, 2]
		if(current_prefix = "")
			Continue
		panel({x:x,y:y, w: bloq_w, h: bloq_h,color: panel_color,text: current_prefix, textsize: 20, boardsize: 0})
		x += bloq_w + 5
	} 

	/*
		Cria os blocos com os valores dos campos
	*/
	for, each, value in campos_sem_espaco{
		;MsgBox, % "valor ser espaco " value
		campo_table := db.get_reference(value, tabela1)
		;MsgBox, % "campo table " campo_table
		if(campo_table = "")
			Continue
		campo_values := db.load_table_in_array(campo_table)
		if(campo_values[1, 1] = "")
			Continue
		panel({x:x, y:y, w: bloq_w, h: bloq_h, color: panel_color, text: 	campo_values[1, 1], textsize: 20, boardsize: 0})
		x += bloq_w + 5
	}	
	savetofile("img\formation.png")
	Gui, M:Default
	GuiControl,, fmcode, % "img\formation.png" 
}

/*
	Carrega o logo na janela principal
*/
load_logo_in_main(){
	image_source := "img\promtologo.png"
	show_image_and_code(image_source, 0)
}
	

/*
	Pega o modelo selecionado em certa list_view
*/
get_selected_model(window, lv){
	model := GetSelectedRow(window, lv)
	if(model[1] = "Modelos" || model[1] = "")
		return 
	modelo := []
	modelo.nome := model[1]
	modelo.mascara := model[2]

	return modelo
}
		

/*
	funcao que busca o nivel da tv 
*/
get_tv_level(window, tv){
	Gui, %window%:default
	Gui, treeview, %tv%
	id := TV_GetSelection()
	count := 0
	Loop{
		count++
		id := TV_GetParent(id)
		if !id 
			Break	
	}
	return count
}

;############ funcao que chama a janela de carregamento ###################################
carregandologo(){
	Global 
	;GC1:="grey"
	;GC2:="darkgrey"
	;GC3:="lightgrey"
	;GC4:="darkgrey"
	;GC5:="orange"
	If !pToken := Gdip_Startup()
	{
	    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	    ExitApp
	}
	Gui, carregandologo: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
	Gui, carregandologo: Show, NA
	hwnd1 := WinExist()
	sw:=A_ScreenWidth,sh:=A_ScreenHeight
	logow:=sw*0.17,logoh:=sh*0.19
	promtologo([GC1,GC2,GC3,GC4,GC5],logow,logoh,0)
	savetofile("logopequeno.png")
	loadintowindow("logopequeno.png",hwnd1)
	_cog:=0
	;SetTimer,carregandoaction,500
	return 		
}

getcolors(colorname){
	colors:=[]
	;lightblue:=75c2d4
	;blue:=3f8c9e
	;darkblue:=235c73
	;75c2d4
	;ff00ff
	;oldblue colors[1]:="0xff1e90ff",colors[2]:="0xff0949e9"
	if(colorname="blue")
		colors[1]:="0xff2661dd",colors[2]:="0xff1941A5"
	if(colorname="black")
		colors[1]:="0xff000000",colors[2]:="0xff000000"
	if(colorname="red")
		colors[1]:="0xFFF90101",colors[2]:="0xFFA50101"
	if(colorname="yellow")
		colors[1]:="0xFFF2B50F",colors[2]:="0xFFFFCC11"
	if(colorname="green")
		colors[1]:="0xFF00933B",colors[2]:="0xFF00533B"
	if(colorname="lightblue")
		colors[1]:="0xff75c2d4",colors[2]:="0xff3f8c9e"
	if(colorname="floralwhite")
		colors[1]:="0xfffffaf0",colors[2]:="0xfffffaf0"
	if(colorname="ghostwhite")
		colors[1]:="0xfff8f8ff",colors[2]:="0xfff8f8ff"
	if(colorname="darkblue")
		colors[1]:="0xff1e3364",colors[2]:="0xff1e3364"
	if(colorname="pink")
		colors[1]:="0xffff00ff",colors[2]:="0xffff00ff"
	if(colorname="darkgrey")
		colors[1]:="0xff545454",colors[2]:="0xffA4A4A4"
	if(colorname="grey")
		colors[1]:="0xffC0C0C0",colors[2]:="0xffffffff"
	if(colorname="lightgrey")
		colors[1]:="0xffAEAEAE",colors[2]:="0xffCECECE"
	if(colorname="white")
		colors[1]:="0xffffffff",colors[2]:="0xffffffff"
	if(colorname="nocolor")
		colors[1]:="0x00ffffff",colors[2]:="0x00ffffff"
	if(colorname="verydarkblue")
		colors[1]:="0xff102E37",colors[2]:="0xff162f3E"
	if(colorname="turquoise")
		colors[1]:="0xff2BBBD8",colors[2]:="0xff2FBFDF"
	if(colorname="lightorange")
		colors[1]:="0xffF78D3F",colors[2]:="0xffFD8F3F"
	if(colorname="nocolor")
		colors[1]:="0x00ffffff",colors[2]:="0x00ffffff"
	if(colorname="darkgreen")
		colors[1]:="0xff009A31",colors[2]:="0xff009A31"
	if(colorname="limegreen")
		colors[1]:="0xff84CF96",colors[2]:="0xff84CF96"
	if(colorname="verylightgreen")
		colors[1]:="0xffC6E7CE",colors[2]:="0xffC6E7CE"
	if(colorname="coolgreen")
		colors[1]:="0xff669900",colors[2]:="0xff225500"
	if(colorname="coolblue")
		colors[1]:="0xff0099FF",colors[2]:="0xff0055AA"
	if(colorname="cooldarkblue")
		colors[1]:="0xff0033CC",colors[2]:="0xff000088"
	if(colorname="orange")
		colors[1]:="0xffff3311",colors[2]:="0xffff7722"
	if(colorname="purple")
		colors[1]:="0xff9933CC",colors[2]:="0xff5511aa"
	return colors
}


;################## load window #####################################   ;atualiza a janela de carregamento
loadintowindow(imagepath,hwnd1){
	pBitmap := Gdip_CreateBitmapFromFile(imagepath)
	;If !pBitmap
	;{
	;    MsgBox, 48, File loading error!, Could not load the image specified
	;    ExitApp
	;}
	Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
	hbm := CreateDIBSection(Width, Height)
	hdc := CreateCompatibleDC()
	obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc)
	Gdip_SetInterpolationMode(G, 7)
	Gdip_DrawImage(G, pBitmap,0,0, Width, Height, 0, 0, Width, Height)
	UpdateLayeredWindow(hwnd1, hdc,(A_ScreenWidth//2)-(Width//2),(A_ScreenHeight//2)-(Height),Width,Height)
	SelectObject(hdc, obm)
	DeleteObject(hbm)
	DeleteDC(hdc)
	Gdip_DeleteGraphics(G)
	Gdip_DisposeImage(pBitmap)
	Return
}
;##############destroy carregando lib#########################
destroycarregandologo(){
	gui,carregandologo:destroy
	;SetTimer,carregandoaction,Off
	return
}
;##########################Showimageandcode################################################
show_image_and_code(image, with_desc = 1){
	Global
	
	;MsgBox, % "show image and code"
	newgdi({w:850,h:280})
	image := Gdip_CreateBitmapFromFile(image)
	w := Gdip_GetImageWidth(image), h := Gdip_GetImageHeight(image)
	Gdip_DrawImage(G,image,10,10,250,250,0,0,w,h)
	if(text = ""){

		/*
			Pega a descricao 
		*/
		if(with_desc){
			desc_ := db.Modelo.get_desc(info)
			StringSplit, desc_, desc_ ,|,
			descricao_model := desc_1
			already_logo := false
		}else{
			if(already_logo)
				return
			descricao_model := ""
			already_logo := true
		}

		/*
			Printa a descricao
		*/
		panel({x:265 ,y:10,w:550,h:250,text2:descricao_model,text2size:textsize,color: "coolblue",boardsize: 0})
	}else{
		panel({x:265 ,y:10,w:550,h:250,text2:text,text2size:textsize,color: "coolblue",boardsize: 0})
	}
	FileDelete, "img/simpleplot.png"  
	Gdip_SaveBitmapToFile(pBitmap,"img/simpleplot.png")
	Gdip_DisposeImage(pBitmap)
	Gdip_DisposeImage(image)	
	Gui, M:default 
	Guicontrol,,ptcode,img/simpleplot.png
}

;#########################PLOTPTCODE#########################################################
plotptcode(prefixpt,prefixpt2,modelpt,_showcode=0,iwidth=820,iheight=1076){
	global
	camptable:=prefixpt modelpt "oc"
	;loop utilizado para determinar o tamanho da foto.
	for,each,value in listcount:=db.getvalues("Campos",camptable){
		campnamecount:=listcount[A_Index,1]
		StringReplace,campnamecount,campnamecount,%A_Space%,,All
		result:=db.iquery("SELECT CODIGO FROM " prefixpt modelpt campnamecount ";")
		count:=result.Rows.Count()
		if(count>countprev)
			countprev:=count
	}
	result.close()
	iheight:=300
	iheight+=countprev*90
	newgdi({w:iwidth,h:iheight})
	;panel({x:0,y:0,w:iwidth,h:iheight,color: "white"})
	image := Gdip_CreateBitmapFromFile("image.png")
	Width := Gdip_GetImageWidth(image), Height :=Gdip_GetImageHeight(image)
	Gdip_DrawImage(G, image,10,10,250,250,0,0,Width,Height)
	table:=db.query("SELECT descricao FROM " prefixpt modelpt "Desc;")
	panel({x: 265 , y: 10 ,w:550,h:250,text2:table["descricao"],text2size: 40,text2color:"000000",textcolor:"000000",color: "nocolor",boardsize: 0})
	panel({x:10,y: 265,w: 90,h: 80,text2:prefixpt2,color: "nocolor",boardsize: 0,textcolor:"000000",text2color:"000000"})
	panel({x:105,y: 265,w: 90,h: 80,text2:modelpt,color: "nocolor",boardsize: 0,textcolor:"000000",text2color:"000000"})
	ix:=200,iy:=265
	for,each,value in list:=db.getvalues("Campos",camptable){
		campname:=list[A_Index,1]
		StringReplace,campname,campname,%A_Space%,,All
		result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='" campname "' AND tabela1='" prefixpt modelpt selectmodel "'")
		camplist:=result["tabela2"]
		for,each,value in list2:=db.getvalues("CODIGO,DR",camplist){
			if(A_Index=1){
				i2y:=iy
				panel({x:ix,y:i2y,w: 90,h: 80,text:list2[A_Index,2],text2y:40,text2:list2[A_Index,1],color: "nocolor",boardsize: 0,textcolor:"000000",text2color:"000000"})
			}else{
				i2y+=85 
				panel({x:ix,y:i2y,w: 90,h: 80,text:list2[A_Index,2],text2y:40,text2:list2[A_Index,1],color: "nocolor",boardsize: 0,textcolor:"000000",text2color:"000000"})
			}	 
		} 	
		ix+=100
	} 
	FileDelete,testeplot.png  
	Gdip_SaveBitmapToFile(pBitmap,A_WorkingDir "\temp\" prefixpt2 modelpt "grupo.png")
	Gdip_DisposeImage(pBitmap)
	Gdip_DisposeImage(image)
	if(_showcode=1)
		run,% A_WorkingDir "\temp\" prefixpt2 modelpt "grupo.png"
	return 
}

/*
	Funcao especifica usada na insercao do modelo 
*/
change_info(v_info){
	Global

	e_info := []
	e_info.empresa[2] := empresa.mascara
	e_info.tipo[2] := tipo.mascara
	e_info.familia[2] := familia.mascara
	e_info.subfamilia[2] := v_info.subfamilia[2]
	e_info.modelo[2] := v_info.modelo[2]

	e_info.empresa[1] :=  empresa.nome
	e_info.tipo[1] := tipo.nome
	e_info.familia[1] := familia.nome
	e_info.subfamilia[1] := v_info.subfamilia[1]
	e_info.modelo[1] := v_info.modelo[1]

	return e_info
}

existindb(connection, sql){  ;connection fora da classe sql 
	if(!IsObject(connection)){
	 	MsgBox,16, Erro,% "A conexao falhou, confira os parametros"
	 	return
	}
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

plot_pt_code_list(){
	global
	;## calcula o tamanho do arquivo final ##.
	newgdi({w:680,h:items_to_plot.maxindex()*170})
	panel({x:0,y:0,w:680,h:items_to_plot.maxindex()*170,color: "white",boardcolor: "0x00000000"})
	y := 10  
	for,each,item in items_to_plot{
		prefixpt := EmpresaMascara AbaMascara FamiliaMascara items_to_plot[A_Index,2] 
		result := db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" EmpresaMascara AbaMascara FamiliaMascara items_to_plot[A_Index,2] items_to_plot[A_Index,1] "'") 
		model_image := result["tabela2"]
		result.close()
		IfnotExist,% A_WorkingDir "\img\" model_image ".png"
		{
			model_image := db.load_image_to_file("","",model_image)
		}
		image := Gdip_CreateBitmapFromFile(A_WorkingDir "\img\" model_image ".png")
		Width := Gdip_GetImageWidth(image), Height := Gdip_GetImageHeight(image)
		Gdip_DrawImage(G,image,10,y,100,100,0,0,Width,Height)
		Gdip_DisposeImage(image)
		table := db.query("SELECT descricao FROM " prefixpt "Desc;")
		panel({x: 110 , y: y ,w:550,h:100,text2:table["descricao"],text2size: 20,text2color:"000000",textcolor:"000000",color: "nocolor",boardsize: 0})
		updateprogress("Imprimindo : " prefixpt items_to_plot[A_Index,1],1)
		y += 120
	}
	Gdip_SaveBitmapToFile(pBitmap,A_WorkingDir "\temp\" FamiliaName ".png")
	Gdip_DisposeImage(pBitmap)
	run,% A_WorkingDir "\temp\" FamiliaName ".png"
	return 
}

remove_t(code){
	StringLeft,testprefix,code,3
	if(testprefix="mpt")
		StringReplace,code,code,MPT,MP, All    ;SUBSTITUI O MPT POR MP
	if(testprefix="mod")
		StringReplace,code,code,MODT,MOD, All    ;SUBSTITUI O MODT POR MOD
	return code
}

load_cert_status(info){
	Global db 

	tabela1 := get_prefix_from_info(info) info.modelo[1]
	rel_value := db.find_items_where(" tipo = 'certificado' AND tabela1 = '" tabela1 "'", "reltable")
	cert_values := db.find_items_where(" modelo ='" rel_value[1, 3] "'", "certificados")
	if(cert_values[1, 1] != ""){
		expiration_date := cert_values[1, 5]
		StringLeft, expiration_date, expiration_date, 8
		StringLeft, year, expiration_date, 4
		StringTrimLeft, sub_exp, expiration_date, 4
		StringLeft, month, sub_exp, 2
		StringRight, day, expiration_date, 2
		Gui, M:default
		GuiControl, , cert_status, % "Vencimento certificado: " day "/" month "/" year	
	}else{
		GuiControl, , cert_status, % ""
	}
}


export_code_list_to_file(code_list,family_name,model_name){	
	if(!code_list || !model_name){
		MsgBox,64,,% "A lista de modelos ou o nomde do modelo estava em branco!"
		Return
	}
	IfnotExist,% A_WorkingDir "\temp\lists\" model_name 
	{
		FileCreateDir, %  A_WorkingDir "\temp\lists\" model_name
	}	
	FileDelete,% A_WorkingDir "\temp\lists\" model_name "\" family_name model_name ".csv"
	fields_to_insert:=
	(JOIN
		"B1_COD"
		";B1_XDESC"
		";B1_DESC"
		";B1_POSIPI"
		";B1_UM"
		";B1_ORIGEM"
		";B1_CONTA"
		";B1_TIPO"
		";B1_GRUPO"
		";B1_IPI"
		";B1_LOCPAD"
		";B1_GARANT"
		";B1_CODBAR"
	)
	FileAppend,% fields_to_insert "`n",% A_WorkingDir "\temp\lists\" model_name "\" family_name model_name ".csv"
	progress(code_list.maxindex())
	for,each,value in code_list{
			updateprogress("Inserindo valores no arquivo: " code_list[A_Index,1],1)
			value_to_insert:=
			(JOIN
				remove_t(code_list[A_Index,1]) ";"
				code_list[A_Index,2] ";"
				code_list[A_Index,3] ";"
				code_list[A_Index,4] ";"
				code_list[A_Index,5] ";"
				code_list[A_Index,6] ";"
				code_list[A_Index,7] ";"
				code_list[A_Index,8] ";"
				code_list[A_Index,9] ";"
				code_list[A_Index,10] ";"
				code_list[A_Index,11] ";"
				"2;"
				code_list[A_Index,1] ";"
			)
			FileAppend,% value_to_insert "`n",% A_WorkingDir "\temp\lists\" model_name "\" family_name model_name ".csv"	
	}
	gui,progress:destroy 
	MsgBox,64,,% "Os Arquivos foram salvos em" A_WorkingDir "\temp\lists\" model_name "\" family_name model_name ".csv"
}

;############logopromto##################################
promtologo(colors,w,h,notext){
	global 
	newgdi({w:w,h:h})
	if(notext!=1){
		L:=w*0.4
		;panel({x:0,y:0,w:w,h:h,color:"grey",boardcolor: "0xff000000",boardsize:5})
		panel({x:w*0.37,y:h*0.026,w:L,h:L,color: colors[3],boardcolor: "0xffffffff",boardsize: w*0.01})
		panel({x:w*0.31,y:h*0.18,w:L*0.8,h:L*0.8,color: colors[2],boardcolor: "0xffffffff",boardsize:w*0.01})
		panel({x:w*0.27,y:h*0.36,w:L*0.5,h:L*0.5,color: colors[1],boardcolor: "0xffffffff",boardsize:w*0.01})
		txcolor1:=getcolors(colors[4]) , txcolor2:=getcolors(colors[5])
		txcolor1:=txcolor1[1] , txcolor2:=txcolor2[2]
		StringReplace,txcolor1,txcolor1,0x,, All
		StringReplace,txcolor2,txcolor2,0x,, All
		panel({x:w*0.06,y:h*0.62,w:w*0.85,h:L*0.3,color: "nocolor",text: "ProMTo!!!",textcolor: txcolor1, textsize:w*0.16,boardcolor: "0x00000000",textalign:"Centre"})
		panel({x:w*0.04,y:h*0.82,w:w*0.9,h:L*0.3,color: "nocolor",text: "product manager tool",textcolor: txcolor2, textsize: w*0.08,boardcolor: "0x00000000",textalign:"Centre"})		
	}else{
		L:=w*0.55
		panel({x:w*0.27,y:h*0.040,w:L,h:L,color: colors[3],boardcolor: "0xffffffff",boardsize:w*0.01})
		panel({x:w*0.21,y:h*0.23,w:L*0.8,h:L*0.8,color: colors[2],boardcolor: "0xffffffff",boardsize:w*0.01})
		panel({x:w*0.17,y:h*0.54,w:L*0.5,h:L*0.5,color: colors[1],boardcolor: "0xffffffff",boardsize:w*0.01})
	}
	return
}


;##############banner#########################
banner(color,ByRef Variable, Text="", TextOptions="x0p y10 s30 Center cffffffff r4 Bold", Font="verdana",r=5)
{
    GuiControlGet, Pos, Pos, Variable
    GuiControlGet, hwnd, hwnd, Variable
    pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)
    w:=posw,h:=posh
    colors:=getcolors(color)
	pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h,colors[1],colors[2])
	Gdip_FillRoundedRectangle(G, pBrush, 0, 0, w, h,r)
	Gdip_DeleteBrush(pBrush)
    Gdip_TextToGraphics(G,Text,TextOptions, Font, Posw, Posh)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    SetImage(hwnd, hBitmap)
    Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
    Return, 0
}

addbutton(bargs){
	Static x,count
	name := bargs["name"],label := bargs["label"],window := bargs["window"]
	w := bargs["w"],h := bargs["h"]
	Gui,%window%:default
	if(bargs["count"]=1){
		x:=bargs["initialx"],y:=bargs["initialy"]
		count:=bargs["count"]
		Gui,Add,Button,x%x% y%y% w%w% h%h%  g%label%,% name
	}else{
		if(objHasValue(bargs["buttonfield"],bargs["count"])){
			x+=bargs["w"],y:=bargs["initialy"]
			Gui,Add,Button,x%x% y%y% w%w% h%h%  g%label%,% name
		}else{
			Gui,Add,Button,y+5 w%w% h%h%  g%label%,% name
		}
	}
	bargs["count"]+=1
	Gui, Show, AutoSize Center
}

GetSelectedItems(wName = "", lvName = "", type = "text"){
	Global 
	Local returnValue
	if(wName != ""){
		Gui,%wName%:default
	}
	if(lvName != ""){
		Gui, listview, %lvName%
	}
	returnValue := []
	if(type = "text"){
		rownumber := 0
		Loop 
		{
			rownumber := LV_GetNext(rownumber)  ; Resume the search at the row after that found by the previous iteration.
    	if not rownumber  ; The above returned zero, so there are no more selected rows.
        break
			LV_GetText(text,rownumber)
			returnValue[A_Index] := text
		}
	}
	if(type = "number"){
		rownumber := 0
		Loop
		{
			rownumber := LV_GetNext(rownumber)
			if not rownumber  ; The above returned zero, so there are no more selected rows.
        break
			returnValue[A_Index] := rownumber
		}
	}
	return returnValue
}

/*
 Remove os items selecionados na determinada 
 listview
*/
remove_selected_in_lv(window_name, lv_name){
	rownumber := 0
	Gui, %window_name%:default 
	Gui, Listview, %lv_name%
	GuiControl, -Redraw, %lv_name% 
	selected_rows := []
	Loop
	{
		rownumber := LV_GetNext(rownumber)
		if not rownumber  ; The above returned zero, so there are no more selected rows.
      break
    selected_rows[A_Index] := rownumber 
	}
	alredy_removed := 0
	removed_count := 0
	for, each, value in selected_rows{
		selected_tbr := selected_rows[A_Index] 
		if(alredy_removed){
			removed_count++
			selected_tbr-=removed_count 
		}
		LV_GetText(selected_text, selected_tbr)
		LV_Delete(selected_tbr)
		alredy_removed := 1
	}
	GuiControl, +Redraw, %lv_name%
}


/*
	RETORNA O VALOR DA PRIMEIRA COLUNA DA LINHA SELECIONADA NA LISTVIEW
*/

GetSelected(wName="",lvName="",type="text"){
	Global 
	Local returnValue
	if(wName != ""){
		Gui,%wName%:default
	}
	if(lvName != ""){
		Gui, listview, %lvName%
	}
	if(type = "text"){
			LV_GetText(returnValue, LV_GetNext())
	}
	if(type = "number"){
			returnValue := LV_GetNext()
	}
	return returnValue
}

;############flip########################
Flip( Str) {
 Loop, Parse, Str
  nStr=%A_LoopField%%nStr%
Return nStr
}
;############reversearray########################
reversearray(array){
	x:=-1,newarray:=[]
	for,each,value in array{
		x+=1
		;MsgBox, % value
		newarray.insert(array[array.maxindex()-x])
	}
	return newarray
}


;###########GetSelectedRow#######################
GetSelectedRow(wName="",lvName=""){
	Global 
	Local returnValue
	if(wName!=""){
		Gui,%wName%:default
	}
	if(lvName!=""){
		Gui,listview,%lvName%
	}
	
	i:=0
	result:=object()
	row:=LV_GetNext()
	Loop,% LV_GetCount("col"){
		i+=1
		LV_GetText(value,row,i)
		result.insert(value)
	}
	return result
}

UpdateScrollBars(GuiNum, GuiWidth, GuiHeight)
{
    static SIF_RANGE=0x1, SIF_PAGE=0x2, SIF_DISABLENOSCROLL=0x8, SB_HORZ=0, SB_VERT=1
    ;msgBox, %GuiNum%
    Gui, %GuiNum%:Default
    Gui, +LastFound
    
    ; Calculate scrolling area.
    Left := Top := 9999
    Right := Bottom := 0
    WinGet, ControlList, ControlList
    Loop, Parse, ControlList, `n
    {
        GuiControlGet, c, Pos, %A_LoopField%
        if (cX < Left)
            Left := cX
        if (cY < Top)
            Top := cY
        if (cX + cW > Right)
            Right := cX + cW
        if (cY + cH > Bottom)
            Bottom := cY + cH
    }
    Left -= 8
    Top -= 8
    Right += 8
    Bottom += 8
    ScrollWidth := Right-Left
    ScrollHeight := Bottom-Top
    
    ; Initialize SCROLLINFO.
    VarSetCapacity(si, 28, 0)
    NumPut(28, si) ; cbSize
    NumPut(SIF_RANGE | SIF_PAGE, si, 4) ; fMask
    
    ; Update horizontal scroll bar.
    NumPut(ScrollWidth, si, 12) ; nMax
    NumPut(GuiWidth, si, 16) ; nPage
    DllCall("SetScrollInfo", "uint", WinExist(), "uint", SB_HORZ, "uint", &si, "int", 1)
    
    ; Update vertical scroll bar.
;     NumPut(SIF_RANGE | SIF_PAGE | SIF_DISABLENOSCROLL, si, 4) ; fMask
    NumPut(ScrollHeight, si, 12) ; nMax
    NumPut(GuiHeight, si, 16) ; nPage
    DllCall("SetScrollInfo", "uint", WinExist(), "uint", SB_VERT, "uint", &si, "int", 1)
    
    if (Left < 0 && Right < GuiWidth)
        x := Abs(Left) > GuiWidth-Right ? GuiWidth-Right : Abs(Left)
    if (Top < 0 && Bottom < GuiHeight)
        y := Abs(Top) > GuiHeight-Bottom ? GuiHeight-Bottom : Abs(Top)
    if (x || y)
        DllCall("ScrollWindow", "uint", WinExist(), "int", x, "int", y, "uint", 0, "uint", 0)
}

;############banner1############################################################################

banner1(color,Variable,Text="",TextOptions="x0p y15p s60p Center cffffffff r4 Bold", Font="verdana",r=1)
{
    GuiControlGet, Pos, Pos,%Variable%
    GuiControlGet, hwnd, hwnd,%Variable%
    pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)
    w:=posw,h:=posh
    colors:=getcolors(color)
	pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h,colors[1],colors[2])
	Gdip_FillRoundedRectangle(G, pBrush, 0, 0,w,h,r)
	Gdip_DeleteBrush(pBrush)
    Gdip_TextToGraphics(G,Text, TextOptions, Font, Posw, Posh)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    SetImage(hwnd, hBitmap)
    Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
    Return, 0
}

;############CREATE TREEVIEW############################################
CreateTreeView(TreeViewDefinitionString) {  ; by Learning one
  Global nameid:={},idlist:=object()
  
  IDs := {}   
  k:=1
  Loop, parse, TreeViewDefinitionString, `n, `r
  {
    if A_LoopField is space
      continue
    Item := RTrim(A_LoopField, A_Space A_Tab), Item := LTrim(Item, A_Space), Level := 0
    While (SubStr(Item,1,1) = A_Tab)
      Level += 1, Item := SubStr(Item, 2)
    RegExMatch(Item, "([^`t]*)([`t]*)([^`t]*)", match)  ; match1 = ItemName, match3 = Options
    if(_dontchange!=1){
      icon:="icon1"
    }
    if(match1="PRODUTOS ACABADOS"){
        icon:="icon2"
        _dontchange := 1
      }
      if(match1="PRODUTOS SEMI-ACABADOS"){
        icon:="icon3"
        _dontchange := 1
      }
      if(match1="MATERIA PRIMA"){
        icon:="icon4"
        _dontchange := 1
      }
      if(match1="PRODUTOS INTERMEDIARIOS"){
        icon:="icon5"
        _dontchange := 1
      }
      if(match1="CONJUNTOS"){
        icon:="icon6"
        _dontchange := 1
      }
      if(match1="MAO DE OBRA"){
        icon:="icon7"
        _dontchange := 1
      }
    if (Level=0){
      IDs["Level0"] := TV_Add(match1, 0,icon)
      nameid[match1]:= IDs["Level0"]
      idlist.insert(IDs["Level0"])
    }else{
      IDs["Level" Level] := TV_Add(match1, IDs["Level" Level-1],icon)
      nameid[match1]:= IDs["Level" Level]
      idlist.insert(IDs["Level" Level])
    }
  }

} ; http://www.autohotkey.com/board/topic/92863-functio

;#############load treeview ##########################
loadtv(tvstring,tv){
	TvDefinition=
	(
	%tvstring%
	)
	gui,treeview,%tv%
	TV_Delete()
	CreateTreeView(TvDefinition)
	return 
}
;################getchild#########################
getchild(itemid,tv,nivel){
	Global newtvstring
	gui,TreeView,%tv%
	ItemID := TV_GetChild(itemid)
	if not ItemID  
        return 
	TV_GetText(ItemText,ItemID)
	nivel.="`t"
	newtvstring.=nivel ItemText "`n"
	;loop do mesmo nivel da crianca
	Loop
    {
        itemid:=TV_GetNext(itemid)
        if not ItemID  
          break
        TV_GetText(ItemText,ItemID)
        newtvstring.=nivel ItemText "`n"
      	;MsgBox, % newtvstring  
      	getchild(ItemID,"treeview",nivel)     
    }
    return 
}
;################haschild#########################
haschild(itemid,wname,tv){
	gui,%wname%:default
	gui,treeview,%tv%
	ItemID := TV_GetChild(itemid)
	if not ItemID  
        return False
    return True 
}

get_info_in_string(info){
	code_table := info 
}

;############# load lv from array ################
load_lv_from_array(columns, array, window, lv, col_sizes = "", start_at = "1"){
	Gui, %window%:default
	Gui, Listview, %lv%

	/*
		Deleta todas as colunas existentes
	*/
	Loop, % columns.maxindex(){
		LV_DeleteCol(1)
	}

	LV_Delete()
	prev_count := 0
	line_count := 0
	column_count := 0

	Gui, %window%:default
	Gui, Listview, %lv%
	GuiControl, -Redraw, %lv% 
	loop, % columns.maxindex(){
		loop, % array[A_Index].maxindex(){
			if(A_Index < start_at)
				Continue

			if(A_Index > column_count){
				col_number := A_Index
				LV_InsertCol(col_number,"",columns[A_Index])	
				column_count++
			}
			loop, % array.maxindex(){
				if(A_Index > line_count){
					LV_Add("","","")
					line_count++	
				}
				LV_Modify(A_Index, "Col" . col_number, array[ A_Index, col_number])
			}
		}	
	}
	for, each, size in col_sizes{
	  LV_ModifyCol(A_Index, size)
	} 
	GuiControl, +Redraw, %lv%
}


load_lv_from_matrix(number_of_columns, array, window, lv){
	Gui, %window%:default
	Gui, Listview, %lv%

	prev_count := 0
	loop, % array.maxindex(){
		row_number := A_Index
		if(row_number = "")
			Continue
		LV_Add("","","")
		Loop, % number_of_columns{
			LV_Modify(row_number, "Col" . A_index, array[row_number, A_Index])			
				LV_ModifyCol(A_Index, 200)
		}
	}
}

/*
	Transform array
*/
transform_array(array){
	return_array := []

	for, each, value in array{
		return_array[A_Index, 1] := array["code", A_Index]
		return_array[A_Index, 2] := array["desc", A_Index]
	}
	return return_array
}

;############### createtag #################################
createtag(prefix, prefix2, model, selectmodel, codelist, codigos_array = "", textsize = 30, textcolor = "ff000000", imagepath = "image.png"){
	Global db, global_image_path

	code_rect_size := 130 ; tamanho do retangulo onde vai o codigo
	code_rect_spacing := 135 ; tamanho do espacamento entre os retangulos 

	if(codigos_array[1, 1] = ""){
		table := db.load_table_in_array(codelist)
	}else{
		table := codigos_array
	}
	
	progress(table.maxindex())
	totalheight := 500.17 * table.maxindex()
	newgdi({w:1200, h:totalheight})
	prefix_in_string := get_prefix_in_string(prefix2)
	StringLen, prefixlength, prefix_in_string
	
	y := 80
	 
	panel({x:0, y:0, w:1200, h:totalheight, color: "white", boardcolor: "0x00000000"})
	
	for, each, value in table{
		if(table[A_Index,1] = "")
			Continue
		x:=30	
		updateprogress("Criando Tags: " table[A_Index,1],1)
		
		; Pega a imagem
		imagepath := db.Imagem.get_image_full_path(table[A_Index, 1])
		
		/*
			Insere o prefixo
		*/
		f_hight := y-60
		for, each, value in prefix2{
			if(prefix2[A_Index] = "")
				Continue
			panel({x:x, y:f_hight, w:code_rect_size, h:50, color: "nocolor", text:"Prefixo", textsize: 10, textcolor: textcolor, boardersize:0})
			panel({x:x, y:f_hight+60, w:code_rect_size, h:50, color: "nocolor", text:prefix2[A_Index], textsize: textsize, textcolor: "ffff3311"})	
			x += code_rect_spacing
		}
		x -= code_rect_spacing

		codigo := table[A_Index,1]	

		StringTrimleft,codigo,codigo, prefixlength
		
		/*
			Pega a tabela de campos, para pegar o nome dos campos
		*/
		camp_table := db.get_reference("oc", prefix model selectmodel)
		
		table_camp := db.load_table_in_array(camp_table)

		for, each, value in table_camp{
			if(table_camp[A_Index, 2] = ""){
				Continue
			}

			campname := table_camp[A_Index, 2]
			StringReplace, campname, campname, %A_Space%,, All
			camp_esp_table := db.get_reference(campname, prefix model selectmodel)
			
			table_camp_esp := db.load_table_in_array(camp_esp_table)

			for, each, value in table_camp_esp{
				codepiece := table_camp_esp[A_Index,1]
				StringLen, length, codepiece
				if(length != ""){
					StringLeft, codepiece, codigo, length
					StringTrimLeft, codigo, codigo, length
					Break
				}
			} 	
			/*
				Insere os campos especificos
			*/
			panel({x:x+=code_rect_spacing,y:y-60,w:code_rect_size,h:50,color: "nocolor",text: table_camp[A_Index,2], textsize:8, textcolor: textcolor})
			panel({x:x, y:y, w:code_rect_size, h:50, color: "nocolor", text:codepiece, textsize: textsize, textcolor: textcolor})
		}

		; Insere a foto na plaqueta  
		panel({x:30,y:y+=60,w:200,h:200,color: "nocolor", imagepath: imagepath})

		/*
			Insere a descricao
		*/
		panel({x:245,y: y,w: 800,h: 200,color: "nocolor",text: table[A_Index,2],textsize: 30,textcolor: textcolor})	

		dottedliney := y + 234.17	
		pPen := Gdip_CreatePen(0xff000000, 3)
		DrawDottedLine(0, dottedliney, 1500, dottedliney)
		Gdip_DeletePen(pPen)
		y += 234.17+81
	}
	Gui,progress:destroy
	MsgBox, 64, Sucesso, % "O arquivo foi salvo!!"
	formated_model := format_file_name(selectmodel)
	savetofile("temp\tag.png")
	MsgBox, % "ira rodar o arquivo temp\tag.png" 
	run, % "temp\tag.png"
}

get_prefix_in_string(table){
	
	for, each, value in table{
		return_value .= table[A_Index]
	}
	return return_value
}

DrawDottedLine(sx,sy,ex,ey){
	Global 
	Loop{
		ex2:=sx+10
		Gdip_DrawLine(G, pPen,sx,sy,ex2,sy)
		sx+=15
		if(sx>ex)
			Break
	}
}

GetCheckedRows2(wName = "", lvName = ""){

	if(wName != "")
		Gui, %wName%:default

	if(lvName != "")
		Gui, listview, %lvName%

	result := {}
	RowNumber = 0  
	
	Loop
	{ 
    RowNumber := LV_GetNext(RowNumber, "Checked")  ; Resume the search at the row after that found by the previous iteration.
    if not RowNumber  ; The above returned zero, so there are no more selected rows.
     break

    LV_GetText(Text, RowNumber)
    LV_GetText(Desc, RowNumber,2)
    result["code", A_Index] := Text
    result["desc", A_Index] := Desc
	}

	return result
}

GetCheckedRows(wName="",lvName=""){

	Local returnValue
	if(wName!=""){
		Gui,%wName%:default
	}
	if(lvName!=""){
		Gui,listview,%lvName%
	}
	result:=object()
	k:=0
	Loop, % LV_GetCount()
	{
		row:=A_Index
		SendMessage,4140,row - 1, 0xF000, SysListView321 
		IsChecked := (ErrorLevel >> 12) - 1
		i:=0
		if (IsChecked!=1)
			continue
		k++
		Loop,% LV_GetCount("col"){
			i+=1
			LV_GetText(value,row,i)
			result[k,i]:=value
		}
	}
	return result
}

;################progress###################
updateprogress(text,increase){
    Global progress,plabel
    GuiControl,,progress,+%increase%
    GuiControl,,plabel,%text%   
}


progress(maxrange, stop_progress_func_local="", undetermined=0, toolwindow=0){
  Global progress,plabel,stop_progress_func
  
  ;declara a funcao a ser rodada quando o botao parar e acionado.
  stop_progress_func := stop_progress_func_local

  Gui,progress:New 
  Gui,color,ffffff
  if(toolwindow=1)
  	Gui,progress:-caption +toolwindow
  Gui, Add, Picture, x40 , % "img\promtologo.png"
  if(undetermined=0){
  	Gui, Add, Progress, w300 h20 x10 c2661dd Range0-%maxrange% vprogress
  }
  Else{
  	Gui, Add, Progress, vprogress  -Smooth 0x8 w300 h18 x10
  	SetTimer, undeterminedprogressaction, 45
  }
  Gui,font,s8
  Gui,Add,text,w300 y+5 vplabel
  Gui,Show,,progresso
} 

;parar_processo:
;%stop_progress_func%()
;return 

undeterminedprogressaction:
gui,progress:default
GuiControl,,progress, 1

pesquisa_simple_array(wname,lvname,string,List){
	Gui,%wname%:default
  Gui,listview,%lvname%
  ;caso a string esteja vazia
	If (string = ""){
		GuiControl, -Redraw,%lvname% 
    LV_Delete()
    for,each,value in List
        LV_Add("",value)

    GuiControl, +Redraw,%lvname%       
    return
  }
	result := []
	for each,value in List{

		IfInString,value,%string%
		{
			result.insert(value)
		}
	}
	GuiControl, -Redraw,%lvname%
	LV_Delete()
	for each,value in result{
		LV_Add("",value)
	}
	GuiControl, +Redraw,%lvname%
}

pesquisalv(wname,lvname,string,List){
	Gui,%wname%:default
    Gui,listview,%lvname%
    GuiControl, -Redraw,%lvname%
    Gui, Submit, NoHide
    resultsearch:=[] 
    If (string=""){ 
        LV_Delete()
        for,each,value in List{
            LV_Add("",List[A_Index,1],List[A_Index,2])
        }       
    }Else{
        for,each,value in List{
            i++
            string2:=List[A_Index,1] List[A_Index,2]
            IfInString,string2,%string%
            {
                resultsearch.insert(i)
            }
        }
        i:=0
        LV_Delete()
        for,each,value in resultsearch{
            LV_Add("",List[value,1],List[value,2])
        }
    }
    GuiControl, +Redraw,%lvname%
    LV_Modify(1, "+Select")
}

any_word_search(wname, lvname, string, List){
	Gui,%wname%:default
  Gui, listview,%lvname%
  GuiControl, -Redraw,%lvname%
  Gui, Submit, NoHide

    resultsearch := [] 
    If (string = ""){ 
      LV_Delete()
      for,each,value in List{
        LV_Add("",List[A_Index,1],List[A_Index,2], List[A_Index, 3], List[A_Index, 4],  List[A_Index, 5], List[A_Index, 6])
      }       
    }Else{
      for,each,value in List{
        i++

        string2 := List[A_Index, 1] List[A_Index, 2] List[A_Index, 3]

        StringSplit, splitted_string, string,%A_Space%

        _exists_in_all := 0
				Loop,% splitted_string0
				{
					value_to_search := trim(splitted_string%A_Index%)
					IfInString, string2, %value_to_search%
          {
            _exists_in_all := 1
          }else{
          	_exists_in_all := 0
          	Break
          }	
				}
				if(_exists_in_all = 1)
					resultsearch.insert(i)
      }
      i := 0
      LV_Delete()
      for, each, value in resultsearch{
          LV_Add("",List[value,1], List[value,2], List[A_Index, 3], List[A_Index, 4],  List[A_Index, 5], List[A_Index, 6])
      }
    }
    GuiControl, +Redraw,%lvname%
    LV_Modify(1, "+Select")
}

any_word_search_backup(wname, lvname, string,List){
	Gui,%wname%:default
    Gui,listview,%lvname%
    GuiControl, -Redraw,%lvname%
    Gui, Submit, NoHide
    resultsearch:=[] 
    If (string=""){ 
        LV_Delete()
        for,each,value in List{
            LV_Add("", List[A_Index, 1], List[A_Index, 2], List[A_Index, 3], List[A_Index, 4],  List[A_Index, 5], List[A_Index, 6])
        }       
    }Else{
        for,each,value in List{
            i++
            string2:=List[A_Index,1] List[A_Index,2]
            StringSplit,splitted_string,string,%A_Space%
            _exists_in_all:=0
			Loop,% splitted_string0
			{
				value_to_search:=trim(splitted_string%A_Index%)
				IfInString,string2,%value_to_search%
	            {
	                _exists_in_all:=1
	            }else{
	            	_exists_in_all:=0
	            	Break
	            }
				;MsgBox, % result%A_Index%	
			}
			if(_exists_in_all=1)
				resultsearch.insert(i)
        }
        i:=0
        LV_Delete()
        for,each,value in resultsearch{
            LV_Add("",List[value,1],List[value,2], List[A_Index, 3], List[A_Index, 4],  List[A_Index, 5], List[A_Index, 6])
        }
    }
    GuiControl, +Redraw,%lvname%
    LV_Modify(1, "+Select")
}

pesquisalv3(wname,lvname,string,List){     ;## PESQUISAR PARA 3 COLUNAS#### 
	Gui,%wname%:default
    Gui,listview,%lvname%
    GuiControl, -Redraw,%lvname%
    Gui, Submit, NoHide
    resultsearch:=[] 
    If (string=""){ 
        LV_Delete()
        for,each,value in List{
            LV_Add("",List[A_Index,1],List[A_Index,2],List[A_Index,3])
        }       
    }Else{
        for,each,value in List{
            i++
            string2:=List[A_Index,1] List[A_Index,2] List[A_Index,3]
            IfInString,string2,%string%
            {
                resultsearch.insert(i)
            }
        }
        i:=0
        LV_Delete()
        for,each,value in resultsearch{
            LV_Add("",List[value,1],List[value,2],List[value,3])
        }
    }
    GuiControl, +Redraw,%lvname%
    LV_Modify(1, "+Select")
} 

pesquisalv4(wname,lvname,string,List){     ;## PESQUISAR PARA 3 COLUNAS#### 
	Gui,%wname%:default
    Gui,listview,%lvname%
    GuiControl, -Redraw,%lvname%
    Gui, Submit, NoHide
    resultsearch:=[] 
    If (string=""){ 
        LV_Delete()
        for,each,value in List{
        		if(List[A_Index,1] = "")
        			Continue
            LV_Add("",List[A_Index,1],List[A_Index,2],List[A_Index,3],List[A_Index,4])
        }       
    }Else{
        for,each,value in List{
            i++
            string2:=List[A_Index,1] List[A_Index,2] List[A_Index,3] List[A_Index,4]
            IfInString,string2,%string%
            {
                resultsearch.insert(i)
            }
        }
        i:=0
        LV_Delete()
        for,each,value in resultsearch{
            LV_Add("",List[value,1],List[value,2],List[value,3],List[A_Index,4])
        }
    }
    GuiControl, +Redraw,%lvname%
    LV_Modify(1, "+Select")
} 

;##############getvaluesLV#####################

getvaluesLV(wName,lvName)   ;extrai todos os valores de uma listview e retorna um array.
{
	values := []
	i := 0
	gui, %wName%:default 
	Gui, listview, %lvName%

	Loop, % LV_GetCount("Column")
	{
		i+=1
		Loop, % LV_GetCount()
		{
			LV_GetText(text,A_Index,i)
			values[A_Index,i] := text
		}
	}
	return values
}

;################objhasvalue###################
objHasValue(obj,value){
	for,each,value2 in obj
		IfEqual,value2,%value%,return,True
}
/*
	Retorna a mascara
*/
getmascara(name,table,field){
	Global db 
	
	result:=db.query("SELECT Mascara FROM " . table . " WHERE " . field . "='" . name . "'")
	returnvalue:=result["Mascara"]
	return returnvalue	
}

/*
	Mensagem de erro 
*/
error_msg(msg){
	MsgBox, 16, Erro, % msg
	return 0 
}

check_blank_parameters(parameters, number){
	loop, % number
	{
		if(parameters[A_Index] = ""){
			return 0
		}
	}
	return 1
}

check_if_mask_is_unique(item_name, item_mask){
	Global ETF_hashmask 
	if(ETF_hashmask[item_name] != "" && ETF_hashmask[item_name] != item_mask){
		error_msg :=
		(JOIN
			"Ja existe uma outra mascara linkada com o nome inserido! `n"
			"Voce pode usar a mesma mascara: " ETF_hashmask[item_name] "`n"
			" Ou alterar o nome."  
		)
		MsgBox, 4, Item duplicado, % error_msg 
		IfMsgBox Yes
		{
			item_mask := ETF_hashmask[item_name]
			MsgBox, % "A mascara foi alterada para " item_mask
			item_hash := {name: item_name, mask: item_mask}
			return item_hash
		}else{
			MsgBox, % "O item nao foi inserido, insira outra vez alterando o nome! "
			return 0
		}
	}else{
		item_hash := {name: item_name, mask: item_mask}
		return item_hash
	}
}

/*
Carrega a string do tv 
	principal
*/
load_ETF(db){
	Global 
	ETF_hashmask := {}
	db.get_treeview("empresas",0,"","")
}

/*
 Carrega a propia ETF_TVSTRING 
 na treeview 
*/
load_main_tv(){
		Global
		
		TvDefinition =
		(
			%ETF_TVSTRING%
		)
		Gui, Treeview, main_tv
		CreateTreeView(TvDefinition)
}

;############deletefromarray###########################
deletefromarray(string,array){
	for,each,value in array{
		if (string=value){
			array.Remove(each)
		}
	}
	for,each,value in array[1]{
		if (string=value){
			array.Remove(each)
		}
	}
	return array
}

;#################save an image to a file#####################
savetofile(imagename, show=0){
	Global pBitmap

	FileDelete, % imagename   
	Gdip_SaveBitmapToFile(pBitmap, imagename)
	Gdip_DisposeImage(pBitmap)
	if(show=1)
		run,%imagename%
}

newgdi(a){
	Global
	
	a.w:= (a.w="") ? 500 : a.w
	a.h:= (a.h="") ? 500 : a.h
	pBitmap := Gdip_CreateBitmap(a.w,a.h), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)
	return 
}

changepic(image){
	Static _showpic
	_showpic:=(_showpic="" || _showpic=2) ? 1 : 2
	if(_showpic=1){
		GuiControl,,plotpicture,% image
		GuiControl,hide,plotpicture2
		GuiControl,Show,plotpicture
	}
	if(_showpic=2){
		GuiControl,,plotpicture2,% image
		GuiControl,hide,plotpicture
		GuiControl,Show,plotpicture2
	}
	return 	
}

;############ imprime as estruturas ##############
printestrutura(item,offset,textcolor = "ff000000",ownercode = "",quantidade = ""){ ; o offset determina a distancia entre os items
	Global
	Local table,maincodes,quantidade_text_size
	squarecolor := "lightgrey", quantidade_text_size := 30
	if item =
		return
	nivel.="`t"
	offset += 30
	if(%ownercode% != "")
		%ownercode% := ""
	table := db.query("SELECT item,componente,QUANTIDADE FROM ESTRUTURAS WHERE item='" . item . "'")
	if(table["componente"] = ""){
		if(ownercode != ""){
		 	IfNotInString,%ownercode%,%item%
		 	{
		 		%ownercode% .= "`n" item
		 		StringReplace,item,item,>>,|,All
				StringSplit,item,item,|
		 		result := db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" item1 "'")
				if(result["tabela2"] != ""){
					imagepath := db.loadimage("","",result["tabela2"])
				}else{
					imagepath := "noimage.png"
				}
				result.close()
		 		panel({x:offset,y:y += 130,w:100,h:100,color: "nocolor",imagepath: imagepath,boardsize: 0})
		 		panel({x:offset+105,y:y,w:450,h:100,color:"nocolor",text:item1 "`n" item2,textsize:10,textcolor: textcolor,boardsize: 0})
		 		panel({x:offset+560,y:y,w:100,h:100,color:"nocolor",text:quantidade "`n",textsize:quantidade_text_size,textcolor: textcolor,boardsize: 0,textalign: "center"})
		 	}	
		 }else{
		 	IfNotInString,maincodes,%item%
		 	{
				maincodes .= "`n" item
		 		StringReplace,item,item,>>,|,All
				StringSplit,item,item,|
		 		result := db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" item1 "'")
				if(result["tabela2"] != ""){
					imagepath := db.loadimage("","",result["tabela2"])
				}else{
					imagepath := "noimage.png"
				}
				result.close()
				;StringLeft,codetype,item1,1
		 		panel({x:offset,y:y+=130,w:100,h:100,color: "nocolor",imagepath: imagepath,boardsize: 0})
		 		panel({x:offset+105,y:y,w:450,h:100,color:"nocolor",text:item1 "`n" item2,textsize:10,textcolor: textcolor,boardsize: 0})
		 		panel({x:offset+560,y:y,w:100,h:100,color:"nocolor",text:quantidade "`n",textsize:quantidade_text_size,textcolor: textcolor,boardsize: 0, textalign: "center"})
		 	}
		 }	
	 }
	while(!table.EOF){
		tableitem := table["item"]
		if(ownercode!=""){	
			IfNotInString,%ownercode%,%tableitem%
			{
				%ownercode%.="`n" tableitem
				StringReplace,tableitem,tableitem,>>,|,All
				StringSplit,tableitem,tableitem,|
				result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" tableitem1 "'")
				if(result["tabela2"]!=""){
					imagepath:=db.loadimage("","",result["tabela2"])
				}else{
					imagepath:="noimage.png"
				}
				result.close()
				;StringLeft,codetype,tableitem1,1
				panel({x:offset,y:y+=130,w:100,h:100,color: "nocolor",imagepath: imagepath,boardsize: 0})
		 		panel({x:offset+105,y:y,w:450,h:100,color:"nocolor",text:tableitem1 "`n" tableitem2,textsize: 10,textcolor: textcolor,boardsize: 0})
		 		panel({x:offset+560,y:y,w:100,h:100,color:"nocolor",text:quantidade "`n",textsize:quantidade_text_size,textcolor: textcolor,boardsize: 0, textalign: "center"})
			}
		}else{
			IfNotInString,maincodes,%tableitem%
		 	{
				maincodes.="`n" tableitem
				StringReplace,tableitem,tableitem,>>,|,All
				StringSplit,tableitem,tableitem,|
				result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" tableitem1 "'")
				if(result["tabela2"]!=""){
					imagepath:=db.loadimage("","",result["tabela2"])
				}else{
					imagepath:="noimage.png"
				}
				result.close()
				;StringLeft,codetype,tableitem1,1
				panel({x:offset,y:y+=210,w:100,h:100,color: "nocolor",imagepath: imagepath,boardsize: 0})
		 		panel({x:offset+105,y:y,w:450,h:100,color:"nocolor",text:tableitem1 "`n" tableitem2,textsize: 10,textcolor: textcolor,boardsize: 0})
		 		panel({x:offset+560,y:y,w:100,h:100,color:"nocolor",text:quantidade "`n",textsize:quantidade_text_size,textcolor: textcolor,boardsize: 0, textalign: "center"})
		 	}
		}
		StringReplace,parseditem,tableitem,>>,|,All
		StringSplit,parseditem,parseditem,|
		StringReplace,parseditem1,parseditem1,%A_Space%,,All
		printestrutura(table["componente"],offset,textcolor,parseditem1,table["QUANTIDADE"])
		table.MoveNext()
	}
	table.close()
	return 
}

;############PANEL###################################
panel(a){
	Global

	if(a.imagepath!=""){
		pBitmapFile1:=Gdip_CreateBitmapFromFile(a.imagepath)
		Width := Gdip_GetImageWidth(pBitmapFile1), Height := Gdip_GetImageHeight(pBitmapFile1)
		Gdip_DrawImage(G,pBitmapFile1,a.x,a.y,a.w,a.h,0,0,Width,Height)
	}
	colors:=getcolors((a.color="") ? "blue" : a.color)
	pBrush := Gdip_CreateLineBrushFromRect(a.x,a.y,(a.w="") ? 100 : a.w,(a.h="") ? 100 : a.h,colors[1],colors[2])
	Gdip_FillRoundedRectangle(G,pBrush,(a.x="") ? 100 : a.x,(a.y="") ? 100 : a.y,(a.w="") ? 100 : a.w,(a.h="") ? 100 : a.h,(a.r="") ? 1 : a.r)
	pPen := Gdip_CreatePen((a.boardcolor="") ? "0xff000000" : a.boardcolor,(a.boardsize="") ? 2 : a.boardsize)
	Gdip_DrawRoundedRectangle(G,pPen,a.x,a.y,a.w,a.h,a.r)
	a.textx:=(a.textx="") ? a.x+5 : a.x+a.textx
	a.texty:=(a.texty="") ? a.y+5 : a.y+a.texty
	a.textsize:=(a.textsize="") ? 8 : a.textsize
	a.textalign:=(a.textalign="") ? "left" : a.textalign
	a.textcolor:=(a.textcolor="") ? "ffffffff" : a.textcolor
	TextOptions:="x" a.textx " y" a.texty  " s" a.textsize " " a.textalign " c" a.textcolor  " r4 Bold",Font:=(a.font="") ? "arial" : a.font
	Gdip_TextToGraphics(G,a.text,TextOptions,Font,a.w,a.h) 
	a.text2x:=(a.text2x="") ? a.x+5 : a.x+a.text2x
	a.text2y:=(a.text2y="") ? a.y+20 : a.y+a.text2y
	a.text2size:=(a.text2size="") ? 20 : a.text2size
	a.text2align:=(a.text2align="") ? "left" : a.text2align
	a.text2color:=(a.text2color="") ? "ffffffff" : a.text2color
	TextOptions:="x" a.text2x " y" a.text2y  " s" a.text2size " " a.text2align " c" a.text2color  " r4 Bold",Font:=(a.font="") ? "arial" : a.font
	Gdip_TextToGraphics(G,a.text2,TextOptions,Font,a.w,a.h) 
	Gdip_DisposeImage(pBitmapFile1)
}

;##############MATHASVALUE###########################
MatHasValue(matrix, value){
		i:=0
		returnValue := False
		while(matrix[A_Index, 1] != ""){
			i+=1
			while(matrix[i, A_Index]!=""){
				if(matrix[i, A_Index] = value){
					returnValue := True
				}
			}
		}
		return returnValue
}

/*
	Transforma os arrays de multi
	para uma so dimensao
*/
singledim_array(array, col = 1){
	return_array := []
	loop, % array.maxindex(){
		return_array.insert(array[A_Index, col])
	}
	Return return_array
}

/*
	Marca todos os items de uma determinada listview
*/
check_all(window, listview){
	Gui, %window%:default
	Gui, Listview, %listview%
	Loop, % LV_GetCount()
		LV_Modify("","+check")	
}

/*
	Desmarca todos os items de determinada listview
*/
uncheck_all(window, listview){
	Gui, %window%:default
	Gui, Listview, %listview%
	Loop, % LV_GetCount()
		LV_Modify("","-check")	
}

remove_from_array(array, value){
	For, each, row in array{
		For, each, item in row{
			if(item = value){
				row.remove(A_Index)
			}
		}
	}
	return array
}

/*
	Deleta a linha da listview que comtem 
	determinado valor 
*/
delete_row_from_lv(window, lv, item_to_remove, everyone = 0){
	Gui, %window%:default
	Gui, Listview, %lv%
	
	values := getvaluesLV(window, lv)
	removed_items := ""
	removed_rows := ""
	for, each, row in values{
		row_number := A_Index
		for, each, item in row{
			if(item = item_to_remove){
				IfNotInString, removed_items, %item%
				{
					IfNotInString, removed_rows, %row_number%
					{
						LV_Delete(row_number)	
						removed_items .= item
						removed_rows .= row_number	
					}
				}else{
					if(everyone = 1){
						IfNotInString, removed_rows, %row_number%
						{
							LV_Delete(row_number)
							removed_rows .= row_number	
						}
					}
				}
			}	
		}
	}
}

/*
	Impede que caracteres ilegais sejam inseridos no 
	nome do arquivo
*/
format_file_name(file_name){
	file_name := Trim(file_name)
	unmodified_name := file_name 
	_ilegal_char := 0

	IfInString, file_name, "
	{
		StringReplace, file_name, file_name,",,All
		_ilegal_char := 1
	} 

	IfInString, file_name, '
	{
		StringReplace, file_name, file_name,',,All
		_ilegal_char := 1
	}

	IfInString, file_name, \
	{
		StringReplace, file_name, file_name,\,,All
		_ilegal_char := 1
	}

	IfInString, file_name, /
	{
		StringReplace, file_name, file_name,/,,All
		_ilegal_char := 1
	}

	IfInString, file_name, :
	{
		StringReplace, file_name, file_name,:,,All
		_ilegal_char := 1
	}

	IfInString, file_name, *
	{
		StringReplace, file_name, file_name,*,,All
		_ilegal_char := 1
	}

	IfInString, file_name, ?
	{
		StringReplace, file_name, file_name,?,,All
		_ilegal_char := 1
	}

	IfInString, file_name, <
	{
		StringReplace, file_name, file_name,<,,All
		_ilegal_char := 1
	}

	IfInString, file_name, >
	{
		StringReplace, file_name, file_name,>,,All
		_ilegal_char := 1
	}

	IfInString, file_name, |
	{
		StringReplace, file_name, file_name,|,,All
		_ilegal_char := 1
	}

	if(_ilegal_char = 1){
		MsgBox, 16, Erro, % "O nome do arquivo continha caracteres ilegais `n e foi alterado de " unmodified_name " para " file_name
		return
	}
	return file_name
}

/*
	Carrega as ultimas modificacoes do 
	determinado modelo na janela principal
*/
load_mod_info(info){
	Global db

	items := db.Log.get_mod_info(info)

	for, each, item in Items{
	  usuario := items[A_Index, 2]
	  hash := hashify(items[A_Index, 3])
	  data := items[A_Index, 4]
	  hora := items[A_Index, 5]
		string .= usuario " alterou o item " hash.modelo " em " data " as " hora "`n"
		mensagem .= items[A_Index, 6] "`n"
	} 
	Gui, M:default
	GuiControl,, mod_info, % string  
	GuiControl,, msg_info, % mensagem
}

/*
	Carrega o status do determinado item na janela 
	principal
*/
load_status_in_main_window(info){
	Global USER_NAME, db

	items := db.Status.get_status(info)

	if(items[1, 1] = ""){
		Gui, M:default
 		Gui, Font, s12 cBlack
 		GuiControl, Font, status_info
		GuiControl,, status_picture, % "img\gray_glossy_ball.png"
		GuiControl,, status_info, % "Nao foi feito"
		return  	
	}

	usuario := items[1, 2]
	status := items[1, 3]
	mensagem := items[1, 4]

	img_path := ""

	if(status = 1){
			img_path := "img\green_glossy_ball.png"
			current_status := "OK:"
			font_color := "green" 
		}else if(status = 2){
			img_path := "img\blue_glossy_ball.png"
			current_status := "Em andamento:"
			font_color := "blue"
			}else if(status = 3){
				img_path := "img\red_glossy_ball.png"
				current_status := "Com problemas:"
				font_color := "red"
				}else if(status = 4){
					img_path := "img\gray_glossy_ball.png"
					current_status := "Nao foi feito:"
					font_color := "gray"
				}

 	msg := current_status " " mensagem " `n Usuario: " usuario
 	Gui, M:default
 	Gui, Font, s12 c%font_color%
 	GuiControl, Font, status_info 
	GuiControl,, status_picture, % img_path
	GuiControl,, status_info, % msg
}

/*
	Retorna um hash com todas 
	as informacoes do item da tabela 
	log em um hash
*/
hashify(string){
	StringSplit, string, string, |,, All
	hash := {}
	hash.empresa := string3
	hash.tipo := string5
	hash.familia := string7
	hash.subfamilia := string9
	hash.modelo := string11
	return hash
}
