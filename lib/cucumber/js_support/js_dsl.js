var CucumberJsDsl = {
  registerStepDefinition: function(regexp, func) {
    jsLanguage.addStepDefinition(regexp, func);
  },

  beforeHook: function(func){
    jsLanguage.registerJsHook('before', func);
  },

  Table: function(raw_table){
     this.raw = raw_table;
  }

}

CucumberJsDsl.Table.prototype.hashes = function(){
  var rows = this.rows();
  var headers = this.headers();
  var hashes = [];

  for (var rowIndex in rows){
    var hash_row = [];
    for (var cellIndex in headers){
      hash_row[headers[cellIndex]] = rows[rowIndex][cellIndex];
    }
    hashes[rowIndex] = hash_row;
  }
  return hashes;
}

CucumberJsDsl.Table.prototype.rows = function(){
  return this.raw.slice(1);
}

CucumberJsDsl.Table.prototype.headers = function(){
  var raw_cells = this.raw.slice(0);
  return raw_cells.shift();
}

var Given = CucumberJsDsl.registerStepDefinition;
var When = CucumberJsDsl.registerStepDefinition;
var Then = CucumberJsDsl.registerStepDefinition;

var Before = CucumberJsDsl.beforeHook;
