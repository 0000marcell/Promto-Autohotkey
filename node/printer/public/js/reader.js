var fs = require("fs");
var promtoPrinter = new PromtoPrinter();

function PromtoReader(){
}

PromtoReader.prototype.start = function(){
	try{
		var jsonString = this.readJson("package.json");
	}catch(err){
		console.log("Houve um erro "+err);
	}
}

PromtoReader.prototype.readJson = function(file){
	var stringJson = fs.readFileSync(file);
	var obj = JSON.parse(stringJson);
	this.prepareForPrinting(obj);
}

PromtoReader.prototype.prepareForPrinting = function(json){
	promtoPrinter.start();
	for (var i = 0; i < json.products.length; i++) {
		promtoPrinter.print(json.products[i]);
	}
	promtoPrinter.close();
}



