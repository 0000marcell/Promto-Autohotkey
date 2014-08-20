class LV{
	set_searcheable_list(list){
		this.list := list
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
		if(this.result = ""){
			this.update_by_list(number, value)
		}else{
			this.update_by_result(number, value)
		}
	}

	update_by_list(number, value) {
		loop, % this.list.maxindex()
		{
			this.list[A_Index, number] := value
		}
		this.any_word_search(this.window, this.lv, "")
	}

	update_by_result(number, value) {
		for, each, item in this.result{
		  this.list[item, number] := value
		}
		this.any_word_search(this.window, this.lv, "")
	}
}