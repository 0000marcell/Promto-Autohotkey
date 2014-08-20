var fs = require("fs");
var file = "print_JSON.json";

function PromtoReader(){
}

PromtoReader.prototype.start = function(){
	console.log("gonna start !!!");
	try{
		var obj =	this.readJSON();
		alert("returned obj length "+obj.items.length);
	  return obj;
	}catch(err){
		console.log("Houve um erro "+err);
	}
}

PromtoReader.prototype.readJSON = function(){
	var content = fs.readFileSync(file, "utf8");
	alert("gonna read content "+content);
	var obj = JSON.parse(content);
	alert("obj max index "+obj.items[1].desc);
	return obj;
}