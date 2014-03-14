Gui, Add, Groupbox, x10 ym w200 h150, % "Opcoes"
Gui, Add, Radio, xp+5 yp+15 w100 h30 vradio_group, % "OK"
Gui, Add, Radio, y+5 w100 h30 , % "Em andamento"
Gui, Add, Radio, y+5 w100 h30 , % "Com problemas"
Gui, Add, Radio, y+5 w100 h10 , % "Nao foi feito"
Gui, Add, Text, xm y+20 w100, % "Mensagem adicional"
Gui, Add, Edit, xm y+5 w200 h50 vaditional_msg,
Gui, Add, Button, xm y+10 w100 h30 gsave_changes, % "Mensagem adicional" 
Gui, Show,, Mudar o status
return 

save_changes:
Gui, submit, nohide
MsgBox, % radio_group
db.Status.change_status(s_info, status_value, USER_NAME, aditional_msg)
return 