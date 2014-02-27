insert_user_view(){
  Static user_name, user_password

  /*
    Gui init
  */
  Gui, insert_user_view:New
  Gui, insert_user_view:+ownerM
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
  Gui, Add, Button, w200 h60 gsave_user, Salvar
  Gui, Show,, Salvar usuario
  return 


  save_user:
  Gui, Submit, nohide
  save_user(user_name, user_password)
  return
}