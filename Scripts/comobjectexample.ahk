oExcel := ComObjCreate("Excel.Application")
oExcel.Workbooks.Add
oExcel.Range("A1").Value := "ITLREF0142AI"
oExcel.Range("A2").Value := "REFLETORA FAB. ACO INOX 28W E 40W LUMINARIA TL.L.EXE.014"
oExcel.Visible := 1 
;MsgBox % A1 "`n" oExcel.Range("A2").Value
ExitApp
;oSiga := ComObjCreate("apconn.dll")
;oSiga.CallProc(U_FIMP_SB1())
;oSiga.CallProc()
;oServer:CallProc(U_DrzUpdB1(cAlias, nRecno, nChave))























;oExcel.Range("A2").Value := 7
;oExcel.Range("A3").Formula := "=SUM(A1:A2)"

;oExcel.Range("A1:A3").Interior.ColorIndex := 19
;oExcel.Range("A3").Borders(8).LineStyle := 1
;oExcel.Range("A3").Borders(8).Weight := 2
;oExcel.Range("A3").Font.Bold := 1

;A1 := oExcel.Range("A1").Value 
;oExcel.Range("A4").Select 