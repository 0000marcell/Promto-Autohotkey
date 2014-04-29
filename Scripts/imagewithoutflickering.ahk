


Gui,color,black
Gui,Add,picture,w500 h500 x10 y10 vpic1
Gui,add,picture,w500 h500 x10 y10 vpic2
Gui,add,button,y+5 w100  gbutton1,Mudar foto
 Gui,add,button,y+5 w100  gbutton2,Mudar foto 2
Gui,Show
return 


button1:
;GuiControl,,pic1,logo.png
changepic("logo.png")
return 

button2:
;GuiControl,,pic2,logogrande.png
changepic("logogrande.png")
return 


changepic(image){
	Static _showpic
	_showpic:=(_showpic="" || _showpic=2) ? 1 : 2
	if(_showpic=1){
		GuiControl,,pic1,% image
		GuiControl,hide,pic2
		GuiControl,Show,pic1
	}
	if(_showpic=2){
		GuiControl,,pic2,% image
		GuiControl,hide,pic1
		GuiControl,Show,pic2
	}
	return 	
}
