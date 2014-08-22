class Usuario{
  /*
    Cria um novo usuario verificando se ele existe
  */

  new_user(user_name, user_password, priv_combo){
    Global mariaDB

    if(this.user_exists(user_name)){
      MsgBox, 16, Erro, % "O usuario a ser inserido ja existe !" 
      return 0
    }

    crypt_value := Crypt.Encrypt.StrEncrypt(user_password, "007", 5, 1)
    record := {}
    record.Nome := user_name
    record.Senha := crypt_value
    record.Privilegio := priv_combo
    mariaDB.Insert(record, "usuarios")
    MsgBox, 64, Sucesso, % "O usuario foi salvo com sucesso!" 
    return 1
  }

  /*
    Deleta determinado usuario
  */
  delete(nome){
    Global db

    result := db.delete_items_where("Nome like '" nome "'", "usuarios")

    if(result){
      MsgBox, 64, Sucesso, % "O usuario " nome "foi deletado com sucesso!" 
      return 1
    }Else{
      MsgBox, 64, Sucesso, % "Houve um erro ao deletar o usuario " nome
      return 0
    }
  }

  /*
    Loga o determinado usuario
  */
  log_in_user(user_name, user_password){
    Global db, USER_PRIV

    if(user_name = "" || user_password = ""){
      MsgBox, 16, Erro, % "Insira um nome de usuario e uma senha! " 
      return 0
    }

    user := db.find_items_where("nome like '" user_name "'", "usuarios")
    if(user[1, 2] = ""){
      MsgBox, 16, Erro, % "O usuario inserido nao existia no banco!" 
      return 0
    }

    stored_password := Crypt.Encrypt.StrDecrypt(user[1, 2], "007", 5, 1)
    if(user_password = stored_password){
      USER_PRIV := user[1, 3]
      return 1
    }else{
      MsgBox, 16, Erro, % " A senha do usuario esta errada!"
      return 0
    }
  }

  /*
    Verifica se determinado usuario ja existe
  */
  user_exists(user_name){
    Global db
    user := db.find_items_where("nome like '" user_name "'", "usuarios")
    if(user[1, 2] != ""){
      return 1
    }else{
      return 0
    }
  }

  remenber_user(user_name, user_password) {
    crypt_value := Crypt.Encrypt.StrEncrypt(user_password, "007", 5, 1)    
    obj := {name: user_name, password: crypt_value}
    JSON_save(obj, "temp\user_info.json")
  }
}
