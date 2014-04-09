<%

dim db_server, db_database, db_username, db_password ' config for server
dim require_access_code, numeric_access_code, show_closed_occurrences, admin_password ' config for general
dim fs, f, word_array ' general variables

fs=Server.CreateObject("Scripting.FileSystemObject")
f=fs.OpenTextFile(Server.MapPath("config\server.dat"),1,false)
	db_server=f.ReadLine
	db_database=f.ReadLine
	db_username=f.ReadLine
	db_password=f.ReadLine
f.Close
f=Nothing
fs=Nothing

word_array = Split(db_server, "=")
db_server = word_array(1)

word_array = Split(db_database, "=")
db_database = word_array(1)

word_array = Split(db_username, "=")
db_username = word_array(1)

word_array = Split(db_password, "=")
db_password = word_array(1)

fs=Server.CreateObject("Scripting.FileSystemObject")
f=fs.OpenTextFile(Server.MapPath("config\general.dat"),1,false)
	require_access_code=f.ReadLine
	numeric_access_code=f.ReadLine
	show_closed_occurrences=f.ReadLine
	admin_password=f.ReadLine
f.Close
f=Nothing
fs=Nothing

word_array = Split(require_access_code, "=")
require_access_code = word_array(1)

word_array = Split(numeric_access_code, "=")
numeric_access_code = word_array(1)

word_array = Split(show_closed_occurrences, "=")
show_closed_occurrences = word_array(1)

word_array = Split(admin_password, "=")
admin_password = word_array(1)

dim conn
conn=server.CreateObject("adodb.connection")
conn.Open("Provider=sqloledb;SERVER=TYPE_SERVER_NAME_HERE;DATABASE=TYPE_DB_NAME_HERE; User ID=TYPE_USER_ID_HERE;PWD=TYPE_PASSWORD_HERE;Trusted_Connection=no;")

%>