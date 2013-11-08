

If !pToken := Gdip_Startup()
{
    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
    ExitApp
}

db := new SQL("SQLite",A_ScriptDir . "\Promto.sqlite")
GLOBAL_C1:="0xff1e90ff"
GLOBAL_C2:="0xff0949e9"
TextOptions:="x0p y0p s8p  cffffffff r4 Bold" 
Font:="Arial"
gui,teste8:new 
Gui,add,button,xm y0 w100 h30 gchange,botao
Gui,add,button,x+5 wp hp gchange2,botao2
;ptcode(200,0,"TL","015")
gui,show,w1200 h500,teste8
return 

change2:
ptcode("teste8",210,10,"TL","004")
return 
change:
ptcode("teste8",210,10,"TL","010")
return 



ptcode(wName,x,y,prefixpt,modelpt){
	Global
	gui,%wName%:default
	destroycontrols(wName)
	controllist:=[]
	ptx:=x,pty:=y
	Gui,add,picture,w200 h200 x%x% y%y%,MAC.EXE.010.bmp
	controllist.insert("MAC.EXE.010.bmp")
	TextOptions:="x0p y0p s40p center  cffffffff r4 Bold" 
	Font:="Arial"
	;MsgBox, % "inserir mainbanner!!"
	sleep,500
	Gui,Add,Picture,w750 h80 x+5 0xE,mainbanner
	controllist.insert("mainbanner")
	table:=db.query("SELECT descricao FROM " prefixpt modelpt "Desc;")
	banner1("blue","mainbanner",table["descricao"],TextOptions,Font)
	table.close()
	TextOptions:="x0p y0p s45p center  cffffffff r4 Bold"
	Gui,Add, Picture,w80 h80 y+5 0xE ,banner0
	controllist.insert("banner0")
	banner1("green","banner0",prefixpt,TextOptions,Font)
	for,each,value in [modelpt]{	
		Gui,Add, Picture,wp hp x+5 0xE ,banner%A_Index%
		valuetbi=banner%A_Index%
		controllist.insert(valuetbi) 
		banner1("yellow",valuetbi,value,TextOptions,Font)
	}
	TextOptions:="x0p y0p s30p center  cffffffff r4 Bold"
	TextOptions2:="x0p y70p s100p center  cffffffff r4 Bold"
	camptable:=prefixpt modelpt "oc"
	for,each,value in list:=db.getvalues("Campos",camptable){
		campname:=list[A_Index,1]
		StringReplace,campname,campname,%A_Space%,,All
		camplist:=prefixpt modelpt campname
		for,each,value in list2:=db.getvalues("CODIGO,DR",camplist){
			if(A_Index=1){
				cy:=y+85
				Gui,Add, Picture,wp hp x+5 y%cy%  0xE,%camplist%%A_Index%
			}
			else 
				Gui,Add, Picture,wp hp y+5 0xE ,%camplist%%A_Index% 
			valuetbi=%camplist%%A_Index%
			controllist.insert(valuetbi)
			banner2("blue",valuetbi,list2[A_Index,2],list2[A_Index,1],TextOptions,TextOptions2,Font)
		} 	
	} 
	Gui, Show,
	return
} 


banner1(color,Variable,Text="",TextOptions="x0p y15p s60p Center cffffffff r4 Bold", Font="verdana")
{
    GuiControlGet, Pos, Pos,%Variable%
    GuiControlGet, hwnd, hwnd,%Variable%
    pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)
    w:=posw,h:=posh
    colors:=getcolors(color)
	pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h,colors[1],colors[2])
	Gdip_FillRectangle(G, pBrush, 0, 0, w, h)
	;Gdip_DeleteBrush(pBrush)
	;pBrush := Gdip_BrushCreateHatch(args.color3,args.color4, 8)
	;Gdip_FillRectangle(G, pBrush, 0, 0, w, h)
	;Gdip_DeleteBrush(pBrush)
    Gdip_TextToGraphics(G,Text, TextOptions, Font, Posw, Posh)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    SetImage(hwnd, hBitmap)
    Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
    Gdip_SaveBitmapToFile(pBitmap,"File.png")
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
    Return, 0
}

banner2(color,Variable,Text="", Text2="", TextOptions="x0p y15p s60p Center cffffffff r4 Bold", TextOptions2="x0p y15p s60p Center cffffffff r4 Bold", Font="verdana")
{
    GuiControlGet, Pos, Pos,%Variable%
    GuiControlGet, hwnd, hwnd,%Variable%
    pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)
    w:=posw,h:=posh
    colors:=getcolors(color)
	pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h,colors[1],colors[2])
	Gdip_FillRectangle(G, pBrush, 0, 0, w, h)
    Gdip_TextToGraphics(G,Text, TextOptions, Font,Posw,Posh//2)
    Gdip_TextToGraphics(G,Text2,TextOptions2, Font,Posw,Posh//2)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    SetImage(hwnd, hBitmap)
    Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
    Return, 0
}

destroycontrols(wName){
	Global
	Gui,%wName%:default
	WM_CLOSE=0x10
	for each,value in controllist{
		;MsgBox, % value 
		PostMessage, %WM_CLOSE%,,,%value%
	}
}

;Blue: #0266C8
;Red: #F90101
;Yellow: #F2B50F
;Green: #00933B

getcolors(colorname){
	colors:=[]
	if(colorname="blue")
		colors[1]:="0xFF0266C8",colors[2]:="0xFF0256C8"
	if(colorname="red")
		colors[1]:="0xFFF90101",colors[2]:="0xFFA50101"
	if(colorname="yellow")
		colors[1]:="0xFFF2B50F",colors[2]:="0xFFFFCC11"
	if(colorname="green")
		colors[1]:="0xFF00933B",colors[2]:="0xFF00533B"
	return colors
}


#Include, Gdip.ahk
#Include, SQL_new.ahk






/*
sql:=
(JOIN
	"UPDATE SB1010 SET B1_COD='" COD_TBI 
	"',B1_DESC='" DESC_TBI 
	"',B1_UM='" UM_TBI 
	"',B1_ORIGEM='" ORIGEM_TBI 
	"',B1_POSIPI='" POSIPI_TBI 
	"',B1_CONTA='" CONTA_TBI 
	"',B1_IPI='" IPI_TBI 
	"',B1_TIPO='" TIPO_TBI 
	"',B1_LOCPAD='" LOCPAD_TBI 
	"',B1_GARANT='" GARANT_TBI 
	"',B1_XCALCPR='" XCALCPR_TBI 
	"',B1_GRUPO='" GRUPO_TBI 
	"',B1_BITMAP='" BITMAP_TBI 
	"',B1_MSBLQL='" MSBLQL_TBI 
	"',R_E_C_N_O_='" R_E_C_N_O_TBI 
	"'WHERE B1_COD='" COD_TBI . "'"
)

"insert or replace into Book (Name, TypeID, Level, Seen) values ( ... )"
MsgBox, % sql
"UPDATE SB1010 SET B1_MSBLQL='2' WHERE B1_COD ='" . z . "'"
sql:=
(JOIN
	"INSERT INTO SB1010 (B1_COD,B1_DESC,B1_UM,B1_ORIGEM,B1_POSIPI,B1_CONTA,B1_IPI,B1_TIPO,B1_LOCPAD,B1_GARANT"
		",B1_XCALCPR,B1_GRUPO,B1_BITMAP,B1_MSBLQL,R_E_C_N_O_) VALUES ('"
		COD_TBI "','" DESC_TBI "','" UM_TBI "','" ORIGEM_TBI "','" POSIPI_TBI "','" CONTA_TBI "','" IPI_TBI 
		"','" TIPO_TBI "','" LOCPAD_TBI "','" GARANT_TBI "','" XCALCPR_TBI "','" GRUPO_TBI "','" BITMAP_TBI "','" MSBLQL_TBI 
		"','" . R_E_C_N_O_TBI . "')"
)

G1_COD:=CODIGO 
G1_COMP:=COMPONENTE
G1_QUANT:=1
G1_INI:=31/12/2006
G1_FIM:=31/12/2049
G1_FIXVAR:=V
G1_REVFIM:=ZZZ
G1_NIV:=1
G1_NIVINV:=99
R_E_C_N_O_:=

%pai_code%;%filho_code%;1;31/12/2006;31/12/2049;V;ZZZ;1;99


/*
string:="`nA`n`tA1"
db := new SQL("SQLite",A_ScriptDir . "\Promto.sqlite")
field:=["Aba","Familia","Modelo"],gettable("empresa",0,"","")  
gettable(table,x,nivel,masc){
	Global db,tvstring,field
	x+=1,nivel.="`t",
	For each in list:=db.getvalues("*",table){
		tvstring.="`n" . nivel . list[A_Index,1]
		result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='" . field[x] . "' AND tabela1='" . masc . list[A_Index,1] . "'")
		if(result["tabela2"])
			gettable(result["tabela2"],x,nivel,masc . list[A_Index,2])
	}
	return 
}

TvDefinition=
(
	%tvstring%
)

Gui, Add, TreeView, h300
CreateTreeView(TvDefinition)
Gui, Show
return

CreateTreeView(TreeViewDefinitionString) {	; by Learning one
	IDs := {} 
	Loop, parse, TreeViewDefinitionString, `n, `r
	{
		if A_LoopField is space
			continue
		Item := RTrim(A_LoopField, A_Space A_Tab), Item := LTrim(Item, A_Space), Level := 0
		While (SubStr(Item,1,1) = A_Tab)
			Level += 1,	Item := SubStr(Item, 2)
		RegExMatch(Item, "([^`t]*)([`t]*)([^`t]*)", match)	; match1 = ItemName, match3 = Options
		if (Level=0)
			IDs["Level0"] := TV_Add(match1, 0, match3)
		else
			IDs["Level" Level] := TV_Add(match1, IDs["Level" Level-1], match3)
	}
}	; http://www.autohotkey.com/board/topic/92863-function-createtreeview/



#Include SQL_new.ahk