
Class Promto {

	get_tv_id(window, treeview){
		Gui, %window%:Default
		Gui, Treeview, %treeview%
		id := TV_GetSelection()
		return id
	}

	/*
		Verifica se ja existe conexao de um 
		determinado nome com uma mascara
	*/
	check_if_ETF_exist(nome, mascara_antiga){
		mascara := ETF_hashmask[nome]
		if(mascara != ""){
			return mascara
		}else{
			return mascara_antiga
		}
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

	remove_t(code){
		StringLeft,testprefix,code,3
		if(testprefix="mpt")
			StringReplace,code,code,MPT,MP, All    ;SUBSTITUI O MPT POR MP
		if(testprefix="mod")
			StringReplace,code,code,MODT,MOD, All    ;SUBSTITUI O MODT POR MOD
		return code
	}

	export_code_list_to_file(code_list,family_name,model_name){	
		if(!code_list || !model_name){
			MsgBox,64,,% "A lista de modelos ou o nome do modelo estava em branco!"
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

	get_prefix_in_string(table){
		for, each, value in table{
			return_value .= table[A_Index]
		}
		return return_value
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
	  Gui,add,picture,w285 h199,%A_WorkingDir%\logotipos\logo.png
	  if(undetermined=0){
	  	Gui, Add, Progress, w300 h20 c2661dd Range0-%maxrange% vprogress
	  }
	  Else{
	  	Gui, Add, Progress, vprogress  -Smooth 0x8 w300 h18
	  	SetTimer,undeterminedprogressaction,45
	  }
	  Gui,font,s8
	  Gui,Add,text,w300 y+5 vplabel
	  Gui,Show,,progresso
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
	Carrega a string do tv 
	principal
	*/
	load_ETF(db){
		Global 
		ETF_hashmask := {}
		
		/*
			Essa funcao ira carregar
			a string ETF_TVSTRING
		*/
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

	load_mod_info(){
		Global db, info

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

	/*
		Une todos os prefixos
		da tabela1 e retorna 
		a string
	*/
	join_tabela1(info){
		tabela1 := 
		(JOIN 
			info.empresa[2] 
			info.tipo[2] 
			info.familia[2] 
			info.subfamilia[2] 
			info.modelo[2] 
			info.modelo[1]
		)
		return tabela1
	}
} ; ///// Promto







undeterminedprogressaction:
gui,progress:default
GuiControl,,progress, 1

