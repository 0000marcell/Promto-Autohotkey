



if A_OSVersion = WIN_XP
  WinVersion := "Microsoft Windows XP"
if A_OSVersion = WIN_7
  WinVersion := "Microsoft Windows 7"

MsgBox, 0x1010, "Anti-virus do Marcell(o melhor que tem)", % "Cuidado, " . A_UserName . "`n Algum virus muito perigoso foi encontrados no seu sistema.`n" . WinVersion . " Arquivos Corronpidos,Caos Total,Ameaca de extincao humana e outras coisas ruins. `n Para remover o virus aperte OK ou Feche a Janela."


Gui, -Caption -AlwaysOnTop 0x800000
Gui, Margin, 10, 10
Gui, Font, s12 bold, Tahoma
Gui, Add, Text, xm ym,Removendo Todos os Virus :
Gui, Font, s10 norm, Tahoma
Gui, Add, Progress, xm yp+40 w300 h20 vIndex cFF0033 BackgroundCFCFCF
Gui, Add, Text, xm yp w300 h20 +0x200 +Center +BackgroundTrans vText , 1 of 100
Gui, Add, Text, xm yp+22 w300 h20 +0x200 +Center +BackgroundTrans vFile 

Gui, Show, AutoSize, WARNING VIRUS DETECTED!

Loop, %WinDir%\system32\*.*
{
  IfGreater, A_Index,100, Break
  GuiControl,, Index, % A_Index
  GuiControl,, File, % "Delete " A_LoopFileName
  GuiControl,, Text, % A_Index " of 100"
  Sleep 100
}
MsgBox,,"Anti-virus do Marcell(o melhor que tem)","Parabens Todos os Virus Foram Removidos pode confiar!!!`nAgente e foda mesmo." 
exitapp
Return

GuiEscape:
   ExitApp

;galinha:=["G1","G2","G3"]
;cachorro:=["C1","C2","C3"]
;vaca:=["V1","V2","V3"]
;array:=[]
;array.insert(galinha)
;array.insert(cachorro)
;array.insert(vaca)
;array:=[galinha,cachorro,vaca]
;x:="array"
;for,k,each in %x%[1]
;{
;   MsgBox, % each
;}
;loop,% array.maxindex()
;{
;   for each in list:=array[A_Index]
;      MsgBox, % list[A_Index] . each 
   
;}




/*
;##############LATAO###############


;##########

;P:=8500
;D:=2.38/1000
;A:=D*D 
;F:=P*A
;MsgBox, % F

Gui, Add, Edit, x22 y20 w110 h30 vDIM, Dimensao
Gui, Add, DropDownList, x152 y20 w130 h50 vMP, Aluminio|Cobre|Latao|ACO INO
Gui, Add, Button, x32 y300 w120 h30 bgerar, Gerar
Gui, Add, ListView, x12 y110 w420 h180 , SEXTAVADA|REDONDA|QUADRADO
Gui, Show, w479 h379, Untitled GUI
return

gerar:
DIM
P:=8500
D1:=2,38
D:=(D1/1000)
L:=(D/2)
H:=((L*1.7)/2)
A:=(H*L*1)
F:=P*A
MsgBox, % F
return 



LV_MoveRow(moveup = true) {
	gui,MAOC:Default
    gui,listview,MAOClv
   ; Original by diebagger (Guest) from:
   ; http://de.autohotkey.com/forum/viewtopic.php?p=58526#58526
   ; Slightly Modifyed by Obi-Wahn
   If moveup not in 1,0
      Return   ; If direction not up or down (true or false)
   while x := LV_GetNext(x)   ; Get selected lines
      i := A_Index, i%i% := x
   If (!i) || ((i1 < 2) && moveup) || ((i%i% = LV_GetCount()) && !moveup)
      Return   ; Break Function if: nothing selected, (first selected < 2 AND moveup = true) [header bug]
            ; OR (last selected = LV_GetCount() AND moveup = false) [delete bug]
   cc := LV_GetCount("Col"), fr := LV_GetNext(0, "Focused"), d := moveup ? -1 : 1
   ; Count Columns, Query Line Number of next selected, set direction math.
   Loop, %i% {   ; Loop selected lines
      r := moveup ? A_Index : i - A_Index + 1, ro := i%r%, rn := ro + d
      ; Calculate row up or down, ro (current row), rn (target row)
      Loop, %cc% {   ; Loop through header count
         LV_GetText(to, ro, A_Index), LV_GetText(tn, rn, A_Index)
         ; Query Text from Current and Targetrow
         LV_Modify(rn, "Col" A_Index, to), LV_Modify(ro, "Col" A_Index, tn)
         ; Modify Rows (switch text)
      }
      LV_Modify(ro, "-select -focus"), LV_Modify(rn, "select vis")
      If (ro = fr)
         LV_Modify(rn, "Focus")
   }
}

#Include,SQL_new.ahk 