manager_users_view(){
  Global db, users_lv, GLOBAL_COLOR, SMALL_FONT
  
  /*
    Gui init
  */
  Gui, manager_users_view:New
  Gui, manager_users_view:+ownerinitialize
  Gui, Font, s%SMALL_FONT%, %FONT%
  Gui, Color, %GLOBAL_COLOR%

  /*
    Usuarios
  */
  Gui, Add, Groupbox, w300 h300, Lista de usuarios
  Gui, Add, Listview, xp+5 yp+15 w250 h250 vusers_lv, Usuario|Senha|Privilegios   

  /*
    Opcoes
  */
  Gui, Add, Groupbox, w300 h60, Opcoes
  Gui, Add, Button, xp +5 yp+15 w100 h30 ginsert_user, Inserir 
  Gui, Add, Button, x+5 w100 h30 gdelete_user, Excluir 
  Gui, Show,, Usuarios
  db.load_lv("manager_users_view", "users_lv", "usuarios", "1")
  return 

  insert_user:
  insert_user_view()
  return

  delete_user:
  selected_value := GetSelectedRow("manager_users_view", "users_lv")
  selected_row := GetSelected("manager_users_view", "users_lv", "number")
  if(delete_user(selected_value[1])){
    Gui, manager_users_view:default
    Gui, Listview, users_lv
    LV_Delete(selected_row)
  }
  return 
}
  