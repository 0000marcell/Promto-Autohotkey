class Main{
  metodo(){
    this.Submain.metodo("marcell")
  }

  class Submain{
    metodo(x){
      MsgBox, % "mensagem " x
    }
  }
}

db := new Main()

db.metodo()