/*
	Connect
*/
try {
		Global mariaDB := this.DataBaseFactory.OpenDataBase(databaseType, connectionString)
		MsgBox, % " a conexao foi estabelecida!"
	} catch e {
		MsgBox,16, Error, % "A conexao nao foi estabelecida. Verifique os parametros da conexao!`n`n" ExceptionDetail(e)
}

/*
	Create Table
*/
try
	{
		SB_SetText("Create Test Data")

		createTableSQL =
		(Ltrim
				CREATE TABLE IF NOT EXISTS Test (
				  Name VARCHAR(250),
				  Fname VARCHAR(250),
				  Phone VARCHAR(250),
				  Room VARCHAR(250),
				  PRIMARY KEY (Name, Fname)
				`)
		)		
		db.Query(createTableSQL)

		InsertTestData(db)
		
	}catch e{
		; // if there where already test data
		; // we ignore the duplicate key exception.
	}

