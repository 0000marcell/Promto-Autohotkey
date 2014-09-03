var fs = require("fs");
var file = "promto_feed_json.json";
var config = "promto_tag_config.json"

function PromtoReader(){
}

PromtoReader.prototype.start = function(){
	try{
		var obj =	this.readJSON();
	  return obj;
	}catch(err){
		console.log("Houve um erro "+err);
	}
}

PromtoReader.prototype.readJSON = function(){
	var content = fs.readFileSync(file, "utf8");
	obj = JSON.parse(content);
	return obj;
}