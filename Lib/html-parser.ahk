class PromtoHTML{
	__New(){
		this.item_number := 0 ;Variavel usada para fechar as tags
		FileDelete, % "index.html"
		FileAppend, % "<!DOCTYPE html>`n`t<html>`n`t<link rel='stylesheet' type='text/css' href='test.css'>`n`t<head>`n<title>Promto</title>`n`t</head>`n`t<body>`n`t<h1>Promto</h1>`n`t<h2>product manager tool</h2>`n`t<nav>`n`t<ul>`n`t<li>", % "index.html"
	}

	;Recebe a string usada para montar o diagrama de arvore e 
	;transforma no html
	generate(string, hash_mask){

		reset_debug()
		StringSplit, items, string, `n,
		prev_item_tab_count := 0
		prefix_array := []
		Loop, % items0
		{
			if(items%A_Index% = "")
				Continue
			StringSplit, tab_count, items%A_Index%, `t,
			this_item_tab_count := tab_count0 -1
			StringReplace, items%A_Index%, items%A_Index%, `t,, All
			if(this_item_tab_count > prev_item_tab_count || prev_item_tab_count = 0){
				this.item(items%A_Index%)
				prefix_array.insert(hash_mask[items%A_Index%])
				this.check_if_it_has_model(prefix_array, items%A_Index%)	
			}else if(this_item_tab_count < prev_item_tab_count){
				diference := prev_item_tab_count - this_item_tab_count
				Loop, % diference
				{
					prefix_array.Remove(prefix_array.MaxIndex())
					this.close_item()	
				}
				prefix_array.Remove(prefix_array.MaxIndex())
				this.close_item()
				this.item(items%A_Index%)	
				prefix_array.insert(hash_mask[items%A_Index%])
				this.check_if_it_has_model(prefix_array, items%A_Index%)
			}else if(this_item_tab_count = prev_item_tab_count){
				prefix_array.Remove(prefix_array.MaxIndex())
				this.close_item()
				this.item(items%A_Index%)	
				prefix_array.insert(hash_mask[items%A_Index%])
				this.check_if_it_has_model(prefix_array, items%A_Index%)
			}

			prev_item_tab_count := this_item_tab_count
		}
		this.close()
		Run, % "index.html"
	}

	item(name){
		FileAppend, % "<li>`n`t<a href=''>" name "</a>`n`t<ul>", % "index.html"
		this.item_number += 1
	}

	model(name, link, prefix_array, model_mask){
		if(model_mask = "")
			return 
		ifnotexist, % "html\" link "\"
		{
			FileCreateDir, % "html\" link "\"	
		}

		; Cria a pagina do produto
		this.create_model(name, model_mask, prefix_array, "html\" link "\")
		FileAppend, % "<a href='html\" link "\" model_mask ".html'>" name "</a>`n", % "index.html"
	}

	close_item(){
		FileAppend, % "</ul>`n", % "index.html"
		FileAppend, % "</li>`n", % "index.html"
		this.item_number -= 1
	}



	close(){
		MsgBox, % "this item number " this.item_number
		
		loop, % this.item_number
		{
			FileAppend, % "</ul>`n", % "index.html"
			FileAppend, % "</li>`n", % "index.html"		
		}
		
		FileAppend, % "</li>`n", % "index.html"
		FileAppend, % "</ul>`n", % "index.html"
		FileAppend, % "</nav>`n", % "index.html"
		FileAppend, % "</body>`n", % "index.html"
		FileAppend, % "</html>`n", % "index.html"
	}

	;Verifica se determinado item tem lista de modelos
	check_if_it_has_model(prefix_array, item_name){
		Global db

		append_debug("array max index: " prefix_array.MaxIndex())
		if(prefix_array.MaxIndex() < 3){
			return
		}

		prefix := ""
		for, each, value in prefix_array{
			if(prefix_array[A_Index] = "")
				Continue
			if(A_Index = prefix_array.MaxIndex()){
				prefix .= item_name 		
			}else{
				prefix .= prefix_array[A_Index]	
			}
		}

		append_debug("prefix : " prefix "ira verificar se existe subfamilia")
		if(db.have_subfamilia(prefix)){
			append_debug("tem subfamilia")
			return
		}else{
			/*
			Pega a tabela de modelos
			*/	 
			append_debug("ira pegar a tabela de modelo prefix: " prefix)
			model_table := db.get_reference("Modelo", prefix)
			append_debug("tabela de modelo retornada " model_table)
			if(model_table = ""){
				return
			}
			append_debug("ira buscar a lista da tabela " model_table)
			list_model := db.load_table_in_array(model_table)
			for, each, value in list_model{
				append_debug("modelo retornado " list_model[A_Index, 1])
				this.model(list_model[A_Index, 1], prefix, prefix_array, list_model[A_Index, 2])
			}
		}
	}

	;Cria a pagina do modelo
	create_model(model_name, model_mask, prefix_array, path){
		Global db

		For, each, value in prefix_array{
			if(value = "")
				Continue
			prefix .= value
		}

		final_prefix := prefix model_mask model_name
		append_debug("final prefix : " final_prefix) 
		fields_table := db.get_reference("Campo", final_prefix)
		if(fields_table = "")
			return 

		list_fields := db.load_table_in_array(fields_table)
		FileDelete, % path model_mask ".html"
		FileAppend, % "<!DOCTYPE html>`n`t<html>`n`t<link rel='stylesheet' type='text/css' href='../test.css'>`n`t<head>`n<title>" model_name "</title>`n`t</head>`n`t<body>`n`t<h1>" model_name "</h1>`n", % path model_mask ".html"
		
		/*
			Insere o prefixo
		*/
		For, each, value in prefix_array{
			if(value = "")
				Continue
			if(A_Index = 1){
				html_piece := 
				(JOIN 
					"<div class='code-formation'>`n"
					"`t<div class='code-item'>`n"
					"`t`t<h2>" value "</h2>`n"
					"</div>`n"
				)	
			}else{
				html_piece := 
				(JOIN 
					"<div class='code-item'>`n"
					"`t`t<h2>" value "</h2>`n"
					"</div>`n"
				)	
			}
			FileAppend, % html_piece, % path model_mask ".html"
		}
		html_piece := 
		(JOIN 
			"<div class='code-item'>`n"
			"`t`t<h2>" model_mask "</h2>`n"
			"</div>`n"
		)	

		/*
			Insere os campos 
		*/
		For, each, value in list_fields{
			field_name := list_fields[A_Index, 2]
			if(field_name = "")
				Continue

			html_piece := 
			(JOIN 
				"<div class='code-formation'>`n"
				"`t<p>" field_name "</p>`n"
				"`t<div class='styled-select'>`n"
				"`t<select>`n"
			)
			FileAppend, % html_piece, % path model_mask ".html"	
			/*
				Carrega os valores
				dos campos especificos
			*/
			StringReplace, field_name, field_name,%A_Space%,, All
			especific_fields_table := db.get_reference(field_name, final_prefix)
			if(especific_fields_table = "")
				Continue

			especific_list_fields := db.load_table_in_array(especific_fields_table)

			For, each, value in especific_list_fields{
				if(especific_list_fields[A_Index, 1] = "")
					Continue

				html_piece := 
				(JOIN
					"<option>" especific_list_fields[A_Index, 1] "</option>`n"
				) 
				FileAppend, % html_piece, % path model_mask ".html"
			}
			html_piece := 
			(JOIN
				"</select>`n"
				"</div>`n"
				"</div>`n"
			) 
			FileAppend, % html_piece, % path model_mask ".html"
		}

	}
}

;string := "Maccomevap`n`tProdutos Acabados`n`t`tLuminaria`n`t`tProjetor"
;HTML := new PromtoHTML()
;HTML.generate(string)

;#include, promtolib.ahk

;TestString := "`t`t`t Produtos Acabados fuck yeah "
;StringSplit, tab_count, TestString, `t,
;MsgBox, % tab_count0 -1


;CountLTabs(String) {
;	Loop, parse, String, `n, `r
;	{
;		Field := A_LoopField, Tabs := 0
;		While (SubStr(Field,1,1) = A_Tab)
;			Field := SubStr(Field, 2), Tabs += 1
;		Out .= Tabs ","
;	}
;	return RTrim(Out, ",")
;}
;HTML.item("Maccomevap")
;HTML.item("Produtos Acabados")
;HTML.item("Luminaria")
;HTML.close_item()
;HTML.item("Projetor")
;HTML.close_item()
;HTML.close_item()
;HTML.item("Produtos Semi-acabados")
;HTML.item("Luminaria")
;HTML.close_item()
;HTML.item("Projetor")
;HTML.close()
;Run, % "index.html"