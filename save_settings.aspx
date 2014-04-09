<%

dim opengate_directory = Server.MapPath(".")
dim section = Request.Form("section")

Select Case section
	Case "General"
	
		' get values to update file with
		dim require_access_code = Request.Form("require_access_code")
		dim numeric_access_code = Request.Form("numeric_access_code")
		dim show_closed_occurrences = Request.Form("show_closed_occurrences")
		dim admin_password = Request.Form("admin_password")

		dim fso = CreateObject("Scripting.FileSystemObject")
		dim f1 = fso.CreateTextFile(opengate_directory & "\config\general.dat", True)
		f1.WriteLine("require_access_code=" & require_access_code)
		f1.WriteLine("numeric_access_code=" & numeric_access_code)
		f1.WriteLine("show_closed_occurrences=" & show_closed_occurrences)
		f1.WriteLine("admin_password=" & admin_password)
		f1.Close
	
		Response.Write("general page hit")
		
	Case "Server"

		' get values to update file with
		dim server = Request.Form("server")
		dim database = Request.Form("database")
		dim username = Request.Form("username")
		dim password = Request.Form("password")

		dim fso = CreateObject("Scripting.FileSystemObject")
		dim f1 = fso.CreateTextFile(opengate_directory & "\config\server.dat", True)
		f1.WriteLine("server=" & server)
		f1.WriteLine("database=" & database)
		f1.WriteLine("username=" & username)
		f1.WriteLine("password=" & password)
		f1.Close
		
		response.write("Server Information Saved")

	Case Else
		Response.Write("Cannot Save - Invalid Page") 
End Select

%>