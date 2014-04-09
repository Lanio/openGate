<%
Const page_title = "openGate"
Const back_button = "false"	

dim report_id = Request.QueryString("report_id")

%>

<%@ Page aspcompat=true Debug="true" Language="VB" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!-- #Include virtual="include/connect_to_db.inc" -->


<html>

<body>


<%

' store variables here
dim cluster_id, cluster_name, rs, rs2, rs3, SQL, people_sql, person_sql

' create a recordset
rs = Server.CreateObject("ADODB.Recordset")
rs2 = Server.CreateObject("ADODB.Recordset")
rs3 = Server.CreateObject("ADODB.Recordset")

' query database
SQL = "select * from list_save_reports WHERE report_id = " & report_id
rs.open(SQL, conn)

' loop through query results
While Not rs.EOF

people_sql = rs("report_query_text").value


	rs.MoveNext

End While

%>

<table border="1">

<%
' get people in list
rs2.open(people_sql, conn)

While Not rs2.EOF

' get information for person
person_sql = "select leader_personList.campus_name as leader_campus_id, core_v_personList.*, smgp_cluster_type.type_name, smgp_group_cluster.cluster_name, parent_cluster.cluster_name as group_campus_name, smgp_group.group_name from core_v_personList INNER JOIN smgp_member ON smgp_member.person_id = core_v_personList.person_id INNER JOIN smgp_group ON smgp_member.group_id = smgp_group.group_id INNER JOIN smgp_group_cluster ON smgp_group.group_cluster_id = smgp_group_cluster.group_cluster_id INNER JOIN smgp_cluster_type ON smgp_cluster_type.cluster_type_id = smgp_group_cluster.cluster_type_id INNER JOIN smgp_group_cluster parent_cluster ON smgp_group_cluster.parent_cluster_id = parent_cluster.group_cluster_id INNER JOIN core_v_personList leader_personList ON leader_personList.person_id = smgp_group.leader_person_id where core_v_personList.person_id = " & rs2("person_id").value

rs3.open(person_sql, conn)

While Not rs3.EOF

%>

<tr>
<td><%=rs3("nick_name").value%></td>
<td><%=rs3("last_name").value%></td>
<td><%=rs3("campus_name").value%></td>
<td><%=rs3("home_phone").value%></td>
<td><%=rs3("cell_phone").value%></td>
<td><%=rs3("email").value%></td>
<td><%=rs3("cluster_name").value%></td>
<td><%=rs3("group_name").value%></td>
<td><%=rs3("type_name").value%></td>
<td><%=rs3("leader_campus_id").value%></td>
<td><%=rs3("group_campus_name").value%></td>
</tr>

<%

			rs3.MoveNext

		End While
		
		rs3.close

	rs2.MoveNext

End While

rs2.close

%>

</body>
</html>