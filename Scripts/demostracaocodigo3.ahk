#Include, Gdip.ahk

If !pToken := Gdip_Startup()
{
    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
    ExitApp
}

TextOptions:="x0p y0p s8p  cffffffff r4 Bold" 
Font:="Arial"

gui,add,picture,x10 y10 w100 h100 0xE,banner
banner("blue","banner","LUMINARIA TL.L.EXE.010 SEGURANCA AUMENTADA",TextOptions,Font)
Gui,add,button,w100 h30 gdeletar,Deletar
Gui,Show,,
;WM_CLOSE=0x10
return

deletar:
PostMessage,0x10, , ,banner
;gui,add,picture,x10 y10 w100 h100 ,MAC.EXE.010.bmp
gui,show,,
return

banner(color,Variable,Text="",TextOptions="x0p y15p s60p Center cffffffff r4 Bold", Font="verdana")
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
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
    Return, 0
}

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


/*
db := new SQL("SQLite",A_ScriptDir . "\Promto.sqlite")

pesquisardb("Tdbteste","Coluna1,Coluna2","func")

func(selectedrow){
    MsgBox, % selectedrow[1]
}

pesquisardb(sctable,field,func){     ;funcao que cria um janela com os dois campos e permite pesquisar dentro deles
    Global db
    Static pesquisa,lv,sctable1,field1,func1
    sctable1:=sctable,field1:=field,func1:=func
    Gui,pesquisa:New
    Gui,add,edit,w300 r1 gpesquisa vpesquisa,
    Gui,add,listview,w500 h400 y+5 vlv glv,
    Gui,add,button,w100 h30 y+5 ginserirdb,Inserir
    Gui,add,button,w100 h30 x+5 grenomeardb,Renomear
    Gui,add,button,w100 h30 x+5 gremoverdb,Remover
    Gui,Show,,Janela!!
    Global List:=[]
    table:=db.query("SELECT " field " FROM " sctable)
    StringSplit,fields,field,`,
    while(!table.EOF){  
            value1:=table[fields1],value2:=table[fields2]
            List[A_Index,1]:=value1 
            List[A_Index,2]:=value2
            table.MoveNext()
    }
    db.loadlv("pesquisa","lv",sctable,field)
    return 

        lv:
        selectedrow:=GetSelectedRow("pesquisa","lv")
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
        for,each,value in List{
            LV_Add("",List[A_Index,1],List[A_Index,2])
        }       
    }Else{
        for,each,value in List{
            i++
            string:=List[A_Index,1] List[A_Index,2]
            IfInString,string,%pesquisa%
            {
                resultsearch.insert(i)
            }
        }
        i:=0
        LV_Delete()
        for,each,value in resultsearch{
            ;MsgBox, % "value " value
            LV_Add("",List[value,1],List[value,2])
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
        ;MsgBox, % "UPDATE " sctable1 " SET " fields1 "='" editdb1 "' WHERE " fields1 "='" selectedrow1[1] "';" 
        db.query("UPDATE " sctable1 " SET " fields1 "='" editdb1 "' WHERE " fields1 "='" selectedrow1[1] "';")
        ;MsgBox, % "UPDATE " sctable1 " SET " fields2 "='" editdb2 "' WHERE " fields2 "='" selectedrow1[2] "';" 
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




#Include SQL_new.ahk
#include,%A_ScriptDir%\OTTK\OTTK.ahk
;m:
;return 
/*
;============================================================
; fill listview with results from query 
; note: the current data in the listview is replaced with the new data
;
; inputs:
;     listviewname: the name of the listview to fill
;
;    table:         provide a table object which is usually generated from mysql call.
;                   Example:   
;                       datatable := db.Query(sql) 
;
;                   Underscores are automatically removed from aliasname before displaying as column headers
;
;                   To hide a column put a $ at the end of the column name 
;                   Example: 
;                       select id as id$, name from table1
;                
;    selectmode:    (optional) Important when refreshing an existing listview.  Set how to re-select the same row.
;                   0 = no re-select  (default)
;                   1 = select by column 1 value  (column 1 is assumed to be unique)
;                   2 = select by row number (recommended only if your list is relatively static)
;
;============================================================ 

lvfill(listviewname, table, selectmode=0)
{

    ;-------------------------------------------
    ; delete all rows in listview
    ;-------------------------------------------

    GuiControl, -Redraw, %listviewname%     ; to improve performance, turn off redraw then turn back on at end
    
    Gui, ListView, %listviewname%    ; specify which listview will be updated with LV commands  
    
    ;-------------------------------------------
    ; remember current selection in listview
    ;-------------------------------------------
    
    if (selectmode = 1) {
        column1value := ""
        selectedrow := LV_GetNext(0)     ; get current selected row
        if selectedrow |= 0
            LV_GetText(column1value, selectedrow, 1) ; get column 1 value for current row          
    } else if (selectmode = 2) {
        selectedrow := LV_GetNext(0)     ; get current selected row
    }
        
    ;-------------------------------------------
    ; delete any pre-existing rows and columns in listview
    ;-------------------------------------------

    LV_Delete()  ; delete all rows in listview
    
    Loop, % LV_GetCount("Column")    ; delete all columns in listview
	   LV_DeleteCol(1)
    
    ;-------------------------------------------
    ; create new columns
    ;-------------------------------------------

    for each, colName in table.Columns 
    {
        colName := RegExReplace(colName , "_", " ")    ; remove underscores from column names
		LV_InsertCol(A_Index,"", colName)
    }

    ;columnCount := table.Columns.Count()

    ;-------------------------------------------
    ; insert rows
    ;-------------------------------------------
    
	for each, row in table.Rows
	{
		rowNum := LV_Add("", "")
		for each, colName in table.Columns 
			LV_Modify(rowNum, "Col" . A_index, row[A_index])
	}

    ;-------------------------------------------
    ; use first row values to set integer columns
    ;-------------------------------------------
    
    if table.Rows.Count()    ; only if table contains rows
        for each, colName in table.Columns 
        {
            data := table[1][A_Index]    ; table[row][column]
            
            StringReplace, data, data, % " KB",,   ; remove " KB" so this column can be interpreted as an integer
            if data is integer
                LV_ModifyCol(A_Index, "Integer")  ; For sorting purposes, indicate column is an integer.
        }
    
    
    ;-------------------------------------------
    ; autosize columns: should be done outside the row loop to improve performance
    ;-------------------------------------------
    
    LV_ModifyCol()  ; Auto-size each column to fit its contents.
    
    for each, colName in table.Columns
    {
        LV_ModifyCol(A_Index,"AutoHdr")   ; Autosize headers (does last header need this?)
        if RegExMatch(colName, "\$$")    ;If there is a $ at end of column name, that indicates a hidden column
            LV_ModifyCol(A_Index,0)   ; set width to 0 to create hidden column
    }
    
    Gui, Submit, NoHide               ; update v control variables	

    ;-------------------------------------------
    ; re-select row in listview
    ;-------------------------------------------

    if (selectmode = 1) {    ;reselect row by column1value
        if (column1value != "") {
            Loop % LV_GetCount()   ; loop through all rows in listview to find column1value
            {
                LV_GetText(value, A_Index, 1)    ; get column1 value for current row

                If (value = column1value) {
                    LV_Modify(A_Index, "+Select +Focus")     ; select originally selected row in list  
                    break
                }
            }
        }
    } else if (selectmode = 2) {    ; reselect row by row number
        if (selectedrow != 0)
            LV_Modify(selectedrow, "+Select +Focus")     ; select originally selected row in list   
    }
    
    GuiControl, +Redraw, %listviewname%     ; to improve performance, turn off redraw at beginning then turn back on at end
    
    Return

}

#include SQL_new.ahk