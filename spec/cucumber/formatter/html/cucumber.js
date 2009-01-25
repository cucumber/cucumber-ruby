jQuery.fn.status = function(s) {
  this.removeClass('idle').addClass(s);
  this.next('span.multiline').addClass(s);
  this.parent().addClass(s);
  this.parent().parent().children('span.feature').addClass(s);
}

jQuery.fn.failed = function(message, backtrace) {
  this.status('failed');
  var indentedMessage   =   message.replace(/^/gm, '      ');
  var indentedBacktrace = backtrace.replace(/^/gm, '      ');
  this.append("\n<span>" + indentedMessage + "</span>").append("\n<span>" + indentedBacktrace + "</span>");
}
