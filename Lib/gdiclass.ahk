Class gdi
{
	__New(filePath){
		If !pToken := Gdip_Startup()
		{
		    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		    ExitApp
		}
		Gui, 1: +Caption +E0x80000 +LastFound +OwnDialogs 
		Gui, 1: Show,NA
		;Gui,+LastFound
		hwnd1 := WinExist()
		hbm := CreateDIBSection(w,h)
		hdc := CreateCompatibleDC()
		obm := SelectObject(hdc, hbm)
		G := Gdip_GraphicsFromHDC(hdc)
		Gdip_SetSmoothingMode(G,1)
	}
}
