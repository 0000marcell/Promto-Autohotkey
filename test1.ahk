Gui, teste:new
Gui, Add, Listview, w500 h200 vlv, Nome|Codigo
Gui, Add, Button, xm y+10 w100 h30 gremover, Remover
Gui, Show,,
load_lv()
return

remover:
delete_row_from_lv("teste", "lv", "coluna15")
return



load_lv(){
	Loop, 10
	{
		LV_Add("", "coluna1" A_Index, "coluna2" A_Index)
	}
}

delete_row_from_lv(window, lv, item_to_remove){
	Gui, %window%:default
	Gui, Listview, %lv%
	
	values := getvaluesLV(window, lv)
	
	for, each, row in values{
		row_number := A_Index
		for, each, item in row{
			if(item = item_to_remove){
				LV_Delete(row_number)
			}	
		}
	}
}

getvaluesLV(wName,lvName)   ;extrai todos os valores de uma listview e retorna um array.
{
	values := []
	i := 0
	gui, %wName%:default 
	Gui, listview, %lvName%

	Loop, % LV_GetCount("Column")
	{
		i+=1
		Loop, % LV_GetCount()
		{
			LV_GetText(text,A_Index,i)
			values[A_Index,i] := text
		}
	}
	return values
}
