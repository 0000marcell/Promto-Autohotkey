control := {window: "janela", combobox: "combobox"}
MsgBox, % control.combobox

;tipo = "empresa"
;x := (tipo = "empresa") ? "TOTALLIGHT" : ""
;y := (tipo = "empresa") ? "T" : ""
;x := (tipo = "tipo") ? "PRODUTOS SEMI-ACABADOS" : ""
;y := (tipo = "tipo") ? "S" : ""

;MsgBox, % " x " x " y " y 

/*

table := []

table[1,1] := "test1"
table[1,2] := "test2"
table.column_count := 2
MsgBox, % table.column_count
MsgBox, % table.maxindex()

loop, % table.maxindex(){
	line := A_Index
	loop, % table.column_count{
		MsgBox, % table[line, A_Index]	
	} 
}

*/