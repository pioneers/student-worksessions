// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs

//= require moment
//= require fullcalendar
//= require bootstrap-datepicker
//= require bootstrap-datetimepicker
//= require jquery.timepicker.js

//= require pickers
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree .

$(document).ready(function() {
  $('.datepicker').datepicker()
  });

$(document).ready(function() {
  $('.timepicker').timepicker(
    { 'scrollDefault': '9:00am' })
  });

$(document).on("click","[data-behaviour~=datepicker]",function(){
    $(this).datetimepicker();
  });


$(document).ready(function() {
   $("#calendar").fullCalendar({
    header: {
                 left: "prev,next today",
                 center: "title",
                 right: 'month,agendaWeek,agendaDay'
             },
     // header: "something"
     // left: "prev,next today",
     // center: "title",
     // right: "month,agendaWeek,agendaDay"
     defaultView: "month",
     height: 800,
     slotMinutes: 15,
     events: "/worksessions.json",
     timeFormat: "h:mm",
     dragOpacity: "0.5"
  });
});

