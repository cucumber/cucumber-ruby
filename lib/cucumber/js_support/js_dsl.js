var CucumberJsDsl = {
  registerStepDefinition: function(regexp, func) {
    jsLanguage.addStepDefinition(regexp, func);
  },

  beforeHook: function(func){
    jsLanguage.registerJsHook('before', func);
  }
}

var Given = CucumberJsDsl.registerStepDefinition;
var When = CucumberJsDsl.registerStepDefinition;
var Then = CucumberJsDsl.registerStepDefinition;

var Before = CucumberJsDsl.beforeHook;

