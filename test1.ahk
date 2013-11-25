#include <DBA>
#include <promtolib>
;#include lib\promto_sql_mariaDB.ahk
ddDatabaseConnection:= connectionvalue["connection"]
ddDatabaseType:= connectionvalue["type"]
MsgBox, % "ddDatabaseConnection " ddDatabaseConnection "`n ddDatabaseType " ddDatabaseType  
try {
	sigaconnection:= DBA.DataBaseFactory.OpenDataBase(ddDatabaseType,ddDatabaseConnection)
} catch e {
	MsgBox,16, Error, % "A conexao falhou!`n" ExceptionDetail(e)
	return 
}
sigaconnection:= DBA.DataBaseFactory.OpenDataBase(ddDatabaseType,ddDatabaseConnection)


x := new OTTK(source)
for,each,value in x{
	x[A_Index, 1]

    db.query("INSERT INTO " args1["table"] " (" args1["field"] ") VALUES ('" x[A_Index,1] "','" x[A_Index,2] "');")
}

db := new PromtoSQL(
	(JOIN 
		"MySQL",
		"Server=localhost;Port=3306;Database=test;Uid=root;Pwd=Recovergun;"
	))



;db.Empresa.incluir("Totallight", "T")
;db.Tipo.incluir("Materia prima", "MP", "T", "Totallight")
db.Modelo.incluir("TL.L.EXE.010", "010", "TMPCH")
;db.Modelo.excluir("TL.L.EXE.010", "010", "TMPCH")
db.Familia.excluir("Chapa", "CH", "TMP")
