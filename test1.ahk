class Test{
	
	rel(x , y){
		this.x := x
		this.y := y
	}

	insert(){
		MsgBox, % this.x 
	}

	insert2(){
		MsgBox, % this.y
	}
}
Test.rel("value1", "value2")
Test.insert()
Test.insert2() 

/*

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