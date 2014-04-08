Class LV{

  LV_MoveRowfam(wname,lvname,moveup = true) {
    gui,%wname%:Default
     gui,listview,%lvname%
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

  loadlv(hash){
    Global Listiv
    Gui, inserirval:default
    Gui, Listview, lviv2
    LV_Delete()
    Listiv := []
    for, each, value in %hash%["valor"]{
      if(%hash%["valor",A_Index] = "")
        Continue
      Listiv[A_Index,1] := %hash%["valor",A_Index]
      Listiv[A_Index,2] := %hash%["descricao",A_Index]
      LV_Add("", %hash%["valor",A_Index], %hash%["descricao", A_Index])
    }
    lv_modifycol(1,200)
  }

  pesquisalvmod(wname,lvname,string,List){    ;funcao de pesquisa na listview modificada!!!!
    Global 

    Gui,%wname%:default
    Gui, Listview, %lvname%
    GuiControl, -Redraw, %lvname%
    Gui, Submit, NoHide
    resultsearch := [] 
    If (string=""){ 
        LV_Delete()
    for,each,value in List{
          codname:=List[A_Index,1]
          if(codname = "")
            continue
            LV_Add("",List[A_Index,1],List[A_Index,2],List[A_Index,3], List[A_Index, 4],%codname%["NCM"],%codname%["UM"],%codname%["ORIGEM"],%codname%["TCONTA"],%codname%["TIPO"],%codname%["GRUPO"],%codname%["IPI"],%codname%["LOCPAD"])
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
          codname := List[value,1]
          if(codname = "")
           continue
          
          LV_Add("", List[value,1], List[value,2], List[A_Index,3], List[A_Index, 4], %codname%["NCM"], %codname%["UM"], %codname%["ORIGEM"], %codname%["TCONTA"], %codname%["TIPO"], %codname%["GRUPO"], %codname%["IPI"])
        }
    }
    GuiControl, +Redraw,%lvname%
    LV_Modify(1, "+Select")
  }

  /*
    Pega os items de determinada listview em um 
    array 
  */
  get_lv_in_array(window_name, lv_name, number_of_columns = 1){
    Gui, %window_name%:default
    GUi, listview, %lv_name%
    returned_array := []
    Loop, % LV_GetCount()
    {
      row := A_Index
      loop, % number_of_columns{
        LV_GetText(Text, row, A_Index)
        returned_array[row, A_Index] := Text  
      }
    }
    return returned_array
  }

  /*
  Pega o modelo selecionado em certa list_view
  */
  get_selected_model(window, lv){
    model := GetSelectedRow(window, lv)
    if(model[1] = "Modelos" || model[1] = "")
      return 
    modelo := []
    modelo.nome := model[1]
    modelo.mascara := model[2]

    return modelo
  }

  GetSelectedItems(wName = "", lvName = "", type = "text"){
    Global 
    Local returnValue
    if(wName != ""){
      Gui,%wName%:default
    }
    if(lvName != ""){
      Gui, listview, %lvName%
    }
    returnValue := []
    if(type = "text"){
      rownumber := 0
      Loop 
      {
        rownumber := LV_GetNext(rownumber)  ; Resume the search at the row after that found by the previous iteration.
        if not rownumber  ; The above returned zero, so there are no more selected rows.
          break
        LV_GetText(text,rownumber)
        returnValue[A_Index] := text
      }
    }
    if(type = "number"){
      rownumber := 0
      Loop
      {
        rownumber := LV_GetNext(rownumber)
        if not rownumber  ; The above returned zero, so there are no more selected rows.
          break
        returnValue[A_Index] := rownumber
      }
    }
    return returnValue
  }

 /*
  Remove os items selecionados na determinada 
  listview
 */
  remove_selected_in_lv(window_name, lv_name){
    rownumber := 0
    Gui, %window_name%:default 
    Gui, Listview, %lv_name%
    GuiControl, -Redraw, %lv_name% 
    selected_rows := []
    Loop
    {
      rownumber := LV_GetNext(rownumber)
      if not rownumber  ; The above returned zero, so there are no more selected rows.
        break
      selected_rows[A_Index] := rownumber 
    }
    alredy_removed := 0
    removed_count := 0
    for, each, value in selected_rows{
      selected_tbr := selected_rows[A_Index] 
      if(alredy_removed){
        removed_count++
        selected_tbr-=removed_count 
      }
      LV_GetText(selected_text, selected_tbr)
      LV_Delete(selected_tbr)
      alredy_removed := 1
    }
    GuiControl, +Redraw, %lv_name%
  }

  GetSelected(wName="",lvName="",type="text"){
    Global 
    Local returnValue
    if(wName != ""){
      Gui,%wName%:default
    }
    if(lvName != ""){
      Gui, listview, %lvName%
    }
    if(type = "text"){
        LV_GetText(returnValue, LV_GetNext())
    }
    if(type = "number"){
        returnValue := LV_GetNext()
    }
    return returnValue
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

  ;############# load lv from array ################
  load_lv_from_array(columns, array, window, lv){
    Gui, %window%:default
    Gui, Listview, %lv%
    LV_Delete()
    prev_count := 0
    loop, % array.maxindex(){
      col_number := A_Index
      LV_InsertCol(col_number,"",columns[A_Index])
      loop,% array[col_number].maxindex(){
        if(prev_count < A_Index){
          prev_count++
          LV_Add("","","")
        }
        LV_Modify(A_Index, "Col" . col_number, array[ A_Index, col_number])

      }
    }
  }

  load_lv_from_matrix(number_of_columns, array, window, lv){
    Gui, %window%:default
    Gui, Listview, %lv%

    prev_count := 0
    loop, % array.maxindex(){
      row_number := A_Index
      if(row_number = "")
        Continue
      LV_Add("","","")
      Loop, % number_of_columns{
        LV_Modify(row_number, "Col" . A_index, array[row_number, A_Index])      
          LV_ModifyCol(A_Index, 200)
      }
    }
  }

  GetCheckedRows2(wName="",lvName=""){
    ;MsgBox, % wName "  " lvName
    if(wName!="")
      Gui,%wName%:default
    if(lvName!="")
      Gui,listview,%lvName%
    result:={}
    RowNumber = 0  ; This causes the first loop iteration to start the search at the top of the list.
    Loop
    { 
        RowNumber := LV_GetNext(RowNumber,"Checked")  ; Resume the search at the row after that found by the previous iteration.
        if not RowNumber  ; The above returned zero, so there are no more selected rows.
            break
        LV_GetText(Text, RowNumber)
        LV_GetText(Desc, RowNumber,2)
        result["code",A_Index]:=Text
        result["desc",A_Index]:=Desc
    }
    return result
  }

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

  pesquisa_simple_array(wname,lvname,string,List){
    Gui,%wname%:default
    Gui,listview,%lvname%
    ;caso a string esteja vazia
    If (string = ""){
      GuiControl, -Redraw,%lvname% 
      LV_Delete()
      for,each,value in List
          LV_Add("",value)

      GuiControl, +Redraw,%lvname%       
      return
    }
    result := []
    for each,value in List{

      IfInString,value,%string%
      {
        result.insert(value)
      }
    }
    GuiControl, -Redraw,%lvname%
    LV_Delete()
    for each,value in result{
      LV_Add("",value)
    }
    GuiControl, +Redraw,%lvname%
  }

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

  any_word_search(wname, lvname, string, List){
    Gui,%wname%:default
    Gui, listview,%lvname%
    GuiControl, -Redraw,%lvname%
    Gui, Submit, NoHide

      resultsearch := [] 
      If (string = ""){ 
        LV_Delete()
        for,each,value in List{
          LV_Add("",List[A_Index,1],List[A_Index,2], List[A_Index,3])
        }       
      }Else{
        for,each,value in List{
          i++

          string2 := List[A_Index, 1] List[A_Index, 2] List[A_Index, 3]

          StringSplit, splitted_string, string,%A_Space%

          _exists_in_all := 0
          Loop,% splitted_string0
          {
            value_to_search := trim(splitted_string%A_Index%)
            IfInString, string2, %value_to_search%
            {
              _exists_in_all := 1
            }else{
              _exists_in_all := 0
              Break
            } 
          }
          if(_exists_in_all = 1)
            resultsearch.insert(i)
        }
        i := 0
        LV_Delete()
        for, each, value in resultsearch{
            LV_Add("",List[value,1], List[value,2], List[value,3])
        }
      }
      GuiControl, +Redraw,%lvname%
      LV_Modify(1, "+Select")
  }

  any_word_search_backup(wname, lvname, string,List){
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
              StringSplit,splitted_string,string,%A_Space%
              _exists_in_all:=0
        Loop,% splitted_string0
        {
          value_to_search:=trim(splitted_string%A_Index%)
          IfInString,string2,%value_to_search%
                {
                    _exists_in_all:=1
                }else{
                  _exists_in_all:=0
                  Break
                }
          ;MsgBox, % result%A_Index%  
        }
        if(_exists_in_all=1)
          resultsearch.insert(i)
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

  pesquisalv3(wname,lvname,string,List){     ;## PESQUISAR PARA 3 COLUNAS#### 
    Gui,%wname%:default
      Gui,listview,%lvname%
      GuiControl, -Redraw,%lvname%
      Gui, Submit, NoHide
      resultsearch:=[] 
      If (string=""){ 
          LV_Delete()
          for,each,value in List{
              LV_Add("",List[A_Index,1],List[A_Index,2],List[A_Index,3])
          }       
      }Else{
          for,each,value in List{
              i++
              string2:=List[A_Index,1] List[A_Index,2] List[A_Index,3]
              IfInString,string2,%string%
              {
                  resultsearch.insert(i)
              }
          }
          i:=0
          LV_Delete()
          for,each,value in resultsearch{
              LV_Add("",List[value,1],List[value,2],List[value,3])
          }
      }
      GuiControl, +Redraw,%lvname%
      LV_Modify(1, "+Select")
  } 

  pesquisalv4(wname,lvname,string,List){     ;## PESQUISAR PARA 3 COLUNAS#### 
    Gui,%wname%:default
      Gui,listview,%lvname%
      GuiControl, -Redraw,%lvname%
      Gui, Submit, NoHide
      resultsearch:=[] 
      If (string=""){ 
          LV_Delete()
          for,each,value in List{
              if(List[A_Index,1] = "")
                Continue
              LV_Add("",List[A_Index,1],List[A_Index,2],List[A_Index,3],List[A_Index,4])
          }       
      }Else{
          for,each,value in List{
              i++
              string2:=List[A_Index,1] List[A_Index,2] List[A_Index,3] List[A_Index,4]
              IfInString,string2,%string%
              {
                  resultsearch.insert(i)
              }
          }
          i:=0
          LV_Delete()
          for,each,value in resultsearch{
              LV_Add("",List[value,1],List[value,2],List[value,3],List[A_Index,4])
          }
      }
      GuiControl, +Redraw,%lvname%
      LV_Modify(1, "+Select")
  } 

  ;##############getvaluesLV#####################

  getvaluesLV(wName,lvName)   ;extrai todos os valores de uma listview e retorna um array.
  {
    values := []
    i := 0
    gui, %wName%:default 
    Gui, listview, %lvName%

    Loop, % LV_GetCount("Column")
    {
      i+=1
      Loop, % LV_GetCount()
      {
        LV_GetText(text,A_Index,i)
        values[A_Index,i] := text
      }
    }
    return values
  }

  /*
    Marca todos os items de uma determinada listview
  */
  check_all(window, listview){
    Gui, %window%:default
    Gui, Listview, %listview%
    Loop, % LV_GetCount()
      LV_Modify("","+check")  
  }

  /*
    Desmarca todos os items de determinada listview
  */
  uncheck_all(window, listview){
    Gui, %window%:default
    Gui, Listview, %listview%
    Loop, % LV_GetCount()
      LV_Modify("","-check")  
  }

  /*
  Deleta a linha da listview que comtem 
  determinado valor 
*/
  delete_row_from_lv(window, lv, item_to_remove, everyone = 0){
    Gui, %window%:default
    Gui, Listview, %lv%
    
    values := getvaluesLV(window, lv)
    removed_items := ""
    removed_rows := ""
    for, each, row in values{
      row_number := A_Index
      for, each, item in row{
        if(item = item_to_remove){
          IfNotInString, removed_items, %item%
          {
            IfNotInString, removed_rows, %row_number%
            {
              LV_Delete(row_number) 
              removed_items .= item
              removed_rows .= row_number  
            }
          }else{
            if(everyone = 1){
              IfNotInString, removed_rows, %row_number%
              {
                LV_Delete(row_number)
                removed_rows .= row_number  
              }
            }
          }
        } 
      }
    }
  }
} ; /// LV

