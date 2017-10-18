SCENARIOS = "h3[id^='scenario_'],h3[id^=background_]";

$(document).ready(function() {
  $(SCENARIOS).css('cursor', 'pointer');
  $(SCENARIOS).click(function() {
    $(this).siblings().toggle(250);
  });

  $("#collapser").css('cursor', 'pointer');
  $("#collapser").click(function() {
    $(SCENARIOS).siblings().hide();
  });

  $("#expander").css('cursor', 'pointer');
  $("#expander").click(function() {
    $(SCENARIOS).siblings().show();
  });

  // Close failures, right at the beginning
  $('li.failed .message').slideToggle();
  $('li.failed .backtrace').slideToggle();
  $('li.failed .ruby').slideToggle();
  $('tr.step').next('tr').children('td.failed').parent().slideToggle();

  // Register to re-open failing Scenario messages
  $('li.failed').click(function() {
    $('.message', this).slideToggle();
    $('.backtrace', this).slideToggle();
    $('.ruby', this).slideToggle();
  });

  // Register to re-open failing Scenario Outline messages
  $('tr.step').click(function() {
    $(this).next('tr').children('td.failed').parent().slideToggle();
  });
})

function moveProgressBar(percentDone) {
  $("cucumber-header").css('width', percentDone +"%");
}
function makeRed(element_id) {
  $('#'+element_id).css('background', '#C40D0D');
  $('#'+element_id).css('color', '#FFFFFF');
}
function makeYellow(element_id) {
  $('#'+element_id).css('background', '#FAF834');
  $('#'+element_id).css('color', '#000000');
}
