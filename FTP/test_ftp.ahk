; initialize and get reference to FTP object
ftp := FTP_Init()

; connect to FTP server
if !ftp.Open("ftp.promto-maccomevap.url.ph", "u832722944", "Celestica1991")
  {
  MsgBox % ftp.LastError
  ExitApp
  }

; get current directory
sOrgPath := ftp.GetCurrentDirectory()
if !sOrgPath
  MsgBox % ftp.LastError

;; Error handling omitted from here on for brevity

; upload a file with progress
ftp.InternetWriteFile( A_ScriptDir . "\SVN\" )
ftp.Close()

#Include FTP.ahk