class View{
	view1(){
		Gui, Add,Listview,w400 h400,
		Gui, Add, Button,xp y+5,Salvar 
		Gui, Add, Button,x+5,Cancelar
	}

	view2(){
		Gui, Add,Listview,w400 h400,
		Gui, Add, Button,xp y+5,Salvar 
		Gui, Add, Button,x+5,Cancelar
	}
}

v := new View("salvar","cancelar","window1")

Gui,main:New
Gui, Add, Button,xm gnew_tab,nova aba
Gui, Add, tab2,x+5 vtab_control,
Gui,Show,w800 h500,
return 

new_tab:
guicontrol,,tab_control,Nova Aba 
count +=1
if(count = 1){
	Gui,tab,1
	v.view2()	
}else{
	Gui,tab,2
	v.view1()
}
