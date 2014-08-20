

var gui = require('nw.gui');
var win = gui.Window.get(
	window.open('print.html')
);
	 
var fs = require("fs");
fs.readFile(theFileEntry, function (err, data) {
  if (err) {
    console.log("Read failed: " + err);
  }

  handleDocumentChange(theFileEntry);
  editor.setValue(String(data));
});
window.print();