reload_hashmask_view(){
	Global db, SMALL_FONT, ETF_hashmask, reload_hashmask_view, undetermine_progress_window , GLOBAL_COLOR, FONT, undetermine_progress_action
	/*
		Gui init
	*/
	Gui, reload_hashmask_view:New
	Gui, reload_hashmask_view:+ownerM
	Gui, Font, s%SMALL_FONT%, %FONT%
	Gui, Color, %GLOBAL_COLOR%

	/*
		Info
	*/
	Gui, Add, Groupbox, xm  w330 h65, Info
	Gui, Add, Text, xp+5 yp+15, % "Recalculando estrutura de dados.." 
	Gui, Add, Progress, xp y+5 vprogress  -Smooth 0x8 w300 h18
	Gui, Show,, Carregando
	undetermine_progress_window := "reload_hashmask_view"
  SetTimer, undetermine_progress_action, 45
  ETF_hashmask := ""
  load_ETF(db)
  SetTimer, undetermine_progress_action, OFF
  Gui, reload_hashmask_view:destroy
  return
}