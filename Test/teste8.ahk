db := new SQL("SQLite",A_ScriptDir . "\Promto2.sqlite")

tvstring:="",selected:="TLAVF012156PEE>>LUMINARIA SEGURANCA AUMENTADA TL.L.EXE.AVF   20W  127V FAB. POLIESTER  SEM REATOR  50HZ/60HZ  PARA 1 LAMPADA  COM EMERGENCIA"
loadestrutura(selected,"")     ;RETORNA tvstring com todos os niveis!!
StringSplit,numberofitems,tvstring,"`n"
totalheight:=numberofitems0*250
MsgBox, % "totalheight: " totalheight
tvstring:=""
newgdi({w:807,h:totalheight})
panel({x:0,y:0,w:750,h:totalheight,color: "white",boardcolor: "0x00000000"})
offset:=0
y:=-90
printestrutura(selected,offset)
MsgBox, % "O arquivo foi salvo!!"
savetofile("imagename.png")
run imagename.png

printestrutura(item,offset,textcolor="ffFFFFFF"){ ; o offset determina a distancia entre os items
	Global
	Local table
	squarecolor:="lightgrey"
	;MsgBox, % item
	if item =
		return
	nivel.="`t"
	offset+=30
	table:=db.query("SELECT item,componente FROM ESTRUTURAS WHERE item='" . item . "'")
	if(table["componente"]=""){
	 	IfNotInString,tvstring,%item%
	 	{
	 		tvstring.="`n" . nivel . item
	 		StringReplace,item,item,>>,|,All
			StringSplit,item,item,|
	 		result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" item1 "'")
			if(result["tabela2"]!="")
				imagepath:=db.loadimage("","",result["tabela2"])

			result.close()
			StringLeft,codetype,item1,1
			;MsgBox, % codetype
			if(codetype="t")
				squarecolor:="blue"
			if(codetype="i")
				squarecolor:="lightblue"
			if(codetype="s")
				squarecolor:="green"
			if(codetype="c")
				squarecolor:="yellow"
			;MsgBox, % "codetype: " codetype " square: " squarecolor
	 		panel({x:offset,y:y+=130,w:100,h:100,color: "nocolor",imagepath: imagepath,boardsize: 0})
	 		panel({x:offset+105,y:y,w:505,h:100,color:"nocolor",text:item1 "`n" item2,textsize:10,textcolor: textcolor,boardsize: 0})
	 	}	 		
	 }
	while(!table.EOF){
		tableitem:=table["item"]	
		IfNotInString,tvstring,%tableitem%
		{
			StringReplace,tableitem,tableitem,>>,|,All
			StringSplit,tableitem,tableitem,|
			tvstring.="`n" . nivel . table["item"]
			;MsgBox, % "SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" tableitem1 "'" 
			result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" tableitem1 "'")
			if(result["tabela2"]!=""){
				imagepath:=db.loadimage("","",result["tabela2"])
			}
			result.close()
			StringLeft,codetype,tableitem1,1
			;MsgBox, % codetype
			if(codetype="t")
				squarecolor:="blue"
			if(codetype="i")
				squarecolor:="lightblue"
			if(codetype="s")
				squarecolor:="green"
			if(codetype="c")
				squarecolor:="yellow"
			;MsgBox, % "codetype: " codetype " square: " squarecolor
			panel({x:offset,y:y+=130,w:100,h:100,color: "nocolor",imagepath: imagepath,boardsize: 0})
	 		panel({x:offset+105,y:y,w:505,h:100,color:"nocolor",text:tableitem1 "`n" tableitem2,textsize: 10,textcolor: textcolor,boardsize: 0})
		}
		printestrutura(table["componente"],offset)
		table.MoveNext()
	}
	;MsgBox, % "ira retornar"
	return 
}

loadestrutura(item,nivel){
	Global db,tvstring
	if item =
		return
	nivel.="`t"
	table:=db.query("SELECT item,componente FROM ESTRUTURAS WHERE item='" . item . "'")
	if (table["componente"]=""){
	 	IfNotInString,tvstring,%item%
	 		tvstring.="`n" . nivel . item
	 }
	while(!table.EOF){
		tableitem:=table["item"]	
		IfNotInString,tvstring,%tableitem%
			tvstring.="`n" . nivel . table["item"]
		loadestrutura(table["componente"],nivel)
		table.MoveNext()
	}
}

#include <promtolib>
#include <testelib>
#include,%A_ScriptDir%\SQL_new.ahk

