;##################################################
;#												  #
;#				OTTK							  #
;#												  #
;##################################################
;#Include, Gdip.ahk

Class OTTK
{
	__New(filePath){
		file:=FileOpen(filePath,"r")
		;if !IsObject(file)
		;{
		; 	MsgBox Nao foi possivel abrir "%filePath%".
		; 	return
		;}
		value:=file.Read()
		this.path:=filePath
		StringSplit,fileLine,value,`n,%A_Space%%A_Tab%`r
		Loop,%fileLine0%
		{
			i+=1
			if(fileLine%A_Index%!="")
			{
					StringSplit,value,fileLine%A_Index%,;
					Loop,%value0%
					{
						this[i,A_Index]:=value%A_Index%
					}
			}
		}
	}
	
	delete(value)
	{
		for,k,v in this
		{
			for,w,z in this[k]
			{
				if(this[k,w]=value)
				{
				  this[k].remove(w)	
				}	
			}
		}
		this.write()
	}

	deleterow(row){
		this.remove(row)
		this.write()
	}
	deletevalue(row,column){
		this[row].remove(column)
		this.write()
	}
	
	rename(ovalue,nvalue)
	{
		i:=0
		while(this[A_Index,1]!="")
		{
			i+=1
			while(this[i,A_Index]!="")
			{
				if(this[i,A_Index]=ovalue)
				{
					this[i,A_Index]:=nvalue
				}
			}
		}
		this.write()
	}
	
	append(value)
	{
		i=0
		while(this[A_Index,1]!="")
		{
			i+=1
		}
		this[i+1,1]:=value
		this.write()
	}
	
	write()
	{
		fPath:=this.path
		FileDelete,% this.path
		write:=FileOpen(fPath,"w")
		for,k,v in this
		{
			for,w,z in this[k]
			{
				if(w=1)
				{
						write.Write(this[k,w])
				}else{
						write.Write(";" . this[k,w])
				}
			}
			write.Write("`r`n")	
		}
		write.close()
	}

	exist(value,column)
	{
		returnValue:=0
		while(this[A_Index,column]!="")
			{
				if(value=this[A_Index,column])
					{
						returnValue:=1
					}
			}	
			return returnValue
	}

	clear()
	{
		while(this[A_Index,1]!="")
		{
			this.remove(A_Index)
		}
	}

	checkduplicated()
	{
		MsgBox, % "CheckDuplicated"
		valores:=object()
		duplicatedValues:=""

		i:=0
		while(this[A_Index,1]!="")
		{
			i+=1	
			while(this[i,A_Index]!="")
			{
				_naoinserir:=0
				for,index,k in valores
				{
					if(k=this[i,A_Index])
					{
						_naoinserir:=1
						if(duplicatedValues="")
						{
							duplicatedValues.=k	
						}Else{
							duplicatedValues.=";" . k
						}
							
					}
				}
				if(_naoinserir=0)
				{
					valores.insert(this[i,A_Index])	
				}
			}
				
		}
		return duplicatedValues
	}
}

getsuperitem(string)
{
	returnValue:=""
	StringReplace,value,string,Q\,|
	StringSplit,value,value,|
	StringSplit,value,value2,\
	Loop,%value0%
	{
		if(A_Index=1)
		{
			returnValue.=value%A_Index%
		}else{
			returnValue.=";" . value%A_Index%
		}
	}
	return returnValue
}



;#############CRIAR PLAQUETAS################################################
createtag(prefix,prefix2,model,selectmodel,codelist,textsize=20,textcolor="ff000000",imagepath="image.png"){
	Global db
	
	;MsgBox, % " prefix " prefix " prefix2 " prefix2 " model " model " selectmodel " selectmodel " codelist " codelist
	table:=db.iquery("SELECT * FROM " codelist ";")
	;MsgBox, % table.Rows.Count() 
	progress(table.Rows.Count())
	totalwidth:=385*table.Rows.Count()
	newgdi({w:807,h:totalwidth})
	StringLen,prefixlength,prefix
	StringLen,modellength,model
	y:=80 
	panel({x:0,y:0,w:807,h:totalwidth,color: "white",boardcolor: "0x00000000"})
	;MsgBox, % " ira iniciar os codigos !!! " codelist 
	for,each,value in list:=db.getvalues("Codigos,DR",codelist){
		x:=30	
		updateprogress("Criando Tags: " list[A_Index,1],1)
		result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" list[A_Index,1] "'")
		db.loadimage("","",result["tabela2"])
		panel({x:x,y:y-60,w:110,h:50,color: "nocolor",text:"Familia",textsize: 10,textcolor: textcolor,boardersize:0})
		panel({x:x,y:y,w:110,h:50,color: "nocolor",text:prefix2,textsize: textsize,textcolor: textcolor})
	
		panel({x:x+=120,y:y-60,w:110,h:50,color: "nocolor",text:"Modelo",textsize: 10,textcolor: textcolor,boardersize:0})
		panel({x:x,y:y,w:110,h:50,color: "nocolor",text:model,textsize: textsize,textcolor: textcolor})
		codigo:=list[A_Index,1]	
		StringTrimleft,codigo,codigo,prefixlength+modellength
		;MsgBox, % "to relreference " prefix model selectmodel
		relreference:=getreferencetable("oc",prefix model selectmodel)
		;MsgBox, % " retorno relreference " relreference 
		for,each,value in list2:=db.getvalues("Campos",relreference){
			campname:=list2[A_Index,1]
			StringReplace,campname,campname,%A_Space%,,All
			result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='" campname "' AND tabela1='" prefix model selectmodel "'")
			camplist:=result["tabela2"]
			;MsgBox, % camplist 
			for,each,value in list3:=db.getvalues("CODIGO,DR",camplist){
				codepiece:=list3[A_Index,1]
				;MsgBox, % codepiece
				StringLen,length,codepiece
				if(length!=""){
					StringLeft,codepiece,codigo,length
					StringTrimLeft,codigo,codigo,length	
					Break
				}
			} 	
			panel({x:x+=120,y:y-60,w:110,h:50,color: "nocolor",text:list2[A_Index,1],textsize:8,textcolor: textcolor})
			panel({x:x,y:y,w:110,h:50,color: "nocolor",text:codepiece,textsize: textsize,textcolor: textcolor})
		}
		panel({x:30,y:y+=60,w:200,h:200,color: "nocolor",imagepath: imagepath})
		panel({x:245,y:y,w:505,h:200,color: "nocolor",text:list[A_Index,2],textsize: 30,textcolor: textcolor})		
		y+=320
	}
	Gui,progress:destroy
	MsgBox, % "O arquivo foi salvo!!"
	savetofile("imagename.png")
}
;################################################################################################################################

;################Format########################
{
	Format(value){
		Local returnValue
		StringReplace,returnValue,value,.,, All
		StringReplace,returnValue,returnValue,(,, All
		StringReplace,returnValue,returnValue,),, All
		return returnValue
	}
}
;################objhasvalue###################
objHasValue(obj,value){
	for,each,value2 in obj
		IfEqual,value2,%value%,return,True
}

;##############banner#########################
banner(color,ByRef Variable, Text="", TextOptions="x0p y15p s60p Center cffffffff r4 Bold", Font="verdana")
{
    GuiControlGet, Pos, Pos, Variable
    GuiControlGet, hwnd, hwnd, Variable
    ;pBrushFront := Gdip_BrushCreateSolid(Foreground), pBrushBack := Gdip_BrushCreateSolid(Background)
    pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)
    w:=posw,h:=posh
    colors:=getcolors(color)
	pPen := Gdip_CreatePen((a.color="") ? "0xff000000" : a.color,(a.size="") ? 5 : a.size)
	Gdip_DrawRoundedRectangle(G,pPen,0,0,w,h,5)
	pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h,colors[1],colors[2])
	Gdip_FillRectangle(G, pBrush, 0, 0, w, h)
	Gdip_DeleteBrush(pBrush)
	;pBrush := Gdip_BrushCreateHatch(args.color3,args.color4, 8)
	;Gdip_FillRectangle(G, pBrush, 0, 0, w, h)
	;Gdip_DeleteBrush(pBrush)
    Gdip_TextToGraphics(G,Text,TextOptions, Font, Posw, Posh)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    SetImage(hwnd, hBitmap)
    Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
    Return, 0
}
;#############GDI TO PICTURE CONTROL ###################
gditopic(ByRef Variable){
	Global pBitmap


    GuiControlGet, hwnd, hwnd, Variable
    hbm1 := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    MsgBox, % "hwnd " hwnd " hbm1 " hbm1
    SetImage(hwnd,hbm1)
    ;Gdip_DisposeImage(pBitmap),DeleteObject(hBitmap)
}

;################progress###################
updateprogress(text,increase){
    Global progress,plabel
    GuiControl,,progress,+%increase%
    GuiControl,,plabel,%text%   
}


progress(maxrange){
    Global progress,plabel
    Gui,progress:New 
    Gui,color,gray
    Gui,progress:-caption +toolwindow +alwaysontop
    Gui, Add, Progress, w300 h20 cBlue Range0-%maxrange% vprogress
    Gui,font,s8
    Gui,Add,text,w300 h100 y+5 vplabel
    Gui,Show,,progresso
} 

;############deletefromarray###########################

deletefromarray(string,array){
	for,each,value in array{
		if (string=value){
			array.Remove(each)
		}
	}
	for,each,value in array[1]{
		if (string=value){
			array.Remove(each)
		}
	}
	return array
}

;#####################################################

;###########existcontrol###########################
existcontrol(name){
	GuiControlGet,x,Pos,%name%
	if(xx!="")    ;isso quer dizer que o botao ja existe na lista!
		returnvalue:=true 
	Else
		returnvalue:=false
	return returnValue
}
;#################save an image to a file#####################
savetofile(imagename,show=0){
	Global pBitmap

	FileDelete, % imagename  
	Gdip_SaveBitmapToFile(pBitmap,imagename)
	Gdip_DisposeImage(pBitmap)
	if(show=1)
		run,%imagename%
}
;############PANEL###################################
panel(a){
	Global

	if(a.imagepath!=""){
		pBitmapFile1:=Gdip_CreateBitmapFromFile(a.imagepath)
		Width := Gdip_GetImageWidth(pBitmapFile1), Height := Gdip_GetImageHeight(pBitmapFile1)
		Gdip_DrawImage(G,pBitmapFile1,a.x,a.y,a.w,a.h,0,0,Width,Height)
	}
	colors:=getcolors((a.color="") ? "blue" : a.color)
	pBrush := Gdip_CreateLineBrushFromRect(a.x,a.y,(a.w="") ? 100 : a.w,(a.h="") ? 100 : a.h,colors[1],colors[2])
	Gdip_FillRoundedRectangle(G,pBrush,(a.x="") ? 100 : a.x,(a.y="") ? 100 : a.y,(a.w="") ? 100 : a.w,(a.h="") ? 100 : a.h,(a.r="") ? 1 : a.r)
	pPen := Gdip_CreatePen((a.boardcolor="") ? "0xff000000" : a.boardcolor,(a.boardsize="") ? 2 : a.boardsize)
	Gdip_DrawRoundedRectangle(G,pPen,a.x,a.y,a.w,a.h,a.r)
	a.textx:=(a.textx="") ? a.x+5 : a.x+a.textx
	a.texty:=(a.texty="") ? a.y+5 : a.y+a.texty
	a.textsize:=(a.textsize="") ? 8 : a.textsize
	a.textalign:=(a.textalign="") ? "left" : a.textalign
	a.textcolor:=(a.textcolor="") ? "ffffffff" : a.textcolor
	TextOptions:="x" a.textx " y" a.texty  " s" a.textsize " " a.textalign " c" a.textcolor  " r4 Bold",Font:=(a.font="") ? "arial" : a.font
	Gdip_TextToGraphics(G,a.text,TextOptions,Font,a.w,a.h) 
	a.text2x:=(a.text2x="") ? a.x+5 : a.x+a.text2x
	a.text2y:=(a.text2y="") ? a.y+20 : a.y+a.text2y
	a.text2size:=(a.text2size="") ? 20 : a.text2size
	a.text2align:=(a.text2align="") ? "left" : a.text2align
	a.text2color:=(a.text2color="") ? "ffffffff" : a.text2color
	TextOptions:="x" a.text2x " y" a.text2y  " s" a.text2size " " a.text2align " c" a.text2color  " r4 Bold",Font:=(a.font="") ? "arial" : a.font
	Gdip_TextToGraphics(G,a.text2,TextOptions,Font,a.w,a.h) 
	Gdip_DisposeImage(pBitmapFile1)
}
;################# start a new instance of gdi+################################################
newgdi(a){
	Global
	If !pToken := Gdip_Startup()
	{
	    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	    ExitApp
	}
	a.w:= (a.w="") ? 500 : a.w
	a.h:= (a.h="") ? 500 : a.h
	pBitmap := Gdip_CreateBitmap(a.w,a.h), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)
	return 
}



; O BACKUP ESTA NO TESTE1.AHK
;############PTCODE##################################
ptcode(wName,x,y,prefixpt,prefixpt2,modelpt){
	Global
	gui,%wName%:default
	;MsgBox, % "prefixpt " prefixpt " prefixpt2 " prefixpt2 " modelpt " modelpt
	destroycontrols(wName)
	controllist:=[]
	ptx:=x,pty:=y
	TextOptions:="x0p y0p s30p center  cffffffff r4 Bold" 
	Font:="Arial"
	Gui,Add, Picture,w900 h900 x%x% y%y% 0xE,background
	banner1("darkblue","background","",TextOptions,Font,5)
	controllist.insert("background")
	Gui,add,picture,w200 h200 x%x% y%y% ,sem_imagem.png
	controllist.insert("sem_imagem.png")
	result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" prefixpt modelpt selectmodel "'")
	db.loadimage(wName,"sem_imagem.png",result["tabela2"])
	;sleep,500
	Gui,Add,Picture,w750 h80 x+5 0xE,mainbanner
	controllist.insert("mainbanner")
	table:=db.query("SELECT descricao FROM " prefixpt modelpt "Desc;")
	banner1("blue","mainbanner",table["descricao"],TextOptions,Font)
	table.close()
	TextOptions:="x0p y0p s30p center  cffffffff r4 Bold"
	Gui,Add, Picture,w80 h70 y+5 0xE ,banner0
	controllist.insert("banner0")
	banner1("green","banner0",prefixpt2,TextOptions,Font)
	for,each,value in [modelpt]{	
		Gui,Add, Picture,wp hp x+5 0xE ,banner%A_Index%
		valuetbi=banner%A_Index%
		controllist.insert(valuetbi) 
		banner1("yellow",valuetbi,value,TextOptions,Font)
	}
	TextOptions:="x0p y0p s30p center  cffffffff r4 Bold"
	TextOptions2:="x0p y70p s70p center  cffffffff r4 Bold"
	;MsgBox, % "SELECT tabela2 FROM reltable WHERE tipo='oc' AND tabela1='" prefixpt modelpt selectmodel "'"
	result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='oc' AND tabela1='" prefixpt modelpt selectmodel "'")
	camptable:=result["tabela2"]
	;MsgBox, % "camptable " camptable
	if(camptable="")
		camptable:=prefixpt modelpt "oc"
	for,each,value in list:=db.getvalues("Campos",camptable){
		campname:=list[A_Index,1]
		StringReplace,campname,campname,%A_Space%,,All
		;MsgBox, % "SELECT tabela2 FROM reltable WHERE tipo='" campname "' AND tabela1='" prefixpt modelpt selectmodel "'"
		result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='" campname "' AND tabela1='" prefixpt modelpt selectmodel "'")
		camplist:=result["tabela2"]
		;MsgBox, % camplist
		if(camplist="")
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
;################################SCROLLL WINDOW######################################################
#IfWinActive ahk_group MyGui
WheelUp::
WheelDown::
+WheelUp::
+WheelDown::
    ; SB_LINEDOWN=1, SB_LINEUP=0, WM_HSCROLL=0x114, WM_VSCROLL=0x115
    OnScroll(InStr(A_ThisHotkey,"Down") ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, WinExist())
return
#IfWinActive

UpdateScrollBars(GuiNum, GuiWidth, GuiHeight)
{
    static SIF_RANGE=0x1, SIF_PAGE=0x2, SIF_DISABLENOSCROLL=0x8, SB_HORZ=0, SB_VERT=1
    ;msgBox, %GuiNum%
    Gui, %GuiNum%:Default
    Gui, +LastFound
    
    ; Calculate scrolling area.
    Left := Top := 9999
    Right := Bottom := 0
    WinGet, ControlList, ControlList
    Loop, Parse, ControlList, `n
    {
        GuiControlGet, c, Pos, %A_LoopField%
        if (cX < Left)
            Left := cX
        if (cY < Top)
            Top := cY
        if (cX + cW > Right)
            Right := cX + cW
        if (cY + cH > Bottom)
            Bottom := cY + cH
    }
    Left -= 8
    Top -= 8
    Right += 8
    Bottom += 8
    ScrollWidth := Right-Left
    ScrollHeight := Bottom-Top
    
    ; Initialize SCROLLINFO.
    VarSetCapacity(si, 28, 0)
    NumPut(28, si) ; cbSize
    NumPut(SIF_RANGE | SIF_PAGE, si, 4) ; fMask
    
    ; Update horizontal scroll bar.
    NumPut(ScrollWidth, si, 12) ; nMax
    NumPut(GuiWidth, si, 16) ; nPage
    DllCall("SetScrollInfo", "uint", WinExist(), "uint", SB_HORZ, "uint", &si, "int", 1)
    
    ; Update vertical scroll bar.
;     NumPut(SIF_RANGE | SIF_PAGE | SIF_DISABLENOSCROLL, si, 4) ; fMask
    NumPut(ScrollHeight, si, 12) ; nMax
    NumPut(GuiHeight, si, 16) ; nPage
    DllCall("SetScrollInfo", "uint", WinExist(), "uint", SB_VERT, "uint", &si, "int", 1)
    
    if (Left < 0 && Right < GuiWidth)
        x := Abs(Left) > GuiWidth-Right ? GuiWidth-Right : Abs(Left)
    if (Top < 0 && Bottom < GuiHeight)
        y := Abs(Top) > GuiHeight-Bottom ? GuiHeight-Bottom : Abs(Top)
    if (x || y)
        DllCall("ScrollWindow", "uint", WinExist(), "int", x, "int", y, "uint", 0, "uint", 0)
}

OnScroll(wParam, lParam, msg, hwnd)
{
    static SIF_ALL=0x17, SCROLL_STEP=10
    
    bar := msg=0x115 ; SB_HORZ=0, SB_VERT=1
    
    VarSetCapacity(si, 28, 0)
    NumPut(28, si) ; cbSize
    NumPut(SIF_ALL, si, 4) ; fMask
    if !DllCall("GetScrollInfo", "uint", hwnd, "int", bar, "uint", &si)
        return
    
    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "uint", hwnd, "uint", &rect)
    
    new_pos := NumGet(si, 20) ; nPos
    
    action := wParam & 0xFFFF
    if action = 0 ; SB_LINEUP
        new_pos -= SCROLL_STEP
    else if action = 1 ; SB_LINEDOWN
        new_pos += SCROLL_STEP
    else if action = 2 ; SB_PAGEUP
        new_pos -= NumGet(rect, 12, "int") - SCROLL_STEP
    else if action = 3 ; SB_PAGEDOWN
        new_pos += NumGet(rect, 12, "int") - SCROLL_STEP
    else if (action = 5 || action = 4) ; SB_THUMBTRACK || SB_THUMBPOSITION
        new_pos := wParam>>16
    else if action = 6 ; SB_TOP
        new_pos := NumGet(si, 8, "int") ; nMin
    else if action = 7 ; SB_BOTTOM
        new_pos := NumGet(si, 12, "int") ; nMax
    else
        return
    
    min := NumGet(si, 8, "int") ; nMin
    max := NumGet(si, 12, "int") - NumGet(si, 16) ; nMax-nPage
    new_pos := new_pos > max ? max : new_pos
    new_pos := new_pos < min ? min : new_pos
    
    old_pos := NumGet(si, 20, "int") ; nPos
    
    x := y := 0
    if bar = 0 ; SB_HORZ
        x := old_pos-new_pos
    else
        y := old_pos-new_pos
    ; Scroll contents of window and invalidate uncovered area.
    DllCall("ScrollWindow", "uint", hwnd, "int", x, "int", y, "uint", 0, "uint", 0)
    
    ; Update scroll bar.
    NumPut(new_pos, si, 20, "int") ; nPos
    DllCall("SetScrollInfo", "uint", hwnd, "int", bar, "uint", &si, "int", 1)
}
;###############################################################
;#####################################################################################################

;##################destroycontrol#####################################################################
destroycontrols(wName){
	Global
	Gui,%wName%:default
	;WM_CLOSE=0x10
	for each,value in controllist{
		;MsgBox, % value 
		PostMessage,0x10,,,%value%
	}
}
;############################getcolors###############################################################
getcolors(colorname){
	colors:=[]
	;lightblue:=75c2d4
	;blue:=3f8c9e
	;darkblue:=235c73
	;75c2d4
	;ff00ff
	;oldblue colors[1]:="0xff1e90ff",colors[2]:="0xff0949e9"
	if(colorname="blue")
		colors[1]:="0xff3f8c9e",colors[2]:="0xff1d5a6b"
	if(colorname="red")
		colors[1]:="0xFFF90101",colors[2]:="0xFFA50101"
	if(colorname="yellow")
		colors[1]:="0xFFF2B50F",colors[2]:="0xFFFFCC11"
	if(colorname="green")
		colors[1]:="0xFF00933B",colors[2]:="0xFF00533B"
	if(colorname="lightblue")
		colors[1]:="0xff75c2d4",colors[2]:="0xff3f8c9e"
	if(colorname="floralwhite")
		colors[1]:="0xfffffaf0",colors[2]:="0xfffffaf0"
	if(colorname="ghostwhite")
		colors[1]:="0xfff8f8ff",colors[2]:="0xfff8f8ff"
	if(colorname="darkblue")
		colors[1]:="0xff1e3364",colors[2]:="0xff1e3364"
	if(colorname="pink")
		colors[1]:="0xffff00ff",colors[2]:="0xffff00ff"
	if(colorname="darkgrey")
		colors[1]:="0xff545454",colors[2]:="0xffA4A4A4"
	if(colorname="grey")
		colors[1]:="0xffC0C0C0",colors[2]:="0xffffffff"
	if(colorname="lightgrey")
		colors[1]:="0xffAEAEAE",colors[2]:="0xffCECECE"
	if(colorname="white")
		colors[1]:="0xffffffff",colors[2]:="0xffffffff"
	if(colorname="nocolor")
		colors[1]:="0x00ffffff",colors[2]:="0x00ffffff"
	if(colorname="verydarkblue")
		colors[1]:="0xff102E37",colors[2]:="0xff162f3E"
	if(colorname="turquoise")
		colors[1]:="0xff2BBBD8",colors[2]:="0xff2FBFDF"
	if(colorname="lightorange")
		colors[1]:="0xffF78D3F",colors[2]:="0xffFD8F3F"
	if(colorname="nocolor")
		colors[1]:="0x00ffffff",colors[2]:="0x00ffffff"
	if(colorname="darkgreen")
		colors[1]:="0xff009A31",colors[2]:="0xff009A31"
	if(colorname="limegreen")
		colors[1]:="0xff84CF96",colors[2]:="0xff84CF96"
	if(colorname="verylightgreen")
		colors[1]:="0xffC6E7CE",colors[2]:="0xffC6E7CE"
	if(colorname="coolgreen")
		colors[1]:="0xff669900",colors[2]:="0xff225500"
	if(colorname="coolblue")
		colors[1]:="0xff0099FF",colors[2]:="0xff0055AA"
	if(colorname="cooldarkblue")
		colors[1]:="0xff0033CC",colors[2]:="0xff000088"
	if(colorname="orange")
		colors[1]:="0xffff3311",colors[2]:="0xffff7722"
	return colors
}
;GREEN 95bb32  DARKBLUE 004066 TURQUOISE 00abde
;############banner1############################################################################

banner1(color,Variable,Text="",TextOptions="x0p y15p s60p Center cffffffff r4 Bold", Font="verdana",r=1)
{
    GuiControlGet, Pos, Pos,%Variable%
    GuiControlGet, hwnd, hwnd,%Variable%
    pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)
    w:=posw,h:=posh
    colors:=getcolors(color)
	pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h,colors[1],colors[2])
	Gdip_FillRoundedRectangle(G, pBrush, 0, 0,w,h,r)
	;Gdip_FillRectangle(G, pBrush, 0, 0, w, h)
	Gdip_DeleteBrush(pBrush)
	;pBrush := Gdip_BrushCreateHatch(args.color3,args.color4, 8)
	;Gdip_FillRectangle(G, pBrush, 0, 0, w, h)
	;Gdip_DeleteBrush(pBrush)
    Gdip_TextToGraphics(G,Text, TextOptions, Font, Posw, Posh)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    SetImage(hwnd, hBitmap)
    Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
    Return, 0
}

;################banner2###########################################################################

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
;##############MATHASVALUE###########################
MatHasValue(matrix,value){
		i:=0
		returnValue:=False
		while(matrix[A_Index,1]!=""){
			i+=1
			while(matrix[i,A_Index]!=""){
				if(matrix[i,A_Index]=value){
					returnValue:=True
				}
			}
		}
		return returnValue
}
;#############addbutton#########################
addbutton(bargs){
	Static x,count
	name:=bargs["name"],label:=bargs["label"],window:=bargs["window"]
	w:=bargs["w"],h:=bargs["h"]
	Gui,%window%:default
	;GuiControlGet,x,Pos,%name%
	;if(xx!="")    ;isso quer dizer que o botao ja existe na lista!
		;return
	if(bargs["count"]=1){
		x:=bargs["initialx"],y:=bargs["initialy"]
		count:=bargs["count"]
		Gui,Add,Button,x%x% y%y% w%w% h%h%  g%label%,% name
	}else{
		if(objHasValue(bargs["buttonfield"],bargs["count"])){
			x+=bargs["w"],y:=bargs["initialy"]
			Gui,Add,Button,x%x% y%y% w%w% h%h%  g%label%,% name
		}else{
			Gui,Add,Button,y+5 w%w% h%h%  g%label%,% name
		}
	}
	bargs["count"]+=1
	Gui, Show, AutoSize Center
}
;################Incremental#################
incrementalseach(list,args){
   	Gui,Incremental:New 
    Gui, Add, Edit, x5 y5 h20 w300 -wrap vSearchString gIncrimentalSearch, 
    Gui, Add, Listbox, x5 y30 h300 w300 Sort vChoice gSelectedItem, %List%
    Gui, Add, Button, x5 y340 h20 w300 gCopyClick default ,OK
    Gui, Show, Center, IncreSimpleSearch
    Return
     
    IncrimentalSearch:
        List_b := "|"
        GuiControl, -Redraw, Choice
        Gui, Submit, NoHide
        If SearchString = 
            GuiControl, , Choice, %List_a%
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
     
    SelectedItem:
        MsgBox, % A_EventInfo
        If A_GuiEvent != DoubleClick
            Return
        Gui, Submit, NoHide
        RegExMatch(Choice,"\d{1,4} \- (.*)",query)
        Run https://www.google.com/search?q=%query1%
    return
     
    CopyClick:
        Gui, Submit, NoHide
        MsgBox, % Choice
        If Choice =
            Return
        Else
        {
            RegExMatch(Choice,"(\d{1,4}) \- .*",Clip)
            ClipBoard   :=  Clip1
            TrayTip, IncreSimpleSearch, Copied: %Clip1%,1,1
        }
    Return
}

;################Read########################
{
Read(filePath,tableName){
		Global 
		OTTK_%tableName%:=Object()
		file:=FileOpen(filePath,"r")
		OTTK_%tableName%.path:=filePath
		value:=file.Read()
		x:=1        ;Variables that counts the number of entryes in the column.
		StringSplit,fileLine,value,`n,%A_Space%%A_Tab%`r
		Loop,%fileLine0%{
			if(fileLine%A_Index%!=""){
					StringSplit,value,fileLine%A_Index%,;
					Loop,%value0%{
							If(A_Index=1){
								OTTK_%tableName%.C1[x]:=value1	
							}
							if(A_Index=2){
								OTTK_%tableName%.C2[x]:=value2	
							}
							if(A_Index=3){
								OTTK_%tableName%.C3[x]:=value3
							}
							if(A_Index=4){
								OTTK_%tableName%.C4[x]:=value4	
							}
							if(A_Index=5){
								OTTK_%tableName%.C5[x]:=value5	
							}
							if(A_Index=6){
								OTTK_%tableName%.C6[x]:=value6	
							}
							if(A_Index=7){
								OTTK_%tableName%.C7[x]:=value7	
							}
							if(A_Index=8){
								OTTK_%tableName%.C8[x]:=value8	
							}
							if(A_Index=9){
								OTTK_%tableName%.C9[x]:=value9
							}
												if(A_Index=10){
								OTTK_%tableName%.C10[x]:=value10
							}
												if(A_Index=11){
								OTTK_%tableName%.C11[x]:=value11
							}
												if(A_Index=12){
								OTTK_%tableName%.C12[x]:=value12
							}
												if(A_Index=13){
								OTTK_%tableName%.C13[x]:=value13
							}
												if(A_Index=14){
								OTTK_%tableName%.C14[x]:=value14
							}
												if(A_Index=15){
								OTTK_%tableName%.C15[x]:=value15
							}
												if(A_Index=16){
								OTTK_%tableName%.C16[x]:=value16
							}
												if(A_Index=17){
								OTTK_%tableName%.C17[x]:=value17
							}
												if(A_Index=18){
								OTTK_%tableName%.C18[x]:=value18
							}
												if(A_Index=19){
								OTTK_%tableName%.C19[x]:=value19	
							}
												if(A_Index=20){
								OTTK_%tableName%.C20[x]:=value20	
							}
						}
						x+=1
				}
				
		}
		OTTK_%tableName%.maxIndex:=x-1
		file.close()
		return
}
}	

;###############ClearRead##################
{
ClearRead(tableName){
		Global 
		OTTK_%tableName%:=Object()
		return
}
}

;###############CreateFile###############
{
CreateFile(Path,obj){
	Global 
			OTTK_%obj%:=object() 
			OTTK_%obj%.path:=Path
	return
}
}

;##############Append####################
{
Append(value,col,obj)
{
	Global 
	Loop{
			if(OTTK_%obj%.C1[A_Index]=""){
				if(col=1){
					OTTK_%obj%.C1[A_Index]:=value
					break
				}
				if(col=2){
					OTTK_%obj%.C2[A_Index]:=value
					break
				}
				if(col=3){
					OTTK_%obj%.C3[A_Index]:=value
					break
				}
				if(col=4){
					OTTK_%obj%.C4[A_Index]:=value
					break
				}
				if(col=5){
					OTTK_%obj%.C5[A_Index]:=value
					break
				}
				if(col=6){
					OTTK_%obj%.C6[A_Index]:=value
					break
				}
				if(col=7){
					OTTK_%obj%.C7[A_Index]:=value
					break
				}
				if(col=8){
					OTTK_%obj%.C8[A_Index]:=value
					break
				}
				if(col=9){
					OTTK_%obj%.C9[A_Index]:=value
					break
				}
				if(col=10){
					OTTK_%obj%.C10[A_Index]:=value
					break
				}
				if(col=11){
					OTTK_%obj%.C11[A_Index]:=value
					break
				}
				if(col=12){
					OTTK_%obj%.C12[A_Index]:=value
					break
				}
				if(col=13){
					OTTK_%obj%.C13[A_Index]:=value
					break
				}
				if(col=14){
					OTTK_%obj%.C14[A_Index]:=value
					break
				}
				if(col=15){
					OTTK_%obj%.C15[A_Index]:=value
					break
				}
				if(col=16){
					OTTK_%obj%.C16[A_Index]:=value
					break
				}
				if(col=17){
					OTTK_%obj%.C17[A_Index]:=value
					break
				}
				if(col=18){
					OTTK_%obj%.C18[A_Index]:=value
					break
				}
				if(col=19){
					OTTK_%obj%.C19[A_Index]:=value
					break
				}
				if(col=20){
					OTTK_%obj%.C20[A_Index]:=value
					break
				}
			}
		}
	}
}

;###############Write#####################
{
Write(obName){
	global
	Local String
	Local fPath 
	fPath:=OTTK_%obName%.path 
	write:=FileOpen(fPath,"w")
	Loop
	{
		if(OTTK_%obName%.C1[A_Index]=""){
				break
		}
		String:=OTTK_%obName%.C1[A_Index] . ";" . OTTK_%obName%.C2[A_Index] . ";" . OTTK_%obName%.C3[A_Index] . ";" . OTTK_%obName%.C4[A_Index] . ";" . OTTK_%obName%.C5[A_Index] . ";" . OTTK_%obName%.C6[A_Index] . ";" . OTTK_%obName%.C7[A_Index] . ";" . OTTK_%obName%.C8[A_Index] . ";" . OTTK_%obName%.C9[A_Index] . ";" . OTTK_%obName%.C10[A_Index] . ";" . OTTK_%obName%.C11[A_Index] . ";" . OTTK_%obName%.C12[A_Index] . ";" . OTTK_%obName%.C13[A_Index] . ";" . OTTK_%obName%.C14[A_Index] . ";" . OTTK_%obName%.C15[A_Index] . ";" . OTTK_%obName%.C16[A_Index] . ";" . OTTK_%obName%.C17[A_Index] . ";" . OTTK_%obName%.C18[A_Index] . ";" . OTTK_%obName%.C19[A_Index] . ";" . OTTK_%obName%.C20[A_Index]
		if(A_Index=1)
		{
				write.Write(String)
		}else{
				write.Write("`r`n" . String)
		}
	}
	write.Close()
    return
}
}
;##############LOADLVFROMFILE#####################

loadlvfromarray(array,wName="",lvName="",ID=""){
	Global
	if(wName!="")
		Gui,%wName%:default 
	if(lvName!="")
		Gui,listView,%lvName%
	LV_Delete(),LV_DeleteCol("1")
	LV_InsertCol("1","",ID)
	for,each,value in array[ID]
		LV_Add("",value)

	LV_ModifyCol(1,150)
}
;##############ReadLV#####################
{
ReadLV(wName="",lvName="",tableName=""){
	Global 
	Local x 
	x:=0
	if(wName!=""){
		Gui,%wName%:default 
	}
	if(lvName!=""){
		Gui,listView,%lvName%
	}
	OTTK_%tableName%:=Object()
	Loop,% LV_GetCount()
	{
		x+=1
		LV_GetText(value1,A_Index,1)
		LV_GetText(value2,A_Index,2)
		LV_GetText(value3,A_Index,3)
		LV_GetText(value4,A_Index,4)
		LV_GetText(value5,A_Index,5)
		LV_GetText(value6,A_Index,6)
		LV_GetText(value7,A_Index,7)
		LV_GetText(value8,A_Index,8)
		LV_GetText(value9,A_Index,9)
		LV_GetText(value10,A_Index,10)
		LV_GetText(value11,A_Index,11)
		LV_GetText(value12,A_Index,12)
		LV_GetText(value13,A_Index,13)
		LV_GetText(value14,A_Index,14)
		LV_GetText(value15,A_Index,15)
		LV_GetText(value16,A_Index,16)
		LV_GetText(value17,A_Index,17)
		LV_GetText(value18,A_Index,18)
		LV_GetText(value19,A_Index,19)
		LV_GetText(value20,A_Index,20)
		OTTK_%tableName%.C1[A_Index]:=value1
		OTTK_%tableName%.C2[A_Index]:=value2
		OTTK_%tableName%.C3[A_Index]:=value3
		OTTK_%tableName%.C4[A_Index]:=value4
		OTTK_%tableName%.C5[A_Index]:=value5
		OTTK_%tableName%.C6[A_Index]:=value6
		OTTK_%tableName%.C7[A_Index]:=value7
		OTTK_%tableName%.C8[A_Index]:=value8
		OTTK_%tableName%.C9[A_Index]:=value9
		OTTK_%tableName%.C10[A_Index]:=value10
		OTTK_%tableName%.C11[A_Index]:=value11
		OTTK_%tableName%.C12[A_Index]:=value12
		OTTK_%tableName%.C13[A_Index]:=value13
		OTTK_%tableName%.C14[A_Index]:=value14
		OTTK_%tableName%.C15[A_Index]:=value15
		OTTK_%tableName%.C16[A_Index]:=value16
		OTTK_%tableName%.C17[A_Index]:=value17
		OTTK_%tableName%.C18[A_Index]:=value18
		OTTK_%tableName%.C19[A_Index]:=value19
		OTTK_%tableName%.C20[A_Index]:=value20
	}
	OTTK_%tableName%.maxIndex:=x
	return 
}
}

;##############FillLV#####################
{

FillLV(filePath,wName="",lvName=""){
	Global
	Read(filePath,"fillLV")
	if(wName!=""){
			Gui,%wName%:default
	}
	if(lvName!=""){
			Gui,ListView,%lvName%
			GuiControl, -Redraw,%lvName%
	}
	Loop,% OTTK_fillLV.maxIndex
	{
		LV_Add("",OTTK_fillLV.C1[A_Index],OTTK_fillLV.C2[A_Index],OTTK_fillLV.C3[A_Index],OTTK_fillLV.C4[A_Index],OTTK_fillLV.C5[A_Index],OTTK_fillLV.C6[A_Index],OTTK_fillLV.C7[A_Index],OTTK_fillLV.C8[A_Index],OTTK_fillLV.C9[A_Index],OTTK_fillLV.C10[A_Index],OTTK_fillLV.C11[A_Index],OTTK_fillLV.C12[A_Index],OTTK_fillLV.C13[A_Index],OTTK_fillLV.C14[A_Index],OTTK_fillLV.C15[A_Index],OTTK_fillLV.C16[A_Index],OTTK_fillLV.C17[A_Index],OTTK_fillLV.C18[A_Index],OTTK_fillLV.C19[A_Index],OTTK_fillLV.C20[A_Index])
	}
	GuiControl, +Redraw,%lvName%
	LV_ModifyCol()
	return
}

}

;##############getvaluesLV#####################

getvaluesLV(wName,lvName)   ;extrai todos os valores de uma listview e retorna um array.
{
	values:=object()
	i:=0
	gui,%wName%:default 
	Gui,listview,%lvName%
	Loop, % LV_GetCount("Column")
	{
		i+=1
		Loop, % LV_GetCount()
		{
			LV_GetText(text,A_Index,i)
			values[A_Index,i]:=text
		}
	}
	return values
}

;##############ClearLV#####################
{
ClearLV(wName,lvName="")
{
	Gui,%wName%:default 
	if(lvName!="")
	{
		Gui,listview,%lvName%
		GuiControl, -Redraw,%lvName%
		LV_Delete()
		GuiControl, +Redraw,%lvName%
	}
}
}
;###############GetSelectedItems###################
GetSelectedItems(wName="",lvName="",type="text"){
	Global 
	Local returnValue
	if(wName!=""){
		Gui,%wName%:default
	}
	if(lvName!=""){
		Gui,listview,%lvName%
	}
	returnValue:={}
	if(type="text"){
		rownumber:=0
		Loop % LV_GetCount()
		{
			LV_GetText(text,LV_GetNext(rownumber))
			returnValue[A_Index]:=text
			rownumber++
		}
	}
	if(type="number"){
		rownumber:=0
		Loop % LV_GetCount(){
			returnValue[A_Index]:=LV_GetNext(rownumber)
			rownumber++
		}
	}
	return returnValue
}
;##############GetSelected#####################
{
	
GetSelected(wName="",lvName="",type="text"){
	Global 
	Local returnValue
	if(wName!=""){
		Gui,%wName%:default
	}
	if(lvName!=""){
		Gui,listview,%lvName%
	}
	if(type="text"){
			LV_GetText(returnValue,LV_GetNext())
	}
	if(type="number"){
			returnValue:=LV_GetNext()
	}
	return returnValue
}
;############flip########################
Flip( Str) {
 Loop, Parse, Str
  nStr=%A_LoopField%%nStr%
Return nStr
}
;############reversearray########################
reversearray(array){
	x:=-1,newarray:=[]
	for,each,value in array{
		x+=1
		;MsgBox, % value
		newarray.insert(array[array.maxindex()-x])
	}
	return newarray
}
;#############load treeview ##########################
loadtv(tvstring,tv){
	TvDefinition=
	(
	%tvstring%
	)
	gui,treeview,%tv%
	TV_Delete()
	CreateTreeView(TvDefinition)
	return 
}
;############CREATE TREEVIEW############################################
CreateTreeView(TreeViewDefinitionString) {  ; by Learning one
  Global nameid:={},idlist:=object()
  IDs := {}   
  k:=1
  Loop, parse, TreeViewDefinitionString, `n, `r
  {
    if A_LoopField is space
      continue
    Item := RTrim(A_LoopField, A_Space A_Tab), Item := LTrim(Item, A_Space), Level := 0
    While (SubStr(Item,1,1) = A_Tab)
      Level += 1, Item := SubStr(Item, 2)
    RegExMatch(Item, "([^`t]*)([`t]*)([^`t]*)", match)  ; match1 = ItemName, match3 = Options
    if(_dontchange!=1){
      icon:="icon1"
    }
    if(match1="PRODUTOS ACABADOS"){
        icon:="icon2"
        _dontchange:=1
      }
      if(match1="PRODUTOS SEMI-ACABADOS"){
        icon:="icon3"
        _dontchange:=1
      }
      if(match1="MATERIA PRIMA"){
        icon:="icon4"
        _dontchange:=1
      }
      if(match1="PRODUTOS INTERMEDIARIOS"){
        icon:="icon5"
        _dontchange:=1
      }
      if(match1="CONJUNTOS"){
        icon:="icon6"
        _dontchange:=1
      }
      if(match1="MAO DE OBRA"){
        icon:="icon7"
        _dontchange:=1
      }
    if (Level=0){
      IDs["Level0"] := TV_Add(match1, 0,icon)
      nameid[match1]:= IDs["Level0"]
      idlist.insert(IDs["Level0"])
    }else{
      IDs["Level" Level] := TV_Add(match1, IDs["Level" Level-1],icon)
      nameid[match1]:= IDs["Level" Level]
      idlist.insert(IDs["Level" Level])
    }
  }

} ; http://www.autohotkey.com/board/topic/92863-functio


;################haschild#########################
haschild(itemid,wname,tv){
	gui,%wname%:default
	gui,treeview,%tv%
	ItemID := TV_GetChild(itemid)
	if not ItemID  
        return False
    return True 
}
;################getchild#########################
getchild(itemid,tv,nivel){
	Global newtvstring
	gui,TreeView,%tv%
	ItemID := TV_GetChild(itemid)
	if not ItemID  
        return 
	TV_GetText(ItemText,ItemID)
	nivel.="`t"
	newtvstring.=nivel ItemText "`n"
	;loop do mesmo nivel da crianca
	Loop
    {
        itemid:=TV_GetNext(itemid)
        if not ItemID  
          break
        TV_GetText(ItemText,ItemID)
        newtvstring.=nivel ItemText "`n"
      	;MsgBox, % newtvstring  
      	getchild(ItemID,"treeview",nivel)     
    }
    return 
}
;###############pesquisa listview##################
pesquisalv(wname,lvname,string,List){
	Gui,%wname%:default
    Gui,listview,%lvname%
    GuiControl, -Redraw,%lvname%
    Gui, Submit, NoHide
    resultsearch:=[] 
    If (string=""){ 
        LV_Delete()
        for,each,value in List{
            LV_Add("",List[A_Index,1],List[A_Index,2])
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
            LV_Add("",List[value,1],List[value,2])
        }
    }
    GuiControl, +Redraw,%lvname%
    LV_Modify(1, "+Select")
}
return 

;###############PESQUISAR DB ##############################

/*
pesquisardb(sctable,field,func,owner){     ;funcao que cria um janela com os dois campos e permite pesquisar dentro deles
    Global db

    Static pesquisa,lv,sctable1,field1,func1
    sctable1:=sctable,field1:=field,func1:=func
    Gui,pesquisa:New
    Gui,pesquisa:+owner%owner%
    Gui,pesquisa:+toolwindow
    Gui,add,edit,w300 r1 gpesquisa vpesquisa,
    Gui,add,listview,w500 h400 y+5 vlv glvdb,
    Gui,add,button,w100 h30 y+5 ginserirdb,Inserir
    Gui,add,button,w100 h30 x+5 grenomeardb,Renomear
    Gui,add,button,w100 h30 x+5 gremoverdb,Remover
    Gui,Show,,Janela!!
    Global Listpes:=[]
    table:=db.query("SELECT " field " FROM " sctable)
    StringSplit,fields,field,`,
    while(!table.EOF){  
            value1:=table[fields1],value2:=table[fields2]
            Listpes[A_Index,1]:=value1 
            Listpes[A_Index,2]:=value2
            table.MoveNext()
    }
    db.loadlv("pesquisa","lv",sctable,field)
    return 

        lvdb:
        selectedrow:=GetSelectedRow("pesquisa","lv")
        if func1!=""
        	%func1%(selectedrow)
        return 

        removerdb:
        selecteditem:=GetSelected("pesquisa","lv")
        removerdb(selecteditem,sctable1,field1)
        return 

        renomeardb:
        selectedrow:=GetSelectedRow("pesquisa","lv")
        renomeardb(selectedrow,sctable1,field1)
        return 

        inserirdb:
        inserirdb(sctable1,field1)
        return 
    
    pesquisa:
    Gui,listview,lv
    GuiControl, -Redraw,lv
    Gui, Submit, NoHide
    resultsearch:=[] 
    If (pesquisa=""){ 
        LV_Delete()
        for,each,value in Listpes{
            LV_Add("",Listpes[A_Index,1],Listpes[A_Index,2])
        }       
    }Else{
        for,each,value in Listpes{
            i++
            string:=Listpes[A_Index,1] Listpes[A_Index,2]
            IfInString,string,%pesquisa%
            {
                resultsearch.insert(i)
            }
        }
        i:=0
        LV_Delete()
        for,each,value in resultsearch{
            ;MsgBox, % "value " value
            LV_Add("",Listpes[value,1],Listpes[value,2])
        }
    }
    GuiControl, +Redraw,lv
    LV_Modify(1, "+Select")
    return 
}

inserirdb(sctable,field){
    Global db
    Static editdb1,editdb2,sctable1,fields1,fields2,field1
    field1:=field
    StringSplit,fields,field,`,
    MsgBox, % "field depois do parse " fields1 " " fields2 
    sctable1:=sctable,field1:=field
    Gui,inserirdb:New 
    Gui,inserirdb:+toolwindow
    Gui,inserirdb:+ownerpesquisa
    Gui,add,text,,Nome Campo:
    Gui,add,edit,w150 y+5 r1 veditdb1
    Gui,add,text,y+5,Valor Campo:
    Gui,add,edit,w150 y+5 r1 veditdb2
    Gui,add,button,w100 h30 y+5 gsalvardb,Salvar
    Gui,Show,,Inserir!!
    return 

        salvardb:
        Gui,submit,nohide
        if(editdb1="")||(editdb2="")
            MsgBox, % "Nenhum dos campos pode estar em branco!!!"
        db.createtable(sctable1,"(" field1 ", PRIMARY KEY(" fields1 " ASC," fields2 " ASC))")
        db.insert(sctable1,"(" fields1 "," fields2 ")","('" . editdb1 . "','" editdb2 "')")
        db.loadlv("pesquisa","lv",sctable1,field1)
        Gui,inserirdb:destroy
        return 
}

renomeardb(selectedrow,sctable,field){
    Global db 
    Static editdb1,editdb2,sctable1,fields1,fields2,field1,selectedrow1
    field1:=field,selectedrow1:=selectedrow
    StringSplit,fields,field,`,
    sctable1:=sctable,field1:=field
    selecteditem:=GetSelected("pesquisar","lv")
    Gui,renomeardb:New 
    Gui,renomeardb:+toolwindow
    Gui,renomeardb:+ownerpesquisa
    Gui,add,text,,Nome Campo:
    Gui,add,edit,w150 y+5 r1 veditdb1,% selectedrow[1]
    Gui,add,text,y+5,Valor Campo:
    Gui,add,edit,w150 y+5 r1 veditdb2,% selectedrow[2]
    Gui,add,button,w100 h30 y+5 gsalvarmoddb,Salvar
    Gui,Show,,Inserir!!
    return 

        salvarmoddb:
        Gui,submit,nohide
        if(editdb1="")||(editdb2="")
            MsgBox, % "Nenhum dos campos pode estar em branco!!!"
        db.query("UPDATE " sctable1 " SET " fields1 "='" editdb1 "' WHERE " fields1 "='" selectedrow1[1] "';")
        db.query("UPDATE " sctable1 " SET " fields2 "='" editdb2 "' WHERE " fields2 "='" selectedrow1[2] "';")
        db.loadlv("pesquisa","lv",sctable1,field1)
        Gui,renomeardb:destroy
        return 
}

removerdb(selecteditem,sctable1,field1){
    Global db 
    MsgBox, % "selected item " selecteditem
    StringSplit,fields,field1,`,
    MsgBox, 4,,Deseja apagar a Campo %selecteditem%?
    IfMsgBox Yes
    {
        MsgBox, % "DELETE FROM " . sctable1 . " WHERE " . fields1 "='" . selecteditem . "';" 
        db.query("DELETE FROM " . sctable1 . " WHERE " . fields1 "='" . selecteditem . "';")
        db.loadlv("pesquisa","lv",sctable1)
    }else{
        return 
    }
}
*/
;###################################################################################################
;###########GetCheckedRow########################
GetCheckedRows(wName="",lvName=""){
	;Global 
	Local returnValue
	if(wName!=""){
		Gui,%wName%:default
	}
	if(lvName!=""){
		Gui,listview,%lvName%
	}
	result:=object()
	k:=0
	Loop, % LV_GetCount()
	{
		row:=A_Index
		SendMessage,4140,row - 1, 0xF000, SysListView321 
		IsChecked := (ErrorLevel >> 12) - 1
		i:=0
		if (IsChecked!=1)
			continue
		k++
		Loop,% LV_GetCount("col"){
			i+=1
			LV_GetText(value,row,i)
			result[k,i]:=value
		}
	}
	return result
}

;###########GetSelectedRow#######################
GetSelectedRow(wName="",lvName=""){
	Global 
	Local returnValue
	if(wName!=""){
		Gui,%wName%:default
	}
	if(lvName!=""){
		Gui,listview,%lvName%
	}
	
	i:=0
	result:=object()
	row:=LV_GetNext()
	Loop,% LV_GetCount("col"){
		i+=1
		LV_GetText(value,row,i)
		result.insert(value)
	}
	return result
}


}
;################subtractarrayfromarray############ ;funcao que subtrai um array de outro 
subtractarrayfromarray(array1,array2){
	for,each,value in array1{
		cvalue:=value 
		for,each,value in array2{
			if(cvalue=value){
				
			}
		}
	}

}
;##############CheckDuplicated#####################
{
	
CheckDuplicated(objName,Type=0){
	Global 
	Local valueObj
	Local valueToInsert
	Local _alreadyExist
	Local duplicatedValues
	valueObj:=Object()
	_alreadyExist:=0
	duplicatedValues:=""
	if(Type=0){
		Loop,% OTTK_%objName%.maxIndex
			{
				if(A_Index=1){
					valueObj.C1[A_Index]:=OTTK_%objName%.C1[A_Index]
					valueObj.C2[A_Index]:=OTTK_%objName%.C2[A_Index]
					valueObj.C3[A_Index]:=OTTK_%objName%.C3[A_Index]
					valueObj.C4[A_Index]:=OTTK_%objName%.C4[A_Index]
					valueObj.C5[A_Index]:=OTTK_%objName%.C5[A_Index]
					valueObj.C6[A_Index]:=OTTK_%objName%.C6[A_Index]
					valueObj.C7[A_Index]:=OTTK_%objName%.C7[A_Index]
					valueObj.C8[A_Index]:=OTTK_%objName%.C8[A_Index]
					valueObj.C9[A_Index]:=OTTK_%objName%.C9[A_Index]
					valueObj.C10[A_Index]:=OTTK_%objName%.C10[A_Index]
					valueObj.C11[A_Index]:=OTTK_%objName%.C11[A_Index]
					valueObj.C12[A_Index]:=OTTK_%objName%.C12[A_Index]
					valueObj.C13[A_Index]:=OTTK_%objName%.C13[A_Index]
					valueObj.C14[A_Index]:=OTTK_%objName%.C14[A_Index]
					valueObj.C15[A_Index]:=OTTK_%objName%.C15[A_Index]
					valueObj.C16[A_Index]:=OTTK_%objName%.C16[A_Index]
					valueObj.C17[A_Index]:=OTTK_%objName%.C17[A_Index]
					valueObj.C18[A_Index]:=OTTK_%objName%.C18[A_Index]
					valueObj.C19[A_Index]:=OTTK_%objName%.C19[A_Index]
					valueObj.C20[A_Index]:=OTTK_%objName%.C20[A_Index]
				}else{
					valueToInsert:=OTTK_%objName%.C1[A_Index]
					For,index,k in valueObj.C1
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C2[A_Index]
					For,index,k in valueObj.C2
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C3[A_Index]
					For,index,k in valueObj.C3
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C4[A_Index]
					For,index,k in valueObj.C4
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C5[A_Index]
					For,index,k in valueObj.C5
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C6[A_Index]
					For,index,k in valueObj.C6
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C7[A_Index]
					For,index,k in valueObj.C7
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C8[A_Index]
					For,index,k in valueObj.C8
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C9[A_Index]
					For,index,k in valueObj.C9
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C10[A_Index]
					For,index,k in valueObj.C10
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C11[A_Index]
					For,index,k in valueObj.C11
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C12[A_Index]
					For,index,k in valueObj.C12
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C13[A_Index]
					For,index,k in valueObj.C13
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C14[A_Index]
					For,index,k in valueObj.C14
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C15[A_Index]
					For,index,k in valueObj.C15
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
							duplicatedValues.=valueToInsert
							}else{
							duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C16[A_Index]
					For,index,k in valueObj.C16
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
								duplicatedValues.=valueToInsert
							}else{
								duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C17[A_Index]
					For,index,k in valueObj.C17
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
								duplicatedValues.=valueToInsert
							}else{
								duplicatedValues.=";" . valueToInsert
							}
						}

					}
					valueToInsert:=OTTK_%objName%.C18[A_Index]
					For,index,k in valueObj.C18
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
								duplicatedValues.=valueToInsert
							}else{
								duplicatedValues.=";" . valueToInsert
							}
						}
					}
					valueToInsert:=OTTK_%objName%.C19[A_Index]
					For,index,k in valueObj.C19
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
								duplicatedValues.=valueToInsert
							}else{
								duplicatedValues.=";" . valueToInsert
							}
						}

					}
					valueToInsert:=OTTK_%objName%.C20[A_Index]
					For,index,k in valueObj.C20
					{
						if(valueToInsert=k)
						{
							_alreadyExist:=1
							if(duplicatedValues=""){
								duplicatedValues.=valueToInsert
							}else{
								duplicatedValues.=";" . valueToInsert
							}
						}

					}
				}
			}
	}
	if(Type=1){
		For,index,k in %objName%
		{
			for,index,w in valueObj
			{
				if(w=k){
					if(duplicatedValues=""){
						duplicatedValues.=k
					}else{
						duplicatedValues.=";" . k
					}
				}
			}
			valueObj.Insert(k)
		}
	}
	return duplicatedValues
}
}
;##############CreateFolder################
{
CreateFolder(path){
	FileCreateDir,%path%
	return
}

}
;##############Move/RenameFolder#########
{

MoveFolder(source,dest,options=0)
{
	if(options="rename")
	{
		options:="R"
	}
	if(options="overwrite")
	{
		options:=1
	}
	FileMoveDir,%source%,%dest%,%options%
	return 
}

}

;##############CopyFolder#########
{

CopyFolder(source,dest,options=1)
{
	FileCopyDir,%source%,%dest%,%options%
	return 
}

}

;##############DeleteFile###############
{
	
DeleteFile(path)
{
	FileDelete,%path%
}

}

;##############CopyFile##################
{
	
CopyFile(source,dest,options=1)
{
	FileCopy,%source%,%dest%,%options%
	return 
}

}
;#############CheckValue##################
{
CheckValue(value)
{
	nao_gravar:=0
	IfInString,value,\
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
	}
	
	IfInString,value,/
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
	}
	
	IfInString,value,:
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
		
	}
	
	IfInString,value,*
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
		
	}
	
	IfInString,value,?
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
		
	}
	
	IfInString,value,"
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
		
	}
	
	IfInString,value,<
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
		
	}
	
	IfInString,value,>
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
		
	}
	
	IfInString,value,|
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
		
	}
	
		
		IfInString,value,\
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
		
	}
	
	IfInString,value,/
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
		
	}
	
	IfInString,value,:
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
		
	}
	
	IfInString,value,*
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
		
	}
	
	IfInString,value,?
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
	}
	
	IfInString,value,"
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
	}
	
	IfInString,value,<
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
	}
	
	IfInString,value,>
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
	}
	
	IfInString,value,|
	{
		MsgBox,O texto nao pode conter \ / : * ? " <> | 
		nao_gravar=1
	}
	if(nao_gravar=1){
		Exit
	}
	return
}
}
;##############DELETEFOLDER###############
{
	
DeleteFolder(path)
{
	FileRemoveDir,%path%,1
}

}
