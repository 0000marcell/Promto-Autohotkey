Class TV{
	/*
	funcao que busca o nivel da tv 
	*/
	get_tv_level(window, tv){
		Gui, %window%:default
		Gui, treeview, %tv%
		id := TV_GetSelection()
		count := 0
		Loop{
			count++
			id := TV_GetParent(id)
			if !id 
				Break	
		}
		return count
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
	        _dontchange := 1
	      }
	      if(match1="PRODUTOS SEMI-ACABADOS"){
	        icon:="icon3"
	        _dontchange := 1
	      }
	      if(match1="MATERIA PRIMA"){
	        icon:="icon4"
	        _dontchange := 1
	      }
	      if(match1="PRODUTOS INTERMEDIARIOS"){
	        icon:="icon5"
	        _dontchange := 1
	      }
	      if(match1="CONJUNTOS"){
	        icon:="icon6"
	        _dontchange := 1
	      }
	      if(match1="MAO DE OBRA"){
	        icon:="icon7"
	        _dontchange := 1
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

	} ; http://www.autohotkey.com/board/topic/92863-function

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
	;################haschild#########################
	haschild(itemid,wname,tv){
		gui,%wname%:default
		gui,treeview,%tv%
		ItemID := TV_GetChild(itemid)
		if not ItemID  
	        return False
	    return True 
	}
}