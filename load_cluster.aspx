<!-- #Include virtual="include/connect_to_db.inc" -->
<%

dim page_title = "Select Group"
Const back_button = "true"

dim cluster_id = Request.QueryString("cluster_id")

' store variables here
dim cluster_name, rs, SQL

' create a recordset
rs = Server.CreateObject("ADODB.Recordset")

' query database
SQL = "select top 1 type_name from smgp_cluster_type where cluster_type_id = " & cluster_id & " order by type_name"
rs.open(SQL, conn)

' loop through query results
While Not rs.EOF

	  cluster_name = rs("type_name")
	  page_title = cluster_name.value
  
	rs.MoveNext
End While

rs.close


%>
<!-- #Include virtual="include/header.inc" -->

<div class="page_content_container">

<h2>Select Group</h2>

<ul data-role="listview">

<%

' query database
    SQL = "select smgp_group_cluster.cluster_name, smgp_group_cluster.cluster_level, smgp_group_cluster.group_cluster_id, smgp_group_cluster.cluster_type_id, smgp_group_cluster.parent_cluster_id, smgp_cluster_level.allow_groups from smgp_group_cluster inner join smgp_cluster_level on smgp_group_cluster.cluster_type_id = smgp_cluster_level.cluster_type_id where smgp_group_cluster.cluster_level = smgp_cluster_level.cluster_level and (smgp_group_cluster.cluster_level = 1 or smgp_group_cluster.cluster_level = 0) and smgp_group_cluster.cluster_type_id = " & cluster_id & " order by smgp_group_cluster.cluster_level, smgp_group_cluster.cluster_name"
    
rs.open(SQL, conn)

dim smaller_cluster_name, group_cluster_id, cluster_level, cluster_type_id, num_of_members, get_num_of_members_query, parent_cluster_id, search_for_level, allow_groups

' loop through query results
While Not rs.EOF

	smaller_cluster_name = rs("cluster_name")
	group_cluster_id = rs("group_cluster_id")
	cluster_level = rs("cluster_level")
	cluster_type_id = rs("cluster_type_id")
	parent_cluster_id = rs("parent_cluster_id")
	allow_groups = rs("allow_groups")

	call generate_group_row(group_cluster_id, cluster_level, smaller_cluster_name, cluster_type_id, group_cluster_id, allow_groups, conn)

	'check for groups assigned under this group
	search_for_level = 2
	
	' find all sub groups under this top group
	If cluster_level.value > 0
		call generate_child_levels(group_cluster_id, search_for_level, conn)
	End If
	
	rs.MoveNext
End While
rs.close

%>

</ul>

</div>

<script language="vb" runat="server">
	
	' recursively display each group starting at provided parent_cluster_id
	Sub generate_child_levels(parent_cluster_id, search_for_level, conn)

		dim child_rs = Server.CreateObject("ADODB.Recordset")
	
		' query database
		'dim SQL = "select cluster_name, cluster_level, group_cluster_id, cluster_type_id, parent_cluster_id from smgp_group_cluster where cluster_level = " & search_for_level & " and parent_cluster_id = " & parent_cluster_id.value & " order by cluster_name"
		dim SQL = "select smgp_group_cluster.cluster_name, smgp_group_cluster.cluster_level, smgp_group_cluster.group_cluster_id, smgp_group_cluster.cluster_type_id, smgp_group_cluster.parent_cluster_id, smgp_cluster_level.allow_groups from smgp_group_cluster inner join smgp_cluster_level on smgp_group_cluster.cluster_type_id = smgp_cluster_level.cluster_type_id where smgp_group_cluster.cluster_level = smgp_cluster_level.cluster_level and smgp_group_cluster.cluster_level = " & search_for_level & " and smgp_group_cluster.parent_cluster_id = " & parent_cluster_id.value & " order by smgp_group_cluster.cluster_name"
		child_rs.open(SQL, conn)

		dim child_smaller_cluster_name, child_group_cluster_id, child_cluster_level, child_cluster_type_id, child_num_of_members, child_get_num_of_members_query, child_parent_cluster_id, child_search_for_level, allow_groups

		' loop through query results
		While Not child_rs.EOF

			child_smaller_cluster_name = child_rs("cluster_name")
			child_group_cluster_id = child_rs("group_cluster_id")
			child_cluster_level = child_rs("cluster_level")
			child_cluster_type_id = child_rs("cluster_type_id")
			child_parent_cluster_id = child_rs("parent_cluster_id")
			allow_groups = child_rs("allow_groups")

			call generate_group_row(child_group_cluster_id, child_cluster_level, child_smaller_cluster_name, child_cluster_type_id, child_group_cluster_id, allow_groups, conn)

			'check for groups assigned under this group
			search_for_level = search_for_level + 1
			
			If child_cluster_level.value > 0
				call generate_child_levels(child_group_cluster_id, search_for_level, conn)
			End If
			
			child_rs.MoveNext
		End While

		child_rs.close

	
	End Sub
	
	Sub generate_group_row(group_id, cluster_level, smaller_cluster_name, cluster_type_id, group_cluster_id, allow_groups, conn)
		response.write("<li>")
		
		' output proper spacing to display hierarchy correctly; subtraction so level 0 and 1 appear on same level
		Dim number_of_spaces = (cluster_level.value - 2) * 2

		' select button (based on level)
        If cluster_level.value = 0 And allow_groups.value = False Then
            Response.Write("<a href=""checkin.aspx?gid=" & cluster_type_id.value & "&level=" & cluster_level.value & "&allow_groups=" & allow_groups.value & """>")
        End If
        
        If cluster_level.value = 0 And allow_groups.value = True Then
            Response.Write("<a href=""checkin.aspx?gid=" & group_cluster_id.value & "&level=" & cluster_level.value & "&allow_groups=" & allow_groups.value & """>")
        End If
        
        'REMOVE TOP TWO IF STATEMENTS IF PROBLEMS; THEY WERE ADDED AS FIX TO GET UNION WORKING
        'If cluster_level.value = 0 And allow_groups.value = False Then
        '   Response.Write("<a href=""checkin.aspx?gid=" & cluster_type_id.value & "&level=" & cluster_level.value & "&allow_groups=" & allow_groups.value & """>")
        'End If
        
        If cluster_level.value > 0 Then
            Response.Write("<a href=""checkin.aspx?gid=" & group_cluster_id.value & "&level=" & cluster_level.value & "&allow_groups=" & allow_groups.value & """>")
        End If
		
        For i = 0 To number_of_spaces Step 1
            Response.Write("&nbsp;&nbsp;")
        Next
		
        ' bold name if level 0 or 1
        If cluster_level.value = 0 Or cluster_level.value = 1 Then
            Response.Write("<span class=""bold"">")
        End If
		
        'output cluster name
        If cluster_level.value = 0 And allow_groups.value = "False" Then
            Response.Write("Everyone")
        Else
            Response.Write(smaller_cluster_name.value)
        End If
		
        ' close bold if level 0 or 1
        If cluster_level.value = 0 Or cluster_level.value = 1 Then
            Response.Write("</span>")
        End If
		
        ' query to get total number of members in given section (determined by level)
        Dim get_num_of_members_query
		
        If cluster_level.value = 0 And allow_groups.value = "False" Then
            get_num_of_members_query = "select COUNT (*) as total_members from core_person INNER JOIN smgp_member ON smgp_member.person_id = core_person.person_id INNER JOIN smgp_group ON smgp_member.group_id = smgp_group.group_id INNER JOIN smgp_group_cluster ON smgp_group.group_cluster_id = smgp_group_cluster.group_cluster_id INNER JOIN smgp_cluster_type ON smgp_cluster_type.cluster_type_id = smgp_group_cluster.cluster_type_id INNER JOIN core_occurrence_type ON core_occurrence_type.sync_with_group = smgp_member.group_id WHERE smgp_cluster_type.cluster_type_id = " & cluster_type_id.value
        ElseIf allow_groups.value = "False" Then
            get_num_of_members_query = "select COUNT (*) as total_members from core_person INNER JOIN smgp_member ON smgp_member.person_id = core_person.person_id INNER JOIN smgp_group ON smgp_member.group_id = smgp_group.group_id INNER JOIN smgp_group_cluster ON smgp_group.group_cluster_id = smgp_group_cluster.group_cluster_id INNER JOIN smgp_cluster_type ON smgp_cluster_type.cluster_type_id = smgp_group_cluster.cluster_type_id INNER JOIN core_occurrence_type ON core_occurrence_type.sync_with_group = smgp_member.group_id WHERE smgp_group_cluster.parent_cluster_id = " & group_cluster_id.value
        ElseIf allow_groups.value = "True" Then
            get_num_of_members_query = "select COUNT (*) as total_members from core_person INNER JOIN smgp_member ON smgp_member.person_id = core_person.person_id INNER JOIN smgp_group ON smgp_member.group_id = smgp_group.group_id INNER JOIN smgp_group_cluster ON smgp_group.group_cluster_id = smgp_group_cluster.group_cluster_id INNER JOIN smgp_cluster_type ON smgp_cluster_type.cluster_type_id = smgp_group_cluster.cluster_type_id INNER JOIN core_occurrence_type ON core_occurrence_type.sync_with_group = smgp_member.group_id WHERE smgp_group_cluster.group_cluster_id = " & group_cluster_id.value
        End If
		
        Dim num_of_members = conn.execute(get_num_of_members_query)
        Response.Write("<span class=""ui-li-count"">" & num_of_members("total_members").value & "</span>")
		
        Response.Write("</li>")
		
	End Sub
	
</script>