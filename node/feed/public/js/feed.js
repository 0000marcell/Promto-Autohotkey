var dateContainer;

function PromtoFeed() {
}

PromtoFeed.prototype.insertValuesInView = function (obj){
	var prevDate = "";
	for (var i = obj.max_index; i > 0; i--){
		this.date(prevDate, obj.log[i].data);
    prevDate = obj.log[i].data; 
	 	this.item(obj.log[i]);
	}
};

PromtoFeed.prototype.date = function (prevDate, currentDate){
	if(prevDate != currentDate){
		this.insertDate(currentDate);
 	}
};

PromtoFeed.prototype.item = function (obj){
	var html = "<li class='list-group-item main-list item-"+obj.tipo+"'>"+
                "<div class='well well-sm path'>"+this.formatPath(obj.item)+"</div>"+
                "<span class='badge "+obj.tipo+"'>"+obj.tipo+"</span></p>"+
                "<span class='label label-primary model'>"+this.getModel(obj.item)+"</span>"+
                "<p>"+
                  "<h6>Usuario: "+obj.usuario+" Horario: "+obj.hora+"</h6>"+
                "</p>"+
                "<div class='well well-lg msg'>"+
                  "<p>"+obj.msg+"</p>"+ 
                "</div>"+
              "</li>";
	$(html).appendTo(dateContainer);
};

PromtoFeed.prototype.formatPath = function(path){
  var res = path.split("|");
  var string = res[2]+" > "+res[4]+" > "+res[6]+" > "+res[8];
  return string;
}

PromtoFeed.prototype.getModel = function(path){
  var res = path.split("|");
  var string = res[10];
  return string;
}

PromtoFeed.prototype.insertDate = function (date){
  $("<blockquote><h1>"+this.getDateInString(date)+"</h1></blockquote>").appendTo("#feed-list");
  dateContainer = $("<ul class='list-group'></ul>").appendTo("#feed-list");     
};

PromtoFeed.prototype.getDateInString = function (date){
	var res = date.split("/");
	var mounth = this.getMounth(res[1]);
	var string = res[0]+" de "+mounth+" de "+res[2];
	return string;
};

PromtoFeed.prototype.getMounth = function (number){
	var mounth;
  switch (number) {
    case "01":
        mounth = "Janeiro";
        break;
    case "02":
        mounth = "Fevereiro";
        break;
    case "03":
        mounth = "Marco";
        break;
    case "04":
        mounth = "Abril";
        break;
    case "05":
        mounth = "Maio";
        break;
    case "06":
        mounth = "Junho";
        break;
    case "07":
        mounth = "Julho";
        break;
    case "08":
        mounth = "Agosto";
        break;
    case "09":
        mounth = "Setembro";
        break;
    case "10":
        mounth = "Outubro";
        break;
    case "11":
        mounth = "Novembro";
        break;
    case "12":
        mounth = "Dezembro";
        break;
	}
	return mounth;	
};
