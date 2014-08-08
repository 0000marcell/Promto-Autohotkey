class Main{
  metodo(){
    this.Submain.metodo("marcell")
  }

  class Submain{
    set_value(y){
    	this.x := y
    }

    metodo(){
      MsgBox, % "mensagem " this.x
    }
  }
}

db := new Main()
db.Submain.set_value("test2")
db.Submain.metodo()