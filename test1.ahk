x := "dfdf"
(x != "") ? error()

MsgBox, % "nao retornou "
error(){
	MsgBox, % "erro!"
	return 0
}