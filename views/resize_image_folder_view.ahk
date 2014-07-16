resize_image_folder_view(){
	FileSelectFolder, source, ""
	FileAppend, % source, % "temp\folder_convert_info.txt"
	RunWait, % "Lib\ConvertImageFolder.jar"
	MsgBox, 64, Sucesso, % "Todas as imagens foram convertidas!"
	return 
}