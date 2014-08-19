make_back_up:
;back_up_path := A_WorkingDir "\" A_DD "-" A_MM "-" A_YYYY "backup.sql"

;Temporary mac path, change to the above to use in windows. 
back_up_path := A_WorkingDir "\" A_DD "-" A_MM "-" A_YYYY "backup.sql"
MsgBox, % "path to backup " back_up_path
Run, %comspec% /K cd %MARIADB_PATH% && mysqldump --host=%HOST% -v -u root -pRecovergun test > %back_up_path%
return

load_back_up:
MsgBox,64, Informacao, % "Essa opcao nao esta ativada ainda :("
return