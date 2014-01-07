Run pull.bat
sleep 1000
WinWaitClose, ahk_class ConsoleWindowClass,, 10
if(ErrorLevel){
	MsgBox, % "Error level"
}
run, Promto(Front-End)(Native).ahk
return