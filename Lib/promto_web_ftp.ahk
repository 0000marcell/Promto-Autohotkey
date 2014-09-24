class PromtoWebFTP{
	__New(){
		this.promtoFTP := new PromtoFTP(
		(JOIN 
			"ftp.promto-maccomevap.url.ph",
			"u832722944", "Recovergun"
		))	
	}	

	upload_xml(){
		this.promtoFTP.upload_file("promto_data.xml")
		MsgBox, 64, Sucesso, % " O arquivo xml foi updado!"
	}

	upload_images(){
		Global global_image_path
		max_index := this.get_image_max_index()
		Loop, %global_image_path%promto_imagens\*.*, 1
		{
			current_index := this.get_image_index(A_LoopFileName)
			if(current_index > max_index){
				this.promtoFTP.upload_file(global_image_path "promto_imagens\" A_LoopFileName)
			}			
		}
		MsgBox, % "Todas as imagens foram atualizadas!"
	}

	get_image_max_index(){
		this.promtoFTP.set_dir("promto_imagens")
		this.promtoFTP.find_first_file("/public_html/promto_imagens/*")
		max_index := 0
		Loop
		{
		  if !(item := this.promtoFTP.find_next_file())
		    break
		  image_index := this.get_image_index(item.Name)
		  if(image_index > max_index)
		  	max_index := image_index
		}
		return max_index
	}

	get_image_index(name){
		StringSplit, name, name, _
		StringSplit, index, name2, .
		return index1
	}
}

global_image_path := "\\192.168.10.1\h\Protheus11\Protheus_Data\bmp_produtos\"
promto_web := new PromtoWebFTP()
promto_web.upload_images()