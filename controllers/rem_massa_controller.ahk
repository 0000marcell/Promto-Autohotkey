rem_massa(componente){
  Global

	if(componente = ""){
		MsgBox, 16, Erro, % "Digite o codigo ou parte do codigo do item a ser excluido!"
		return
	}

  checked_items := GetCheckedRows2("massaestrut","lv1")

	if(checked_items["code", 1] = ""){
		MsgBox, 16, Erro, % "Selecione pelo menos um item para inserir compoenentes" 
		return
	}
  
	for, each, value in checked_items["code"]{
   if(checked_items["code", A_Index] = ""){
    Continue
   }

	 item := checked_items["code", A_Index]
   db.Estrutura.remover(item, componente)
	}
  MsgBox, 64, Sucesso, % " Os items foram removidos com sucesso!"
}