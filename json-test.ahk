#SingleInstance,force
#NoTrayIcon
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include, lib\json_parser.ahk
#EscapeChar `
#CommentFlag ;

jsonString =
(ltrim join
	{
		"companies" : [ {	"name" : "maccomevap","mask" : "m" ,
			"types" : [{ "name" : "produtos intermediarios", "mask" : "I", 
				"families" : [{ "name" : "luminaria", "mask" : "L",
					"subfamilies" : [{ "name" : "corpo", "mask" : "CO",
						"models" : [{ "name" : "TL.L.EXE.010", "mask" : "010"

							}]
						}]
					}]}
			]},
			{ "name" : "totallight"}
		]
	}
)

obj := {}
obj.companies := []
obj.companies.insert(
	(JOIN 
 	{"name" : "MACCOMEVAP", 
  	"mask" : "M",
  	"types" : []
	}
	))
obj.companies[obj.companies.maxindex()].types.insert(
	(JOIN 
	{
	 "name" : "PRODUTOS INTERMEDIARIOS",
	 "mask" : "I",
	 "families" : [] 
	}
	)) 
obj.companies[1].types[1].families.insert(
	(JOIN
		{
			"name" : "LUMINARIA",
			"mask" : "L", 
			"models" : []
		}
	))
obj.companies[1].types[1].families[1].models.insert(
	(JOIN
		{
		 "name" : "TL.L.EXE.010",
		 "mask" : "010",
		 "image" : "image_path",
		 "fields" : [],
		 "codes" : []
	}
	))

string := JSON_to(obj) 
MsgBox, % string 
j := JSON_from(jsonString) ;msgbox, % "company name " j.companies[1].types[1].name