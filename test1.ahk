Menu, backup_menu, Add, Fazer Back up, make_back_up
Menu, backup_menu, Add, Carregar Back up, load_back_up
Menu, backup_menu_bar, Add, &Back up, :backup_menu
Menu, backup_menu_bar, Color, White
Gui, Menu, backup_menu_bar
Gui, Show, w500 h500, 
return

make_back_up:
back_up_path := A_WorkingDir "\" A_DD "-" A_MM "-" A_YYYY "backup.sql"
Run, %comspec% /K cd C:\Program Files\MariaDB 5.5\bin && mysqldump -v -u root -pRecovergun test > %back_up_path%
return

load_back_up:
return

