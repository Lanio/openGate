<%@ Page aspcompat=true Debug="true" Language="VB" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!-- #Include virtual="include/connect_to_db.inc" -->

<%
	dim search_string = Request.Form("name").Replace(" ", string.empty) ' remove whitespace due to concatanation in sql query not having a space (fn concat function only takes two arguments; the new CONCAT() function can handle more I believe but is only available on SQL 2012+
	dim group_id = Request.Form("gid")
	dim level = Request.Form("level")
	dim allow_groups = Request.Form("allow_groups")
	dim open = Request.Form("open")
	
dim rs_grp_list = Server.CreateObject("ADODB.Recordset")	
dim rs_get_occurance = Server.CreateObject("ADODB.Recordset")
dim cluster_list_SQL, getOccSql
dim cluster_select, cluster_select_options, occurrence_id, occurrence_description

If open <> "0" Then ' if occurance is open

If level = 0 And allow_groups = "False"
	cluster_list_SQL = "select distinct smgp_group.group_id, smgp_group.group_name, core_occurrence_type.occurrence_type_id from core_person INNER JOIN smgp_member ON smgp_member.person_id = core_person.person_id INNER JOIN smgp_group ON smgp_member.group_id = smgp_group.group_id INNER JOIN smgp_group_cluster ON smgp_group.group_cluster_id = smgp_group_cluster.group_cluster_id INNER JOIN smgp_cluster_type ON smgp_cluster_type.cluster_type_id = smgp_group_cluster.cluster_type_id INNER JOIN core_occurrence_type ON core_occurrence_type.sync_with_group = smgp_member.group_id WHERE smgp_cluster_type.cluster_type_id = " & group_id & " ORDER BY smgp_group.group_name"
ElseIf allow_groups = "False"
	cluster_list_SQL = "select distinct smgp_group.group_id, smgp_group.group_name, core_occurrence_type.occurrence_type_id from core_person INNER JOIN smgp_member ON smgp_member.person_id = core_person.person_id INNER JOIN smgp_group ON smgp_member.group_id = smgp_group.group_id INNER JOIN smgp_group_cluster ON smgp_group.group_cluster_id = smgp_group_cluster.group_cluster_id INNER JOIN smgp_cluster_type ON smgp_cluster_type.cluster_type_id = smgp_group_cluster.cluster_type_id INNER JOIN core_occurrence_type ON core_occurrence_type.sync_with_group = smgp_member.group_id WHERE smgp_group_cluster.parent_cluster_id = " & group_id & " ORDER BY smgp_group.group_name"
ElseIf allow_groups = "True"
	cluster_list_SQL = "select distinct smgp_group.group_id, smgp_group.group_name, core_occurrence_type.occurrence_type_id from smgp_group INNER JOIN smgp_group_cluster ON smgp_group.group_cluster_id = smgp_group_cluster.group_cluster_id INNER JOIN smgp_cluster_type ON smgp_cluster_type.cluster_type_id = smgp_group_cluster.cluster_type_id INNER JOIN core_occurrence_type ON core_occurrence_type.sync_with_group = smgp_group.group_id WHERE smgp_group_cluster.group_cluster_id = " & group_id & " ORDER BY smgp_group.group_name" ' get all possible groups (is used when adding users from outside list)
End If

' construct select options for which occurance to check into
rs_grp_list.open(cluster_list_SQL, conn)
	While Not rs_grp_list.EOF
		' need to get occurance id from occurrence_type_id and include that in the select option instead
		getOccSql = "SELECT TOP 1 occurrence_id, occurrence_name, occurrence_description FROM core_occurrence WHERE occurrence_type = " & rs_grp_list("occurrence_type_id").value & " AND GETDATE() BETWEEN check_in_start AND check_in_end"
		rs_get_occurance.open(getOccSql, conn)
			If NOT rs_get_occurance.EOF Then
				occurrence_id = rs_get_occurance("occurrence_id")
				occurrence_description = rs_get_occurance("occurrence_description").value
				cluster_select_options = cluster_select_options & "<option value='" & occurrence_id.value & "'>" & occurrence_description & "</option>"			
			End If
		rs_get_occurance.close
		rs_grp_list.MoveNext
	End While
rs_grp_list.close

End If ' if open

' retrieve people
dim person_id, first_name, nick_name, last_name, repeat_name
dim birth_date as String
dim person_age as Integer
dim num_of_results = 0
dim rs_grp_name = Server.CreateObject("ADODB.Recordset")
dim PERSON_SQL = "SELECT TOP 400 * FROM core_person WHERE ({fn concat (first_name, last_name)} LIKE '%" & search_string & "%' OR {fn concat (nick_name, last_name)} LIKE '%" & search_string & "%') AND first_name != '' ORDER BY last_name, first_name"

%>
<ul data-role="listview">
<%

rs_grp_name.open(PERSON_SQL, conn)

	While Not rs_grp_name.EOF
		If first_name = rs_grp_name("first_name").value And last_name = rs_grp_name("last_name").value Then
			repeat_name = "1"
		Else
			repeat_name = "0"
		End If
		num_of_results = num_of_results + 1
		person_id = rs_grp_name("person_id").value
		first_name = rs_grp_name("first_name").value
		nick_name = rs_grp_name("nick_name").value
		last_name = rs_grp_name("last_name").value
		birth_date = rs_grp_name("birth_date").value
		cluster_select = "<select data-mini='true' data-inline='true' class='check_in_outside_of_group' data-person_name='" & last_name & ", " & nick_name & "' data-person_id='" & person_id & "'><option value=''>Check Into...</option>" & cluster_select_options & "</select>"
		%>
			<li>
				<div class="check_in_person outside_group">
					<%=last_name%>, <%=first_name%>
					<% If nick_name <> first_name Then %>
						(<%=nick_name%>)
					<% End If %>
					<% 
					If repeat_name = "1" Then 
						person_age = Math.Floor(DateDiff(DateInterval.Month, DateValue(birth_date), Now()) / 12)
						If person_age < 19 Then
						%>
						<span class="age_label">age <%=person_age%></span>
						<% End If %>
					<% End If %>
				</div>
				<div class="check_in_slider">
				
					<% If open = "0" Then %>
						<button data-icon="delete" disabled="disabled">Closed</button>
					<% Else %>
						<%=cluster_select%>
					<% End If %>
						
				</div>
				<div style="clear: both;"></div>
			</li>	
		<%
		rs_grp_name.MoveNext
	End While
	
	' if no users found
	If num_of_results < 1 Then %>
		<li><span class="searching_outside_group">Sorry, no people found matching your search.</span></li>
	<% End If	
	
	%>
	
	</ul>

	<%
rs_grp_name.close
	
	
%>


<%
'closes the connection
'rs.close
conn.close
'rs = Nothing
conn = Nothing

%>
