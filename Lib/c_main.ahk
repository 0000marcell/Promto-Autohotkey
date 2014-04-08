Class Main{
	__New(lv){
		this.lv := lv 
	}

	set_code_number(number){
		Gui, M:default
		GuiControl,, numberofitems, % number 
	}
	number_of_items(){
	 	Global
		
		
	}

	get_lv(){
		return this.lv
	}
}