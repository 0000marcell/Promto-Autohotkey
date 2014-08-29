function PromtoPrinter(){
}

PromtoPrinter.prototype.start = function(){
	$("#main-page").empty();
	this.printTag();
};


PromtoPrinter.prototype.printTag = function() {
	for(var i = 1; i <= obj.max_index; i++) {
		this.itemNumber = i;
		this.insertItem(obj.items[i]);
	}
	window.print();
};

PromtoPrinter.prototype.insertItem = function(item) {
	this.insertTagCodeFormation(item);
	this.insertTagImage(item);
	this.insertTagDesc(item);
};

PromtoPrinter.prototype.insertTagImage = function(item) {
	var image_path = replaceAll("/", "\\", item.image_path)
	$("<img src="+image_path+">").appendTo(this.container);
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

PromtoPrinter.prototype.insertPageBreak = function() {
	if(this.itemNumber%2 != 0){
		this.currentPage = $('<div class="page"></div>').appendTo("#main-page");
	}
	return this.currentPage;
}

PromtoPrinter.prototype.insertTagCodeFormation = function(item) {
	this.page = this.insertPageBreak();
	this.container = $('<div class="item"></div>').appendTo(this.page);
	this.insertTagPrefix(item);	
	this.insertTagCodePiece(item);
};

PromtoPrinter.prototype.insertTagPrefix = function(item) {
	this.codeContainer = $("<div class='code-formation'></div>").appendTo(this.container);
	for (var i = 1; i <= item.prefix_max_index; i++) {
		var prefix_piece = item.prefix[i];
		var res = prefix_piece.split("|");
		var html = this.get_HTML_panel(res[0], res[1]);	
    $(html).appendTo(this.codeContainer);     
	}	
};

PromtoPrinter.prototype.insertTagCodePiece = function(item) {
	for (var i = 1; i <= item.fields_max_index; i++) {
		var field = item.fields[i];
		var res = field.split("|");
		var html = this.get_HTML_panel(res[0], res[1]);	
    $(html).appendTo(this.codeContainer);
	}
};

PromtoPrinter.prototype.get_HTML_panel = function(title, item) {
	var fontSize = this.getTitleFontSize(title.length); 
	var fontSizeItem = this.getItemFontSize(item.length);
	var html = "<div class='panel panel-primary code-panel'>"+
									"<div class='panel-heading pt-heading'>"+
			              "<h3 style='font-size: "+fontSize+"px;' class='panel-title'>"+title+"</h3>"+
			            "</div>"+
			            "<div class='panel-body panel-text-pos'>"+
			              "<h3 style='font-size: "+fontSizeItem+"px;'>"+item+"</h3>"+
			            "</div>"+
		            "</div>";
	return html;
};

PromtoPrinter.prototype.getTitleFontSize = function(size) {	
	if(size > 13){
		var fontSize = 6;
	}else{
		var fontSize = 9;
	}
	return fontSize;	
};

PromtoPrinter.prototype.getItemFontSize = function(size) {	
	if(size > 5){
		var fontSize = 10;
	}else{
		var fontSize = 20;
	}
	return fontSize;	
};

function replaceAll(find, replace, str) {
  return str.replace(new RegExp(find, 'g'), replace);
}
