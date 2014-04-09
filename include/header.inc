<%@ Page aspcompat=true Debug="true" Language="VB" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

	<head>
	
		<title>openGate | Arena Checkin Application</title>
		<meta name="viewport" content="initial-scale=1.0,maximum-scale=1.0" >
		<link rel="icon" type="image/png" href="images/favicon.ico">
		<link rel="stylesheet" href="//code.jquery.com/mobile/1.3.2/jquery.mobile-1.3.2.min.css" />
		<script src="js/jquery-1.6.4.min.js"></script>
		<script src="//code.jquery.com/mobile/1.3.2/jquery.mobile-1.3.2.min.js"></script>
		<script type="text/javascript" src="js/jquery.liveready-1.0-min.js"></script>
		<link rel="stylesheet" type="text/css" href="css/style.css" />
		<link rel="stylesheet" type="text/css" href="//netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.min.css" />
		
		
		
		<script type="text/JavaScript">
		
			<!--
			
			$(document).ready(function() {
				$('.key_button').click(function() {
					if($(this).attr('id') == "del") { $('#access_code_entry').html( $('#access_code_entry').text().replace(/(\s+)?.$/, "") ); } 
					else if($(this).attr('id') == "key_button_enter") { login(); }
					else { $('#access_code_entry').append($(this).html()); }
				});
				
			});
			
			$(document).bind('pageinit', function () {
						
				$('.ui-input-text').keyup(function() {
					$('.search_outside_group_search_string').text(this.value);
					$('.search_outside_group_collapsible').trigger('collapse'); // collapse accordian containing results if running new search
					if(this.value) {
						$('.search_outside_group_container').show(); // show search more options if search text
					} else {
						$('.search_outside_group_container').hide(); // hide if no search text
					}
				} );
				
				$("div.search_outside_group_collapsible").delegate("select.check_in_outside_of_group", "change", function() {
					var occurrence_id = $(this).val();
					var option_name = $('option:selected', this).text();
					var person_id = $(this).data('person_id');
					var person_name = $(this).data('person_name');

					
						var div_id = Math.floor(Math.random()*99999999) + 999999 // random number will be at least over 1 million, serves as div_id for button (assuming list of people is < 1 million)
						$('.search_outside_group_container').hide(); //hide others outside group
						$('input[data-type="search"]').val("");	//reset filter to no search content
						$('input[data-type="search"]').trigger("change"); //update listview to match updated filter
						$('li.outside_group_label').show(); // show label
						$('ul#people_list').append('<li><div class="check_in_person">' + person_name + '<br /><span style="font-weight: 300; color: #919191;">'+option_name+'</span></div><div id="button_div_' + div_id + '" class="check_in_slider"><div data-theme="a" class="ui-btn ui-btn-icon-left ui-btn-corner-all ui-shadow ui-btn-up-a" aria-disabled="false"><span class="ui-btn-inner ui-btn-corner-all" aria-hidden="true"><span class="ui-btn-text">Check In</span><span class="ui-icon ui-icon-check ui-icon-shadow"></span></span><button class="add_record_button ui-btn-hidden" data-theme="a" data-icon="check" aria-disabled="false">Check In</button></div></div><div style="clear: both;"></div></li>').listview('refresh');
						$('.added_button').trigger("change");
						$("html, body").animate({ scrollTop: $(document).height() }, 0); //scroll to bottom where newly added person is					
						
						// add to num checked in
						var num_checked_in = $(".num_checked_in").html(); // retrieve current checked in
						var num_checked_in_numeric = num_checked_in.replace(/\D/g,'');
						num_checked_in_numeric++; // add one to total checked in
						num_checked_in = " ("+num_checked_in_numeric+")";
						$(".num_checked_in").html(num_checked_in); // update with new number	
					
					// add record to row
					$.ajax({
					  url: "add_attendance_record.aspx?occurrence_id=" + occurrence_id + "&person_id=" + person_id + "&outside_group=1",
					  context: document.body,
					  error: function(){
							alert('Could not add to group.');
							return false;
						},
					  success: function(){
					
							$("ul#people_list #button_div_" + div_id).html('<div data-theme="b" class="ui-btn ui-btn-icon-left ui-btn-corner-all ui-shadow ui-btn-up-b" aria-disabled="false" onclick="remove_attendance_record(\'' + occurrence_id + '\', \'' + person_id + '\', \'' + div_id + '\', \'1\')"><span class="ui-btn-inner ui-btn-corner-all" aria-hidden="true"><span class="ui-btn-text">Check In</span><span class="ui-icon ui-icon-check ui-icon-shadow"></span></span><button class="add_record_button ui-btn-hidden" data-theme="b" data-icon="check" aria-disabled="false">Check In</button></div>');

					  }
					});	
				});				
				
				$('.search_outside_group_collapsible').bind('expand', function() {
				
						$('.search_outside_group_results').html('<span class="searching_outside_group">Searching...</span>');
						
						var search_string = $('.search_outside_group_search_string:visible').text();
								
						$.ajax({
						  type: "POST",
						  url: "fetch_people.aspx",
						  data: ({
						  name: search_string,
						  gid: $(this).data('gid'),
						  level: $(this).data('level'),
						  allow_groups: $(this).data('allow_groups'),
						  open: $(this).data('open')
						  }),
						  cache: false,
						  dataType: "text",
						  success: populate_people
						});
                					
						
				});
				
			}); 
			
			function populate_people(data)
            {
                $('.search_outside_group_results').html(data);
				$('.search_outside_group_results').trigger("create"); // add jquery mobile styles
            }
			
			function login() {
				var access_code = $('#access_code_entry').html();
				alert('under construction code is ' + access_code);
			}
			
			function add_attendance_record(occurrence_id, person_id, div_id, outside_group) {
			
				$("#button_div_" + div_id).html('<i class="fa fa-check-square checkin_icon checkin_icon_selected"></i>');

				// add record to row
				$.ajax({
				  url: "add_attendance_record.aspx?occurrence_id=" + occurrence_id + "&person_id=" + person_id + "&outside_group=" + outside_group,
				  context: document.body,
				  error: function(){
				  
					// reset original button
					// $("#button_div_" + div_id).html("<img src=\"images/button_check_in.png\">");
				  
					
					$("#button_div_" + div_id).html('<i class="fa fa-check-square checkin_icon checkin_icon_unselected"></i>');
					
					// set so that if clicked again, it performs original action
					$("#button_div_" + div_id).unbind(); // clear previous click action so new action isn't simply added to previous
					$("#button_div_" + div_id).attr('onclick', '').click(
						function() { 
						add_attendance_record(occurrence_id, person_id, div_id, outside_group);
						}
					);
					
					alert('Network Connection Lost');

					},
				  success: function(response){
					
					// if closed, force refresh
					if(response == 'closed') { 
						$(".check_in_slider").html('Closed');
						$( "#closed" ).popup( "open");
						
					} else {
					
						// display new button
						$("#button_div_" + div_id).html('<i class="fa fa-check-square checkin_icon checkin_icon_selected"></i>');
					
						// set so that if clicked again, it performs opposite action
						$("#button_div_" + div_id).unbind(); // clear previous click action so new action isn't simply added to previous
						$("#button_div_" + div_id).attr('onclick', '').click(
							function() { 
							remove_attendance_record(occurrence_id, person_id, div_id, outside_group);
							}
						);
					  
						// add to num checked in
						var num_checked_in = $(".num_checked_in").html(); // retrieve current checked in
						var num_checked_in_numeric = num_checked_in.replace(/\D/g,'');
						num_checked_in_numeric = parseFloat(num_checked_in_numeric) + 1; // add one to total checked in
						num_checked_in = " ("+num_checked_in_numeric+")";
						$(".num_checked_in").html(num_checked_in); // update with new number
						
					}
					
				  }
				  
				});
				

				
			}
			
			function remove_attendance_record(occurrence_id, person_id, div_id, outside_group) {
														
				// display loading button
				$("#button_div_" + div_id).html('<i class="fa fa-check-square checkin_icon checkin_icon_unselected"></i>');

				// add record to row
				$.ajax({
				  url: "remove_attendance_record.aspx?occurrence_id=" + occurrence_id + "&person_id=" + person_id,
				  context: document.body,
				  error: function(){
				  
					// reset original button
					// $("#button_div_" + div_id).html("<img src=\"images/button_checked_in.png\">");
				  
					$("#button_div_" + div_id).html('<i class="fa fa-check-square checkin_icon checkin_icon_selected"></i>');
					
					// set so that if clicked again, it performs original action
					$("#button_div_" + div_id).unbind(); // clear previous click action so new action isn't simply added to previous
					$("#button_div_" + div_id).attr('onclick', '').click(
						function() { 
						remove_attendance_record(occurrence_id, person_id, div_id, outside_group);
						}
					);
					
					alert('Network Connection Lost');

					},
				  success: function(){				  

						var num_checked_in = $(".num_checked_in").html(); // retrieve current checked in
						var num_checked_in_numeric = num_checked_in.replace(/\D/g,'');
						num_checked_in_numeric = num_checked_in_numeric-1; // subtract one to total checked in
						num_checked_in = " ("+num_checked_in_numeric+")";
						$(".num_checked_in").html(num_checked_in); // update with new number
				  
						// display new button
						$("#button_div_" + div_id).html('<i class="fa fa-check-square checkin_icon checkin_icon_unselected"></i>');

						// set so that if clicked again, it performs opposite action
						$("#button_div_" + div_id).unbind(); // clear previous click action so new action isn't simply added to previous
						$("#button_div_" + div_id).attr('onclick', '').click(
							function() { 
								add_attendance_record(occurrence_id, person_id, div_id, outside_group); 
							}
						);
										  
				  }
				});
				
			}
			
			function goToByScroll(id) {
				$('html,body').animate({scrollTop: $("#"+id).offset().top-93},500);
				
				if(id == 'search_names') {
					$('div.page_content_container').find('input.ui-input-text').focus();
				}
				
			}
			
			function displayCheckin(cluster_id, cluster_level, allow_groups) {
				
				$("#page_container").load("checkin.aspx?gid=" + cluster_id + "&level=" + cluster_level + "&allow_groups=" + allow_groups, function(response, status, xhr) {
				  if (status == "error" && xhr.status != 0) {
					var error_msg = "<center><br /><br /><img src='images/abandon_ship.png' border='0'><br /><br /><span style='font-size: 22pt; color: #7C7C7C;'>Yarr, something has gone terribly wrong! (" + xhr.status + " " + xhr.statusText + ")</span><br /><br /><a href='javascript:history.go(0)'><img src='images/save_the_boat.png' border='0'></a></center>";
					$("#page_container").html(error_msg);
				  }
				  
				});
				
			}
						
			function loadCluster(cluster_id) {
				
				goToTop();
				
				$("#cluster_content_container").load("load_cluster.aspx?cluster_id=" + cluster_id, function(response, status, xhr) {
				  if (status == "error" && xhr.status != 0) {
					var error_msg = "<center><br /><br /><img src='images/abandon_ship.png' border='0'><br /><br /><span style='font-size: 22pt; color: #7C7C7C;'>Yarr, something has gone terribly wrong! (" + xhr.status + " " + xhr.statusText + ")</span><br /><br /><a href='javascript:history.go(0)'><img src='images/save_the_boat.png' border='0'></a></center>";
					$("#page_container").html(error_msg);
				  }
				});
				
			}
			
			function loadSettings(section) {
				
				goToTop();
				
				$("#cluster_content_container").load("load_settings.aspx?section=" + section, function(response, status, xhr) {
				  if (status == "error" && xhr.status != 0) {
					var error_msg = "<center><br /><br /><img src='images/abandon_ship.png' border='0'><br /><br /><span style='font-size: 22pt; color: #7C7C7C;'>Yarr, something has gone terribly wrong! (" + xhr.status + " " + xhr.statusText + ")</span><br /><br /><a href='javascript:history.go(0)'><img src='images/save_the_boat.png' border='0'></a></center>";
					$("#page_container").html(error_msg);
				  }
				});
				
			}
			
			function goToTop() {
				$('html,body').animate({scrollTop: $("#top").offset().top-43},'fast');
			}
			
			$('#save_server').click(function() {

				var section = $('#section').val();
				var server_address = $('#server_address').val();
				var database_name = $('#database_name').val();
				var database_user = $('#database_username').val();
				var database_password = $('#database_password').val();
				var confirm_database_password = $('#confirm_database_password').val();
			  
				if(database_password != confirm_database_password) { alert('Password and confirm password do not match'); } else {
				  
				$.post("save_settings.aspx", { section: section, server: server_address, database: database_name, username: database_user, password: database_password },
				function(data) {
					$('#save_settings_notice_green').show();
				});
			   
			   }
			  
			  return false; // don't try to reload page
			});
			
			$("#numeric_access_code").keydown(function(event) {
				// Allow only backspace and delete
				if ( event.keyCode == 46 || event.keyCode == 8 ) {
					// let it happen, don't do anything
				}
				else {
					// Ensure that it is a number and stop the keypress
					if ((event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
						event.preventDefault(); 
					}   
				}
			});
			
			$('#require_access_code_yes').click(function() {
				$('#numeric_access_code_container').show();
			});
			
	
			$('#require_access_code_no').click(function() {
				$('#numeric_access_code_container').hide();
			});
			
			$('#save_general').click(function() {

				var section = $('#section').val();
				var admin_password = $('#admin_password').val();
				var confirm_admin_password = $('#confirm_admin_password').val();
				var require_access_code = $('input[name=require_access_code]:checked').val();
				var numeric_access_code = $('#numeric_access_code').val();
				if(require_access_code == "no") { numeric_access_code = ""; }
				var show_closed_occurrences = $('input[name=show_closed_occurrences]:checked').val();
			  
				if(admin_password != confirm_admin_password) { alert('Admin password and confirm password do not match'); } else {
				  
				$.post("save_settings.aspx", { section: section, admin_password: admin_password, require_access_code: require_access_code, numeric_access_code: numeric_access_code, show_closed_occurrences: show_closed_occurrences },
				function(data) {
					$('#save_settings_notice_green').show();
				});
			   
			   }
			  
			  return false; // don't try to reload page
			});
			
			$('#settings_cancel').click(function() {
			  window.location = 'index.aspx';
			  return false; // don't try to reload page
			});


			//-->
			
		</script>

	</head>
	
	

	<%
		
	Dim lsPath, arPath, current_filename, body_class_name, num_checked_in_name
	lsPath = Request.ServerVariables("SCRIPT_NAME")
	arPath = Split(lsPath, "/")
	current_filename = arPath(UBound(arPath,1))

	If current_filename = "index.aspx" Or current_filename = "admin.aspx"
		body_class_name = "group_select"
	End If
	
	If current_filename = "checkin.aspx"
		num_checked_in_name = "num_checked_in"
	End If
	
	%>
	
	<body class="<%=body_class_name%>"><div id="top" style="display: hidden;"></div>
	
	<div data-role="page" data-add-back-btn="<%=back_button%>"> 
		
		<div data-role="header" data-position="fixed" data-tap-toggle="false">
			<h1><%=page_title%><span class="<%=num_checked_in_name%>"></span></h1>
			<a href="index.aspx" data-transition="fade" data-icon="home" class="ui-btn-right">Home</a>
		</div> 