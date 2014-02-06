MyTable := []
MyTable[1, 1] := "d"
MyTable[1, 2] := "o"
MyTable[1, 3] := "g"
MyTable[2, 1] := "e"
MyTable.insert("abc", [2,2])
MsgBox, % MyTable[2,2] 
MyTable := remove_from_array(MyTable, "o")

for, each, row in MyTable{
	for, each, item in row{
		MsgBox, % item
	}
}

#include, lib\promtolib.ahk