var fs = require("fs");
var file = "print_JSON.json";

function PromtoReader(){
}

PromtoReader.prototype.start = function(){
	console.log("gonna start !!!");
	try{
		var obj =	this.readJSON();
	  return obj;
	}catch(err){
		console.log("Houve um erro "+err);
	}
}

PromtoReader.prototype.readJSON = function(){
	var content = fs.readFileSync(file, "utf8");
	var obj = JSON.parse(content);
	return obj;
}