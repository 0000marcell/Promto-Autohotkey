x := 5

try{
	func()
}catch e{
	MsgBox, % e.what " no arquivo " e.file " na linha " e.line
}

func(){
	throw { what: "Erro ", file: A_LineFile, line: A_LineNumber }
	MsgBox, % "linha depois do throw!"
}		