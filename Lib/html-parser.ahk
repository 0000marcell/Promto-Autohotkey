class PromtoHTML{
	__New(){
		this.item_number := 0 ;Variavel usada para fechar as tags
		this.file_path := "html\index.html"
		this.date := A_DD "/" A_MM "/" A_YYYY " as " A_Hour ":" A_Min
		FileCopyDir, % "\\192.168.10.1\h\Protheus11\Protheus_Data\bmp_produtos\promto_imagens",% "html\promto_imagens", 1
		FileDelete, % this.file_path
		FileAppend, % "<!DOCTYPE html>`n`t<html>`n`t<link rel='stylesheet' type='text/css' href='test.css'>`n`t<head>`n<title>Promto</title>`n`t</head>`n`t<body>`n`t`t<h2>Ultima modificacao:" this.date "</h2>`n`t<img src='promtologo.jpg' style='margin-left:40%;'>`n`t<nav>`n`t<ul>`n`t<li>", % this.file_path
	}

	;Recebe a string usada para montar o diagrama de arvore e 
	;transforma no html
	generate(string, hash_mask){
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
		Run, % this.file_path
	}

	item(name){
		FileAppend, % "<li>`n`t<a href=''>" name "</a>`n`t<ul>", % this.file_path
		this.item_number += 1
	}

	model(name, link, prefix_array, model_mask){
		Global db

		if(model_mask = "")
			return 
		ifnotexist, % "html\" link "\"
		{
			FileCreateDir, % "html\" link "\"	
		}

		tabela1 := ""
		for, each, valu in prefix_array
			tabela1 .= prefix_array[A_Index]
		tabela1 .= model_mask name
		image_full_path := db.Imagem.get_html_image_full_path(tabela1)

		; Cria a pagina do produto
		this.create_model(name, model_mask, prefix_array, "html\" link "\", image_full_path)
		html_piece :=
		(JOIN
			"<a href='" link "\" model_mask ".html'>"
			"<img src='" image_full_path "' class='small-image'>" name "</a>`n" 
		)
		FileAppend, % html_piece, % this.file_path
	}

	close_item(){
		FileAppend, % "</ul>`n", % this.file_path
		FileAppend, % "</li>`n", % this.file_path
		this.item_number -= 1
	}



	close(){
		loop, % this.item_number
		{
			FileAppend, % "</ul>`n", % this.file_path
			FileAppend, % "</li>`n", % this.file_path	
		}
		
		FileAppend, % "</li>`n", % this.file_path
		FileAppend, % "</ul>`n", % this.file_path
		FileAppend, % "</nav>`n", % this.file_path
		FileAppend, % "</body>`n", % this.file_path
		FileAppend, % "</html>`n", % this.file_path
	}

	;Verifica se determinado item tem lista de modelos
	check_if_it_has_model(prefix_array, item_name){
		Global db

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

		if(db.have_subfamilia(prefix)){
			return
		}else{
			/*
			Pega a tabela de modelos
			*/	 
			model_table := db.get_reference("Modelo", prefix)
			if(model_table = ""){
				return
			}
			list_model := db.load_table_in_array(model_table)
			for, each, value in list_model{
				this.model(list_model[A_Index, 1], prefix, prefix_array, list_model[A_Index, 2])
			}
		}
	}

	;Cria a pagina do modelo
	create_model(model_name, model_mask, prefix_array, path, image_path){
		Global db

		For, each, value in prefix_array{
			if(value = "")
				Continue
			prefix .= value
		}

		final_prefix := prefix model_mask model_name 
		fields_table := db.get_reference("Campo", final_prefix)
		if(fields_table = "")
			return 

		list_fields := db.load_table_in_array(fields_table)
		FileDelete, % path model_mask ".html"
		html_piece :=
		(JOIN
			"<!DOCTYPE html>" 
			"`n`t<html>`n"
			"`t<link rel='stylesheet' type='text/css' href='../test.css'>`n"
			"`t<head>`n<title>" model_name "</title>`n"
			"`t</head>`n`t<body>`n"
			"`t<div class='model-page'>`n"
			"<h2>Ultima modificacao:" this.date "</h2>"
			"`t`t<img src='..\" image_path "' class='large-image'>`n"
			"<h1>" model_name "</h1>`n"
			"<div class='code-container'>" 
		)
		FileAppend, % html_piece, % path model_mask ".html"
		
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
		FileAppend, % html_piece, % path model_mask ".html"
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
					"<option>" especific_list_fields[A_Index, 1] "<span>-" especific_list_fields[A_Index, 3] "</span></option>`n"
				) 
				FileAppend, % html_piece, % path model_mask ".html"
			}
			html_piece := 
			(JOIN
				"</select>`n"
				"</div>`n"
				"</div>`n"
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