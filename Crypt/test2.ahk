
;$$ := JSON_load(A_WorkingDir "\..\test.json")
;jsonString := JSON_to($$) 
;settings := JSON_from(jsonString) 
;hash := settings.children
;MsgBox, % hash[1].name
;#include, ..\lib\json_parser.ahk

#SingleInstance, Force
gui:=new xml("gui","Wierd","acid.xml") 		;Creates an xml with the filename of acid.xml, a root node of Wierd, and an association named gui.
another:=new xml("another")				;Creates an xml with the filename of another.xml, a root node of another, and an association named another.
gui.add("Just_A_Path")					;Add Just_A_Path to the gui xml
gui.add("Path","","With text")				;Add a path named 'Path' with text 'With text' to the gui xml
gui.add("unique",{value:3},"",1)			;Add a path named 'unique' with the attribute 'value' and the value of '3' to the gui xml
gui.add("unique",{value:3},"",1)			;Add a duplicate of the above
gui.add("unique",{value:4},"","",{value:3})	;Re-assign '4' to the attribute 'value'
for a,b in {gui:gui,another:another}{			
	b.add("foo",{this:1})				
	b.add("foo/bar/another",{this:1},"Hi")		
	b.add("foo/bar",{another:1})			
	b.add("foo",{that:1},"Hello",1)			
}
m(gui[],another[])					;Displays the xml files.
gui.transform()						;Transforms them from a file without indentations to a file with them.
another.transform()
p:=gui.sn("//*")					;Selects all of the nodes in the gui xml.
while,v:=p.item[A_Index-1]				;Loops all of the nodes that were selected in the line before
m(v.xml)						;Displays the node in the current loop
m(gui.ssn("//*[text()='Hi']").xml)			;Finds the node that contains the text value of Hi (Case sensitive)
m(gui[],another[])					;Displaying the xml files after the transform.
gui.save()						;Save the gui file
another.save()						;Save the another file
return
class xml{
	__New(param*){
		ref:=param.1,root:=param.2,file:=param.3
		file:=file?file:ref ".xml",root:=!root?ref:root
		temp:=ComObjCreate("MSXML2.DOMDocument"),temp.setProperty("SelectionLanguage","XPath")
		ifexist %file%
		temp.load(file),this.xml:=temp
		else
		this.xml:=xml.CreateElement(temp,root)
		this.file:=file
		xml.list({ref:ref,xml:this.xml,obj:this})
	}
	__Get(){
		return this.xml.xml
	}
	CreateElement(doc,root){
		x:=doc.CreateElement(root),doc.AppendChild(x)
		return doc
	}
	add(path,att="",text="",dup="",find=""){
		main:=this.xml.SelectSingleNode("*")
		for a,b in find
		if found:=main.SelectSingleNode("//" path "[@" a "='" b "']"){
			for a,b in att
			found.setattribute(a,b)
			return found
		}
		if p:=this.xml.SelectSingleNode(path)
		for a,b in att
		p.SetAttribute(a,b)
		else
		{
			p:=main
			Loop,Parse,path,/
			{
				total.=A_LoopField "/"
				if dup
				new:=this.xml.CreateElement(A_LoopField),p.AppendChild(new)
				else if !new:=p.SelectSingleNode("//" Trim(total,"/"))
				new:=this.xml.CreateElement(A_LoopField),p.AppendChild(new)
				p:=new
			}
			for a,b in att
			p.SetAttribute(a,b)
			if Text
			p.text:=text
		}
	}
	remove(){
		this.xml:=""
	}
	save(){
		this.xml.save(this.file)
	}
	transform(){
		this.xml.transformNodeToObject(xml.style(),this.xml)
	}
	ssn(node){
		return this.xml.SelectSingleNode(node)
	}
	sn(node){
		return this.xml.SelectNodes(node)
	}
	style(){
		static
		if !IsObject(xsl){
			xsl:=ComObjCreate("MSXML2.DOMDocument")
			style=
			(
			<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
			<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
			<xsl:template match="@*|node()">
			<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:for-each select="@*">
			<xsl:text></xsl:text>
			</xsl:for-each>
			</xsl:copy>
			</xsl:template>
			</xsl:stylesheet>
			)
			xsl.loadXML(style), style:=null
		}
		return xsl
	}
}
m(x*){
	for a,b in x
	list.=b "`n"
	MsgBox,% list
}