<!-- #Include virtual="include/header.inc" -->
<!-- #Include virtual="include/connect_to_db.inc" -->

<%

dim section = Request.QueryString("section")

' store variables here
dim cluster_name, rs, SQL

' create a recordset
rs = Server.CreateObject("ADODB.Recordset")
%>

<span class="cluster_title_text"><%=section%></span><br />

<%
Select Case section
	Case "General"
%>
<div id="save_settings_notice_green" class="notice_green">
	Saved Successfully
</div>
<form>
  <fieldset>
	<%
	dim require_access_code_yes_checked, require_access_code_no_checked, access_code_display
	If (require_access_code = "yes") Then
		require_access_code_yes_checked = " checked"
		require_access_code_no_checked = ""
		access_code_display = ""
	ElseIf (require_access_code = "no") Then
		require_access_code_yes_checked = ""
		require_access_code_no_checked = " checked"
		access_code_display = " display: none;"
	End If
	%>
		<div class="setting_row">
			<div class="setting_label"><label for="require_access_code">Require Access Code</label></div>
			<div class="setting_response">
				<input id="require_access_code_yes" name="require_access_code" type="radio" class="radio" value="yes"<%=require_access_code_yes_checked%>> <label for="require_access_code_yes">Yes</label>
				<input id="require_access_code_no" name="require_access_code" type="radio" class="radio" value="no"<%=require_access_code_no_checked%> style="margin-left: 20px;"> <label for="require_access_code_no">No</label><br />
			</div>
			<div class="clear_both"></div>
			<div id="numeric_access_code_container" style="margin-top: 20px;<%=access_code_display%>">
				<div class="setting_label"><label for="numeric_access_code">Numeric Access Code</label></div>
				<div class="setting_response"><input id="numeric_access_code" name="numeric_access_code" type="text" class="setting_text" style="width: 40px;" maxlength="5" value="<%=numeric_access_code%>" /></div>
			</div>
			<div class="clear_both"></div>
		</div>		
	<%
	dim show_closed_occurrences_yes_checked, show_closed_occurrences_no_checked
	If (show_closed_occurrences = "yes") Then
		show_closed_occurrences_yes_checked = " checked"
		show_closed_occurrences_no_checked = ""
	ElseIf (show_closed_occurrences = "no") Then
		show_closed_occurrences_yes_checked = ""
		show_closed_occurrences_no_checked = " checked"
	End If
	%>
		<div class="setting_row">
			<div class="setting_label"><label>Show Closed Occurrences</label></div>
			<div class="setting_response">
				<input id="closed_occurrences_yes" name="show_closed_occurrences" type="radio" class="radio" value="yes"<%=show_closed_occurrences_yes_checked%>> <label for="closed_occurrences_yes">Yes</label>
				<input id="closed_occurrences_no" name="show_closed_occurrences" type="radio" class="radio" value="no"<%=show_closed_occurrences_no_checked%> style="margin-left: 20px;"> <label for="closed_occurrences_no">No</label><br />
			</div>
			<div class="clear_both"></div>
		</div>
		
		<div class="setting_row">
			<div class="setting_label"><label for="admin_password">Admin Password</label></div>
			<div class="setting_response">
				<input id="admin_password" name="admin_password" type="password" class="setting_text" value="<%=admin_password%>" />
			</div><br /><br />
			<div class="clear_both"></div>
			<div class="setting_label"><label for="confirm_admin_password">Confirm Admin Password</label></div>
			<div class="setting_response"><input id="confirm_admin_password" name="confirm_admin_password" type="password" class="setting_text" value="<%=admin_password%>" /></div>
			<div class="clear_both"></div>
		</div>
				
		<div class="setting_row" style="text-align: center;">
			<input type="hidden" id="section" name="section" value="<%=section%>">
			<button type="button" id="save_general">Save Changes</button>
			<button type="button" id="settings_cancel">Cancel</button>
		</div>
		
  </fieldset>
</form>
<%
	Case "Server"
%>
<div id="save_settings_notice_green" class="notice_green">
	Saved Successfully
</div>
<form>
  <fieldset>
		<div class="setting_row">
			<div class="setting_label"><label for="server_address">Database Server Address</label></div>
			<div class="setting_response"><input id="server_address" name="server_address" type="text" class="setting_text" value="<%=db_server%>" /></div>
			<div class="clear_both"></div>
		</div>
		
		<div class="setting_row">
			<div class="setting_label"><label for="database_name">Database Name</label></div>
			<div class="setting_response"><input id="database_name" name="database_name" type="text" class="setting_text" value="<%=db_database%>" /></div>
			<div class="clear_both"></div>
		</div>
		
		<div class="setting_row">
			<div class="setting_label"><label for="database_username">Database Username</label></div>
			<div class="setting_response"><input id="database_username" name="database_username" type="text" class="setting_text" value="<%=db_username%>" /></div>
			<div class="clear_both"></div>
		</div>
		
		<div class="setting_row">
			<div class="setting_label"><label for="database_password">Database Password</label></div>
			<div class="setting_response"><input id="database_password" name="database_password" type="password" class="setting_text" value="<%=db_password%>" /></div>
			<div class="clear_both"></div>
		</div>

		<div class="setting_row">
			<div class="setting_label"><label for="confirm_database_password">Confirm Database Password</label></div>
			<div class="setting_response"><input id="confirm_database_password" name="confirm_database_password" type="password" class="setting_text" value="<%=db_password%>" /></div>
			<div class="clear_both"></div>
		</div>
		
		<div class="setting_row" style="text-align: center;">
			<input type="hidden" id="section" name="section" value="<%=section%>">
			<button type="button" id="save_server">Save Changes</button>
			<button type="button" id="settings_cancel">Cancel</button>
		</div>
		
  </fieldset>
</form>
<%
	Case Else
		Response.Write("Invalid") 
End Select

%>