<%@ Page aspcompat=true Debug="true" Language="VB" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%
Const page_title = "openGate"
Const back_button = "false"	
%>
<!-- #Include virtual="include/connect_to_db.inc" -->
<%

dim occurrence_id = Request.QueryString("occurrence_id")
dim person_id = Request.QueryString("person_id")
dim outside_group = Request.QueryString("outside_group")
dim records_found
dim closed_warning = ""

' get occurrence details for open occurrence
dim rs3 = Server.CreateObject("ADODB.Recordset")
dim is_closed, check_in_start, check_in_end
dim occurrence_details = "SELECT * FROM core_occurrence WHERE occurrence_id = " & occurrence_id & " AND GETDATE() BETWEEN check_in_start AND check_in_end"
rs3.open(occurrence_details, conn)

' if occurrence exists
If NOT rs3.EOF Then

	' check if attendance already exists (prevent duplicates)
	dim rs2 = Server.CreateObject("ADODB.Recordset")
	dim recordSqlNum = "SELECT * FROM core_occurrence_attendance WHERE occurrence_id = " & occurrence_id & " AND person_id = " & person_id & " AND attended = 1 AND type = 1"
	rs2.open(recordSqlNum, conn)

	' if not already existing, add
	If rs2.EOF = true Then
	
		' create a recordset
		dim rs = Server.CreateObject("ADODB.Recordset")

		' determine note (note is what check in uses to determine if there are users from outside the group checked in
		dim note
		If outside_group = "1" Then
		note = "openGate Checkin (Outside Group)"
		Else
		note = "openGate Checkin"
		End If

		' query database
		dim SQL = "INSERT INTO core_occurrence_attendance (occurrence_id, person_id, check_in_time, notes, attended, type) VALUES (" & occurrence_id & ", " & person_id & ", getdate(),'" & note & "', 1, 1)"
		rs.open(SQL, conn)
		
	End If
	
' if occurrence not found (most likely means closed)
Else

	Response.Write("closed")

End If

rs3.close

%>