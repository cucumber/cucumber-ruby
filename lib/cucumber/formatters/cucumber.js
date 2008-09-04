function stepPassed(id) {
  $("#"+id).removeClass("new").addClass("passed");
}

function stepPending(id) {
  $("#"+id).removeClass("new").addClass("pending");
}

function stepFailed(id, message, backtrace) {
  $("#"+id).removeClass("new").addClass("failed").append("<div>" + message + "</div>").append("<pre>" + backtrace + "</pre>");
}
