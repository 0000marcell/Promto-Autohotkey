
function FeedSearch(){
}

FeedSearch.prototype.search =	function() {
	var searchTerm = $("#search-input").val();
	var searchTerm = searchTerm.toUpperCase();
	var searchResult = [];
	for (var i = obj.max_index; i > 0; i--){
		var string = obj.log[i].data+obj.log[i].item+obj.log[i].usuario+obj.log[i].msg;
		var string = string.toUpperCase();
		if(string.indexOf(searchTerm) > -1){
			searchResult.push(obj.log[i]);
		}
	}
	if(searchResult.length == 0) {
		$("#feed-list").empty();
		feed.insertValuesInView(obj); 
	}else{
		this.loadSearchResults(searchResult);
	}
}

FeedSearch.prototype.loadSearchResults = function(results) {
	$("#feed-list").empty();	
	var prevDate = "";
	for (var i = 0; i < results.length; i++) {
		feed.date(prevDate, results[i].data);
    prevDate = results[i].data; 
	 	feed.item(results[i]);
	};
}

