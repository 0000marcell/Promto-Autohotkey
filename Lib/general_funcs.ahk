Class AHK{
	/*
	Funcao que verifica se existe algum valor em branco em um
	hash de valores
	*/
	check_if_blank(hash){
		for, each, value in hash{
			if(value = ""){
				MsgBox, 16, Erro, % "O valor " each " estava em branco!"
				return	
			}
		}
	}

	;############flip########################
	Flip( Str) {
	 Loop, Parse, Str
	  nStr=%A_LoopField%%nStr%
	 Return nStr
	}
	;############reversearray########################
	reversearray(array){
		x:=-1,newarray:=[]
		for,each,value in array{
			x+=1
			;MsgBox, % value
			newarray.insert(array[array.maxindex()-x])
		}
		return newarray
	}

	UpdateScrollBars(GuiNum, GuiWidth, GuiHeight)
	{
    static SIF_RANGE=0x1, SIF_PAGE=0x2, SIF_DISABLENOSCROLL=0x8, SB_HORZ=0, SB_VERT=1
    ;msgBox, %GuiNum%
    Gui, %GuiNum%:Default
    Gui, +LastFound
    
    ; Calculate scrolling area.
    Left := Top := 9999
    Right := Bottom := 0
    WinGet, ControlList, ControlList
    Loop, Parse, ControlList, `n
    {
        GuiControlGet, c, Pos, %A_LoopField%
        if (cX < Left)
            Left := cX
        if (cY < Top)
            Top := cY
        if (cX + cW > Right)
            Right := cX + cW
        if (cY + cH > Bottom)
            Bottom := cY + cH
    }
    Left -= 8
    Top -= 8
    Right += 8
    Bottom += 8
    ScrollWidth := Right-Left
    ScrollHeight := Bottom-Top
    
    ; Initialize SCROLLINFO.
    VarSetCapacity(si, 28, 0)
    NumPut(28, si) ; cbSize
    NumPut(SIF_RANGE | SIF_PAGE, si, 4) ; fMask
    
    ; Update horizontal scroll bar.
    NumPut(ScrollWidth, si, 12) ; nMax
    NumPut(GuiWidth, si, 16) ; nPage
    DllCall("SetScrollInfo", "uint", WinExist(), "uint", SB_HORZ, "uint", &si, "int", 1)
    
    ; Update vertical scroll bar.
		;NumPut(SIF_RANGE | SIF_PAGE | SIF_DISABLENOSCROLL, si, 4) ; fMask
    NumPut(ScrollHeight, si, 12) ; nMax
    NumPut(GuiHeight, si, 16) ; nPage
    DllCall("SetScrollInfo", "uint", WinExist(), "uint", SB_VERT, "uint", &si, "int", 1)
    
    if (Left < 0 && Right < GuiWidth)
        x := Abs(Left) > GuiWidth-Right ? GuiWidth-Right : Abs(Left)
    if (Top < 0 && Bottom < GuiHeight)
        y := Abs(Top) > GuiHeight-Bottom ? GuiHeight-Bottom : Abs(Top)
    if (x || y)
        DllCall("ScrollWindow", "uint", WinExist(), "int", x, "int", y, "uint", 0, "uint", 0)
	}

	/*
	Transform array
	*/
	transform_array(array){
		return_array := []

		for, each, value in array{
			return_array[A_Index, 1] := array["code", A_Index]
			return_array[A_Index, 2] := array["desc", A_Index]
		}
		return return_array
	}

	;################objhasvalue###################
	objHasValue(obj,value){
		for,each,value2 in obj
			IfEqual,value2,%value%,return,True
	}

	;##############MATHASVALUE###########################
	MatHasValue(matrix,value){
			i:=0
			returnValue := False
			while(matrix[A_Index,1] != ""){
				i+=1
				while(matrix[i,A_Index]!=""){
					if(matrix[i,A_Index]=value){
						returnValue:=True
					}
				}
			}
			return returnValue
	}

	/*
		Transforma os arrays de multi
		para uma so dimensao
	*/
	singledim_array(array, col = 1){
		return_array := []
		loop, % array.maxindex(){
			return_array.insert(array[A_Index, col])
		}
		Return return_array
	}

	/*
	deleta o arquivo de debug 
	*/

	reset_debug(){
		FileDelete, % "temp\debug.txt"
	}

	/*
		Insere novos valores no debug
	*/
	append_debug(string){
		FileAppend, % string "`n", % "temp\debug.txt"
	}

	/*
	Impede que caracteres ilegais sejam inseridos no 
	nome do arquivo
*/
	format_file_name(file_name){
		file_name := Trim(file_name)
		unmodified_name := file_name 
		_ilegal_char := 0

		IfInString, file_name, "
		{
			StringReplace, file_name, file_name,",,All
			_ilegal_char := 1
		} 

		IfInString, file_name, '
		{
			StringReplace, file_name, file_name,',,All
			_ilegal_char := 1
		}

		IfInString, file_name, \
		{
			StringReplace, file_name, file_name,\,,All
			_ilegal_char := 1
		}

		IfInString, file_name, /
		{
			StringReplace, file_name, file_name,/,,All
			_ilegal_char := 1
		}

		IfInString, file_name, :
		{
			StringReplace, file_name, file_name,:,,All
			_ilegal_char := 1
		}

		IfInString, file_name, *
		{
			StringReplace, file_name, file_name,*,,All
			_ilegal_char := 1
		}

		IfInString, file_name, ?
		{
			StringReplace, file_name, file_name,?,,All
			_ilegal_char := 1
		}

		IfInString, file_name, <
		{
			StringReplace, file_name, file_name,<,,All
			_ilegal_char := 1
		}

		IfInString, file_name, >
		{
			StringReplace, file_name, file_name,>,,All
			_ilegal_char := 1
		}

		IfInString, file_name, |
		{
			StringReplace, file_name, file_name,|,,All
			_ilegal_char := 1
		}

		if(_ilegal_char = 1){
			MsgBox, 16, Erro, % "O nome do arquivo continha caracteres ilegais `n e foi alterado de " unmodified_name " para " file_name
			return
		}
		return file_name
	}

	/*
		Remove all the white spaces of a string
	*/

	rem_space(string){
		StringReplace, string, string,%A_Space%,,All
		return string
	}
} ; /// General 