insert_user_view(){
  Global db, GLOBAL_COLOR, SMALL_FONT
  Static user_name, user_password, priv_combo

  /*
    Gui init
  */
  Gui, inserir_user_view:New
  Gui, inserir_user_view:+ownermanager_users_view
  Gui, Font, s%SMALL_FONT%, %FONT%
  Gui, Color, %GLOBAL_COLOR%
  
  /*
    Opcoes
  */
  Gui, Add, Groupbox, x10 y10 w160 h200, Opcoes
  Gui, Add, Text, xp+5 yp+15 w150, Nome
  Gui, Add, Edit, y+5 w150 vuser_name,
  Gui, Add, Text, y+5 w150 , Senha
  Gui, Add, Edit, y+5 w150 vuser_password password,
  Gui, Add, Text, y+5 w150, Privilegios
  Gui, Add, Combobox, y+5 w150 vpriv_combo, Leitura|Edicao
  Gui, Add, Button, y+5 w150 h30 gsave_new_user, Salvar
  Gui, Show,, Inserir usuario
  return

  save_new_user:
  Gui, Submit, Nohide
  if(user_name = "" || user_password = "" || priv_combo = "")
    MsgBox, 64, Sucesso, % "Nenhum dos valores do formulario podem estar em branco! " 
  
  if(db.Usuario.new_user(user_name, user_password, priv_combo)){
    Gui, manager_users_view:default
    Gui, Listview, users_lv
    LV_Add("", user_name, user_password, priv_combo)
    LV_ModifyCol()
  }else{
    return 0  
  }
  return
}