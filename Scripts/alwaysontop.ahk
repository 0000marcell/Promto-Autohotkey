#a::
WinGet, active_id, ID, A
;WinMaximize, ahk_id %active_id%
;MsgBox, The active window's ID is "%active_id%".
WinSet, AlwaysOnTop, toggle,ahk_id %active_id%