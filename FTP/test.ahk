;initialize and get reference to FTP object

ftp := FTP_Init()

; connect to FTP server
if !ftp.Open("ftp.promto-maccomevap.url.ph", "u832722944", "Recovergun")
  {
  MsgBox % ftp.LastError
  ExitApp
  }

; get current directory
MsgBox, % "gonna get current directory!"
sOrgPath := ftp.GetCurrentDirectory()
if !sOrgPath
  MsgBox % ftp.LastError
  
;; upload a file with progress
;ftp.InternetWriteFile( "D:\Temp\english.lng" )

;; download a file with progress
;ftp.InternetReadFile( "english.lng" , "D:\Temp\english1.lng")

;; delete the file
;ftp.DeleteFile("english.lng")

;MsgBox, % "gonna sleep!"
;if(!SleepWhile()){
;	MsgBox, % "Erro ao tentar alterar o diretorio padrao!"
;	return
;}

if(!ftp.SetCurrentDirectory("promto_imagens"))
  MsgBox, % "Erro ao buscar o diretorio de imagens " ftp.LastError

item := ftp.FindFirstFile("/public_html/promto_imagens/*")
MsgBox % "Name : " . item.Name
 . "`nCreationTime : " . item.CreationTime
 . "`nLastAccessTime : " . item.LastAccessTime
 . "`nLastWriteTime : " . item.LastWriteTime
 . "`nSize : " . item.Size
 . "`nAttribs : " . item.Attribs

;item := ftp.FindFirstFile("public_html/promto_imagens/*")
MsgBox, % "gonna loop!"
Loop
{
  if !(item := ftp.FindNextFile())
    break
  MsgBox % "Name : " . item.Name
   . "`nCreationTime : " . item.CreationTime
   . "`nLastAccessTime : " . item.LastAccessTime
   . "`nLastWriteTime : " . item.LastWriteTime
   . "`nSize : " . item.Size
   . "`nAttribs : " . item.Attribs
}

; close the FTP connection, free library
ftp.Close()

SleepWhile() {
  global fep
  While !ftp.AsyncRequestComplete
    sleep 50
  return (ftp.AsyncRequestComplete = 1) ? 1 : 0 ; -1 means request complete but failed, only 1 is success
}


#Include FTP.ahk