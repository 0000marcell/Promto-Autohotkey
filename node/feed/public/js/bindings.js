var prev_selected;

function filter(selected){
	if(prev_selected != selected){
		changeVis(selected);
		$("#"+selected+"-button").addClass('selected');
		$("#"+prev_selected+"-button").removeClass('selected');	
		prev_selected = selected;
	}else{		
		$("#"+selected+"-button").removeClass('selected');
		prev_selected = "";
	}	
}

function makeAllVisible(){
	$('.main-list').each(function(index) {
    $(this).removeClass('hidden');
	});
}

function changeVis(selected){
	$('.main-list').each(function(index) {
    $(this).addClass('hidden');
    $('.item-'+selected).removeClass('hidden');
	});
}