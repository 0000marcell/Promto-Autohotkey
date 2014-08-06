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
;obj.companies.insert({type : {"name" : "marcell"}})
obj.companies.insert({})
obj.companies[1].type := "marcell"
;obj.companies.types := [{}]
;obj.companies.types.families := [{}]
;obj.companies.types.families.subfamilies := [{}]
;obj.companies.types.families.models := [{}]
;obj.companies.types.families.subfamilies.models := [{}]
string := JSON_to(obj)
MsgBox, % string

j := JSON_from(jsonString)
;msgbox, % "company name " j.companies[1].types[1].name
