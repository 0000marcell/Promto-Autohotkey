#Include xml.ahk

doc =
(LTrim
<root name="XML Sample">
	<!-- A comment -->
	<child attribute="value">
		<![CDATA[This is a CDATA Section]]>
		This is a text
		<subchild_1>Text</subchild_1>
		<subchild>
			Another text
			<node>The quick brown fox jumps over tha lazy dog</node>
		</subchild>
		Second text
	</child>
	<child>
		Some text
		<subchild name="Hello World">AutoHotkey</subchild>
		<!-- Another comment -->
	</child>
</root>
)


try
	; create an XMLDOMDocument object
	; and load the XML string
	x := new xml(doc)
catch pe ; catch parsing error(if any)
	MsgBox, 16, PARSE ERROR
	, % "Exception thrown!!`n`nWhat: " pe.What "`nFile: " pe.File
	. "`nLine: " pe.Line "`nMessage: " pe.Message "`nExtra: " pe.Extra
	
if x.documentElement {
	; class Built-in methods
	MsgBox, % x.getText("//node") ; getText() method
	MsgBox, % x.getAtt("//child[2]/subchild", "name") ; getAtt() method
	
	; XML DOM methods (counter-part)
	n := x.selectSingleNode("//node")
	MsgBox, % n.text ; get text
	
	; Alternate way of calling 'selectSingleNode'
	n := x["//child[2]/subchild"]
	MsgBox, % n.getAttribute("name") ; get attribute
	
	x.transformXML()
	x.viewXML()
}

ExitApp