

format_field(field){
	return_field := Trim(field)
	_ilegal_char := 0
	IfInString, return_field, "
	{
		_ilegal_char := 1
	} 

	IfInString, return_field, '
	{
		_ilegal_char := 1
	}

	if(_ilegal_char = 1){
		MsgBox, % "O campo nao pode contem aspas simples ou duplas!"
		return
	}
	return return_field
}



x = "teste"
v := format_field(x)
MsgBox, % "valor final retornado! " v