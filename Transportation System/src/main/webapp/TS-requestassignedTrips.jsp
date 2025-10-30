<%@ page import="java.sql.*" %>
<%@ page import="com.TransportationSystem.model.DBconnect" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page session="true" %>

<%
    String fullName = (String) session.getAttribute("employeeName");
    String employeeId = (String) session.getAttribute("employeeId");

    if (fullName == null || employeeId == null) {
        response.sendRedirect("login.html");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Assigned Trips</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <style>
    body {
      background-color: #f8f9fa;
      font-family: Arial, sans-serif;
    }
    .navbar-custom {
      background-color: transparent !important;
      border-bottom: 1px solid #000;
      height: 70px;
    }
    .navbar-center {
      position: absolute;
      left: 50%;
      top: 50%;
      transform: translate(-50%, -50%);
      display: flex;
      align-items: center;
    }
    .navbar-center img {
      height: 50px;
      margin-right: 10px;
    }
    .navbar-title {
      font-size: 1.1rem;
      font-weight: bold;
      color: #000;
      white-space: nowrap;
    }
    /* Updated styling for the form container */
    .form-container {
      margin: 40px auto;
      padding: 30px;
      /* Removed max-width to let the container size to its content */
      background-color: #fff;
      border-radius: 8px;
     /* box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); */
      width: fit-content; /* Adjusts the width to fit the content */
      min-width: 500px; /* Optional: Sets a minimum width for better layout */
    }
    .navbar-custom .nav-link {
      color: #000;
      font-weight: bold;
    }
    .navbar-custom .nav-link:hover {
      text-decoration: underline;
    }
    .navbar-end-links {
      display: flex;
      align-items: center;
    }
    /* Removed table-responsive-custom to prevent horizontal scrolling */
    .table-striped tbody tr:nth-of-type(odd) {
      background-color: #f9f9f9;
    }
  </style>
   <link rel="icon" type="image/png" href="scdl.png">
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-custom">
  <div class="container-fluid position-relative">
    <div class="d-flex align-items-center">
      <span class="nav-link">Welcome, <%= fullName %></span>
    </div>
    <div class="navbar-center">
      <img src="scdl.png" alt="SCDL Logo">
      <span class="navbar-title">Symbiosis Centre for Distance Learning</span>
    </div>
    <div class="navbar-end-links">
      <a class="nav-link me-3" href="transport-request.jsp">Request Form</a>
      <a class="nav-link" href="TS-logout.jsp">Logout</a>
    </div>
  </div>
</nav>

<div class="form-container">
  <h3 class="text-center mb-4">Your Assigned Trips</h3>

  <table class="table table-striped table-bordered">
    <thead>
      <tr>
        <th>Sr. No.</th>
        <th>Date</th>
        <th>Pickup Location</th>
        <th>Drop Location</th>
        <th>Pickup Time</th>
        <th>Return Time</th>
        <th>Status</th>
        <th>Assigned Car</th>
        <th>Driver Name</th>
        <th>Driver Phone</th>
      </tr>
    </thead>
    <tbody>
      <% 
        boolean hasTrips = false;
        int srNo = 1;
        
        // Define date and time formatters
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
        
        try (Connection con = DBconnect.getConnection()) {
            String sql = "SELECT at.assignment_id, tr.reason, tr.travel_date, tr.pickup_location, tr.drop_location, tr.pickup_time, tr.return_time, " +
                         "at.trip_status AS status, v.vehicle_number, v.vehicle_name, d.full_name AS driver_name, d.mobile_number AS driver_phone " +
                         "FROM AssignedTrips AS at " +
                         "INNER JOIN TransportRequests AS tr ON at.request_id = tr.request_id " +
                         "INNER JOIN Drivers AS d ON at.driver_id = d.driver_id " +
                         "INNER JOIN Vehicles AS v ON at.vehicle_id = v.vehicle_id " +
                         "WHERE tr.full_name = ? AND at.trip_status = 'Assigned'";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, fullName);
            ResultSet rs = ps.executeQuery();
            
            while(rs.next()) {
                hasTrips = true;
                
                // Retrieve and format the Date and Time objects
                Date travelDate = rs.getDate("travel_date");
                Time pickupTime = rs.getTime("pickup_time");
                Time returnTime = rs.getTime("return_time");
                
                String formattedDate = (travelDate != null) ? dateFormat.format(travelDate) : "N/A";
                String formattedPickupTime = (pickupTime != null) ? timeFormat.format(pickupTime) : "N/A";
                String formattedReturnTime = (returnTime != null) ? timeFormat.format(returnTime) : "N/A";
      %>
      <tr>
        <td><%= srNo++ %></td>
        <td><%= formattedDate %></td>
        <td><%= rs.getString("pickup_location") %></td>
        <td><%= rs.getString("drop_location") %></td>
        <td><%= formattedPickupTime %></td>
        <td><%= formattedReturnTime %></td>
        <td><%= rs.getString("status") %></td>
        <td><%= rs.getString("vehicle_name") %> (<%= rs.getString("vehicle_number") %>)</td>
        <td><%= rs.getString("driver_name") %></td>
        <td><%= rs.getString("driver_phone") %></td>
      </tr>
      <%
            }
        } catch (Exception e) {
            e.printStackTrace();
      %>
      <tr>
        <td colspan="10" class="text-center text-danger">An error occurred while fetching trip details.</td>
      </tr>
      <%
        }
      %>
    </tbody>
  </table>
  
  <% if (!hasTrips) { %>
    <div class="alert alert-info text-center mt-4">
      You have no assigned trips at the moment.
    </div>
  <% } %>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>