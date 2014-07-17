massa_lv(){
	Global

	if A_GuiEvent = I
	{
		selecteditem2 := GetSelected("massaphoto","lv")
		if(selecteditem2 = "" || selecteditem2 = "Codigos")
			return 

		image_path := db.Imagem.get_image_full_path(selecteditem2)
		if(image_path != ""){
			Guicontrol,, picture, % image_path 
		}else{
			Guicontrol,,Picture,% "img\sem_foto.jpg"
		}	
	}
}

