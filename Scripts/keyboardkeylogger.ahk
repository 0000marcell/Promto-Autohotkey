;---- Configuration Section: Customize the size of the on-screen keyboard and
; other options here.

; Changing this font size will make the entire on-screen keyboard get
; larger or smaller:
k_FontSize = 10
k_FontName = Verdana  ; This can be blank to use the system's default font.
k_FontStyle = Bold    ; Example of an alternative: Italic Underline

; Names for the tray menu items:
k_MenuItemHide = Hide on-screen &keyboard
k_MenuItemShow = Show on-screen &keyboard

; To have the keyboard appear on a monitor other than the primary, specify
; a number such as 2 for the following variable.  Leave it blank to use
; the primary:
k_Monitor = 

;---- End of configuration section.  Don't change anything below this point
; unless you want to alter the basic nature of the script.


;---- Alter the tray icon menu:
Menu, Tray, Add, %k_MenuItemHide%, k_ShowHide
Menu, Tray, Add, &Exit, k_MenuExit
Menu, Tray, Default, %k_MenuItemHide%
Menu, Tray, NoStandard

;---- Calculate object dimensions based on chosen font size:
k_KeyWidth = %k_FontSize%
k_KeyWidth *= 3
k_KeyHeight = %k_FontSize%
k_KeyHeight *= 3
k_KeyMargin = %k_FontSize%
k_KeyMargin /= 6
k_SpacebarWidth = %k_FontSize%
k_SpacebarWidth *= 25
k_KeyWidthHalf = %k_KeyWidth%
k_KeyWidthHalf /= 2

k_KeySize = w%k_KeyWidth% h%k_KeyHeight%
k_Position = x+%k_KeyMargin% %k_KeySize%

;---- Create a GUI window for the on-screen keyboard:
Gui, Font, s%k_FontSize% %k_FontStyle%, %k_FontName%
Gui, -Caption +E0x200 +ToolWindow
TransColor = F1ECED
Gui, Color, %TransColor%  ; This color will be made transparent later below.

;---- Add a button for each key. Position the first button with absolute
; coordinates so that all other buttons can be positioned relative to it:
Gui, Add, Button, section %k_KeySize% xm+%k_KeyWidth%, 1
Gui, Add, Button, %k_Position%, 2
Gui, Add, Button, %k_Position%, 3
Gui, Add, Button, %k_Position%, 4
Gui, Add, Button, %k_Position%, 5
Gui, Add, Button, %k_Position%, 6
Gui, Add, Button, %k_Position%, 7
Gui, Add, Button, %k_Position%, 8
Gui, Add, Button, %k_Position%, 9
Gui, Add, Button, %k_Position%, 0
Gui, Add, Button, %k_Position%, -
Gui, Add, Button, %k_Position%, =
Gui, Add, Button, %k_Position%, Bk

Gui, Add, Button, xm y+%k_KeyMargin% h%k_KeyHeight%, Tab  ; Auto-width.
Gui, Add, Button, %k_Position%, Q
Gui, Add, Button, %k_Position%, W
Gui, Add, Button, %k_Position%, E
Gui, Add, Button, %k_Position%, R
Gui, Add, Button, %k_Position%, T
Gui, Add, Button, %k_Position%, Y
Gui, Add, Button, %k_Position%, U
Gui, Add, Button, %k_Position%, I
Gui, Add, Button, %k_Position%, O
Gui, Add, Button, %k_Position%, P
Gui, Add, Button, %k_Position%, [
Gui, Add, Button, %k_Position%, ]
Gui, Add, Button, %k_Position%, \

Gui, Add, Button, xs+%k_KeyWidthHalf% y+%k_KeyMargin% %k_KeySize%, A
Gui, Add, Button, %k_Position%, S
Gui, Add, Button, %k_Position%, D
Gui, Add, Button, %k_Position%, F
Gui, Add, Button, %k_Position%, G
Gui, Add, Button, %k_Position%, H
Gui, Add, Button, %k_Position%, J
Gui, Add, Button, %k_Position%, K
Gui, Add, Button, %k_Position%, L
Gui, Add, Button, %k_Position%, `;
Gui, Add, Button, %k_Position%, '
Gui, Add, Button, x+%k_KeyMargin% h%k_KeyHeight%, Enter  ; Auto-width.

; The first button below adds %A_Space% at the end to widen it a little,
; making the layout of keys next to it more accurately reflect a real keyboard:
Gui, Add, Button, xm y+%k_KeyMargin% h%k_KeyHeight%, Shift%A_Space%%A_Space%
Gui, Add, Button, %k_Position%, Z
Gui, Add, Button, %k_Position%, X
Gui, Add, Button, %k_Position%, C
Gui, Add, Button, %k_Position%, V
Gui, Add, Button, %k_Position%, B
Gui, Add, Button, %k_Position%, N
Gui, Add, Button, %k_Position%, M
Gui, Add, Button, %k_Position%, `,
Gui, Add, Button, %k_Position%, .
Gui, Add, Button, %k_Position%, /
Gui, Add, Button, xm y+%k_KeyMargin% h%k_KeyHeight%, Ctrl  ; Auto-width.
Gui, Add, Button, h%k_KeyHeight% x+%k_KeyMargin%, Win      ; Auto-width.
Gui, Add, Button, h%k_KeyHeight% x+%k_KeyMargin%, Alt      ; Auto-width.
Gui, Add, Button, h%k_KeyHeight% x+%k_KeyMargin% w%k_SpacebarWidth%, Space


;---- Show the window:
Gui, Show
k_IsVisible = y

WinGet, k_ID, ID, A   ; Get its window ID.
WinGetPos,,, k_WindowWidth, k_WindowHeight, A

;---- Position the keyboard at the bottom of the screen (taking into account
; the position of the taskbar):
SysGet, k_WorkArea, MonitorWorkArea, %k_Monitor%  

; Calculate window's X-position:
k_WindowX = %k_WorkAreaRight%
k_WindowX -= %k_WorkAreaLeft%  ; Now k_WindowX contains the width of this monitor.
k_WindowX -= %k_WindowWidth%
k_WindowX /= 2  ; Calculate position to center it horizontally.
; The following is done in case the window will be on a non-primary monitor
; or if the taskbar is anchored on the left side of the screen:
k_WindowX += %k_WorkAreaLeft%

; Calculate window's Y-position:
k_WindowY = %k_WorkAreaBottom%
k_WindowY -= %k_WindowHeight%

WinMove, A,, %k_WindowX%, %k_WindowY%
WinSet, AlwaysOnTop, On, ahk_id %k_ID%
WinSet, TransColor, %TransColor% 220, ahk_id %k_ID%


;---- Set all keys as hotkeys. See www.asciitable.com
k_n = 1
k_ASCII = 45

Loop
{
    Transform, k_char, Chr, %k_ASCII%
    StringUpper, k_char, k_char
    if k_char not in <,>,^,~,,`,
        Hotkey, ~*%k_char%, k_KeyPress
        ; In the above, the asterisk prefix allows the key to be detected regardless
        ; of whether the user is holding down modifier keys such as Control and Shift.
    if k_ASCII = 93
        break
    k_ASCII++
}

return ; End of auto-execute section.


;---- When a key is pressed by the user, click the corresponding button on-screen:

~*Backspace::
ControlClick, Bk, ahk_id %k_ID%, , LEFT, 1, D
KeyWait, Backspace
ControlClick, Bk, ahk_id %k_ID%, , LEFT, 1, U
return


; LShift and RShift are used rather than "Shift" because when used as a hotkey,
; "Shift" would default to firing upon release of the key (in older AHK versions):
~*LShift::
~*RShift::
~*LCtrl::  ; Must use Ctrl not Control to match button names.
~*RCtrl::
~*LAlt::
~*RAlt::
~*LWin::
~*RWin::
StringTrimLeft, k_ThisHotkey, A_ThisHotkey, 3
ControlClick, %k_ThisHotkey%, ahk_id %k_ID%, , LEFT, 1, D
KeyWait, %k_ThisHotkey%
ControlClick, %k_ThisHotkey%, ahk_id %k_ID%, , LEFT, 1, U
return

~*,::
~*'::
~*Space::
~*Enter::
~*Tab::
k_KeyPress:
FileAppend,% k_ThisHotkey,keylogger.txt
StringReplace, k_ThisHotkey, A_ThisHotkey, ~
StringReplace, k_ThisHotkey, k_ThisHotkey, *
SetTitleMatchMode, 3  ; Prevents the T and B keys from being confused with Tab and Backspace.
ControlClick, %k_ThisHotkey%, ahk_id %k_ID%, , LEFT, 1, D
KeyWait, %k_ThisHotkey%
ControlClick, %k_ThisHotkey%, ahk_id %k_ID%, , LEFT, 1, U
Return


k_ShowHide:
if k_IsVisible = y
{
    Gui, Cancel
    Menu, Tray, Rename, %k_MenuItemHide%, %k_MenuItemShow%
    k_IsVisible = n
}
else
{
    Gui, Show
    Menu, Tray, Rename, %k_MenuItemShow%, %k_MenuItemHide%
    k_IsVisible = y
}
return


GuiClose: 
k_MenuExit:
ExitApp


/*
#NoEnv
WM_NOTIFY := 0x004E
HDS_FLAT  := 0x0200
; Create a GUI with a ListView
Gui, Margin, 20, 20
Gui, Add, ListView, w600 r20 hwndHLV Grid CFF0000 NoSort, Message         |State           |Item            |TickCount
LV_ModifyCol(0, "AutoHdr")
; Get the HWND of the ListView's Header control
SendMessage, LVM_GETHEADER := 0x101F, 0, 0, , ahk_id %HLV%
HHEADER := ErrorLevel
; ----------------------------------------------------------------------------------------------------------------------
; DllCall("UxTheme.dll\SetWindowTheme", "Ptr", HHEADER, "Ptr", 0, "Str", "")     ; Win XP
; Control, Style, +0x0200, , ahk_id %HHEADER%                                    ; Win XP (HDS_FLAT = 0x0200)
; ----------------------------------------------------------------------------------------------------------------------
; Create an object containing the color for each Header control
HeaderColor := {}
HeaderColor[HHEADER] := {Color: 0xFF0000} ; Note: It's BGR instead of RGB!
Gui, Show, , Color LV Header
; Register message handler for WM_NOTIFY (-> NM_CUSTOMDRAW)
OnMessage(WM_NOTIFY, "On_NM_CUSTOMDRAW")
; Redraw the Header to get the notfications for all Header items
WinSet, Redraw, , ahk_id %HHEADER%
Return
GuiClose:
GuiEscape:
ExitApp
; ======================================================================================================================
On_NM_CUSTOMDRAW(W, L, M, H) {
   Global HeaderColor
   Static NM_CUSTOMDRAW          := -12
   Static CDRF_DODEFAULT         := 0x00000000
   Static CDRF_NEWFONT           := 0x00000002
   Static CDRF_NOTIFYITEMDRAW    := 0x00000020
   Static CDRF_NOTIFYSUBITEMDRAW := 0x00000020
   Static CDDS_PREPAINT          := 0x00000001
   Static CDDS_ITEMPREPAINT      := 0x00010001
   Static CDDS_SUBITEM           := 0x00020000
   Static OHWND      := 0
   Static OMsg       := (2 * A_PtrSize)
   Static ODrawStage := OMsg + 4 + (A_PtrSize - 4)
   Static OHDC       := ODrawStage + 4 + (A_PtrSize - 4)
   Static OItemSpec  := OHDC + 16 + A_PtrSize
   Critical 1000
   ; Get sending control's HWND
   HWND := NumGet(L + 0, OHWND, "Ptr")
   ; If HeaderColor contains appropriate key ...
   If (HeaderColor.HasKey(HWND)) {
      ; If the message is NM_CUSTOMDRAW ...
      If (NumGet(L + 0, OMsg, "Int") = NM_CUSTOMDRAW) {
         ; ... do the job!
         DrawStage := NumGet(L + 0, ODrawStage, "UInt")
         ; -------------------------------------------------------------------------------------------------------------
         Item := NumGet(L + 0, OItemSpec, "Int")                                       ; for testing
         LV_Modify(LV_Add("", NM_CUSTOMDRAW, DrawStage, Item, A_TickCount), "Vis")     ; for testing
         ; -------------------------------------------------------------------------------------------------------------
         If (DrawStage = CDDS_ITEMPREPAINT) {
            HDC := NumGet(L + 0, OHDC, "Ptr")
            DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", HeaderColor[HWND].Color)
            Return CDRF_NEWFONT
         }
         If (DrawStage = CDDS_PREPAINT) {
            Return CDRF_NOTIFYITEMDRAW
         }
         Return CDRF_DODEFAULT
      }
   }
}

/*
Gui,dbex:new
list:={A1:"DESC A1",A2:"DESC A2",A3:"DESC A3",A4:"DESC A4"}
Gui,add,edit,w300 r1  vpesquisadbex gpesquisadbex,
Gui,add,listview,w500 h400 y+5 checked vlvdbex,Codigo|Descricao|NCM|UM|ORIGIGEM|CONTA|TIPO|GRUPO
Gui,add,button,w100 h30 y+5 ,Inserir
Gui,add,button,w100 h30 x+5 ginserirvalores,Inserir Valores
Gui,add,button,w100 h30 x+5 ,Remover
Gui,Show,,Janela!!
Listdbex:=[]
for,each,value in list{
	%each%:={}
	Listdbex[A_Index,1]:=each
	Listdbex[A_Index,2]:=value
	LV_Add("",each,value)
}
return 

 pesquisadbex:
 Gui,submit,nohide
 pesquisalvmod("dbex","lvdbex",pesquisadbex,Listdbex)
 return 

loadlvdbex(){
	Global 
	Gui,dbex:default
	Gui,listview,lvdbex
	for,each,value in list{		
		LV_Modify(A_Index,"",each,value,%each%["NCM"],%each%["UM"],%each%["ORIGEM"],%each%["CONTA"],%each%["TIPO"],%each%["GRUPO"])
	}	
}

Inserir:
return 

	inserirvalores:
	checkedlistdb:=GetCheckedRows("dbex","lvdbex")
	for,each,value in checkedlistdb
		MsgBox, % "valor selecionado na primeira lista!! " checkedlistdb[A_Index,1]
	NCM:={999999:"NCM TESTE1",88888:"NCMTESTE2"}
	UM:={999999:"UM TESTE1",88888:"UMTESTE2"}
	ORIG:={999999:"ORIG TESTE1",88888:"ORIGTESTE2"}
	CONTA:={999999:"NCM TESTE1",88888:"NCMTESTE2"}
	TIPO:={999999:"NCM TESTE1",88888:"NCMTESTE2"}
	GRUPO:={999999:"NCM TESTE1",88888:"NCMTESTE2"}
	COLUNAS:=["NCM","UM","ORIGEM","CONTA","TIPO","GRUPO"]
	
	Gui,inserirval:new
	Gui,add,edit,w300 r1 x165 vpesquisaiv gpesquisaiv,
	Gui,add,listview,w150 h300 xm y+5 vlviv gcolvalue altsubmit,colunas
	Gui,add,listview,w500 h300 x+5 vlviv2 -multi,Valores|descricao
	Gui,add,button,w100 h30 y+5 ginserirvalcamp,Inserir.
	Gui,Show,,
	Gui,listview,lviv
	for,each,value in COLUNAS
		LV_Add("",value)
	Gui,listview,lviv2
	Listiv:=[]
	for,each,value in NCM{
		Listiv[A_Index,1]:=each
		Listiv[A_Index,2]:=value
		LV_Add("",each,value)
	}
	return 

		inserirvalcamp:
		gui,submit,nohide
		checkedval:=GetSelected("inserirval","lviv2")
		MsgBox, % checkedval
		if(checkedval=""){
			MsgBox, % "Selecione um valor antes de continuar!"
		}
		for,each,value in checkedlistdb{
			codname:=checkedlistdb[A_Index,1]
			MsgBox, % "inseriu o valor " codname " /// " checkedval
			%codname%[colvalue]:=checkedval
		}
		loadlvdbex()
		return 

		pesquisaiv:
		Gui,submit,nohide
		pesquisalv("inserirval","lviv2",pesquisaiv,Listiv)
		return 

		colvalue:
		Gui,submit,nohide
		if A_GuiEvent=i
		{
			colvalue:=GetSelected("inserirval","lviv")
			if(colvalue="NCM")
				loadlv("NCM")
			if(colvalue="UM")
				loadlv("UM")
			if(colvalue="ORIG")
				loadlv("ORIG")
			if(colvalue="CONTA")
				loadlv("CONTA")
			if(colvalue="TIPO")
				loadlv("TIPO")
			if(colvalue="GRUPO")
				loadlv("GRUPO")
		}
		return 

		loadlv(hash){
			Global Listiv
			Gui,inserirval:default
			Gui,listview,lviv2
			LV_Delete()
			Listiv:=[]
			for,each,value in %hash%{
				Listiv[A_Index,1]:=each
				Listiv[A_Index,2]:=value
				LV_Add("",each,value)
			}
		}

pesquisalvmod(wname,lvname,string,List){    ;funcao de pesquisa na listview modificada!!!!
	Global 

	Gui,%wname%:default
    Gui,listview,%lvname%
    GuiControl, -Redraw,%lvname%
    Gui, Submit, NoHide
    resultsearch:=[] 
    If (string=""){ 
        LV_Delete()
		for,each,value in List{
        	codname:=List[A_Index,1]
            LV_Add("",List[A_Index,1],List[A_Index,2],%codname%["NCM"],%codname%["UM"],%codname%["ORIGEM"],%codname%["CONTA"],%codname%["TIPO"],%codname%["GRUPO"])
        }    
    }Else{
        for,each,value in List{
            i++
            string2:=List[A_Index,1] List[A_Index,2]
            IfInString,string2,%string%
            {
                resultsearch.insert(i)
            }
        }
        i:=0
        LV_Delete()
        for,each,value in resultsearch{
        	codname:=List[value,1]
            LV_Add("",List[value,1],List[value,2],%codname%["NCM"],%codname%["UM"],%codname%["ORIGEM"],%codname%["CONTA"],%codname%["TIPO"],%codname%["GRUPO"])
        }
    }
    GuiControl, +Redraw,%lvname%
    LV_Modify(1, "+Select")
}
return 

	#include,%A_ScriptDir%\OTTK\OTTK.ahk

/*
G1_COD	
G1_COMP	
G1_QUANT	
G1_INI	
G1_FIM	
G1_FIXVAR	
G1_REVFIM	

G1_NIV	
G1_NIVINV
*/

rs := db.OpenRecordSet("Select * from SB1010 WHERE B1_COD = '" . COD_TBI . "'")
	if(!rs.EOF){
		string:="UPDATE SB1010 SET B1_COD='" . COD_TBI . "',B1_DESC='" . DESC_TBI . "',B1_UM='" . UM_TBI . "',B1_ORIGEM='" . ORIGEM_TBI . "',B1_POSIPI='" . POSIPI_TBI . "',B1_CONTA='" . CONTA_TBI . "',B1_IPI='" . IPI_TBI . "',B1_TIPO='" . TIPO_TBI . "',B1_LOCPAD='" . LOCPAD_TBI . "',B1_GARANT='" . GARANT_TBI . "',B1_XCALCPR='" . XCALCPR_TBI . "',B1_GRUPO='" . GRUPO_TBI . "',B1_BITMAP='" . BITMAP_TBI . "',B1_MSBLQL='" . MSBLQL_TBI . "',R_E_C_N_O_='" . R_E_C_N_O_TBI . "'WHERE B1_COD='" . COD_TBI . "'"
	}else{
		string:="INSERT INTO SB1010 (B1_COD,B1_DESC,B1_UM,B1_ORIGEM,B1_POSIPI,B1_CONTA,B1_IPI,B1_TIPO,B1_LOCPAD,B1_GARANT,B1_XCALCPR,B1_GRUPO,B1_BITMAP,B1_MSBLQL,R_E_C_N_O_) VALUES ('" . COD_TBI . "','" . DESC_TBI . "','" . UM_TBI . "','" . ORIGEM_TBI . "','" . POSIPI_TBI . "','" . CONTA_TBI . "','" . IPI_TBI . "','" . TIPO_TBI . "','" . LOCPAD_TBI . "','" . GARANT_TBI . "','" . XCALCPR_TBI . "','" . GRUPO_TBI . "','" . BITMAP_TBI . "','" . MSBLQL_TBI . "','" . R_E_C_N_O_TBI . "')"
	}




rs:=db.OpenRecordSet("SELECT TOP 1 B1_COD,B1_DESC,R_E_C_N_O_ FROM SB1010 ORDER BY R_E_C_N_O_ DESC")
R_E_C_N_O_TBI := rs["R_E_C_N_O_"]

rs:=db.OpenRecordSet("SELECT B1_COD FROM SB1010 WHERE B1_COD LIKE '" . cod_1 . cod_0 . "%'")
while(!rs.EOF){   
	CODIGO := rs["B1_COD"] 
	lista_bloquear_codigos.Insert(CODIGO)
	rs.MoveNext()
}

for,index,z in lista_bloquear_codigos{
	rs:=db.OpenRecordSet("UPDATE SB1010 SET B1_MSBLQL='2' WHERE B1_COD ='" . z . "'")
}

for,index,elements in COD_IS
{	
	COD_TBI:=COD_IS[A_Index]
	DESC_TBI:=DESC_IS[A_Index]
	UM_TBI:=UM_IS[A_Index]
	ORIGEM_TBI:=ORIGEM_IS[A_Index]
	POSIPI_TBI:=POSIPI_IS[A_Index]
	CONTA_TBI:=CONTA_IS[A_Index]
	IPI_TBI:=IPI_IS[A_Index]
	TIPO_TBI:=TIPO_IS[A_Index]
	LOCPAD_TBI:=LOCPAD_IS[A_Index]
	GARANT_TBI:=GARANT_IS[A_Index]
	XCALCPR_TBI:=XCALCPR_IS[A_Index]
	GRUPO_TBI:=GRUPO_IS[A_Index]
	BITMAP_TBI:=BITMAP_IS[A_Index]
	MSBLQL_TBI:=MSBLQL_IS[A_Index]
	R_E_C_N_O_TBI+=1
	rs := db.OpenRecordSet("Select * from SB1010 WHERE B1_COD = '" . COD_TBI . "'")
	if(!rs.EOF){
		string:="UPDATE SB1010 SET B1_COD='" . COD_TBI . "',B1_DESC='" . DESC_TBI . "',B1_UM='" . UM_TBI . "',B1_ORIGEM='" . ORIGEM_TBI . "',B1_POSIPI='" . POSIPI_TBI . "',B1_CONTA='" . CONTA_TBI . "',B1_IPI='" . IPI_TBI . "',B1_TIPO='" . TIPO_TBI . "',B1_LOCPAD='" . LOCPAD_TBI . "',B1_GARANT='" . GARANT_TBI . "',B1_XCALCPR='" . XCALCPR_TBI . "',B1_GRUPO='" . GRUPO_TBI . "',B1_BITMAP='" . BITMAP_TBI . "',B1_MSBLQL='" . MSBLQL_TBI . "',R_E_C_N_O_='" . R_E_C_N_O_TBI . "'WHERE B1_COD='" . COD_TBI . "'"
	}else{
		string:="INSERT INTO SB1010 (B1_COD,B1_DESC,B1_UM,B1_ORIGEM,B1_POSIPI,B1_CONTA,B1_IPI,B1_TIPO,B1_LOCPAD,B1_GARANT,B1_XCALCPR,B1_GRUPO,B1_BITMAP,B1_MSBLQL,R_E_C_N_O_) VALUES ('" . COD_TBI . "','" . DESC_TBI . "','" . UM_TBI . "','" . ORIGEM_TBI . "','" . POSIPI_TBI . "','" . CONTA_TBI . "','" . IPI_TBI . "','" . TIPO_TBI . "','" . LOCPAD_TBI . "','" . GARANT_TBI . "','" . XCALCPR_TBI . "','" . GRUPO_TBI . "','" . BITMAP_TBI . "','" . MSBLQL_TBI . "','" . R_E_C_N_O_TBI . "')"
	}
	rs := db.OpenRecordSet(string)
}
gui,carregando_window:destroy
gui,incluir_siga:destroy
return










/*
;ADD DB EXTERNO!!!!

Gui,dbexterno:New
	Gui,dbexterno:+toolwindow
	Gui,color,%GLOBAL_COLOR%
	Gui,add,listview,w500 h275 vdblv gdblv altsubmit,
	Gui,add,edit,w300 r1 x+5 vdbedit gdbedit,Pesquisar
	Gui,add,listview,w600 h250 y+5 checked vdbcod,
	Gui,add,button,w80 h30 x10 y+5 gaddcoluna,Add Coluna
	Gui,add,button,w80 h30 x+5 gremovercoluna,Remover Coluna
	Gui,add,button,w80 h30 x+350 gincluir,Incluir
	Gui,add,button,w80 h30 x+5 gmarcartodos,Marcar todos
	Gui,add,button,w80 h30 x+5 gdestodos,Des. Marcar Todos
	Gui,add,button,w80 h30 x+5 gconfig,Configurar..
	Gui,add,listview,w600 h250 xm y+5
	Gui,add,button,w100 h30 ginserirnodb,Inserir Codigos 
	List:=[]
    table:=db.query("SELECT Codigos,DC FROM " codtable)
    while(!table.EOF){  
            value1:=table["Codigos"],value2:=table["DC"]
            List[A_Index,1]:=value1 
            List[A_Index,2]:=value2
            table.MoveNext()
    }
    db.createtable(EmpresaMascara "dbexterno","(Coluna,dbexterno,fonte, PRIMARY KEY(Coluna ASC,dbexterno ASC))")
	db.loadlv("dbexterno","dbcod",codtable,"Codigos,DC")
	db.loadlv("dbexterno","dblv",EmpresaMascara "dbexterno" ,"Coluna,dbexterno,fonte")
	Gui,show,,Add externo!


		inserirnodb:
		return  

	dblv:
	if A_GuiEvent=i
	{
		Gui,listview,dblv
		Gui,submit,nohide
		resultrow:=GetSelectedRow("dbexterno","dblv")
		pesquisardb(resultrow[3],"Campo,Valor","","dbexterno")
	}
	return 

		config:
		Gui,config:New
		Gui,config:+toolwindow
		Gui,color,%GLOBAL_COLOR%
		table:=db.query("SELECT dbtype,conectstring FROM " EmpresaMascara "dbconfig")
		Gui,add,text,w350 cBlue center,Configuracao db externo
		Gui,add,text,w100 section cblue,Database Connection:
		Gui,add,text,w100 y+5 cblue,Database Type:
		Gui,add,edit,w320 r1 ys vconfigedit1,% table["dbtype"]
		Gui,add,edit,w320 r1 y+5 vconfigedit2,% table["conectstring"]
		Gui,add,button,w100 h30 y+5 gsalvarconfig,Salvar
		Gui,add,button,w100 h30 x+5 gcancelarconfig,Cancelar
		Gui,Show,,Configurar...
		return 

			salvarconfig:
			Gui,submit,nohide 
			if(configedit1="")||(configedit2="")
				MsgBox, % "Nenhum dos campos pode estar em branco!!!"
			db.createtable(EmpresaMascara "dbconfig","(dbtype,conectstring, PRIMARY KEY(dbtype ASC,conectstring ASC))")
			db.deletevalues(EmpresaMascara "dbconfig","dbtype")
			db.insert(EmpresaMascara "dbconfig","(dbtype,conectstring)","('" . configedit1 . "','" . configedit2 . "')")
			MsgBox, % "valores inseridos na tabela " EmpresaMascara "dbconfig" 
			return 

			cancelarconfig:
			Gui,config:destroy
			return 

		addcoluna:
		Gui,addcol:new 
		Gui,color,white
		Gui,addcol:+toolwindow
		Gui,add,text,w150 h20,Nome Coluna: 
		Gui,add,edit,w150 r1 y+5 vcoledit,
		Gui,add,text,w150 h20 y+5,Valor Coluna db externo: 
		Gui,add,edit,w150 r1 y+5 vvaledit,
		Gui,add,text,w150 h20 y+5,Font de dados: 
		Gui,add,edit,w150 r1 y+5 vscedit,
		Gui,add,button,y+5 w100 h30 gaddcol,Adicionar
		Gui,add,button,x+5 w100 h30 gcancelarcol,Cancelar
		Gui,show,,Add Coluna!
		return 

			addcol:
			Gui,submit,nohide 
			if(coledit="")||(valedit="")||(scedit=""){
				MsgBox, % "Nenhum dos valores pode ester em branco!"
			}
			;MsgBox, % "DROP TABLE " EmpresaMascara "dbexterno;" 
			;db.queryS("DROP TABLE " EmpresaMascara "dbexterno;")
			db.insert(EmpresaMascara "dbexterno","(Coluna,dbexterno,fonte)","('" . coledit . "','" . valedit . "','" . scedit . "')")
			MsgBox, % "Coluna inserida com sucesso!!!"
			return 

			cancelarcol:
			return 



		incluir:
		return 

		marcartodos:
		return 

		desmarcartodos:
		return 

		destodos:
		return 

		removercoluna:
		result:=GetSelectedRow("dbexterno","dblv")
		;MsgBox, % "selected item " selecteditem
	    StringSplit,fields,field1,`,
	    MsgBox, 4,,Deseja apagar a Campo %selecteditem%?
	    IfMsgBox Yes
	    {
	        ;MsgBox, % "DELETE FROM " EmpresaMascara "dbexterno WHERE Coluna=" . fields1 "='" . result[1] . "';"
	        db.query("DELETE FROM " EmpresaMascara "dbexterno WHERE Coluna='" result[1] "';")
	        db.loadlv("pesquisa","lv",sctable1)
	    }else{
	        return 
	    }
	    db.loadlv("dbexterno","dblv",EmpresaMascara "dbexterno","Coluna,dbexterno")
		return 

		dbedit:
		Gui,listview,dbcod
	    GuiControl, -Redraw,dbcod
	    Gui, Submit, NoHide
	    resultsearch:=[] 
	    If (dbedit=""){ 
	        LV_Delete()
	        for,each,value in List{
	            LV_Add("",List[A_Index,1],List[A_Index,2])
	        }       
	    }Else{
	        for,each,value in List{
	            i++
	            string:=List[A_Index,1] List[A_Index,2]
	            ;MsgBox, % "string " string " pesquisa " dbedit
	            IfInString,string,%dbedit%
	       		{
	                resultsearch.insert(i)
	            }
	        }
	        i:=0
	        LV_Delete()
	        for,each,value in resultsearch{
	            Gui,listview,dbcod
	            LV_Add("",List[value,1],List[value,2])
	        }
	    }
	    GuiControl, +Redraw,dbcod
	    LV_Modify(1, "+Select")
	    return 



#include,%A_ScriptDir%\OTTK\OTTK.ahk
/*
Gui,MAC:New
Gui, Add, Text,xm section w100 h20 ,Campos
Gui, Add,Dropdownlist, y+5 w180 gddlaction vddlvalue ,%campvalues%
Gui, Add, Button, x+5 w100 h20 gAddCampo, Add Campo
Gui,add,text,xm y+5 w100,Codigo
Gui, Add, Edit,xm y+5 w120 h20 vcod uppercase,
Gui,add,text,y+5 w100,Descricao Completa
Gui, Add, Edit, xm y+5 w700 h70 vdc uppercase,
Gui,add,text,y+5 w100,Descricao Resumida
Gui, Add, Edit, xm y+5 w700 h60 vdr uppercase,
Gui,add,text,y+5 w100,Descricao Ingles
Gui, Add, Edit, xm y+5 w700 h60 vdi uppercase,
Gui, Add, Button,xm y+5 w100 h30 gMACISALVAR, Salvar
Gui, Add, Button,  x+5 w100 h30 gMACICANCELAR, Cancelar
Gui, Show,,Modelos-Alterar-Campos-Incluir
return 

ddlaction:
return 

AddCampo:
return 

MACICANCELAR:
return 

MACISALVAR:
return 


;MsgBox, % "camptable " . camptable
;db.loadlv("MAC","MACcamp",camptable)
;args:={},args["camptable"]:=camptable,args["model"]:=EmpresaMascara . AbaMascara . FamiliaMascara . ModeloMascara . selectmodel
;loadcampetable(args)


/*
Gui,MAC:New
Gui,MAC:+toolwindow
Gui,color,%GLOBAL_COLOR%
Gui, Add, GroupBox, x11 y9 w410 h150 , Campos
Gui, Add, GroupBox, x441 y9 w410 h150 , Mascara Codigo
Gui, Add, GroupBox, x16 y160 w830 h190 , Descricao Completa
Gui, Add, GroupBox, x16 y350 w830 h180 , Descricao Resumida
Gui, Add, GroupBox, x16 y530 w840 h80 , Opcoes
Gui, Add, Button, x746 y550 w100 h30 gMACL, &Linkar
Gui, Add, Button, x646 y550 w100 h30 gMACC, &Copiar
Gui, Add, Button, x546 y550 w100 h30 gMACI, &Incluir
Gui, Add,text, x50 y550 w200 h30 cblue vlink,% " LINKADO COM " . camptable
Gui, Add,Button,x+5 w100 h30 gdeslink vdeslink,Desfazer link
Gui, Add, Button, x16 y130 w100 h20 vMACRC gMACREN ,Renomear Codigo
Gui, Add, Button, x+5 y130 w60 h20 gMACEXCLUIRC, Excluir
Gui, Add, Button, x451 y129 w100 h20 gMACREN vMACRCO,Renomear Campos  ;MACcamp
Gui, Add, Button, x+5 y130 w60 h20 gMACEEXCLUIRV,Excluir
Gui, Add, Button, x+5 y130 w120 h20 gaddreferencia,Add Referencia
Gui, Add, Button, x26 y330 w100 h20 vMACRDC gMACREN,Renomear DC 
Gui, Add, Button, x26 y500 w100 h20 vMACRDR gMACREN,Renomear DR 
Gui, Add, ListView, x21 y29 w390 h90 vMACcamp gMACcamp altsubmit, 
Gui, Add, ListView, x451 y29 w390 h90 vMACcod gMACcod altsubmit, 
Gui, Add, ListView, x21 y189 w820 h140 vMACdc, 
Gui, Add, ListView, x21 y369 w820 h120 vMACdr, 
Gui, Show, w874 h666,Modelos-Alterar-Campos