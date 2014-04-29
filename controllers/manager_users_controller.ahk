delete_user(user_name){
  Global db
  if(db.Usuario.delete(user_name)){
    return 1
  }else{
    return 0
  }
}