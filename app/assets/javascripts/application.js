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
//= require jquery_ujs
//= require turbolinks
//= require moment
//= require fullcalendar
//= require bootstrap-datetimepicker
//= require pickers
//= require bootstrap-sprockets

//= require_tree .
$('.datetimepicker').datetimepicker();
$(document).on("click","[data-behaviour~=datepicker]",function(){
    $(this).datetimepicker();
  });
$(document).ready(function() {
   $("#calendar").fullCalendar({
     // header: "something"
     left: "prev,next today",
     // center: "title",
     // right: "month,agendaWeek,agendaDay"
     defaultView: "month",
     height: 500,
     slotMinutes: 15,
     events: "/worksessions.json",
    //  [
    //     {
    //         title  : 'event1',
    //         start  : '2010-01-01'
    //     },
    //     {
    //         title  : 'event2',
    //         start  : '2010-01-05',
    //         end    : '2010-01-07'
    //     },
    //     {
    //         title  : 'event3',
    //         start  : '2010-01-09T12:30:00',
    //         allDay : false // will make the time show
    //     }
    // ],
     timeFormat: "h:mm t{ - h:mm t} ",
     dragOpacity: "0.5"
  });
});