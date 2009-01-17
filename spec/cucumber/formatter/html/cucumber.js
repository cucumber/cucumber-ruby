jQuery.fn.status = function(s) {
  this.removeClass('idle').addClass(s);
  this.next('span.multiline').addClass(s);
  this.parent().addClass(s);
  this.parent().parent().children('span.feature').addClass(s);
}

jQuery.fn.failed = function(message, backtrace) {
  this.status('failed');
  this.append("\n<span>" + message.replace(/^/gm, '      ') + "</span>").append("\n<span>" + backtrace.replace(/^/gm, '      ') + "</span>");
}
