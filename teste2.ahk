#Include <DBA>

connectionString := "Server=localhost;Port=3306;Database=test;Uid=root;Pwd=Recovergun;"
try {
	db := DBA.DataBaseFactory.OpenDataBase("mySQL", connectionString)
	MsgBox, % " conectado"
} catch e
	MsgBox,16, Error, % "Failed to create connection. Check your Connection string and DB Settings!`n`n" ExceptionDetail(e)

;"create table if not exists " tablename "(Campos,PRIMARY KEY(Campos ASC))"
try {
	createTableSQL =
		(Ltrim
				CREATE TABLE IF NOT EXISTS test_table (
				  Name VARCHAR(250),
				  Fname VARCHAR(250),
				  Phone VARCHAR(250),
				  Room VARCHAR(250),
				  PRIMARY KEY (Name, Fname)
				`)
		)		
	db.Query(createTableSQL)
}catch e
	MsgBox,16, Erro, % "algo aconteceu ao tentar inserir um valor " ExceptionDetail(e)

