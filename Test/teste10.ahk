gui,cont:New
Gui,add,listview,w100 h300,Values 
Gui,Show
return 

gui_mainGuiContextMenu:

return 


gui := new GUI()
gui.insert_window("salvar","cancelar")

salvar(){
	MsgBox, % "salvar func"
}

cancelar(){
	MsgBox, % "cancelar func"
}



OnGuiControl(ctrl, fn, p*) {
    static ctrls := {}
    GuiControlGet hwnd, Hwnd, %ctrl%  ; Normalize identifier.
    if ErrorLevel
        return
    ret := ctrls[hwnd]
    if fn {
        ctrls[hwnd] := [fn, p]
        GuiControl +gOnGuiControl_, %ctrl%
    } else {
        GuiControl -g, %ctrl%
        ctrls.Remove(hwnd, "")
    }
    return ret
    OnGuiControl_:
        static _hwnd, _p, _fn
        GuiControlGet _hwnd, Hwnd, %A_GuiControl%  ; Normalize identifier.
        if _p := ctrls[_hwnd] {
            _fn := _p[1]
            %_fn%(_p[2]*)
            _p := ""
        }
    return
}




