#include <DBA>
#include lib\promto_sql_mariaDB.ahk

db := new PromtoSQL(
	(JOIN 
		"MySQL",
		"Server=localhost;Port=3306;Database=test;Uid=root;Pwd=Recovergun;"
	))

;db.Empresa.incluir("Totallight", "T")
;db.Tipo.incluir("Materia prima", "MP", "T", "Totallight")
;db.Modelo.incluir("TL.L.EXE.010", "010", "TMPCH")
;db.Modelo.excluir("TL.L.EXE.010", "010", "TMPCH")
db.Familia.excluir("Chapa", "CH", "TMP")
