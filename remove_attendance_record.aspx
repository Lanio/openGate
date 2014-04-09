<%
Const page_title = "openGate"
Const back_button = "false"	
%>

<!-- #Include virtual="include/header.inc" -->
<!-- #Include virtual="include/connect_to_db.inc" -->

<%

dim occurrence_id = Request.QueryString("occurrence_id")
dim person_id = Request.QueryString("person_id")
dim rs, SQL

' create a recordset
rs = Server.CreateObject("ADODB.Recordset")

' query database
SQL = "DELETE FROM core_occurrence_attendance WHERE occurrence_id = " & occurrence_id & " AND person_id = " & person_id & " AND attended = 1 AND type = 1"
rs.open(SQL, conn)

%>

