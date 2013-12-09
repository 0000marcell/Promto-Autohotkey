inserir_imagem_view(owner_name, picture_control = ""){
	Global
	Static s_picture_control, s_owner_name

	s_picture_control := picture_control 
	s_owner_name := owner_name 

	FileSelectFile, source, 1, , Selecione uma imagem, Imagens (*.png; *.jpg; *.bmp)

	if(source = ""){
		MsgBox,16,Erro, % " E preciso selecionar uma imagem antes de continuar"
		return  
	}

	/*
		Gui init
	*/
	Gui, insert_dialogo_2:New
	Gui, insert_dialogo_2:+owner%owner_name%
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Campos
	*/
	Gui, Add, Groupbox, w230 h80, Campos
	Gui, Add, Text,xp+10 yp+15, Nome da imagem:
	Gui, Add, Edit, y+10 w200 vnome_imagem uppercase,

	/*
		Opcoes
	*/
	Gui, Add, Groupbox,xm y+20 w230 h60, Opcoes
	Gui, Add, Button, xp+113 yp+19 w100 h30 gsalvar_imagem Default, Inserir
	Gui, Show,,Inserir 
	return 
	
	salvar_imagem:
	Gui, Submit, Nohide
	if(nome_imagem = ""){
		MsgBox,16, Erro, % "Coloque um nome para a imagem!"
		return 
	}
	Gui, insert_dialogo_2:destroy
	/* 
		Incluir a foto 
	*/
	db.Imagem.incluir(source, nome_imagem)
	
	/*
		Recarrega o controle da foto com 
		a nova foto
	*/
	Gui, %s_owner_name%:default 
	GuiControl,, %s_picture_control%,%source% 
	return
}