massa_lv(){
	Global

	if A_GuiEvent = i
	{
		selecteditem2 := GetSelected("massaphoto","lv")
		if(selecteditem2 = "" || selecteditem2 = "Codigos")
			return 
		result:=db.query("SELECT tipo,tabela1,tabela2 FROM reltable WHERE tipo='image' AND tabela1='" selecteditem2 "'")
		if(result["tabela2"]!="")
			db.loadimage("massaphoto","picture",result["tabela2"])
		Else
			guicontrol,,picture,% "noimage.png"
	}
}