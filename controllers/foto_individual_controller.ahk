massa_lv(){
	Global

	if A_GuiEvent = i
	{
		selecteditem2 := GetSelected("massaphoto","lv")
		if(selecteditem2 = "" || selecteditem2 = "Codigos")
			return 
		image_path := db.Imagem.get_image_path(selecteditem2)
		
		if(image_path != ""){
			full_image_path = %global_image_path%%image_path%.jpg
		 	append_debug(full_image_path)
			Guicontrol,, picture, % full_image_path 
		}else{
			Guicontrol,,Picture,% "img\sem_foto.jpg"
		}	
	}
}

