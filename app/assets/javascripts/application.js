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

//= require moment
//= require fullcalendar
//= require jquery-ui
//= require bootstrap-datepicker
//= require bootstrap-datetimepicker
//= require bootstrap-sprockets
//= require jquery.timepicker.js
//= require jquery.cookie
//= require pickers


//= require_tree .

var bootstrapButton = $.fn.button.noConflict() // return $.fn.button to previously assigned value
$.fn.bootstrapBtn = bootstrapButton

$(document).on("click","[data-behaviour~=datepicker]",function(){
    $(this).datetimepicker();
  });


$(document).ready(function() {


    $('.datepicker').datepicker()
    $('.timepicker').timepicker(
        { 'scrollDefault': '9:00am' })
   $("#calendar").fullCalendar({
        header: {
                     left: "prev,next today",
                     center: "title",
                     right: 'month,agendaWeek,agendaDay'
                 },

        defaultView: $.cookie('fullcalendar_defaultView') || 'agendaWeek',
        defaultDate: $.cookie('fullcalendar_defaultDay') || null, 
        slotMinutes: 60,
        events: "/worksessions/available.json",
        timeFormat: "h:mm a",
        contentHeight: 'auto',
        dragOpacity: "0.5",
        minTime: "10:00:00",
        maxTime: "20:00:00",
        viewRender: function(view) {
         $.cookie('fullcalendar_defaultView', view.name); 
         $.cookie('fullcalendar_defaultDay', view.intervalStart.format()); 

        },

        eventClick:  function(event, jsEvent, view) {
            //set the values and open the modal
            $("#cancel").remove()
            $("#signUp").remove()
            $("#startTime").html(moment(event.start).format('MMM Do, h:mm A') + "-" + moment(event.end).format('h:mm A'));
            $("#eventInfo").html(event.description); 
            if (event.notes != null) {
                $("#eventNotes").html(event.notes); 
              }
            else {
              $("#eventNotes").empty(); 
            }
            if(event.title == "Available") {
                var signup_div= $('<p><strong><button id="signUp">Sign Up</button> </strong>');
                $("#eventContent").append(signup_div)
                $("#signUp").on('click', function(){
                    $("#txtbox").html("<strong>(Optional)</strong> Any specific debugging/problems you want help with? Or specific materials you want for worksessions?");
                    var signUpUrl = '<form action =' + event.signup_url.toString() + ' >'

                    var textArea = $(signUpUrl + ' <textarea type= "text" name = "notes" placeholder= "e.g. We need help debugging code/are having grizzly problems." style = "width: 320px; height: 100px; font-size: 12px;" /> <input type="submit"/> <input type="submit" value = "Nope, we\'re good!"/>'); 
                    $("#txtbox").append(textArea);
                    // $("#notes").html("<input id='notes' type='text'  placeholder='e.g. Debugging Runtime, grizzly problems' style = 'width:320px; height:180px; padding-top: 1px;'>");
                    $("#eventContent").dialog('close');
                    $("#Notes").dialog({ modal: true, title: "Additional Notes",resizable: true, width:400, height: 270});
                    $("#Submit").html('Submit');
                    $("#Submit").addClass('btn btn-default');
                    $("#Submit").attr('href', event.signup_url);
                    });
            };

            if (event.title == "Signed Up") {
                var cancel_div= $('<p><strong><a id="cancel" class="widget button">Cancel</a> </strong>');
                $("#eventContent").append(cancel_div)
                $("#cancel").attr('href', event.cancel_url);
            }
        $("#eventContent").dialog({ modal: true, title: "Worksession (" + event.title  + ")"});
        return false

    

  }
});
    $("#admin_calendar").fullCalendar({
        header: {
                     left: "prev,next today",
                     center: "title",
                     right: 'month,agendaWeek,agendaDay'
                 },

        defaultView: $.cookie('fullcalendar_defaultView') || 'agendaWeek',
        defaultDate: $.cookie('fullcalendar_defaultDay') || null, 
        slotMinutes: 60,
        events: "/worksessions.json",
        timeFormat: "h:mm a",
        contentHeight: 'auto',
        dragOpacity: "0.5",
        minTime: "10:00:00",
        maxTime: "20:00:00",
        viewRender: function(view) {
         $.cookie('fullcalendar_defaultView', view.name); 
         $.cookie('fullcalendar_defaultDay', view.intervalStart.format()); 

        },

        eventClick:  function(event, jsEvent, view) {
            //set the values and open the modal
            
            $("#Notes-Button").remove();
            $("#add_team-button").empty();
            $("#All-Teams").empty();
            $("#startTime").html(moment(event.start).format('MMM Do, h:mm A') + "-" + moment(event.end).format('h:mm A'));
            $("#eventInfo").html(event.team_names);
            $("#eventContent").dialog({
             modal: true, 
             title: "Worksession (" + event.title  + ")",
              });
            $("#eventContent").append("<p><strong><a id='add_team-button' href=''></a> </strong></p>");
            $("#eventContent").append("<p><strong><button id='Notes-Button'>All Notes</button>");
            $("#add_team-button").html("Add Team");
            $("#delete-button").html("Delete");
            // $("#add_team-button").html("Add Team")
            $("#delete-button").on("click", function(evt){  
                $.ajax({
                    type:'POST',
                    url:'/worksessions/' + event.id,
                    dataType: "json",
                    data: {"_method":"delete"},
                    success:function(){
                      //I assume you want to do something on controller action execution success?
                      $( "#eventContent" ).dialog( "close" );
                            alert("Deleted successfully");
                        },
                     error: function (err, data) {
                            alert("Error " + err.responseText);
                        }
                    });
                // evt.preventDefault();
                });
            
            $("#add_team-button").on("click", function(evt){  
              $("#All-Teams").dialog({
                     modal: true, 
                     title: "All Teams",
                  });
              $("#All-Teams").html('');
                var users = $("#all_users").data("users");
                for (var i = 0; i < users.length; i++) {
                  var user = users[i];
                  var url = '/worksessions/' + event.id +'/' + user['id'] + '/add_team';
                  var team_name = '<p><strong><a href=' + url + '>' + user['team_name'] + ' </a></strong>';
                  $("#All-Teams").append(team_name);
                }
                evt.preventDefault();
                });
            $("#Notes-Button").on("click", function(){  

                $("#All-Notes").dialog({
                     modal: true, 
                     title: "All Notes for this Worksession",
                  });
                $("#All-Notes").html('');
                var team_notes = event.team_notes;
                for (var team_name in team_notes) {
                  var notes = team_notes[team_name]
                  if (notes != null && /\S/.test(notes)) {
                    var team_div = '<p><strong><div>' + team_name + ' </div></strong>';
                    var Notes= '<div>' + notes + '</div></p>'; 
                    $("#All-Notes").append(team_div);
                    $("#All-Notes").append(Notes);
                  }
                }
                  

                });

            
        return false;
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
  $("#view_calendar").fullCalendar({
    header: {
                 left: "prev,next today",
                 center: "title",
                 right: 'month,agendaWeek,agendaDay'
             },

    defaultView: $.cookie('fullcalendar_defaultView2') || 'agendaWeek',
    defaultDate: $.cookie('fullcalendar_defaultDay2') || null, 
    slotMinutes: 30,
    contentHeight: 'auto',
    events: "/worksessions/view.json",
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
        $("#eventContent").dialog({ modal: true, title: "Worksession"});
        return false
    },

    

  });
});

