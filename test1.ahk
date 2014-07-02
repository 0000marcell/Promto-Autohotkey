class Test{
	test1(x){
		MsgBox, % "x " x
		this.x := x
	}

	test2(){
		MsgBox, % this.x
	}
} 

Test.test1("marcell")
Test.test2()