class PromtoHTML{
	__New(){
		this.close_tags := [] ;Variavel usada para fechar as tags
		FileDelete, % "index.html"
		FileAppend, % "<!DOCTYPE html><html><link rel=`"stylesheet`" type=`"text/css`" href=`"test.css`"><head><title>Promto</title></head><body><h1>Promto</h1><h2>product manager tool</h2><nav><ul><li>", % "index.html"
		this.close_tags.add("</li>")
		this.close_tags.add("</ul>")
		this.close_tags.add("</nav>")
		this.close_tags.add("</body>")
		this.close_tags.add("</html>")
	}

	company(name){
		FileAppend, % "<li><a href="">" name "</a><ul>", % "index.html"
		this.close_tags.add("</ul>")
		this.close_tags.add("</li>")
	}

	type(name){
		FileAppend, % "<li><a href="">" name "</a><ul>", % "index.html"
		this.close_tags.add("</ul>")
	}

	family(name){
		FileAppend, % "<a href="">" name "</a><ul>", % "index.html"
		this.close_tags.add("</ul>")
	}

	sub-family(name){
		FileAppend, % "<a href="">" name "</a><ul>", % "index.html"
		this.close_tags.add("</ul>")
	}

	model(name){
		FileAppend, % "<a href="">" name "</a><ul>", % "index.html"
		this.close_tags.add("</ul>")
	}

	close(){
		for, each, value in this.close_tags{
			FileAppend, % value, % "index.html"
		}
	}
}