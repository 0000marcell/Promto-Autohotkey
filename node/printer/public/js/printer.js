function PromtoPrinter(){
}

PromtoPrinter.prototype.start = function(){
	$("#main-page").empty();
}


PromtoPrinter.prototype.printTag = function() {
	for (var i = 0; i < obj.items.length; i++){
		this.insertItem(obj.items[i]);
	}
}

PromtoPrinter.prototype.insertItem = function(item) {
	this.insertTagImage(item);
	this.insertTagDesc(item);
	this.insertTagCodeFormation(item);
}

PromtoPrinter.prototype.insertTagImage = function(item) {
	this.container = $('<div class="item"></div>').appendTo("#main-page");
	$("<img src="+item.image+">").appendTo(this.container);
}

PromtoPrinter.prototype.insertTagDesc = function(item) {
	var html = "<div class='panel panel-primary desc'>"+
		            "<div class='panel-heading'>"+
		              "<h3 class='panel-title'>Descricao</h3>"+
		            "</div>"+
		            "<div class='panel-body panel-text-pos'>"+
		              "<h3>"+item.desc+"</h3>"+
		            "</div>"+
        			"</div>";
	$(html).appendTo(this.container);

}

PromtoPrinter.prototype.insertTagCodeFormation = function(item) {

}
