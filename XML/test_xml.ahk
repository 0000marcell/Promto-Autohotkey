#Include xml.ahk

try
	; create an XMLDOMDocument object
	; set its top-level node
	promtoXML := new xml("<root/>")
catch pe ; catch parsing error(if any)
	MsgBox, 16, PARSE ERROR
	, % "Exception thrown!!`n`nWhat: " pe.What "`nFile: " pe.File
	. "`nLine: " pe.Line "`nMessage: " pe.Message "`nExtra: " pe.Extra

if promtoXML.documentElement {
	
	promtoXML.addElement("promto", "root")
	
	promtoXML.addElement("companies", "//promto")
	promtoXML.addElement("company", "//promto/companies", {mask: "M"}, "Maccomevap")
	promtoXML.addElement("types", "//promto/companies/company[1]")
	promtoXML.addElement("type", "//promto/companies/company[1]/types", {mask: ""}, "Produtos acabados")
	promtoXML.addElement("company", "//promto/companies", {mask: "T"}, "Totallight")
	promtoXML.addElement("types", "//promto/companies/company[2]")
	promtoXML.addElement("type", "//promto/companies/company[2]/types", {mask: ""}, "Produtos acabados")
	
	promtoXML.transformXML()
	
	promtoXML.viewXML()
	promtoXML.save("test.xml")
}