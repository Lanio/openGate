<!-- #Include virtual="include/header.inc" -->
<!-- #Include virtual="include/connect_to_db.inc" -->

<%
' get id for group being checked in
dim group_id = Request.QueryString("gid")
dim cluster_level = Request.QueryString("level")
dim allow_groups = Request.QueryString("allow_groups")
%>

<div id="page_container">

<center>

<div id="centeredcontent">
<img src="images/title.png"><br />
<img src="images/loading_circle.gif">
</div>

<script type="text/javascript">
displayCheckin(<%=group_id%>, <%=cluster_level%>, '<%=allow_groups%>');
</script>

</center>

</div>