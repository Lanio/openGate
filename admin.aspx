<!-- #Include virtual="include/header.inc" -->
<!-- #Include virtual="include/connect_to_db.inc" -->

<%
' get id for group being checked in
dim group_id = Request.QueryString("gid")
%>

<div class="left_entry_bar">

<%


' store variables here
dim cluster_name, rs, SQL

' create a recordset
rs = Server.CreateObject("ADODB.Recordset")

' query database
SQL = "select cluster_type_id, type_name from smgp_cluster_type order by type_name"
rs.open(SQL, conn)

%>

<div class="left_entry_bar_item" onClick="loadSettings('General');"><div class="left_entry_bar_item_text">General</div></div>
<div class="left_entry_bar_item" onClick="loadSettings('Server');"><div class="left_entry_bar_item_text">Server</div></div>

</div>

<div class="cluster_content_container" id="cluster_content_container">

<center><div class="please_select_category_text"><img src="images/title.png"><br />Please Select Category</div></center>

</div>

<!-- #Include virtual="include/footer.inc" -->