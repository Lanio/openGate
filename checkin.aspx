<!-- #Include virtual="include/connect_to_db.inc" -->

<%

dim page_title = "Check In"
Const back_button = "true"
dim num_checked_in = 0

' detect if mobile (iOS devices, at time of writing (9.20.11), do not support fixed positions well and this is a workaround)
Dim user_agent, mobile_browser, isIpad, isIpod, mobile_name_width
Dim show_nav = 1
Dim nav_top_margin = " style=""margin-top: 45px;"""
mobile_browser = 0
user_agent = Request.ServerVariables("HTTP_USER_AGENT")
isIpad = InStr(user_agent, "iPad")
isIpod = InStr(user_agent, "iPod")

If isIpad > 0
	mobile_browser = isIpad 
End If

If isIpod > 0
	mobile_browser = isIpod
	mobile_name_width = " style=""width: 180px;"""
	nav_top_margin = " style=""margin-top: 0px;"""
	show_nav = 0
End If

' get id for group being checked in
dim group_id = Request.QueryString("gid")
dim level = Request.QueryString("level")
dim allow_groups = Request.QueryString("allow_groups")

' define variables
dim rs, SQL, getOccSql
dim person_id, person_first_name, person_last_name, person_group_id, group_name, group_cluster_id, cluster_name, cluster_type_id, cluster_type_name, occurrence_type_id, occurrence_type_name

dim occurrence_id, occurrence_id_value
dim occurrence_id_where_statement = ""
dim occurrence_id_dictionary = CreateObject("Scripting.Dictionary")

dim current_occurrence_id_array_result
dim id_for_current_row = 0
dim previously_used_alphabet_letter = ""
dim person_name_first_letter = ""
dim list_of_used_letters = ""
dim title_cluster_name = ""
dim num_of_occurances
dim any_open = "0" 'detemrine if any occurances are open; defaults to no (0)

' retrieve cluster name
dim rs_grp_name = Server.CreateObject("ADODB.Recordset")
dim CLUSTER_NAME_SQL = "SELECT TOP 1 cluster_name FROM smgp_group_cluster WHERE group_cluster_id = " & group_id

rs_grp_name.open(CLUSTER_NAME_SQL, conn)
	While Not rs_grp_name.EOF
		title_cluster_name = rs_grp_name("cluster_name").value
		page_title = title_cluster_name
		rs_grp_name.MoveNext
	End While
rs_grp_name.close

%>

<!-- #Include virtual="include/header.inc" -->


<div class="page_content_container"<%=nav_top_margin%>>
<div style="display: hidden;" id="search_names"></div>

<ul id="people_list" data-role="listview" data-filter="true">

<%

' create a recordset
rs = Server.CreateObject("ADODB.Recordset")

' query database for specific level
If level = 0 And allow_groups = "False"
	SQL = "select core_person.person_id, core_person.first_name, core_person.nick_name, core_person.last_name, smgp_member.group_id, smgp_group.group_name, smgp_group.group_cluster_id, smgp_group_cluster.cluster_type_id, smgp_cluster_type.type_name, core_occurrence_type.occurrence_type_id, core_occurrence_type.type_name from core_person INNER JOIN smgp_member ON smgp_member.person_id = core_person.person_id INNER JOIN smgp_group ON smgp_member.group_id = smgp_group.group_id INNER JOIN smgp_group_cluster ON smgp_group.group_cluster_id = smgp_group_cluster.group_cluster_id INNER JOIN smgp_cluster_type ON smgp_cluster_type.cluster_type_id = smgp_group_cluster.cluster_type_id INNER JOIN core_occurrence_type ON core_occurrence_type.sync_with_group = smgp_member.group_id WHERE smgp_cluster_type.cluster_type_id = " & group_id & " ORDER BY core_person.last_name, core_person.first_name"
ElseIf allow_groups = "False"
	SQL = "select core_person.person_id, core_person.first_name, core_person.nick_name, core_person.last_name, smgp_member.group_id, smgp_group.group_name, smgp_group.group_cluster_id, smgp_group_cluster.cluster_type_id, smgp_cluster_type.type_name, core_occurrence_type.occurrence_type_id, core_occurrence_type.type_name from core_person INNER JOIN smgp_member ON smgp_member.person_id = core_person.person_id INNER JOIN smgp_group ON smgp_member.group_id = smgp_group.group_id INNER JOIN smgp_group_cluster ON smgp_group.group_cluster_id = smgp_group_cluster.group_cluster_id INNER JOIN smgp_cluster_type ON smgp_cluster_type.cluster_type_id = smgp_group_cluster.cluster_type_id INNER JOIN core_occurrence_type ON core_occurrence_type.sync_with_group = smgp_member.group_id WHERE smgp_group_cluster.parent_cluster_id = " & group_id & " ORDER BY core_person.last_name, core_person.first_name"
ElseIf allow_groups = "True"
	SQL = "select core_person.person_id, core_person.first_name, core_person.nick_name, core_person.last_name, smgp_member.group_id, smgp_group.group_name, smgp_group.group_cluster_id, smgp_group_cluster.cluster_type_id, smgp_cluster_type.type_name, core_occurrence_type.occurrence_type_id, core_occurrence_type.type_name from core_person INNER JOIN smgp_member ON smgp_member.person_id = core_person.person_id INNER JOIN smgp_group ON smgp_member.group_id = smgp_group.group_id INNER JOIN smgp_group_cluster ON smgp_group.group_cluster_id = smgp_group_cluster.group_cluster_id INNER JOIN smgp_cluster_type ON smgp_cluster_type.cluster_type_id = smgp_group_cluster.cluster_type_id INNER JOIN core_occurrence_type ON core_occurrence_type.sync_with_group = smgp_member.group_id WHERE smgp_group_cluster.group_cluster_id = " & group_id & " ORDER BY core_person.last_name, core_person.first_name"
End If

rs.open(SQL, conn)

' loop through query results
While Not rs.EOF

  person_id = rs("person_id")
  person_first_name = rs("nick_name") 'using nick_name instead of first_name
  person_last_name = rs("last_name")
  person_group_id = rs("group_id")
  group_name = rs("group_name")
  group_cluster_id = rs("group_cluster_id")
  cluster_type_id = rs("cluster_type_id")
  cluster_type_name = rs("type_name")
  occurrence_type_id = rs("occurrence_type_id")
  occurrence_type_name = rs("type_name")
  
  ' check first letter of value and see if anchor tag is needed
  person_name_first_letter = Left(person_last_name.value, 1)
  
  If person_name_first_letter <> previously_used_alphabet_letter Then
    response.write("<div style=""display: hidden;""	id=""" & person_name_first_letter & """></div>")
	response.write("<li data-role=""list-divider"" role=""heading"">" & person_name_first_letter & "</li>")
	previously_used_alphabet_letter = person_name_first_letter
	list_of_used_letters = list_of_used_letters & ", " & person_name_first_letter
  End If
  
  ' check for open occurance for group
  dim rs2 = Server.CreateObject("ADODB.Recordset")
  dim rs3 = Server.CreateObject("ADODB.Recordset")
    
  dim occSqlNum = "SELECT COUNT(*) as occurrences_returned FROM core_occurrence WHERE occurrence_type = " & occurrence_type_id.value & " AND GETDATE() BETWEEN check_in_start AND check_in_end"
  rs3.open(occSqlNum, conn)

  While Not rs3.EOF

	  num_of_occurances = rs3("occurrences_returned")

	'If num_of_occurances.value <> "0" Then
	  
	  response.write("<li>")
	  	  
	  response.write("<div class=""check_in_person""" & mobile_name_width & ">" & person_last_name.value & ", " & person_first_name.value & "<span class='cluster_name_container' style=""font-weight: 300; color: #919191;""><br />" & cluster_type_name.value & "</span></div>")
		  
		  If (num_of_occurances.value = "0") Then
			'response.write("closed")
			%>
			
			<div class="check_in_slider">
				Closed
			</div>
			<div style="clear: both;"></div>
			
			<%		
		  Else

			' limit to only one opened occurance (other opened occurances will be ignored)
			  getOccSql = "SELECT TOP 1 occurrence_id FROM core_occurrence WHERE occurrence_type = " & occurrence_type_id.value & " AND GETDATE() BETWEEN check_in_start AND check_in_end"

			  rs2.open(getOccSql, conn)

			  While Not rs2.EOF

				  occurrence_id = rs2("occurrence_id")
				  occurrence_id_value = rs2("occurrence_id").value
			
					If Not occurrence_id_dictionary.Exists(occurrence_id_value) Then
						occurrence_id_dictionary.Add(occurrence_id_value, occurrence_id_value)
					End If

					any_open = "1"		  
				  'check if attendance already stored for user
				  dim checked_in_query_num
				  dim rs4 = Server.CreateObject("ADODB.Recordset")
				  dim checked_in_query = "SELECT COUNT(*) as rows_returned FROM core_occurrence_attendance WHERE occurrence_id = " & occurrence_id.value & " AND person_id = " & person_id.value & " AND attended = 1 AND type = 1"
				  rs4.open(checked_in_query, conn)
				  checked_in_query_num = rs4("rows_returned")

				  If (checked_in_query_num.value > 0) Then
					num_checked_in = num_checked_in + 1 ' record total number of checked in
				  %>
					<div id="button_div_<%=id_for_current_row%>" class="check_in_slider">
						<a class="add_record_button" data-theme="b" onClick="remove_attendance_record('<%=occurrence_id.value%>', '<%=person_id.value%>', '<%=id_for_current_row%>')" data-icon="check"><i class="fa fa-check-square checkin_icon checkin_icon_selected"></i></a>
					</div>
					<div style="clear: both;"></div>
				  <%
					'response.write("<div style=""cursor:pointer;"" id=""button_div_" & id_for_current_row & """ onClick=""remove_attendance_record('" & occurrence_id.value & "', '" & person_id.value & "', '" & id_for_current_row & "')"">check in</div>")
				  
				  Else
					%>
					
					<div id="button_div_<%=id_for_current_row%>" class="check_in_slider">
						<a onClick="add_attendance_record('<%=occurrence_id.value%>', '<%=person_id.value%>', '<%=id_for_current_row%>');"><i class="fa fa-check-square checkin_icon checkin_icon_unselected"></i></a>
					</div>
					<div style="clear: both;"></div>
					<%
					'response.write("<div style=""cursor:pointer;"" id=""button_div_" & id_for_current_row & """ onClick=""add_attendance_record('" & occurrence_id.value & "', '" & person_id.value & "', '" & id_for_current_row & "')"">checked in</div>")
					
				  End If
				  
				  id_for_current_row = id_for_current_row + 1
				  
				rs2.MoveNext
			  End While
		  
			'End If
			
	End If
	
    rs3.MoveNext
  End While
    
	response.write("</li>")
		
  rs.MoveNext

End While

' prepare where statement so when checking for users not in group, all applicable occurrence_id values can be checked
For Each unique_occurrence_id in occurrence_id_dictionary.Keys
	If occurrence_id_where_statement <> "" Then ' include "OR" if previous occurrence statement present
		occurrence_id_where_statement = occurrence_id_where_statement & " OR" 
	End If
    occurrence_id_where_statement = occurrence_id_where_statement & " core_occurrence_attendance.occurrence_id = " & unique_occurrence_id
Next

If occurrence_id_where_statement <> "" Then

' check for users checked in who are not part of group (checks by notes section being equal to 'openGate Checkin (Outside Group)'
dim checked_in_outside_group_sql = "SELECT TOP 1000 * FROM core_occurrence_attendance INNER JOIN core_occurrence ON core_occurrence_attendance.occurrence_id = core_occurrence.occurrence_id INNER JOIN core_person ON core_person.person_id = core_occurrence_attendance.person_id WHERE (" & occurrence_id_where_statement & ") AND core_occurrence_attendance.notes = 'openGate Checkin (Outside Group)' ORDER BY core_person.last_name, core_person.first_name"
dim checked_in_outside_group_rs = Server.CreateObject("ADODB.Recordset")
checked_in_outside_group_rs.open(checked_in_outside_group_sql, conn)

' loop through query results
dim outside_group_person_id, outside_person_first_name, outside_person_nick_name, outside_person_last_name, outside_group_occurrence_id, outside_group_occurrence_label
dim outside_person_sql
dim outside_person_rs = Server.CreateObject("ADODB.Recordset")
dim outside_group_label_displayed = "0" 'default is hide
dim outside_group_div_id

While Not checked_in_outside_group_rs.EOF

	' show/hide outside group label by default
	If outside_group_label_displayed = "0" Then ' show outside group label if not yet shown (this is within the block that makes sure there's an outside person also selected)
		outside_group_label_displayed = "1" %>
		<li class="outside_group_label" data-role="list-divider">Outside Group</li>
	<% End If

	outside_group_person_id = checked_in_outside_group_rs("person_id").value
	outside_group_occurrence_id = checked_in_outside_group_rs("occurrence_id").value
	outside_group_occurrence_label = checked_in_outside_group_rs("occurrence_description").value
	num_checked_in = num_checked_in + 1 ' include people outside group in total number of checked in
	outside_person_first_name = checked_in_outside_group_rs("first_name").value
	outside_person_nick_name = checked_in_outside_group_rs("nick_name").value
	outside_person_last_name = checked_in_outside_group_rs("last_name").value
	outside_group_div_id = Int((Rnd * 999) + 99999) ' div id, higher than range of what's expected for main list so as to not interfere
	%>
	
			<li>
				<div class="check_in_person"><%=outside_person_last_name%>, <%=outside_person_nick_name%><br /><span style="font-weight: 300; color: #919191;"><%=outside_group_occurrence_label%></span></div>
				<div id="button_div_<%=outside_group_div_id%>" class="check_in_slider">
					<button class="add_record_button" data-theme="b" onClick="remove_attendance_record('<%=outside_group_occurrence_id%>', '<%=outside_group_person_id%>', '<%=outside_group_div_id%>', '1')" data-icon="check">Check In</button>
				</div>
				<div style="clear: both;"></div>
			</li>
		
		<%
	checked_in_outside_group_rs.MoveNext
End While

%>

	<% 
		If outside_group_label_displayed = "0" Then %><li class="outside_group_label hide" data-role="list-divider">Outside Group</li><% End If ' if outside group label not previously placed, hide it at the end for access to show if any outside group people are added
	%>

<% End If %>
	
</ul>

</div>

<%
If show_nav = 1
%>

<div data-role="navbar" class="alphabet_nav">
<div data-role="controlgroup" data-type="horizontal">
<a href="#" onClick="goToByScroll('search_names');" data-role="button" data-icon="search" data-iconpos="notext" title="Search">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>
<%

dim used_letters_array = Split(list_of_used_letters, ", ")

For Each item In used_letters_array
	If item <> "" Then
		Response.Write("<a href=""#"" onClick=""goToByScroll('" & item & "');" & """>" & item & "</a> ")
	End If
Next

%>

<a href="#" onClick="window.location.reload();" data-role="button" data-icon="refresh" data-iconpos="notext" title="Update">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>

</div>

</div>

<%
End If
%>

<div class="search_outside_group_container">
	<div class="search_outside_group_collapsible" data-role="collapsible" data-theme="c" data-content-theme="d" data-gid="<%=group_id%>" data-level="<%=level%>" data-allow_groups="<%=allow_groups%>" data-open="<%=any_open%>">
	   <h3>Search for "<span class="search_outside_group_search_string"></span>" outside of group...</h3>
	   
			<span class="search_outside_group_results"></span>
	   
	</div>
</div>

<div id="closed" data-role="popup" id="popupDialog" data-overlay-theme="a" data-theme="c" data-dismissible="false" style="max-width:400px;" class="ui-corner-all">
    <div data-role="header" data-theme="a" class="ui-corner-top">
        <h1>Service Closed</h1>
    </div>
    <div data-role="content" data-theme="d" class="ui-corner-bottom ui-content">
        <h3 class="ui-title">Sorry, this service is no longer open.  Click below to update your view.</h3>
        <center><a href="#" data-role="button" data-inline="true" data-theme="b" onClick="window.location.reload();">Update</a></center>
    </div>
</div>

<script>

if($('.search_outside_group_search_string').text() == '') { $('.search_outside_group_container').hide(); } // if no filter text (first load), hide filter button (this causes issues if it's in the main JS section)

$('div').live('pageshow',function(event, ui){
  $(".num_checked_in").html(" (<%=num_checked_in%>)"); // update with checked in number
});
				
</script>

<!-- #Include virtual="include/footer.inc" -->