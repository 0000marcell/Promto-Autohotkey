x := "y estava vazio"
y := ""
x := ((y != "") ? (y) : ())
MsgBox, % x


;control := {window: "janela", combobox: "combobox"}
;MsgBox, % control.combobox

;prop_table := [
;(JOIN 
;	"value1", "value2", "value3", "value4", "value5", "value6", 
;	"value7", "value8", "value9", "value10", "value11"
;)]
;MsgBox, % prop_table[8]

;for each, value in prop_table{
;	MsgBox, % value
;}
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