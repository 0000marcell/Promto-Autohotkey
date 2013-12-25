class TV_Items{
	_New(){
		items := {}
		count := 0
	}

	add_items(nome, prefixo, subitems){
		if(nome != "" || prefixo != "" || subitems != "")
			count++
		items[count]:=
	}

	/*
		Retorna um objeto ou um array de objetos com os subitems
		do item pesquisado e o prefixo dos pais do item
	*/
	find_item(nome){
		value.subitems[]
		value.nome 
	}
}


items := {
	(JOIN
		nomes: ["luminaria", "projetor"], 
		prefixos: ["st", "sp"],
		subitems: [["TL.L.EXE.010", "TL.L.EXE.011"] , ["TL.P.EXE.105", "TL.P.EXD.104"] ]
	)}
;items[subitems] := subitems 
items.subitems[1].insert("TL.L.EXN.015")

for, each, value in items.subitems[1]{
	MsgBox, % value
}

