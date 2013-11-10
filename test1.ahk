#include <DBA>
#include lib\promto_sql_mariaDB.ahk

db := new PromtoSQL(
	(JOIN 
		"MySQL",
		"Server=localhost;Port=3306;Database=test;Uid=root;Pwd=Recovergun;"
	))

db.Empresa.excluir("Maccomevap", "M")



	;MsgBox, % "empresa_name: " empresa_name " empresa_mascara: " empresa_mascara
	;	mariaDB.BeginTransaction()
	;	{
	;		MsgBox, % "begin transation"
	;		sql := 
	;		(JOIN 
	;			" INSERT INTO empresas (Empresas,Mascara) " 
	;			" VALUES ('" empresa_name "','" empresa_mascara "');"
	;		)
	;		MsgBox, % "gonna query `n" sql 
	;		if(!mariaDB.Query(sql)){
	;			MsgBox, % "erro na query"
	;			Msg := "ErrorLevel: " . ErrorLevel . "`n" . SQLite_LastError() "`n`n" sQry
	;		  FileAppend, %Msg%, sqliteTestQuery.log
	;		  throw Exception("Query failed: " Msg)
	;		}
	;	}mariaDB.EndTransaction()