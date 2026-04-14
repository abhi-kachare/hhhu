<%-- 
    Document   : testdb
    Created on : 03-Mar-2026, 3:55:47 pm
    Author     : abhishek
--%>



<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DatabaseMetaData" %>
<%@ page import="util.DBConnection" %>

<!DOCTYPE html>
<html>
<head>
    <title>Database Connection Test</title>
    <style>
        body {
            font-family: Arial;
            background-color: #f4f4f4;
            text-align: center;
            padding-top: 50px;
        }
        .box {
            background: white;
            padding: 30px;
            width: 500px;
            margin: auto;
            border-radius: 8px;
            box-shadow: 0 0 10px #ccc;
        }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>

<div class="box">
<%
    Connection con = null;
    try {
        con = DBConnection.getConnection();
        DatabaseMetaData meta = con.getMetaData();
%>
        <h2 class="success">Database Connected Successfully</h2>
        <p><strong>Database:</strong> <%= meta.getDatabaseProductName() %></p>
        <p><strong>Version:</strong> <%= meta.getDatabaseProductVersion() %></p>
        <p><strong>URL:</strong> <%= meta.getURL() %></p>
<%
    } catch (Exception e) {
%>
        <h2 class="error">Database Connection Failed</h2>
        <p><%= e.getMessage() %></p>
<%
    } finally {
        if (con != null) {
            try { con.close(); } catch (Exception ignore) {}
        }
    }
%>
</div>

</body>
</html>