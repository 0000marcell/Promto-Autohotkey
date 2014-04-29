Gui, Add, Text, w300, Use Window Spy && hover over each button, see Button1 2 && 3, press Delete Me, then hover again...Delete Me was really deleted.
Gui, Add, Button, section, Test
Gui,Add,picture,ys w200 h200 vpicture,
Gui, Add, Button, ys vdeleteme, Delete Me
Gui, Add, Button, ys, Keep Me
Gui, Show ;, w300 h100 ;, AutoSize
WM_CLOSE=0x10
return

ButtonDeleteMe:
;PostMessage, %WM_CLOSE%,,,picture
GuiControlGet,OutputVar,Sub-command,ControlID,Param4
DllCall("DestoryWindow", "UInt",%deleteme%)
return

GuiClose:
ExitApp











/*
#SingleInstance force 
db := new SQL("SQLite",A_ScriptDir . "\Promto.sqlite")
loadestrutura("ABD1ABC","")
loadestrutura(item,nivel){
	Global db,tvstring
	MsgBox, % item
	nivel.="`t"
	table:=db.query("SELECT item,componente FROM ESTRUTURAS WHERE item='" . item . "'")
	if (table["componente"]="")
	 	tvstring.="`n" . nivel . item
	while(!table.EOF){	
		;MsgBox, % table["item"] . " " table["componente"]	
		tvstring.="`n" . nivel . table["item"]
		loadestrutura(table["componente"],nivel)
		table.MoveNext()
	}
	MsgBox, % tvstring
}
args:={},hashmask:={},subitem:={}
args["table"]:="ABD1ABC",args["loadfunc"]:="loadestrutura"
tvstring:=""
tvwindow2(args)

tvwindow2(args){
	Global tvstring,selectmodel,hashmask,subitem
	Static args1
	args1:=args 
	Gui,tvwindow2:New
	Gui,color,white
	Gui, Add, GroupBox, x2 y0 w490 h550 , Gerar Estrutura
	Gui, Add, GroupBox, x12 y20 w470 h430 , TreeView
	Gui, Add, GroupBox, x12 y450 w470 h90 , Opcoes
	Gui, Add, TreeView, x22 y40 w450 h400 gtvest , 
	Gui, Add, Button, x272 y480 w100 h30 gsalvartv , Salvar
	Gui, Add, Button, x372 y480 w100 h30 gcancelartv, Cancelar
	table:=args["table"]
	loadfunc:=args.loadfunc,%loadfunc%(args)
	TvDefinition=
	(
		%tvstring%
	)
	CreateTreeView(TvDefinition)
	Gui, Show, w501 h559,Gerar Estruturas!	
	return

		salvartv2:
		id:=TV_GetSelection()
		Loop
		{
			TV_GetText(text,id)
			if(A_Index=1)
				selected2:=text
			if hashmask[text]
				mask.=hashmask[text]
			id:=TV_GetParent(id)
			if !id 
				Break
		}
		mask:=flip(mask)
		scmodel:=args1["mascaraant"] . selectmodel
		dtmodel:=mask . selected2
		savetvfunc:=args1["savetvfunc"],%savetvfunc%(scmodel,dtmodel,args1["mascaraant"],mask)
		return 

		cancelartv2:

		return 
}

#Include SQL_new.ahk
#include Promto(Front-End)(Native).ahk


