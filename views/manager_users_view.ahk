manager_users_view(){
  Global db, users_lv
  
  /*
    Gui init
  */
  Gui, manager_users_view:New
  Gui, manager_users_view:+ownerM
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
  Gui, Add, Button, x+5 w100 h30 gedit_user, Editar
  Gui, Add, Button, x+5 w100 h30 gdelete_user, Excluir 
  Gui, Show,, Usuarios
  db.load_lv("manager_users_view", "users_lv", "usuarios", "1")
  return 

  insert_user:
  insert_user_view()
  return

  edit_user:
  selected_value := GetSelectedRow("manager_users_view", "users_lv")
  edit_user_view(selected_value[1], selected_value[2])
  return

  delete_user:
  selected_value := GetSelectedRow("manager_users_view", "users_lv")
  delete_user(selected_value[1], selected_value[2])
  return 
}
  