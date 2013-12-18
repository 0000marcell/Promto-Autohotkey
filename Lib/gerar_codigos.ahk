gerarcodigos:
_reload_gettable := True
db.correct_todas_ordems(info)
/*
	Funcao que pega todas as tabelas necessarias para
	a formacao dos codigos 
*/
info := get_item_info("M", "MODlv")
db.Modelo.load_tables(info)
if(!camptable)||(!octable)||(!odctable)||(!odrtable)||(!codtable){
	MsgBox,64,, % "Uma ou mais campos, das tabelas necessarias para gerar os codigos esta em branco!"
}

args:={}
args["codtable"] := codtable
args["octable"] := octable 
args["odctable"] := odctable
args["odrtable"] := odrtable
args["oditable"] := oditable
args["camptable"] := camptable
args["empmasc"] := info.empresa[2]
args["abamasc"] := info.tipo[2]
args["fammasc"] := info.familia[2]
args["modmasc"] := info.modelo[2]
args["mascaraant"] := info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2]

/*
	Carrega a tabela de campos
*/
table_values := db.load_table_in_array(info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2] "prefixo")

for,each,value in table_values{
	if(table_values[A_Index,2] = "")
		Continue
	args["mascaraant2"] .= table_values[A_Index,2]	
}

if(args["mascaraant2"] = ""){
	MsgBox, % "Defina a ordem do prefixo antes de continuar!!!"
	return 
}

args["selecteditem"] := info.modelo[1]
tables := ["oc","odc","odr","odi"]
tables2 := ["octable","odctable","odrtable","oditable"]
fields := ["Codigo","DC","DR","DI"]
relational := {}    ;tabela usada para relacionar os valores do codigo com as descricoes no formato relational[campo,desc,value] := valor do codigo
for,each,value in tables2
	args["ordemtable"] := args[value], args["field"] := fields[A_Index], args["type"] := tables[A_Index], loadtables(args)	

finalcod := []
for,each,value in tables {
	codlist := []
	args["table"] := value, prefix := args["mascaraant2"], global_prefix := prefix, x := 1,gerarcodigos(args,prefix,x)
	for,each2,value2 in codlist {
		;FileAppend, % "valor final para " value " > " value2 "`n", % "gc_debug.txt"
		finalcod[value, A_Index] := value2 
	}
}
MsgBox,64,, % " Aguarde.... (numero total de codigos:" finalcod["oc"].maxindex() ")"
db.clean_table(codtable)

codes := {}

descgeral_array := db.load_table_in_array(info.empresa[2] info.tipo[2] info.familia[2] info.modelo[2] "Desc")
desc_ := db.Modelo.get_desc(info)
StringSplit, desc_, desc_ ,|,
descgeral := desc_1
descgeralingles := desc_2
progress(finalcod["oc"].maxindex(), parar_gerar_codigo)
_error := 0
for,each,value in finalcod["oc"]{
		finalresult := organizecode(finalcod["oc",each]) ;Funcao que organiza os codigos com as descricao correspondentes.
		updateprogress("Inserindo Codigos " finalresult.oc,1)
		code_initial_prefix := finalresult.oc
		Stringleft,code_initial_prefix,code_initial_prefix,3
		if(code_initial_prefix != "MPT" ){
			if(StrLen(finalresult.oc) > 15){
				MsgBox,16,,% "O codigo " finalresult.oc " tem mais de 15 caracteres a insercao de codigo ira parar "
				_error := 1
				Break
			}	
		}else{
			if(StrLen(finalresult.oc)>16){
				MsgBox,16,,% "O codigo " finalresult.oc " tem mais de 15 caracteres a insercao de codigo ira parar "
				_error := 1
				Break
			}	
		}
		
		if(StrLen(descgeral " " finalresult.dc)>255){
			MsgBox,16,,% "A descricao completa do codigo " finalresult.oc " tem mais de 255 caracteres a insercao de codigo ira parar "
			_error:=1
			Break 
		}
		if(StrLen(descgeral " " finalresult.dr)>155){
			MsgBox,16,,% "A descricao resumida do codigo " finalresult.oc " tem mais de 155 caracteres a insercao de codigo ira parar "
			_error := 1
			Break 
		}
		if(StrLen(descgeralingles " " finalresult.di)>155){
			MsgBox,16,,% "A descricao em ingles do codigo " finalresult.oc " tem mais de 155 caracteres a insercao de codigo ira parar "
			_error:=1
			Break 
		}
		db.Modelo.inserir_codigo(codtable, [finalresult.oc, descgeral " " finalresult.dc, descgeral " " finalresult.dr, descgeralingles " " finalresult.di])
}
Gui,progress:destroy
if(_error = 0)
	MsgBox,64,, % "codigos gerados!!"
else
	MsgBox,16,, % "Os codigos NAO foram gerados!!"
db.load_codigos_combobox(codtable)
return 

parar_gerar_codigo(){
	MsgBox, % "parar gerar codigo!"
}

organizecode(code){
	Global
	campo := {}
	StringSplit,codepiece,code,|
	x := 1
	cleancode := ""
	field2 := ""
	Loop,% codepiece0 {
		if(A_Index = 1){
			x += 1
			Continue
		}
		StringSplit,field,codepiece%x%,>
		campo[field1] := field2
		cleancode .= field2
		x += 1
	}
	returndesc := {}
	returndesc.oc := codepiece1 cleancode
	returndesc.dc := getdesc(campo,"odc")
	returndesc.dr := getdesc(campo,"odr")
	returndesc.di := getdesc(campo,"odi")	
	return returndesc
}

getdesc(campo,typedesc){
	Global
	for,each,value in finalcod[typedesc]{
		value := finalcod[typedesc,each]
		StringSplit,code,value,|
		fieldnames := object()
		campo2 := {}
		campo2withspaces := {}
		x:=1
		Loop,% code0{
			if(A_Index = 1){
				x += 1
				Continue
			}
			StringSplit,field,code%x%,>
			campo2withspaces[field1] := field2
			StringReplace,field2,field2,%A_Space%,,All
			campo2[field1] := field2
			fieldnames.insert(field1)
			x+=1
		}
		match := 0
		desc := ""
		for,each,value in fieldnames{
			if(campo[value] = relational[value,typedesc,campo2[value]]){
				match := 1
				desc .= campo2withspaces[value] " " 
			}else{
				match := 0
				Break
			}
		}
		if(match = 1)
			Break
	} 
	return desc
}

loadtables(args)
{
	Global db,oc,odc,odr,odi,relational

	type := args["type"], %type% := []
	
	;FileAppend, % "type : " type "`n", % "ld_debug.txt"

	ordem_table_values := db.load_table_in_array(args["ordemtable"])
	
	;FileAppend, % "ordem_table_values max index : " ordem_table_values  "`n" , % "ld_debug.txt"
	For each in ordem_table_values{
		if(ordem_table_values[A_Index,2] = "")
			Break
		read := ordem_table_values[A_Index,2]
		StringReplace, value, read, %A_Space%,,All
		;FileAppend, % "value : " value "`n", % "ld_debug.txt"
		k:=[]
		;MsgBox, % "ira buscar a tabela de referencia `n value: " value " `n tabela1: " args["mascaraant"] . args["selecteditem"] 
		result := db.get_reference(value, args["mascaraant"] . args["selecteditem"])
		;MsgBox, % "tabela retornada: " result
		;result := db.query("SELECT tabela2 FROM reltable WHERE tipo='" . value . "' AND tabela1='" . args["mascaraant"] . args["selecteditem"] . "'")
		;FileAppend, % "tabela retornada " result "`n", % "ld_debug.txt"
		
		field := args["field"]
		
		;MsgBox, % "4"
		
		ordem_esp_table := db.load_table_in_array(result)

		;FileAppend, % "ordem esp table " ordem_esp_table[1,1] "`n", % "ld_debug.txt"
		For each in ordem_esp_table{
			if(type = "oc"){
				if(ordem_esp_table[A_Index,1] != ""){
					k.insert("|" value ">" ordem_esp_table[A_Index,1])	
				}
			}else if(type = "odc"){
				if(ordem_esp_table[A_Index,2] != ""){
					k.insert("|" value ">" ordem_esp_table[A_Index,2])	
				}
			}else if(type = "odr"){
				if(ordem_esp_table[A_Index,3] != ""){
					k.insert("|" value ">" ordem_esp_table[A_Index,3])	
				}
			}else if(type = "odi"){
				if(ordem_esp_table[A_Index,4] != ""){
					k.insert("|" value ">" ordem_esp_table[A_Index,4])	
				}			
			}
		}

		;FileAppend, % "ordem esp table item " ordem_esp_table[A_Index,1] "`n", % "ld_debug.txt"

		;MsgBox, % "5"
		ordem_esp_table2 := db.load_table_in_array(result)
		
		;FileAppend, % "ordem esp table 2 " ordem_esp_table2[1,1] "`n", % "ld_debug.txt"

		For each in ordem_esp_table2{  ;Loop que cria a relational table !!!
			dc1 := ordem_esp_table2[A_Index,2]
			dr1 := ordem_esp_table2[A_Index,3] 
			di1 := ordem_esp_table2[A_Index,4]
			StringReplace,dc1,dc1,%A_Space%,, All
			StringReplace,dr1,dr1,%A_Space%,, All
			StringReplace,di1,di1,%A_Space%,, All

			;MsgBox, % "value: " value "`n dc1: " dc1
			;FileAppend, % "value " value " dc1 " dc1 "`n", % "ld_debug.txt"

			relational[value,"odc",dc1] := ordem_esp_table2[A_Index,1]
			relational[value,"odr",dr1] := ordem_esp_table2[A_Index,1]
			relational[value,"odi",di1] := ordem_esp_table2[A_Index,1]
		}

		if(k[1] != ""){
			;FileAppend, % "valor inserido no tipo " type " valor k: " k[1] "`n ########################################################### `n ######################################### `n ", % "ld_debug.txt"
			%type%.insert(k)
		}
	}
}

gerarcodigos(args,prefix,x)
{
	Global db,oc,odc,odr,odi,codlist,_firsttime,global_prefix

	table := args["table"]
	
	;FileAppend, % "table " table "`n", % "gc_debug.txt"
	maxindex := %table%[x].maxindex()
	;FileAppend, % "next table max index > " maxindex "`n", % "gc_debug.txt" 
	for,each,value in list:=%table%[x]{
		if(table = "oc")
			cod := prefix value
		if(table = "odc")
			cod := prefix " " value
		if(table = "odr")
			cod := prefix " " value
		if(table = "odi")
			cod := prefix " " value
		x+=1
		;FileAppend, % "cod " cod "`n", % "gc_debug.txt"
		gerarcodigos(args,cod,x)
		x-=1		
	}
	if(!%table%[x]){
		if(table!="oc")
			StringReplace,prefix,prefix,% global_prefix,,All
		;FileAppend, % "prefix " prefix "`n ########################### `n ########################## `n ############################## `n", % "gc_debug.txt"
		codlist.insert(prefix)
		return
	}
}