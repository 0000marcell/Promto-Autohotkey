#include SQL_new.ahk 

db := new SQL("SQLite",A_ScriptDir . "\Promto.sqlite")


Gui,font,s20
Gui,add,text, center cblue w500,Modelos
Gui,font,s8,Segoe UI
Gui,add,edit,w450 r1 section y+5 vbloqpes,
Gui,add,listview,w450 h400 y+5 vbloqlv checked,tipo|tabela1
Gui,add,button,w100 h30 y+5 gsalvarbloq,Salvar
Gui,add,button,w100 h30 x+5 gmarctodos,Marcar Todos
Gui,add,button,w100 h30 x+5 gdesmarctodos,Des. Marcar Todos
Gui,Show,,Modelos-Alterar-Bloquear
SQL =
	( JOIN 
 SELECT tipo,tabela1
 FROM reltable 
 WHERE tipo='Codigo'
	)
MsgBox, % sql
;sql:="SELECT tipo,tabela1,tabela2 FROM reltable WHERE tipo='" . tipo . "'"
;rs := db.query(sql)
result := db.query("SELECT tipo,tabela1,tabela2 FROM reltable WHERE tipo='Campo'")
while(!result.EOF){	
	Gui,listview,bloqlv
	LV_Add("",result["tipo"],result["tabela1"])
	result.MoveNext()
}
return 


salvarbloq:
return 

marctodos:

return 

desmarctodos:
return 

bloqpes:
    List_b := "|"
    GuiControl, -Redraw, Choice
    Gui, Submit, NoHide
    If SearchString = 
        GuiControl, , Choice, %List%
    Else
    {
        Loop, Parse, List, |
        {
            IfInString, A_LoopField, %SearchString%
                List_b  .= A_LoopField . "|"
        }
        GuiControl, , Choice, %List_b%
    }
    GuiControl, +Redraw, Choice
    GuiControl Choose, Choice,1
Return

;bloqpes:
;    List_b := "|"
;    GuiControl, -Redraw, Choice
;    Gui, Submit, NoHide
;    If SearchString = 
;        GuiControl, , Choice, %List%
;    Else
;    {
;        Loop, Parse, List, |
;        {
;            IfInString, A_LoopField, %SearchString%
;                List_b  .= A_LoopField . "|"
;        }
;        GuiControl, , Choice, %List_b%
;    }
;    GuiControl, +Redraw, Choice
;    GuiControl Choose, Choice,1
;Return


;M:
;Gui,M:New
;Gui,color,white
;if(!_refresh)
;	FamiliaName:=A_GuiControl
;Else
;	_refresh:=false
;FamiliaMascara:=getmascara(FamiliaName,famtable,"Familias")
;modtable:=getreferencetable("Modelo",EmpresaMascara . AbaMascara . FamiliaName)
;if(!modtable)
;	modtable:=EmpresaMascara . AbaMascara . FamiliaMascara . "Modelo"
;Gui,font,s20
;Gui,add,text,cblue w1203 center,Modelos.
;Gui,font,s8

;Gui, Add, ListView,  w230 h280 vMODlv gMODlv altsubmit,

;Gui, Add, Button,  w100 h30 gMAM,Modelos
;Gui, Add, Button,  w100 h30 gMAB, Bloqueados
;Gui, Add, Button,  w100 h30 gMAC,Campos
;Gui, Add, Button, x292 y+5 section w100 h30 gordemprefix, Ordem Prefixo
;Gui, Add, Button, x292 y+5 w100 h30 gMAOC, Ordem Codigo
;Gui, Add, Button, x292 y+5 w100 h30 gMAODC, Ordem Des Completa
;Gui, Add, Button, x292 y+5 w100 h30 gMAODR, Ordem Des Resumida
;Gui, Add, Button, x292 y+5 w100 h30 ggerarcodigos,Gerar Codigos
;Gui, Add, Button, x402 y40 w100 h30 ggerarestruturas,Gerar Estruturas
;Gui, Add, Button, x402 y+5 w100 h30 glinkarm,Linkar
;Gui, Add, Button, y+5 w100 h30 gdbex,Add db Externo
;Gui, Add, Picture, ys w260 h270 , C:\Users\mcruz\Desktop\Dropbox\AutoHotkey\Promto\SGTK\Images\carregando2.gif
;Gui, Add, ListView,y+5 w1150 h240 vCODlv gCODlv altsubmit  ,
;Gui, Show, w1203 h600,%FamiliaName%
;db.loadlv("M","MODlv",modtable,"Modelos,Mascara")
;gui,listview,MODlv
;LV_Modify(1, "+Select")
;return

MAOC:
return 

MAODC:
return 

MAODR:
return 

gerarcodigos:
return 

gerarestruturas:
return 

linkarm:
return 

dbex:
return 

MAB:
return 

MAC:
return 
MAM:
return 

ordemprefix:
return 
;Gui, Add, Button,  w100 h30 gMAM,Modelos
;Gui, Add, Button,  w100 h30 gMAB, Bloqueados
;Gui, Add, Button,  w100 h30 gMAC,Campos
;Gui, Add, Button, x292 y+5 section w100 h30 gordemprefix, Ordem Prefixo
;Gui, Add, Button, x292 y+5 w100 h30 gMAOC, Ordem Codigo
;Gui, Add, Button, x292 y+5 w100 h30 gMAODC, Ordem Des Completa
;Gui, Add, Button, x292 y+5 w100 h30 gMAODR, Ordem Des Resumida
;Gui, Add, Button, x292 y+5 w100 h30 ggerarcodigos,Gerar Codigos
;Gui, Add, Button, x402 y40 w100 h30 ggerarestruturas,Gerar Estruturas
;Gui, Add, Button, x402 y+5 w100 h30 glinkarm,Linkar
;Gui, Add, Button, y+5 w100 h30 gdbex,Add db Externo

;gui, add, edit, w600  ; Add a fairly wide edit control at the top of the window.
;gui, add, text, section, First Name:  ; Save this control's position and start a new section.
;gui, add, text,, Last Name:
;gui, add, edit, ys  ; Start a new column within this section.
;gui, add, edit
;gui, show
;array:=["a","b","c"]
;reversearray(array){
;	x:=-1,newarray:=[]
;	for,each,value in array{
;		x+=1
;		newarray.insert(array[array.maxindex()-x])
;	}
;	return newarray
;}

;reversed:=reversearray(array)
;for,each,value in reversed
;	MsgBox, % value




/*
E:
famtable:=""   
db := new SQL("SQLite",A_ScriptDir . "\Promto.sqlite")
gui,E:New 
Gui,color,white
;Gui, Add, Picture, xp-8 yp+0 w509 h399 0xE hwndcHwnd ; %GradientFile% ; ShowGradient
;ApplyGradient( cHwnd, Colour1, Colour2 )
buttonfield:=["4","8","12","16","20","24"] 
For each in emplist:=db.getvalues("Empresas","empresa")
	buttoncount+=1,addbutton(emplist[A_Index,1],buttonfield,buttoncount,"Empresa")
Gui, Add, GroupBox, x12 y10 w470 h310 , Empresas
Gui, Add, Button, x372 y340 w100 h30 gEA ,&Alterar  
Gui, Add, Button, x26 y340 w100 h30 gEAREFRESH,&Refresh
Gui, Add, GroupBox, x12 y320 w470 h70 ,Alterar
Gui, Show, w502 h399,Empresa
GuiControlGet,x,Pos,C
	MsgBox The X coordinate is %xx%. The Y coordinate is %xy%. The width is %xw%. The height is %xh%.
return



EA:
return 

EAREFRESH:
return 


Empresa:
MsgBox, % A_GuiControl
return 

GuiClose:
ExitApp

#include,%A_ScriptDir%\OTTK\OTTK.ahk
#Include SQL_new.ahk

;For each in emplist:=db.getvalues("Empresas","empresa")
;{
;	(A_Index>5) ? (x+=110,y:=55),buttonvalue:=emplist[A_Index,1]
;	if(A_Index=1)
;		Gui, Add, Button, x20 y40 w100 h30  +0x8000 gF v%buttonvalue%,% emplist[A_Index,1]	
;	else
;		Gui, Add, Button, y+5 w100 h30 gF  v%buttonvalue%,% emplist[A_Index,1]
;}

;F:
;if(!_refresh)
;	EmpresaName:=A_GuiControl
;Else
;	_refresh:=false
;result:=db.query("SELECT Mascara FROM empresa WHERE Empresas='" . EmpresaName . "'")
;EmpresaMascara:=result["Mascara"]
;result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='Aba' AND tabela1='" . EmpresaName . "'")
;abatable:=result["tabela2"]
;abalist:=db.getvalues("Abas,Mascara",abatable)
;tablist:=""
;firsttab:=""
;gui,%EmpresaName%:New

;Gui,color,white
;;Gui, Add, Picture, xp-8 yp+0 w1523 h690 0xE hwndcHwnd ; %GradientFile% ; ShowGradient
;For,k,v in abalist			;lOOP QUE CARREGA TODAS AS ABAS  
;{
;	if(A_Index=1)
;		tablist.=abalist[A_Index,1],firsttab:=abalist[A_Index,1],AbaMascara:=abalist[A_Index,2]
;	else
;		tablist.="|" . abalist[A_Index,1]
;}
;if(tablist="")
;{
;	Gui, Add, Tab2, x16 y110 w1380 h560 ,InsiraAbas		
;	Gui, Add, GroupBox, x116 y20 w1270 h90 , Empresa
;	Gui, Add, GroupBox, x36 y150 w1340 h500 , Familias
;	Gui, Add, GroupBox, x56 y540 w1300 h100 , Opcoes
;	;##############BOTAO#######################################
;	Gui,Add, Button,x1236 y580 w100 h30 gAA, &Alterar Abas
;	Gui,Add, Button,x1126 y580 w100 h30 gFA, &Alterar Familias
;	Gui,Add, Button,x76 y580 w100 h30 gE, Empresas
;	;##############BOTAO#######################################
;	Gui,Add, Text, x146 y40 w680 h50 , Text
;	Gui,Add, Picture, x836 y40 w90 h60 , C:\Documents and Settings\marcell\Desktop\Dropbox\AutoHotkey\Promto\SGTK\Images\NoImage1.png
;	Gui,Add, Edit, x1096 y50 w250 h30 , Edit
;	;##############BOTAO#######################################
;}else{
;	Gui, Add, Tab2, x16 y110 w1380 h560 gtabaction vpressedtab ,%tablist%
;	For,k,v in abalist  		;LOOP QUE CARREGA TODOS OS BOTOES DE TODAS AS ABAS
;	{
;		abanumber:=A_Index
;		familiatable:=abalist[A_Index,1]
;		result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='Familia' AND tabela1='" . EmpresaMascara . familiatable . "'")
;		famtable:=result["tabela2"]	
;		FamiliaMascara:=abalist[A_Index,2]
;		famlist:=db.getvalues("Familias",famtable)
;		x:=60
;		y:=170
;		gui,tab,%abanumber%
;		For,k,v in famlist
;		{
;			if(A_Index=14)
;			{
;				x+=110
;				y:=170
;			}
;			buttonvalue:=FamiliaMascara . "QQ" . famlist[A_Index,1]
;			StringReplace,buttonvalue,buttonvalue,%A_Space%,,All
;			Gui,Add,Button,x%x% y%y% w100 h30 gM v%buttonvalue%,% famlist[A_Index,1]		
;			y+=35
;		}
;		Gui, Add, GroupBox, x116 y20 w1270 h90 , Empresa
;		Gui, Add, GroupBox, x36 y150 w1340 h500 , Familias
;		Gui, Add, GroupBox, x56 y540 w1300 h100 , Opcoes
;		;##############BOTAO#######################################
;		Gui,Add, Button,x1236 y580 w100 h30 gAA, Alterar Abas
;		Gui,Add, Button,x1126 y580 w100 h30 gFA, Alterar Familias
;		Gui,Add, Button,x76 y580 w100 h30 gE, Empresas
;		;##############BOTAO#######################################
;		Gui,Add, Text, x146 y40 w680 h50 , Text
;		Gui,Add, Picture, x836 y40 w90 h60 , C:\Documents and Settings\marcell\Desktop\Dropbox\AutoHotkey\Promto\SGTK\Images\NoImage1.png
;		Gui,Add, Edit, x1096 y50 w250 h30 , Edit
;		;##############BOTAO#######################################
;	}	
;}
;Gui, Show, w1423 h689,%EmpresaName%
;Gosub,tabaction
;return

;tabaction:
;gui,submit,nohide 
;result:=db.query("SELECT Mascara FROM " . abatable . " WHERE Abas='" . pressedtab . "'")
;AbaMascara:=result["Mascara"]
;result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='Familia' AND tabela1='" . EmpresaMascara . pressedtab . "'")
;famtable:=result["tabela2"]
;if(!famtable)
;	famtable:=EmpresaMascara . AbaMascara . "Familia"	
;return 


AA:
if(abatable=""){
	result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='Aba' AND tabela1='" . EmpresaName . "'")
	abatable:=result["tabela2"]
}
args:={}
args["table"]:=abatable,args["field"]:="Abas,Mascara"
args["field1"]:="Abas",args["field2"]:="Mascara",args["primarykey"]:="Abas ASC,Mascara ASC"
args["tipo"]:="Familia",args["mascaraant"]:=EmpresaMascara,args["closefunc"]:="refreshf",args["relcondition"]:=true
inserir1(args)
return

refreshf(){
	Global _refresh
	_refresh:=true
	Gosub,F
}

FA:
args:={}
args["table"]:=famtable,args["field"]:="Familias,Mascara"
args["field1"]:="Familias",args["field2"]:="Mascara",args["primarykey"]:="Familias ASC,Mascara ASC"
args["tipo"]:="Modelo",args["mascaraant"]:=EmpresaMascara . AbaMascara,args["closefunc"]:="refreshf",args["relcondition"]:=true
inserir1(args)
return
