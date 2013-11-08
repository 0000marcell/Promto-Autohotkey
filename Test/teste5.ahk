db := new SQL("SQLite",A_ScriptDir . "\Promto.sqlite")
db.query("CREATE TABLE IPI (valor,descricao);")
pesquisardbmod("IPI","valor,descricao","","")
;NCM:={},UM:={},ORIGEM:={},CONTA:={},TIPO:={},GRUPO:={}
;for,each,value in ["NCM","UM","ORIGEM","TCONTA","TIPO","GRUPO"]{
;    table:=db.query("SELECT valor,descricao FROM " value ";")
;    while(!table.EOF){
;        %value%[table["valor"]]:=table["descricao"]
;        %value%[table["valor"]]:=table["descricao"]
;        table.MoveNext()
;    }
;    table.close
;}



pesquisardbmod(sctable,field,func,owner){     ;funcao que cria um janela com os dois campos e permite pesquisar dentro deles
    Global db

    Static pesquisa,lv,sctable1,field1,func1
    sctable1:=sctable,field1:=field,func1:=func
    Gui,pesquisa:New
    Gui,pesquisa:+owner%owner%
    Gui,pesquisa:+toolwindow
    Gui,add,edit,w300 r1 gpesquisa vpesquisa,
    Gui,add,listview,w500 h400 y+5 vlv glvdb,
    Gui,add,button,w100 h30 y+5 ginserirdb,Inserir
    Gui,add,button,wp hp x+5 grenomeardb,Renomear
    Gui,add,button,wp hp x+5 gremoverdb,Remover
    Gui,add,button,wp hp x+5 gexportardb,Exportar
    Gui,add,button,wp hp x+5 gimportardb,Importar
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

        importardb:
        Gui,submit,nohide
        FileSelectFile,source,""
        ;MsgBox, % "criar table " sctable1 " campo1 " fields1 " campo2 " fields2
        db.query("CREATE TABLE " sctable1 "(valor,descricao);")
        x:= new OTTK(source)
        for,each,value in x{
            MsgBox, % "valor1" x[A_Index,2] " valor2 " x[A_Index,1]
            db.query("INSERT INTO " sctable1 "(valor,descricao) VALUES ('" x[A_Index,2] "','" x[A_Index,1] "');")
        }
        MsgBox,64,,% "valores importados!!!!"
        return 

        exportardb:
        Gui,listview,lv
        valuesex:=getvaluesLV("pesquisa","lv")
        for,each,value in valuesex{
            FileAppend, % valuesex[A_Index,1] ";" valuesex[A_Index,2] "`n",temp.csv
        }
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
        db.query("CREATE TABLE " sctable1 "(valor,descricao);")
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
    Gui,add,edit,w300 y+5 r1 veditdb1,% selectedrow[1]
    Gui,add,text,y+5,Valor Campo:
    Gui,add,edit,w300 y+5 r1 veditdb2,% selectedrow[2]
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
    ;MsgBox, % "selected item " selecteditem
    StringSplit,fields,field1,`,
    MsgBox, 4,,Deseja apagar a Campo %selecteditem%?
    IfMsgBox Yes
    {
        ;MsgBox, % "DELETE FROM " . sctable1 . " WHERE " . fields1 "='" . selecteditem . "';" 
        db.query("DELETE FROM " . sctable1 . " WHERE " . fields1 "='" . selecteditem . "';")
        db.loadlv("pesquisa","lv",sctable1)
    }else{
        return 
    }
}

#Include SQL_new.ahk 
#include,%A_ScriptDir%\OTTK\OTTK.ahk


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

pesquisardb(args){
    Global db
    Static pesquisa,lv,sctable1,fields1,field2,args1
    args1:=args
    sctable1:=sctable
    Gui,pesquisa:New
    Gui,add,edit,w300 r1 gpesquisa vpesquisa,
    Gui,add,listview,w500 h400 y+5 vlv,coluna1|coluna2
    Gui,add,button,w100 h30 y+5 gadd,Adicionar
    Gui,add,button,w100 h30 x+5 grenon,Renomear
    Gui,add,button,w100 h30 x+5 gremove,Remover
    Gui,Show,,Janela!!
    Global List:=[]
    table:=db.query("SELECT " args["field"] " FROM " args["sctable"])
    columns := table.getColumnNames()
        columnCount := columns.Count()
        for each, colName in columns
            args1["colname",A_Index].=colName
    field:=args["field"]
    StringSplit,fields,field,`,
    args1["numcol"]:=fields0
    i:=0
    while(!table.EOF){  
            i++
            Loop,% fields0{
                value%A_Index%:=table[fields%A_Index%]
                List[i,A_Index]:=value%A_Index%
            }
            table.MoveNext()
    }
    db.loadlv("pesquisa","lv",args["sctable"],args["field"])
    return 

        add:
        addwindow(args1)
        return 

        renon:
        selecteditem:=GetSelected("pesquisa","lv")
        args["selecteditem"]:=selecteditem
        renonwindow(args1)
        return 

        remove:
        selecteditem:=GetSelected("pesquisa","lv")
        args["selecteditem"]:=selecteditem
        removewindow(args1)
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
            ;MsgBox, % "string " string " pesquisa " pesquisa
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

addwindow(args){
    Global db
    Static edit1,edit2,args1
    args1:=args
    MsgBox, % args1["numcol"]
    Gui,add:new
    Loop, % args1["numcol"]{ 
        Gui,add,text, cgreen,% args1["colname",A_Index]
        Gui,add,edit,w300 r1 x+5 vedit%A_Index%,
    }
    Gui,add,button,w100 h30 center gincluir,Incluir
    Gui,add,button,wp hp x+5 gcancelar,Cancelar
    Gui,Show,,Adicionar!!
    return

        incluir:
        Gui,submit,nohide
        if(edit1="")||(edit2=""){
            MsgBox, % "Nenhum campo pode estar em branco!!"
            return 
        }
        field:=args1["field"]
        StringSplit,fields,field,`,
        Loop, % args1["numcol"]{ 
            insertfields.=args1["colname",A_Index] ","
            insertvalues.=edit
        }
        MsgBox, % "fields1 " fields1 " fields2 " fields2 " edit1 " edit1 " edit2 " edit2
        db.insert(sctable1,"(" fields1 "," fields2 ")","('" . edit1 . "','" edit2 "')")
        db.loadlv("pesquisa","lv",sctable,field)
        return 

        cancelar:
        Gui,add:destroy
        return 
} 

renonwindow(args){
    Global db
    Static edit1,edit2

    Gui,renon:new 
    Gui,add,text, cgreen,valor campo 1:
    Gui,add,edit,w300 r1 x+5 vedit1,
    Gui,add,text,cgreen xm,valor campo 2:
    Gui,add,edit,w300 r1 x+5 vedit2 
    Gui,add,button,w100 h30 center grenomear,Renomear
    Gui,add,button,wp hp x+5 gcancelrenon,Cancelar
    Gui,Show,,Renomear!!!!

        Renomear:
        Gui,submit,nohide
        sql =
        (JOIN
            "UPDATE " args1["sctable"]
            "SET " args1[]
            "WHERE " where . ";"
        ) 
        db.query()
        return 

        cancelrenon:
        return
}

removewindow(args){

}


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
