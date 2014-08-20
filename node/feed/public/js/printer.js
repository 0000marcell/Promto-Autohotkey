function PromtoPrinter(){
}

PromtoPrinter.prototype.start = function(){
	$("#main-page").empty();
}

PromtoPrinter.prototype.print = function(obj){
	this.item = $('<div class="item"></div>').appendTo("#main-page");
	this.image = obj.image;
	this.desc = obj.desc;  
	$("<img src="+this.image+">").appendTo(item);
	this.insertDesc();
}

PromtoPrinter.prototype.insertDesc = function(){
	"<div class='panel panel-primary desc'>"
    "<div class='panel-heading'>"
      "<h3 class='panel-title'>Descricao</h3>"
    "</div>"
    "<div class='panel-body panel-text-pos'>"
      "<h3>"+this.desc+"</h3>"
    "</div>"
	"</div>"
}

PromtoPrinter.prototype.close = function(){
	
}