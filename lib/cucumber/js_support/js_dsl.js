var CucumberJsDsl = {
  registerStepDefinition: function(regexp, func) {
    if(func == null){
      jsLanguage.executeStepDefinition(regexp);
    }
    else{
      jsLanguage.addStepDefinition(regexp, func);
    }
  },

  registerTransform: function(regexp, func){
    jsLanguage.registerJsTransform(regexp, func);
  },

  beforeHook: function(tag_expressions_or_func, func){
    CucumberJsDsl.__registerJsHook('before', tag_expressions_or_func, func);
  },

  afterHook: function(tag_expressions_or_func, func){
    CucumberJsDsl.__registerJsHook('after', tag_expressions_or_func, func);
  },

  Table: function(raw_table){
     this.raw = raw_table;
  },

  __registerJsHook: function(label, tag_expressions_or_func, func){
    if(func != null){
      var hook_func = func;
      var tag_expressions = tag_expressions_or_func;
    } else {
      var hook_func = tag_expressions_or_func;
      var tag_expressions = [];
    }
    jsLanguage.registerJsHook(label, tag_expressions, hook_func);
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
var After = CucumberJsDsl.afterHook;
var Transform = CucumberJsDsl.registerTransform;