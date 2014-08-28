edit_user_view(current_user_name, current_user_password){
  Global db, SMALL_FONT, GLOBAL_COLOR, FONT
  Static user_name, user_password

  Gui, edit_user_view:New
  Gui, edit_user_view:+ownerM
  Gui, Font, s%SMALL_FONT%, %FONT%
  Gui, Color, %GLOBAL_COLOR%
  Gui, Add, Groupbox, w300 h110, Dados
  Gui, Add, Text, xp+5 yp+15, Nome:
  Gui, Add, Edit, w280 vuser_name, % current_user_name
  Gui, Add, Text, , Senha:
  Gui, Add, Edit, w280 vuser_password, % current_user_password
  Gui, Add, Button, w100 h30 gsave_edited_user, Salvar
  Gui, Show,, Editar
  return

  save_edited_user:
  Gui, Submit
  try{
    db.Usuario.edit_user(user_name, user_password)
  }catch e {
    MsgBox, 16, Erro, % " Alterar o usuario " e.what " no arquivo " e.file " na linha " e.line 
  } 
  return

}