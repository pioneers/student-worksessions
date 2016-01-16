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
//= require jquery-ui
//= require bootstrap-datepicker
//= require bootstrap-datetimepicker
//= require bootstrap-sprockets
//= require jquery.timepicker.js
//= require jquery.cookie
//= require pickers

//= require turbolinks
//= require_tree .

var bootstrapButton = $.fn.button.noConflict() // return $.fn.button to previously assigned value
$.fn.bootstrapBtn = bootstrapButton

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

    defaultView: $.cookie('fullcalendar_defaultView') || 'agendaWeek',
    defaultDate: $.cookie('fullcalendar_defaultDay') || null, 
    slotMinutes: 30,
    events: "/worksessions/available.json",
    timeFormat: "h:mm a",
    contentHeight: 'auto',
    dragOpacity: "0.5",
    minTime: "09:00:00",
    maxTime: "21:00:00",
    viewRender: function(view) {
     $.cookie('fullcalendar_defaultView', view.name); 
     $.cookie('fullcalendar_defaultDay', view.intervalStart.format()); 

   },

    eventClick:  function(event, jsEvent, view) {
        //set the values and open the modal
        $("#eventInfo").html(event.description);
        $("#startTime").html(moment(event.start).format('MMM Do, h:mm A') + "-" + moment(event.end).format('h:mm A'));
        if(event.title == "Available") {
          $("#signUp").html("Sign Up");
          $("#signUp").attr('href', event.signup_url);
        } else if (event.title == "Taken") {
          if (event.user_id == event.current_user_id) {
            $("#signUp").html("Cancel");
            $("#signUp").attr('href', event.cancel_url);
          }
        }


        $("#eventContent").dialog({ modal: true, title: "Worksession (" + event.title  + ")"});
        return false
    },

    

  });

  
  $("#signed_up_calendar").fullCalendar({
    header: {
                 left: "prev,next today",
                 center: "title",
                 right: 'month,agendaWeek,agendaDay'
             },

    defaultView: $.cookie('fullcalendar_defaultView2') || 'agendaWeek',
    defaultDate: $.cookie('fullcalendar_defaultDay2') || null, 
    slotMinutes: 30,
    contentHeight: 'auto',
    events: "/worksessions.json",
    timeFormat: "h:mm a",
    dragOpacity: "0.5",
    displayEventTime: true,
    minTime: "09:00:00",
    maxTime: "21:00:00",
    viewRender: function(view) {
     $.cookie('fullcalendar_defaultView2', view.name); 
     $.cookie('fullcalendar_defaultDay2', view.intervalStart.format()); 

   },

    eventClick:  function(event, jsEvent, view) {
        //set the values and open the modal
        $("#eventInfo").html(event.description);
        $("#startTime").html(moment(event.start).format('MMM Do, h:mm A') + "-" + moment(event.end).format('h:mm A')); 
        $("#cancel").html("Cancel");
        $("#cancel").attr('href', event.cancel_url);
        


        $("#eventContent").dialog({ modal: true, title: "Worksession"});
        return false
    },

    

  });
});

