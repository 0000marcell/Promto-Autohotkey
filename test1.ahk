Gui,MAB:New
Gui, color, white


/*
	Listview Codigo livre
*/
Gui, Add, Groupbox, xm y+20 w200 h300, Codigos Livres
Gui, Add, Listview, xp+10 yp+15 w180 h280 vcodigos_livres, Codigos

/*
	Bloquear / Desbloquear
*/
Gui, Add, Button, x+20 y150 w50 h50 gbloquear_codigo hwndhb, % "bloquear"
Gui, Add, Button, y+10 w50 h50 gdesbloquear_codigo hwndhd, % "desbloquear"

/*
	Listview Codigo bloqueado
*/
Gui, Add, Groupbox, x+10 yp-100 w200 h300, Codigos Bloqueados
Gui, Add, Listview, xp+10 yp+15 w180 h280 vcodigos_bloqueados, Codigos

/*
	Opcoes
*/
Gui, Add, Groupbox, xm y+10 w400 h60, Opcoes
cod_table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "Codigo"

desbloqueados := ["A", "B", "C", "D", "E", "F", "G"]
load_lv("codigos_livres", desbloqueados)
Gui, Show,, Bloqueio
return

bloquear_codigo:
bloquear_codigo()
return 

desbloquear_codigo:
desbloquear_codigo()
return



load_lv(lv, array){
	Gui, listview, %lv% 
	for, each, value in array{
		LV_Add(, array[A_Index])
	}
}


bloquear_codigo(){
	Global

	Gui, Listview, codigos_bloqueados
	LV_Modify(0, "-Select")
	selected_items := ""
	selected_numbers := ""
	selected_items := getselecteditems("MAB", "codigos_livres")
	last_item := bloqueados_a.maxindex()
	if(last_item = "")
		last_item := 0
	for, each, value in selected_items{
		selected_item := selected_items[A_Index]
		if(selected_item = "Codigos" || selected_item = ""){
			Continue
		}
		last_item++
		bloqueados_a[last_item, 1] := selected_item 
		Gui, Listview, codigos_bloqueados

		item_inserted := LV_Add("", selected_item)
	}
	remove_selected_in_lv("MAB", "codigos_livres")
}

desbloquear_codigo(){
	Global

	algum_codigo_foi_desbloqueado := true

	Gui, Listview, codigos_livres
	LV_Modify(0, "-Select")
	selected_items := ""
	selected_items := getselecteditems("MAB","codigos_bloqueados")
	
	for, each, value in selected_items{
		selected_item := selected_items[A_Index]

		if(selected_item = "Codigos" || selected_item = ""){
			Continue
		}
		bloqueados_a := remove_from_array(bloqueados_a, selected_item)
		Gui, Listview, codigos_livres
		item_inserted := LV_Add("", selected_item)
	} 
	remove_selected_in_lv("MAB", "codigos_bloqueados")
}

GetSelectedItems(wName = "", lvName = "", type = "text"){
	Global 
	Local returnValue
	if(wName != ""){
		Gui,%wName%:default
	}
	if(lvName != ""){
		Gui, listview, %lvName%
	}
	returnValue := []
	if(type = "text"){
		rownumber := 0
		Loop 
		{
			rownumber := LV_GetNext(rownumber)  ; Resume the search at the row after that found by the previous iteration.
    	if not rownumber  ; The above returned zero, so there are no more selected rows.
        break
			LV_GetText(text,rownumber)
			returnValue[A_Index] := text
		}
	}
	if(type = "number"){
		rownumber := 0
		Loop
		{
			rownumber := LV_GetNext(rownumber)
			if not rownumber  ; The above returned zero, so there are no more selected rows.
        break
			returnValue[A_Index] := rownumber
		}
	}
	return returnValue
}

remove_selected_in_lv(window_name, lv_name){
	rownumber := 0
	Gui, %window_name%:default 
	Gui, Listview, %lv_name%
	GuiControl, -Redraw, %lv_name% 
	selected_rows := []
	Loop
	{
		rownumber := LV_GetNext(rownumber)
		if not rownumber  ; The above returned zero, so there are no more selected rows.
      break
    selected_rows[A_Index] := rownumber 
	}
	alredy_removed := 0
	removed_count := 0
	for, each, value in selected_rows{
		selected_tbr := selected_rows[A_Index] 
		if(alredy_removed){
			removed_count++
			selected_tbr-=removed_count 
		}
		LV_GetText(selected_text, selected_tbr)
		LV_Delete(selected_tbr)
		alredy_removed := 1
	}
	GuiControl, +Redraw, %lv_name%
}

remove_from_array(array, value){
	For, each, row in array{
		For, each, item in row{
			if(item = value){
				row.remove(A_Index)
			}
		}
	}
	return array
}
