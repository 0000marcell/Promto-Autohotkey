#include <DBA>
#include <promtolib>
;#include lib\promto_sql_mariaDB.ahk

ddDatabaseConnection = Provider=SQLOLEDB.1;Persist Security Info=False;User ID=lvieira;Initial Catalog=MP11_TOTAL_PRODUCAO;Data Source=192.168.10.5
ddDatabaseType = ADO
MsgBox, % "ddDatabaseConnection " ddDatabaseConnection "`n ddDatabaseType " ddDatabaseType  

try {
	sigaDB := DBA.DataBaseFactory.OpenDataBase(ddDatabaseType,ddDatabaseConnection)
	MsgBox, % "conectado :)"
} catch e {
	MsgBox,16, Error, % "A conexao falhou!`n" ExceptionDetail(e)
	return 
}
;sigaDB := DBA.DataBaseFactory.OpenDataBase(ddDatabaseType,ddDatabaseConnection)


x := new OTTK("dadosestrutura.csv")
for,each,value in x{
	codigo := x[A_Index,2]
	MsgBox, % codigo
  rs := sigaDB.OpenRecordSet(
  								(JOIN 
  										"SELECT B1_DESC FROM SB1010 WHERE B1_COD = '" codigo "'"
  								))
   ;descricao := rs.
   MsgBox, % rs.B1_DESC
   ;FileAppend, codigo ";" descricao "`n",codigos_descricao.csv
}