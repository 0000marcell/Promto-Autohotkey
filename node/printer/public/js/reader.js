var fs = require("fs");
var file = "print_JSON.json";
var prop_file = "printer_tag_settings.json"
var prop_tag_values;

function PromtoReader(){
}

PromtoReader.prototype.start = function(){
	try{
		var obj =	this.readJSON(file);
		prop_tag_values = this.readJSON(prop_file);
	  return obj;
	}catch(err){
		console.log("Houve um erro "+err);
	}
}

PromtoReader.prototype.readJSON = function(file_path){
	var content = fs.readFileSync(file_path, "utf8");
	var obj = JSON.parse(content);
	return obj;
}