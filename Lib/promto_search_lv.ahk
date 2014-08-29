class LV{
	set_searcheable_list(list, db_table = ""){
		this.list := list, this.db_table := db_table
		this.result := ""
	}

	set_window_handler(window, lv) {
		this.window := window, this.lv := lv
	}

	any_word_search(window, lv, keyword){
		Global search	
		this.window := window, this.lv := lv
		this.keyword := keyword 
    If(keyword = ""){ 
      this.reset_lv()
    }Else{
    	this.result := search.any_word_in_array(keyword, this.list)
     	this.load_result() 
    }
    LV_Modify(1, "+Select")
	}

	load_result(){
		clear_lv(this.window, this.lv)
		this.redraw("-redraw", this.window, this.lv)
    for, each, value in this.result{
    	this.include_in_lv(value, this.window, this.lv) 
    }
    this.redraw("+redraw", this.window, this.lv)
	}

	reset_lv(){
		clear_lv(this.window, this.lv)
		this.redraw("-redraw", this.window, this.lv)
		for, each, value in this.list{
     this.include_in_lv(A_Index, this.window, this.lv) 
   	}
    this.redraw("+redraw", this.window, this.lv) 
	}

	redraw(command, window, lv){
		Gui,	%window%:default
	  Gui, listview, %lv%
		GuiControl, %command%, %lv%
	}

	include_in_lv(line, window, lv){
		Gui,	%window%:default
	  Gui, listview, %lv%
	  if(this.list[line, 1] = "")
	  	return
		LV_Add(
      (JOIN
      	"", 
    		this.list[line, 1], this.list[line, 2],
    		this.list[line, 3], this.list[line, 4],
    		this.list[line, 5], this.list[line, 6],
    		this.list[line, 7], this.list[line, 8],
    		this.list[line, 9], this.list[line, 10],
    		this.list[line, 11], this.list[line, 12]  
    	))
	}

	update_list(number, value, checked_list){
		if(this.result != ""){
			this.update_by_result(number, value, checked_list)
		}else if(checked_list[1, 1] != ""){
			this.update_by_checked_list(number, value, checked_list)
		}else {
			this.update_by_result(number, value)
		}
	}

	update_by_checked_list(number, value, checked_list) {
		Global db
		for, each, item in checked_list{
			item := checked_list[A_Index, 1]
			this.list[item, number] := value
		  db.Modelo.insert_fiscal_value(this.list[item, 1], number, value, this.db_table)
		}
		this.any_word_search(this.window, this.lv, "") 
	}

	update_by_list(number, value) {
		Global db
		loop, % this.list.maxindex()
		{
			this.list[A_Index, number] := value
			db.Modelo.insert_fiscal_value(this.list[A_Index, 1], number, value, this.db_table)		
		}
		this.any_word_search(this.window, this.lv, "")
	}

	update_by_result(number, value, checked_list) {
		Global db
		for, each, item in this.result{
			if(checked_list[1, 1] != ""){
				if(!MatHasValue(checked_list, A_Index)){
					Continue
				}
			}
		  this.list[item, number] := value
		  db.Modelo.insert_fiscal_value(this.list[item, 1], number, value, this.db_table)
		}
		this.any_word_search(this.window, this.lv, "")
	}
}