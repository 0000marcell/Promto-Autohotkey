function PromtoPrinter(){
}

PromtoPrinter.prototype.start = function(){
	alert("gonna sta")
	$("#main-page").empty();
	this.printTag();
};


PromtoPrinter.prototype.printTag = function() {
	for (var i = 1; i < obj.items.length; i++){
		this.insertItem(obj.items[i]);
	}
};

PromtoPrinter.prototype.insertItem = function(item) {
	this.insertTagImage(item);
	this.insertTagDesc(item);
	this.insertTagCodeFormation(item);
};

PromtoPrinter.prototype.insertTagImage = function(item) {
	this.container = $('<div class="item"></div>').appendTo("#main-page");
	$("<img src="+item.image+">").appendTo(this.container);
};

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
};

PromtoPrinter.prototype.insertTagCodeFormation = function(item) {
	this.insertTagPrefix(item);	
	this.insertTagCodePiece(item);
};

PromtoPrinter.prototype.insertTagPrefix = function(item) {
	this.codeContainer = $("<div class='code-formation'></div>").appendTo(this.container);
	for (var i = 1; i < item.prefix.length; i++) {
		var prefix_piece = item.prefix[i];
		var res = prefix_piece.split("|");
		var html = this.get_HTML_panel(res[0], res[1]);	
    $(html).appendTo(this.codeContainer);     
	}	
};

PromtoPrinter.prototype.insertTagCodePiece = function(item) {
	for (var i = 1; i < item.fields.length; i++) {
		var field = item.fields[i];
		var res = field.split("|");
		var html = this.get_HTML_panel(res[0], res[1]);	
    $(html).appendTo(this.codeContainer);
	}
};

PromtoPrinter.prototype.get_HTML_panel = function(title, item) {
	var html = "<div class='panel panel-primary code-panel'>"+
									"<div class='panel-heading'>"+
			              "<h3 class='panel-title'>"+title+"</h3>"+
			            "</div>"+
			            "<div class='panel-body panel-text-pos'>"+
			              "<h3>"+item+"</h3>"+
			            "</div>"+
		            "</div>";
	return html;
};
