rem_massa_view(){
	Global 

	/*
    Gui init
  */
  Gui, rem_massa_view:New
  Gui, rem_massa_view:+ownermassaestrut
  ;Gui, Font, s%SMALL_FONT%, %FONT%
  ;Gui, Color, %GLOBAL_COLOR%

  /*
   Codigos
  */
  Gui, Add, Groupbox, w300 h40, Codigos  
 	Gui, Add, Edit, xp+10 yp+15 w150 vcode_value uppercase,
  /*
  	Remover
  */
  Gui, Add, Button, y+10 w100 h30 gremover_massa, Remover
  Gui, Show,, Remover em massa
  return 

  remover_massa:
  Gui, Submit, Nohide
  rem_massa(code_value)
  return 
}