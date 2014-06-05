class Print{
	product_list(info){
		Global db, file_name

		reset_debug()
		prefix := Print.get_prefix(info)
		file_name := prefix
		model_table := db.get_reference("Modelo", prefix)
		table_items := db.load_table_in_array(model_table)
		Print.startHTML(info.familia[1])
		loop, % table_items.maxindex(){
			tabela1 :=
			(JOIN 
				info.empresa[2]
				info.tipo[2] 
				info.familia[2] 
				table_items[A_Index, 2] 
				table_items[A_Index, 1] 
			)
			image_path := "..\" db.Imagem.get_image_full_path(tabela1)
			item_name := table_items[A_Index, 1]
			Print.add_item(image_path, item_name)
			Print.insert_break(A_Index, table_items.maxindex())
		}
		Print.closeHTML()
		MsgBox, 64,, % "Os arquivos foram gerados!"
		Run, % "print\" file_name ".html"
	}

	insert_break(index, max_index){
		Global file_name

		if(Mod(index, 5) = 0){
			if(index != max_index){
				html :=
				(JOIN 
					"</div>`n"
					"<div class='page'>`n"
				)	
			}else{
				html :=
				(JOIN 
					"</div>`n"
				)	
			}
			
			FileAppend, % html, % "print\" file_name ".html"
		}
	}

	startHTML(family_name){
		Global file_name

		FileDelete, % "print\" file_name ".html"
		html :=
		(JOIN 
			"<!DOCTYPE html>`n"
			"<html>`n"
    "<head>`n"
    		"<style type='text/css'>`n"
				  "body {`n"
				  	"text-align: center;`n"
				    "background-color: #fff;`n"
				  "}`n"
					".page{`n"
					"page-break-after: always;`n"
  				"page-break-inside: avoid;`n"
					"}`n"
				  ".item{`n"
				  	"background: #fff;`n"
				  	"margin-top: 10px;`n"
				  	"border: 2px solid #c8c8c8;`n"
				  	"width: 50%;`n"
				  	"margin-left: auto;`n"
					  "margin-right: auto;`n"
				  	"height: 150px;`n"
				  "}`n"
				  ".item img{`n"
				  	"float: left;`n"
				  	"width: 30%;`n"
				  	"height: 149px;`n"
				  "}`n"
				  ".item-text{`n"
				  	"float: left;`n"
				  	"width: 60%;`n"
				  	"height: 99%;`n"
				  "}`n"
			  "</style>`n"
        "<title>" family_name "</title>`n"
    "</head>`n"
    "<body>`n"
    "<h1>" family_name "</h1>`n"
    "<div class='page'>`n"
		)
		FileAppend, % html, % "print\" file_name ".html"
	}

	add_item(image, name){
		Global file_name

		html :=
		(JOIN 
			"<div class='item'>`n"
    		"<img src='" image "'>`n"
    		"<div class='item-text'>`n"
    			"<h2>" name "</h2>`n"
    		"</div>`n"
    	"</div>`n"
		)	

		FileAppend, % html, % "print\" file_name ".html"
	}

	closeHTML(){
		Global file_name

		html := 
		(JOIN 
			"</body>`n"
    		"<footer>`n"
    		"</footer>`n"
			"</html>"
		)
		FileAppend, % html, % "print\" file_name ".html"
	}

	get_prefix(info){
		Global file_name

		if(info.subfamilia[1] != ""){
			prefix := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[1]
		}else{
			prefix := info.empresa[2] info.tipo[2] info.familia[1]			
		}
		return prefix 
	}
}