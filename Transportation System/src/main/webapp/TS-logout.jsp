<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Logging Out...</title>
</head>
<body>

<%
    // Get the current session
    HttpSession sessionObj = request.getSession(false);

    if (sessionObj != null) {
        // Invalidate the session to remove all user data
        sessionObj.invalidate();
    }
    
    // Redirect the user back to the login page
    response.sendRedirect("login.html");
%>

</body>
</html>