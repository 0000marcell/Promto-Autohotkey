Class OTTK{

	__New(filePath){
		file := FileOpen(filePath,"r")
		value := file.Read()
		this.path := filePath
		StringSplit, fileLine, value, `n, %A_Space%%A_Tab%`r
		Loop, %fileLine0%
		{
			i += 1
			if(fileLine%A_Index% != "")
			{
					StringSplit, value, fileLine%A_Index%,;
					Loop, %value0%
					{
						this[i,A_Index] := value%A_Index%
					}
			}
		}
	}
	
	delete(value){
		for, k, v in this{
			for, w, z in this[k]{
				if(this[k,w] = value){
				  this[k].remove(w)	
				}	
			}
		}
		this.write()
	}

	deleterow(row){
		this.remove(row)
		this.write()
	}

	deletevalue(row, column){
		this[row].remove(column)
		this.write()
	}
	
	rename(ovalue, nvalue){
		i := 0
		while(this[A_Index,1] != ""){
			i+=1
			while(this[i,A_Index] != ""){
				if(this[i,A_Index] = ovalue){
					this[i,A_Index] := nvalue
				}
			}
		}
		this.write()
	}
	
	append(value){
		i := 0
		while(this[A_Index,1] != ""){
			i += 1
		}
		this[i+1,1] := value
		this.write()
	}
	
	write(){
		fPath := this.path
		FileDelete,% this.path
		write := FileOpen(fPath,"w")
		for, k, v in this{
			for, w, z in this[k]{
				if(w = 1){
					write.Write(this[k,w])
				}else{
					write.Write(";" . this[k,w])
				}
			}
			write.Write("`r`n")	
		}
		write.close()
	}

	exist(value, column){
		returnValue := 0
		while(this[A_Index,column] != ""){
			if(value=this[A_Index,column]){
					returnValue:=1
			}
		}	
		return returnValue
	}

	clear(){
		while(this[A_Index,1]!=""){
			this.remove(A_Index)
		}
	}

	checkduplicated(){
		valores := object()
		duplicatedValues := ""
		i := 0
		while(this[A_Index,1] != ""){
			i += 1	
			while(this[i,A_Index] != ""){
				_naoinserir := 0
				for, index, k in valores{
					if(k = this[i,A_Index]){
						_naoinserir := 1
						if(duplicatedValues = ""){
							duplicatedValues .= k	
						}Else{
							duplicatedValues.=";" . k
						}							
					}
				}
				
				if(_naoinserir = 0){
					valores.insert(this[i,A_Index])	
				}
			}
				
		}
		return duplicatedValues
	}
}