edit_user_view(user_name, user_password){
  Global db

  /*
    Gui init
  */
  Gui, edit_user_view:New
  Gui, edit_user_view:+ownerM
  Gui, Font, s%SMALL_FONT%, %FONT%
  Gui, Color, %GLOBAL_COLOR%

  /*
    Dados
  */
  Gui, Add, Groupbox, w300 h110, Dados
  Gui, Add, Text, xp+5 yp+15, Nome:
  Gui, Add, Edit, w280 vuser_name, 
  Gui, Add, Text, , Senha:
  Gui, Add, Edit, w280 vuser_password,

  /*
    Opcoes
  */
  Gui, Add, Groupbox, w300 h60, Opcoes
  Gui, Add, Button, w200 h60 gsave_edited_user, Salvar
  Gui, Show,, Editar
  return

  save_edited_user:
  Gui, Submit, Nohide
  ;save_edited_user(user_name, user_password)
  return

}