<%
Const page_title = "openGate"
Const back_button = "false"	
%>

<!-- #Include virtual="include/header.inc" -->
<!-- #Include virtual="include/connect_to_db.inc" -->

<div class="page_content_container">

<h2>Select Ministry</h2>

<%
' get id for group being checked in
dim group_id = Request.QueryString("gid")
%>

<ul data-role="listview">

<%


' store variables here
dim cluster_id, cluster_name, rs, SQL

' create a recordset
rs = Server.CreateObject("ADODB.Recordset")

' query database
SQL = "select cluster_type_id, type_name from smgp_cluster_type order by type_name"
rs.open(SQL, conn)

' loop through query results
While Not rs.EOF

  cluster_id = rs("cluster_type_id")
  cluster_name = rs("type_name")

%>

<li><a href="load_cluster.aspx?cluster_id=<%=cluster_id.value%>"><%=cluster_name.value%></a></li>

<%

	rs.MoveNext

End While

%>

</ul>

</div>

<!-- #Include virtual="include/footer.inc" -->