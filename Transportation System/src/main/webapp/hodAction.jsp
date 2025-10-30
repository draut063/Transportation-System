<%@ page import="java.sql.*" %>
<%@ page import="com.TransportationSystem.model.DBconnect" %>
<%@ page session="true" %>

<%
    String hodName = (String) session.getAttribute("employeeName");
    String department = (String) session.getAttribute("department");

    if (hodName == null || department == null) {
        response.sendRedirect("login.html");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html>
<head>
  <title>HOD Dashboard</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="website icon" type="png" href="scdl.png">
</head>
<body>
<div class="container mt-5">
  <h2 class="mb-4">Welcome HOD: <%= hodName %></h2>
  <h4>Pending Transport Requests</h4>

  <table class="table table-bordered table-hover">
    <thead>
      <tr>
        <th>Employee Name</th>
        <th>Reason</th>
        <th>Travel Date</th>
        <th>Pickup Time</th>
        <th>Return Time</th>
        <th>Action</th>
      </tr>
    </thead>
    <tbody>
<%
    try {
        con = DBconnect.getConnection();
        String sql = "SELECT * FROM TransportRequests WHERE department = ? AND request_status = 'Pending'";
        ps = con.prepareStatement(sql);
        ps.setString(1, department);
        rs = ps.executeQuery();

        while (rs.next()) {
%>
      <tr>
        <td><%= rs.getString("full_name") %></td>
        <td><%= rs.getString("reason") %></td>
        <td><%= rs.getDate("travel_date") %></td>
        <td><%= rs.getTime("pickup_time") %></td>
        <td><%= rs.getTime("return_time") %></td>
        <td>
          <form action="HODActionServlet" method="post" class="d-flex">
            <input type="hidden" name="requestId" value="<%= rs.getInt("request_id") %>">
            <input type="text" name="remarks" class="form-control me-2" placeholder="Add remarks" required>
            <button type="submit" name="action" value="Approve" class="btn btn-success btn-sm me-2">Approve</button>
            <button type="submit" name="action" value="Reject" class="btn btn-danger btn-sm">Reject</button>
          </form>
        </td>
      </tr>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
%>
    </tbody>
  </table>
</div>
</body>
</html>
