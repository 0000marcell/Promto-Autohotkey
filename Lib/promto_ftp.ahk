;#include, ..\FTP\FTP.ahk

class PromtoFTP{
	__New(ftp_server, user, password){
		Global
		this.ftp := FTP_Init()
		MsgBox, % "Gonna conect to server!"
		if(!this.ftp.Open(ftp_server, user, password)){
	  	MsgBox % "Houve um erro a conexao com o servidor FTP! " this.ftp.LastError
	  	return 
	  }
	  sOrgPath := this.ftp.GetCurrentDirectory()
		if !sOrgPath
  		MsgBox % this.ftp.LastError
	}

	upload_file(file_path, remote_path = ""){
			IfNotExist, % file_path
			{
				MsgBox, 16, Erro, % "erro no upload o arquivo " file_path " nao existia!"
				return 
			}
			if(remote_path = ""){
				if(!this.ftp.putFile(file_path)){
					MsgBox, 16, Erro, % "Erro ao tentar fazer upload do arquivo `n" file_path "`n" this.ftp.LastError
				}
			}else{
				if(!this.ftp.putFile(file_path, remote_path)){
					MsgBox, 16, Erro, % "Erro ao tentar fazer upload do arquivo `n" file_path "`n" this.ftp.LastError
				}
			}	
	}

	set_dir(dir){
		if(!this.ftp.SetCurrentDirectory(dir))
 		 MsgBox, % "Erro ao buscar o diretorio de imagens " ftp.LastError
	}

	find_first_file(path){
		item := this.ftp.FindFirstFile("/public_html/promto_imagens/*")
		return item
	}

	find_next_file(){
		item := this.ftp.FindNextFile()
		return item
	}

}

;promtoFTP := new PromtoFTP(
;		(JOIN 
;			"ftp.promto-maccomevap.url.ph",
;			"u832722944", "Recovergun"
;		))
;global_image_path := "\\192.168.10.1\h\Protheus11\Protheus_Data\bmp_produtos\"
;promtoFTP.upload_file("print_JSON.json")
;promtoFTP.update_folder(global_image_path "promto_imagens\", "promto_imagens")