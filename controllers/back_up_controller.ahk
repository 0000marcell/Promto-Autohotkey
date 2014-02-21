make_back_up:
back_up_path := A_WorkingDir "\" A_DD "-" A_MM "-" A_YYYY "backup.sql"
Run, %comspec% /K cd C:\Program Files\MariaDB 5.5\bin && mysqldump -v -u root -pRecovergun test > %back_up_path%
return

load_back_up:
MsgBox,64, Informacao, % "Essa opcao nao esta ativada ainda :("
return