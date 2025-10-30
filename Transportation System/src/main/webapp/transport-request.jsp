<%@ page import="java.sql.*" %>
<%@ page import="com.TransportationSystem.model.DBconnect" %>
<%@ page session="true" %>

<%
    String fullName = (String) session.getAttribute("employeeName");
    String employeeId = (String) session.getAttribute("employeeId");

    String department = "";
    if (fullName == null || employeeId == null) {
        response.sendRedirect("login.html");
        return;
    }

    try (Connection con = DBconnect.getConnection()) {
        PreparedStatement ps = con.prepareStatement("SELECT department FROM EmployeesRegistration WHERE employee_id = ?");
        ps.setString(1, employeeId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            department = rs.getString("department");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    String successMessage = (String) request.getAttribute("success");
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Transportation Request Form</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="icon" type="image/png" href="scdl.png">
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

    .form-container {
      margin: 40px auto;
      padding: 30px;
      max-width: 700px;
      background-color: #fff;
      border-radius: 8px;
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
  </style>
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
      <a class="nav-link me-3" href="TS-requestassignedTrips.jsp">Trips</a>
      <a class="nav-link" href="TS-logout.jsp">Logout</a>
    </div>
  </div>
</nav>

<div class="form-container">
  <h3 class="text-center mb-4">Transportation Request Form</h3>

  <% if (successMessage != null) { %>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
      <%= successMessage %>
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
  <% } %>

  <form action="submit-transport-request" method="post">
    <div class="row mb-3">
      <div class="col-md-6">
        <label class="form-label">Full Name</label>
        <input type="text" class="form-control" value="<%= fullName %>" name="fullName" readonly>
      </div>
      <div class="col-md-6">
        <label class="form-label">Department</label>
        <input type="text" class="form-control" value="<%= department %>" name="department" readonly>
      </div>
    </div>

    <div class="row mb-3">
      <div class="col-md-6">
        <label class="form-label">Reason for Travel</label>
        <input type="text" class="form-control" name="reason" required placeholder="Enter reason">
      </div>
      <div class="col-md-6">
        <label class="form-label">Date</label>
        <input type="date" class="form-control" name="travelDate" required>
      </div>
    </div>

    <div class="row mb-3">
      <div class="col-md-6">
        <label class="form-label">Pickup Location</label>
        <input type="text" class="form-control" name="pickupLocation" required>
      </div>
      <div class="col-md-6">
        <label class="form-label">Drop Location</label>
        <input type="text" class="form-control" name="dropLocation" required>
      </div>
    </div>

    <div class="row mb-3">
      <div class="col-md-6">
        <label class="form-label">Pickup Time</label>
        <input type="time" class="form-control" name="pickupTime" required>
      </div>
      <div class="col-md-6">
        <label class="form-label">Return Time</label>
        <input type="time" class="form-control" name="returnTime" required>
      </div>
    </div>
    
    <div class="row mb-3">
        <div class="col-md-6">
            <label class="form-label">Number of Additional Employees</label>
            <input type="number" class="form-control" name="additionalEmployeesCount" placeholder="Enter count" min="0">
        </div>
        <div class="col-md-6">
            <label class="form-label">Remarks</label>
            <textarea class="form-control" name="remarks" rows="3" placeholder="Add any special instructions or remarks..."></textarea>
        </div>
    </div>
    
    <div class="d-grid mt-4">
      <button type="submit" class="btn btn-primary btn-lg">Submit Request</button>
    </div>
  </form>
</div>  

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>