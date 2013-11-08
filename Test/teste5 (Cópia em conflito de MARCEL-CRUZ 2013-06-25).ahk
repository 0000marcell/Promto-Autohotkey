Gui, M:New
Gui, Add, Treeview, x10 y10 w300 h500 vtree,
Gui, Show,,
TV_Add("teste1")
TV_Add("teste2")
TV_Add("teste3")
TV_Add("teste4")
TV_Add("teste5")
return 

MGuiContextMenu:
if A_GuiControl = tree
{
    Menu, MyMenu, Add, Adicionar, Adicionar 
    Menu, MyMenu, Add, Remover, Remover
    Menu, MyMenu, Show, x%A_GuiX% y%A_GuiY% 
    TV_GetText(name, A_EventInfo)
}
return 