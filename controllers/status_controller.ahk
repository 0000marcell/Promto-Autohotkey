clean_status(info){
	Global db, USER_NAME
	
	db.Status.change_status(info, "4", USER_NAME, "Nao feito")
	load_status_in_main_window(info)
}