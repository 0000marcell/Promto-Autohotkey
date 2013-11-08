Gui, Add, Tab2, AltSubmit gNewtab vMyTab, General|View|Appearance|Settings
Gui, Show,, TabGui
PostMessage, 0x1333, 0, 1, SysTabControl321, TabGui
return

Newtab:
GuiControlGet, ThisTab,, MyTab
PostMessage, 0x1333, % ThisTab -1, 1, SysTabControl321, TabGui
PostMessage, 0x1333, % MyTab -1, 0, SysTabControl321, TabGui
return