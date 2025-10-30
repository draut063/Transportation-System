<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.TransportationSystem.model.DBconnect" %>
<%@ page session="true" %>
<%
    String fullName = (String) session.getAttribute("employeeName");
    if (fullName == null) {
        response.sendRedirect("login.html");
        return;
    }
    String view = request.getParameter("view");
    if (view == null) {
        view = "triprequests";
    }
    String status = request.getParameter("status");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>TS-Admin DashBoard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link rel="website icon" type="png" href="scdl.png">
    <style>
        body {
            background-color: #f8f9fa;
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
        .navbar-custom .nav-link, .navbar-custom .navbar-text {
            color: #000;
            font-weight: bold;
        }
        .sidebar {
            background-color: #e9ecef;
            min-height: 100vh;
            padding-top: 20px;
        }
        .sidebar-link {
            display: block;
            padding: 10px 15px;
            color: #495057;
            text-decoration: none;
            font-weight: bold;
            border-radius: 5px;
        }
        .sidebar-link.active, .sidebar-link:hover {
            background-color: #007bff;
            color: #fff;
        }
        .main-content {
            padding: 20px;
        }
        .profile-pic {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #000;
        }
        table {
            table-layout: fixed;
            width: 100%;
        }
        td, th {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
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
    <div class="ms-auto d-flex align-items-center">
      <a class="nav-link" href="TS-logout.jsp">Logout</a>
    </div>
  </div>
</nav>

<div class="container-fluid">
    <div class="row">
        <div class="col-md-2 sidebar">
            <h5 class="mb-4">Transportation System</h5>
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a class="sidebar-link <%= "triprequests".equals(view) ? "active" : "" %>" href="SystemAdminpage.jsp?view=triprequests">Assign Trip</a>
                </li>
                <li class="nav-item">
                    <a class="sidebar-link <%= "assignedtrips".equals(view) ? "active" : "" %>" href="SystemAdminpage.jsp?view=assignedtrips">Ongoing Trips</a>
                </li>
                <li class="nav-item">
                    <a class="sidebar-link <%= "drivers".equals(view) ? "active" : "" %>" href="SystemAdminpage.jsp?view=drivers">Drivers</a>
                </li>
                <li class="nav-item">
                    <a class="sidebar-link <%= "vehicles".equals(view) ? "active" : "" %>" href="SystemAdminpage.jsp?view=vehicles">Vehicles</a>
                </li>
                <li class="nav-item">
                    <a class="sidebar-link <%= "logs".equals(view) ? "active" : "" %>" href="SystemAdminpage.jsp?view=logs">View Logs</a>
                </li>
                <li class="nav-item">
                    <a class="sidebar-link <%= "accidents".equals(view) ? "active" : "" %>" href="SystemAdminpage.jsp?view=accidents">Accident Logs</a>
                </li>
            </ul>
        </div>

        <div class="col-md-10 main-content">
            <% 
                if ("success".equals(status)) { 
                    String message = request.getParameter("message") != null ? request.getParameter("message") : "Success!";
            %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <strong>Success!</strong> <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } else if ("error".equals(status)) { 
                    String message = request.getParameter("message") != null ? request.getParameter("message") : "An error occurred.";
            %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <strong>Error!</strong> <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <% if ("triprequests".equals(view)) { %>
                <h3>Assign Trip</h3>
                <%
                    boolean hasRequests = false;
                    Connection con = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;
                    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy");
                    DateTimeFormatter timeFormat = DateTimeFormatter.ofPattern("hh:mm a");
                    try {
                        con = DBconnect.getConnection();
                        String sqlRequests = "SELECT * FROM TransportRequests WHERE request_status = 'Approved' AND travel_date >= CAST(GETDATE() AS DATE)";
                        ps = con.prepareStatement(sqlRequests);
                        rs = ps.executeQuery();
                        while (rs.next()) {
                            hasRequests = true;
                            LocalDate travelDate = rs.getDate("travel_date").toLocalDate();
                            LocalTime pickupTime = LocalTime.parse(rs.getString("pickup_time"));
                            LocalTime returnTime = LocalTime.parse(rs.getString("return_time"));
                %>
                <form action="AssignTripServlet" method="post" class="row g-3 mt-3 assign-trip-form" data-travel-date="<%= travelDate.toString() %>">
                    <div class="col-12 border p-3 rounded shadow-sm mb-4">
                        <input type="hidden" name="requestId" value="<%= rs.getInt("request_id") %>">
                        <input type="hidden" name="travel_date" value="<%= travelDate.toString() %>">
                        <div class="row mb-2">
                            <div class="col-md-6">
                                <strong>Name:</strong> <%= rs.getString("full_name") %>
                            </div>
                            <div class="col-md-6">
                                <strong>Date:</strong> <span class="travel-date"><%= travelDate.format(dateFormat) %></span>
                            </div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-md-6">
                                <strong>Pickup Location:</strong> <%= rs.getString("pickup_location") %>
                            </div>
                            <div class="col-md-6">
                                <strong>Drop Location:</strong> <%= rs.getString("drop_location") %>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong>Pickup Time:</strong> <%= pickupTime.format(timeFormat) %>
                            </div>
                            <div class="col-md-6">
                                <strong>Return Time:</strong> <%= returnTime.format(timeFormat) %>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong>Number of Additional Employees:</strong> <%= rs.getInt("additional_employees_count") %>
                            </div>
                            <div class="col-md-6">
                                <strong>Remarks:</strong> <%= rs.getString("remarks") != null ? rs.getString("remarks") : "N/A" %>
                            </div>
                        </div>
                        <div class="row mt-3">
                            <div class="col-md-4">
                                <label>Vehicle</label>
                                <select name="vehicleId" class="form-select" required>
                                    <option value="">Select Vehicle</option>
                                    <%
                                        Connection conn = null;
                                        PreparedStatement vps = null;
                                        ResultSet vrs = null;
                                        try {
                                            conn = DBconnect.getConnection();
                                            String vehiclesSql = "SELECT V.vehicle_id, V.vehicle_name, V.vehicle_number, V.capacity " +
                                                    "FROM Vehicles V " +
                                                    "LEFT JOIN AssignedTrips AT ON V.vehicle_id = AT.vehicle_id AND AT.trip_status = 'Assigned' " +
                                                    "WHERE V.IsActive = 1 AND (V.IsAvailable = 1 OR V.capacity > (SELECT COUNT(AT2.assignment_id) FROM AssignedTrips AT2 WHERE AT2.vehicle_id = V.vehicle_id AND AT2.trip_status = 'Assigned')) " +
                                                    "GROUP BY V.vehicle_id, V.vehicle_name, V.vehicle_number, V.capacity " +
                                                    "ORDER BY V.vehicle_name                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      ";
                                            vps = conn.prepareStatement(vehiclesSql);
                                            vrs = vps.executeQuery();
                                            while (vrs.next()) {
                                    %>
                                                <option value="<%= vrs.getInt("vehicle_id") %>">
                                                    <%= vrs.getString("vehicle_name") %> - <%= vrs.getString("vehicle_number") %>
                                                </option>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                    %>
                                                <option value="" disabled>Error loading vehicles</option>
                                    <%
                                        } finally {
                                            try { if (vrs != null) vrs.close(); } catch (SQLException e) {}
                                            try { if (vps != null) vps.close(); } catch (SQLException e) {}
                                            try { if (conn != null) conn.close(); } catch (SQLException e) {}
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label>Driver</label>
                                <select name="driverId" class="form-select" required>
                                    <option value="">Select Driver</option>
                                    <%
                                        Connection conn2 = null;
                                        PreparedStatement dps = null;
                                        ResultSet drs = null;
                                        try {
                                            conn2 = DBconnect.getConnection();
                                            String driversSql = "SELECT D.driver_id, D.full_name, D.mobile_number, V.capacity FROM Drivers D "
                                                    + "LEFT JOIN AssignedTrips AT ON D.driver_id = AT.driver_id AND AT.trip_status = 'Assigned' "
                                                    + "LEFT JOIN Vehicles V ON AT.vehicle_id = V.vehicle_id "
                                                    + "WHERE D.IsActive = 1 AND (D.IsAvailable = 1 OR (V.capacity > (SELECT COUNT(AT2.assignment_id) FROM AssignedTrips AT2 WHERE AT2.driver_id = D.driver_id AND AT2.trip_status = 'Assigned'))) "
                                                    + "GROUP BY D.driver_id, D.full_name, D.mobile_number, V.capacity "
                                                    + "ORDER BY D.full_name";                                            dps = conn2.prepareStatement(driversSql);
                                            drs = dps.executeQuery();
                                            while (drs.next()) {
                                    %>
                                                <option value="<%= drs.getInt("driver_id") %>">
                                                    <%= drs.getString("full_name") %> - <%= drs.getString("mobile_number") %>
                                                </option>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                    %>
                                                <option value="" disabled>Error loading drivers</option>
                                    <%
                                        } finally {
                                            try { if (drs != null) drs.close(); } catch (SQLException e) {}
                                            try { if (dps != null) dps.close(); } catch (SQLException e) {}
                                            try { if (conn2 != null) conn2.close(); } catch (SQLException e) {}
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label>Assigned Time</label>
                                <input type="time" name="assignedTime" class="form-control" required>
                            </div>
                        </div>
                        <div class="mt-3">
                            <button type="submit" class="btn btn-success">Assign Trip</button>
                        </div>
                    </div>
                </form>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                %>
                    <div class="alert alert-danger">Error loading trip requests.</div>
                <%
                    } finally {
                        try { if (rs != null) rs.close(); } catch (SQLException e) {}
                        try { if (ps != null) ps.close(); } catch (SQLException e) {}
                        try { if (con != null) con.close(); } catch (SQLException e) {}
                    }
                    if (!hasRequests) {
                %>
                    <div class="alert alert-info mt-3">No Assign Trip requests are currently pending.</div>
                <%
                    }
                %>
            <% } else if ("assignedtrips".equals(view)) { %>
                <h3>Ongoing Trips</h3>
                <div class="table-responsive">
                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                                <th>Trip ID</th>
                                <th>Requestor Name</th>
                                <th>Driver</th>
                                <th>Vehicle</th>
                                <th>Assigned Date</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conAssigned = null;
                                PreparedStatement psAssigned = null;
                                ResultSet rsAssigned = null;
                                DateTimeFormatter dateTimeFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy hh:mm a");
                                try {
                                    conAssigned = DBconnect.getConnection();
                                    String sqlAssigned = "SELECT AT.assignment_id, TR.full_name AS requestor_name, D.full_name AS driver_name, V.vehicle_name, AT.assigned_on, AT.trip_status FROM AssignedTrips AT JOIN TransportRequests TR ON AT.request_id = TR.request_id JOIN Drivers D ON AT.driver_id = D.driver_id JOIN Vehicles V ON AT.vehicle_id = V.vehicle_id WHERE AT.trip_status = 'Assigned'";
                                    psAssigned = conAssigned.prepareStatement(sqlAssigned);
                                    rsAssigned = psAssigned.executeQuery();
                                    
                                    boolean hasAssignedTrips = false;
                                    while (rsAssigned.next()) {
                                        hasAssignedTrips = true;
                            %>
                            <tr>
                                <td><%= rsAssigned.getInt("assignment_id") %></td>
                                <td><%= rsAssigned.getString("requestor_name") %></td>
                                <td><%= rsAssigned.getString("driver_name") %></td>
                                <td><%= rsAssigned.getString("vehicle_name") %></td>
                                <td><%= rsAssigned.getTimestamp("assigned_on").toLocalDateTime().format(dateTimeFormat) %></td>
                                <td><span class="badge bg-primary"><%= rsAssigned.getString("trip_status") %></span></td>
                                <td>
                                    <form action="CompleteTripServlet" method="post" onsubmit="return confirm('Are you sure you want to mark this trip as complete?');">
                                        <input type="hidden" name="assignmentId" value="<%= rsAssigned.getInt("assignment_id") %>">
                                        <button type="submit" class="btn btn-success btn-sm">Complete Trip</button>
                                    </form>
                                </td>
                            </tr>
                            <%
                                    }
                                    if (!hasAssignedTrips) {
                            %>
                            <tr><td colspan="7" class="text-center">No ongoing trips found.</td></tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                            %>
                                <tr><td colspan="7" class="text-danger">Error loading assigned trips.</td></tr>
                            <%
                                } finally {
                                    try { if (rsAssigned != null) rsAssigned.close(); } catch (SQLException e) {}
                                    try { if (psAssigned != null) psAssigned.close(); } catch (SQLException e) {}
                                    try { if (conAssigned != null) conAssigned.close(); } catch (SQLException e) {}
                                }
                            %>
                        </tbody>
                    </table>
                </div>

            <% } else if ("drivers".equals(view)) { %>
                <h3>Drivers</h3>
                <div class="table-responsive">
                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Employee ID</th>
                                <th>Email</th>
                                <th>Mobile</th>
                                <th>Blood Group</th>
                                <th>License</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conDrivers = null;
                                Statement stDrivers = null;
                                ResultSet rsDrivers = null;
                                try {
                                    conDrivers = DBconnect.getConnection();
                                    stDrivers = conDrivers.createStatement();
                                    rsDrivers = stDrivers.executeQuery("select * from Drivers where IsActive=1;");
                                    while (rsDrivers.next()) {
                            %>
                            <tr>
                                <td><%= rsDrivers.getString("full_name") %></td>
                                <td><%= rsDrivers.getString("emp_id") %></td>
                                <td><%= rsDrivers.getString("email") %></td>
                                <td><%= rsDrivers.getString("mobile_number") %></td>
                                <td><%= rsDrivers.getString("blood_group") %></td>
                                <td><a href="<%= rsDrivers.getString("license_photo_path") %>" target="_blank">View License</a></td>
                                <td>
                                    <%= rsDrivers.getBoolean("IsAvailable") ?
                                    "<span class='badge bg-success'>Available</span>" : "<span class='badge bg-warning text-dark'>On Trip</span>" %>
                                </td>
                                <td>
                                    <form action="DeleteDriverServlet" method="post" class="d-inline" onsubmit="return confirm('Are you sure you want to delete this driver?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="driverId" value="<%= rsDrivers.getInt("driver_id") %>">
                                        <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                                    </form>
                                </td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                            %>
                            <tr><td colspan="8" class="text-danger">Error loading driver data.</td></tr>
                            <%
                                } finally {
                                    try { if (rsDrivers != null) rsDrivers.close(); } catch (SQLException e) {}
                                    try { if (stDrivers != null) stDrivers.close(); } catch (SQLException e) {}
                                    try { if (conDrivers != null) conDrivers.close(); } catch (SQLException e) {}
                                }
                            %>
                        </tbody>
                    </table>
                </div>

            <% } else if ("vehicles".equals(view)) { %>
                <h3>Vehicles</h3>
                <ul class="nav nav-tabs mb-3">
                    <li class="nav-item">
                        <a class="nav-link <%= "check".equals(request.getParameter("action")) || request.getParameter("action") == null ? "active" : "" %>"
                           href="SystemAdminpage.jsp?view=vehicles&action=check">Check Vehicles</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link <%= "add".equals(request.getParameter("action")) ? "active" : "" %>"
                           href="SystemAdminpage.jsp?view=vehicles&action=add">Add Vehicle</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link <%= "info".equals(request.getParameter("action")) ? "active" : "" %>"
                           href="SystemAdminpage.jsp?view=vehicles&action=info">Vehicle Info</a>
                    </li>
                </ul>
                <%
                    String action = request.getParameter("action");
                    if (action == null || "check".equals(action)) {
                %>
                    <div class="table-responsive">
                        <table class="table table-striped table-bordered">
                            <thead>
                                <tr>
                                    <th>Vehicle Name</th>
                                    <th>Vehicle Number</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    Connection conVehicles = null;
                                    Statement stVehicles = null;
                                    ResultSet rsVehicles = null;
                                    try {
                                        conVehicles = DBconnect.getConnection();
                                        stVehicles = conVehicles.createStatement();
                                        rsVehicles = stVehicles.executeQuery("Select * from Vehicles where IsActive=1");
                                        while (rsVehicles.next()) {
                                %>
                                <tr>
                                    <td><%= rsVehicles.getString("vehicle_name") %></td>
                                    <td><%= rsVehicles.getString("vehicle_number") %></td>
                                    <td>
                                        <%= rsVehicles.getBoolean("IsAvailable") ?
                                        "<span class='badge bg-success'>Available</span>" : "<span class='badge bg-warning text-dark'>On Trip</span>" %>
                                    </td>
                                    <td>
                                        <a href="SystemAdminpage.jsp?view=vehicles&action=info&vehicleId=<%= rsVehicles.getInt("vehicle_id") %>" class="btn btn-info btn-sm">
                                            View Info
                                        </a>
                                        <button type="button" class="btn btn-warning btn-sm"
                                                data-bs-toggle="modal" data-bs-target="#updateVehicleModal"
                                                data-id="<%= rsVehicles.getInt("vehicle_id") %>"
                                                data-vehicle-name="<%= rsVehicles.getString("vehicle_name") %>"
                                                data-vehicle-number="<%= rsVehicles.getString("vehicle_number") %>"
                                                data-capacity="<%= rsVehicles.getInt("capacity") %>"
                                                data-insurance-policy-number="<%= rsVehicles.getString("insurance_policy_number") %>"
                                                data-insurance-expiry-date="<%= rsVehicles.getString("insurance_expiry_date") %>"
                                                data-puc-certificate-number="<%= rsVehicles.getString("puc_certificate_number") %>"
                                                data-puc-expiry-date="<%= rsVehicles.getString("puc_expiry_date") %>"
                                                data-other-policies-path="<%= rsVehicles.getString("other_policies_path") %>">
                                            Update
                                        </button>
                                        <form action="VehicleServlet" method="post" class="d-inline" onsubmit="return confirm('Are you sure you want to delete this vehicle?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="vehicleId" value="<%= rsVehicles.getInt("vehicle_id") %>">
                                            <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                %>
                                <tr><td colspan="4" class="text-danger">Error loading vehicle data.</td></tr>
                                <%
                                    } finally {
                                        try { if (rsVehicles != null) rsVehicles.close(); } catch (SQLException e) {}
                                        try { if (stVehicles != null) stVehicles.close(); } catch (SQLException e) {}
                                        try { if (conVehicles != null) conVehicles.close(); } catch (SQLException e) {}
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                <%
                    } else if ("add".equals(action)) {
                %>
                    <div class="card mb-4">
                        <div class="card-header bg-primary text-white">Add New Vehicle</div>
                        <div class="card-body">
                            <form action="VehicleServlet" method="post" enctype="multipart/form-data">
                                <input type="hidden" name="action" value="add">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label for="vehicleName" class="form-label">Vehicle Name</label>
                                        <input type="text" class="form-control" id="vehicleName" name="vehicleName" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="vehicleNumber" class="form-label">Vehicle Number</label>
                                        <input type="text" class="form-control" id="vehicleNumber" name="vehicleNumber" required>
                                    </div>
                                </div>
                                <div class="row g-3 mt-2">
                                    <div class="col-md-6">
                                        <label for="capacity" class="form-label">Passenger Capacity</label>
                                        <input type="number" class="form-control" id="capacity" name="capacity" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="insurancePolicyNumber" class="form-label">Insurance Policy Number</label>
                                        <input type="text" class="form-control" id="insurancePolicyNumber" name="insurancePolicyNumber">
                                    </div>
                                </div>
                                <div class="row g-3 mt-2">
                                    <div class="col-md-6">
                                        <label for="insuranceExpiryDate" class="form-label">Insurance Expiry Date</label>
                                        <input type="date" class="form-control" id="insuranceExpiryDate" name="insuranceExpiryDate">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="pucCertificateNumber" class="form-label">PUC Certificate Number</label>
                                        <input type="text" class="form-control" id="pucCertificateNumber" name="pucCertificateNumber">
                                    </div>
                                </div>
                                <div class="row g-3 mt-2">
                                    <div class="col-md-6">
                                        <label for="pucExpiryDate" class="form-label">PUC Expiry Date</label>
                                        <input type="date" class="form-control" id="pucExpiryDate" name="pucExpiryDate">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="otherPolicies" class="form-label">Other Policies (Upload)</label>
                                        <input type="file" class="form-control" id="otherPolicies" name="otherPolicies">
                                    </div>
                                </div>
                                <div class="row g-3 mt-2">
                                    <div class="col-12 d-flex align-items-end">
                                        <button type="submit" class="btn btn-success">Add Vehicle</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
	              <% } else if ("info".equals(action)) { %>
	    <div class="card mb-4">
	        <div class="card-header bg-primary text-white">Vehicle Information</div>
	        <div class="card-body">
	            <%
	                String selectedVehicleId = request.getParameter("vehicleId");
	                if (selectedVehicleId != null && !selectedVehicleId.isEmpty()) {
	                    try (Connection con = DBconnect.getConnection()) {
	                        String sql = "SELECT * FROM Vehicles WHERE vehicle_id = ?";
	                        try (PreparedStatement ps = con.prepareStatement(sql)) {
	                            ps.setInt(1, Integer.parseInt(selectedVehicleId));
	                            try (ResultSet rs = ps.executeQuery()) {
	                                if (rs.next()) {
	            %>
	            <p><strong>Vehicle Name:</strong> <%= rs.getString("vehicle_name") %></p>
	            <p><strong>Vehicle Number:</strong> <%= rs.getString("vehicle_number") %></p>
	            <p><strong>Capacity:</strong> <%= rs.getInt("capacity") %></p>
	            <hr>
	            <h6>Policy Information</h6>
	            <p><strong>Insurance Policy:</strong> <%= rs.getString("insurance_policy_number") != null ? rs.getString("insurance_policy_number") : "N/A" %></p>
	            <p><strong>Insurance Expiry:</strong> <%= rs.getString("insurance_expiry_date") != null ? rs.getString("insurance_expiry_date") : "N/A" %></p>
	            <p><strong>PUC Certificate:</strong> <%= rs.getString("puc_certificate_number") != null ? rs.getString("puc_certificate_number") : "N/A" %></p>
	            <p><strong>PUC Expiry:</strong> <%= rs.getString("puc_expiry_date") != null ? rs.getString("puc_expiry_date") : "N/A" %></p>
	            <p><strong>Other Policies:</strong> <% if (rs.getString("other_policies_path") != null && !rs.getString("other_policies_path").isEmpty()) { %>
	                <a href="<%= rs.getString("other_policies_path") %>" target="_blank">View Document</a>
	            <% } else { %>
	                N/A
	            <% } %>
	            </p>
            <%
                                } else {
                                    out.print("<p class='text-danger'>Vehicle not found.</p>");
                                }
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.print("<p class='text-danger'>Error loading vehicle details.</p>");
                    }
                } else {
                    out.print("<p class='text-muted'>Please select a vehicle from the 'Check Vehicles' list to view its details.</p>");
                }
            %>
        </div>
    </div>
<% } %>
            <% } else if ("logs".equals(view)) { %>
                <h3>Vehicle Logs</h3>
                <ul class="nav nav-tabs mb-3">
                    <li class="nav-item">
                        <a class="nav-link <%= "petrol".equals(request.getParameter("log_type")) || request.getParameter("log_type") == null ? "active" : "" %>" href="SystemAdminpage.jsp?view=logs&log_type=petrol">Petrol Logs</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link <%= "service".equals(request.getParameter("log_type")) ? "active" : "" %>" href="SystemAdminpage.jsp?view=logs&log_type=service">Service Logs</a>
                    </li>
                </ul>
                <%
                    String logType = request.getParameter("log_type");
                    if (logType == null || "petrol".equals(logType)) {
                %>
                    <h4>Petrol Log History</h4>
                    <div class="table-responsive">
                        <table class="table table-striped table-bordered">
                            <thead>
                                <tr>
                                    <th>Sr. No.</th>
                                    <th>Vehicle Number</th>
                                    <th>Driver Name</th>
                                    <th>Liters</th>
                                    <th>Cost</th>
                                    <th>Date and Time</th>
                                    <th>Bill</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    boolean hasPetrolLogs = false;
                                    int petrolSrNo = 1;
                                    DateTimeFormatter logsDateFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy hh:mm a");
                                    try (Connection con = DBconnect.getConnection()) {
                                        String sql = "SELECT v.vehicle_number, d.full_name, vpl.petrol_liters, vpl.cost, vpl.log_date, vpl.bill_photo_path FROM VehiclePetrolLogs vpl INNER JOIN Vehicles v ON vpl.vehicle_id = v.vehicle_id INNER JOIN Drivers d ON vpl.driver_id = d.driver_id ORDER BY vpl.log_date DESC";
                                        PreparedStatement psLogs = con.prepareStatement(sql);
                                        ResultSet rsLogs = psLogs.executeQuery();
                                        while (rsLogs.next()) {
                                            hasPetrolLogs = true;
                                %>
                                <tr>
                                    <td><%= petrolSrNo++ %></td>
                                    <td><%= rsLogs.getString("vehicle_number") %></td>
                                    <td><%= rsLogs.getString("full_name") %></td>
                                    <td><%= rsLogs.getDouble("petrol_liters") %></td>
                                    <td><%= rsLogs.getDouble("cost") %></td>
                                    <td><%= rsLogs.getTimestamp("log_date").toLocalDateTime().format(logsDateFormat) %></td>
                                    <td><a href="<%= rsLogs.getString("bill_photo_path") %>" target="_blank">View Bill</a></td>
                                </tr>
                                <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                %>
                                <tr>
                                    <td colspan="7" class="text-center text-danger">Error loading petrol logs.</td>
                                </tr>
                                <%
                                    }
                                    if (!hasPetrolLogs) {
                                %>
                                <tr>
                                    <td colspan="7" class="text-center">No petrol log history found.</td>
                                </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                <% } else if ("service".equals(logType)) { %>
                    <h4>Service Log History</h4>
                    <div class="table-responsive">
                        <table class="table table-striped table-bordered">
                            <thead>
                                <tr>
                                    <th>Sr. No.</th>
                                    <th>Vehicle Number</th>
                                    <th>Driver Name</th>
                                    <th>Description</th>
                                    <th>Cost </th>
                                    <th>Date and Time</th>
                                    <th>Bill</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    boolean hasServiceLogs = false;
                                    int serviceSrNo = 1;
                                    DateTimeFormatter logsDateFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy hh:mm a");
                                    try (Connection con = DBconnect.getConnection()) {
                                        String sql = "SELECT v.vehicle_number, d.full_name, vsl.service_description, vsl.cost, vsl.service_date, vsl.bill_photo_path FROM VehicleServiceLogs vsl INNER JOIN Vehicles v ON vsl.vehicle_id = v.vehicle_id INNER JOIN Drivers d ON vsl.driver_id = d.driver_id ORDER BY vsl.service_date DESC";
                                        PreparedStatement psLogs = con.prepareStatement(sql);
                                        ResultSet rsLogs = psLogs.executeQuery();
                                        while (rsLogs.next()) {
                                            hasServiceLogs = true;
                                %>
                                <tr>
                                    <td><%= serviceSrNo++ %></td>
                                    <td><%= rsLogs.getString("vehicle_number") %></td>
                                    <td><%= rsLogs.getString("full_name") %></td>
                                    <td><%= rsLogs.getString("service_description") %></td>
                                    <td><%= rsLogs.getDouble("cost") %></td>
                                    <td><%= rsLogs.getTimestamp("service_date").toLocalDateTime().format(logsDateFormat) %></td>
                                    <td><a href="<%= rsLogs.getString("bill_photo_path") %>" target="_blank">View Bill</a></td>
                                </tr>
                                <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                %>
                                <tr>
                                    <td colspan="7" class="text-center text-danger">Error loading service logs.</td>
                                </tr>
                                <%
                                    }
                                    if (!hasServiceLogs) {
                                %>
                                <tr>
                                    <td colspan="7" class="text-center">No service log history found.</td>
                                </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
<% } else if ("accidents".equals(view)) { %>
                <h3>Vehicle Accident Logs</h3>
                <div class="card mb-4">
                    <div class="card-header bg-primary text-white">Add New Accident Log</div>
                    <div class="card-body">
                        <form action="AccidentLogServlet" method="post" enctype="multipart/form-data">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label for="accidentVehicle" class="form-label">Vehicle</label>
                                    <select name="vehicleId" id="accidentVehicle" class="form-select" required>
                                        <option value="">Select Vehicle</option>
                                        <%
                                            Connection conVehiclesAccident = null;
                                            PreparedStatement psVehiclesAccident = null;
                                            ResultSet rsVehiclesAccident = null;
                                            try {
                                                conVehiclesAccident = DBconnect.getConnection();
                                                String sqlVehiclesAccident = "SELECT vehicle_id, vehicle_name, vehicle_number FROM Vehicles ORDER BY vehicle_name";
                                                psVehiclesAccident = conVehiclesAccident.prepareStatement(sqlVehiclesAccident);
                                                rsVehiclesAccident = psVehiclesAccident.executeQuery();
                                                while (rsVehiclesAccident.next()) {
                                        %>
                                        <option value="<%= rsVehiclesAccident.getInt("vehicle_id") %>">
                                            <%= rsVehiclesAccident.getString("vehicle_name") %> - <%= rsVehiclesAccident.getString("vehicle_number") %>
                                        </option>
                                        <%
                                                }
                                            } catch (Exception e) {
                                                e.printStackTrace();
                                            } finally {
                                                try { if (rsVehiclesAccident != null) rsVehiclesAccident.close(); } catch (SQLException e) {}
                                                try { if (psVehiclesAccident != null) psVehiclesAccident.close(); } catch (SQLException e) {}
                                                try { if (conVehiclesAccident != null) conVehiclesAccident.close(); } catch (SQLException e) {}
                                            }
                                        %>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="accidentDriver" class="form-label">Driver</label>
                                    <select name="driverId" id="accidentDriver" class="form-select" required>
                                        <option value="">Select Driver</option>
                                        <%
                                            Connection conDriversAccident = null;
                                            PreparedStatement psDriversAccident = null;
                                            ResultSet rsDriversAccident = null;
                                            try {
                                                conDriversAccident = DBconnect.getConnection();
                                                String sqlDriversAccident = "SELECT driver_id, full_name FROM Drivers ORDER BY full_name";
                                                psDriversAccident = conDriversAccident.prepareStatement(sqlDriversAccident);
                                                rsDriversAccident = psDriversAccident.executeQuery();
                                                while (rsDriversAccident.next()) {
                                        %>
                                        <option value="<%= rsDriversAccident.getInt("driver_id") %>">
                                            <%= rsDriversAccident.getString("full_name") %>
                                        </option>
                                        <%
                                                }
                                            } catch (Exception e) {
                                                e.printStackTrace();
                                            } finally {
                                                try { if (rsDriversAccident != null) rsDriversAccident.close(); } catch (SQLException e) {}
                                                try { if (psDriversAccident != null) psDriversAccident.close(); } catch (SQLException e) {}
                                                try { if (conDriversAccident != null) conDriversAccident.close(); } catch (SQLException e) {}
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="row g-3 mt-2">
                                <div class="col-md-6">
                                    <label for="accidentDate" class="form-label">Date of Accident</label>
                                    <input type="date" class="form-control" id="accidentDate" name="accidentDate" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="estimatedCost" class="form-label">Estimated Repair Cost</label>
                                    <input type="number" step="0.01" class="form-control" id="estimatedCost" name="estimatedCost" required>
                                </div>
                            </div>
                            <div class="row g-3 mt-2">
                                <div class="col-md-6">
                                    <label for="policeComplaintNumber" class="form-label">Police Complaint Number</label>
                                    <input type="text" class="form-control" id="policeComplaintNumber" name="policeComplaintNumber">
                                </div>
                                <div class="col-md-6">
                                    <label for="policeOfficerName" class="form-label">Police Officer Name</label>
                                    <input type="text" class="form-control" id="policeOfficerName" name="policeOfficerName">
                                </div>
                            </div>
                             <div class="row g-3 mt-2">
                                <div class="col-md-6">
                                    <label for="policeStationName" class="form-label">Police Station Name</label>
                                    <input type="text" class="form-control" id="policeStationName" name="policeStationName">
                                </div>
                                <div class="col-md-6">
                                    <label for="policeMobileNumber" class="form-label">Police Mobile Number</label>
                                    <input type="tel" class="form-control" id="policeMobileNumber" name="policeMobileNumber">
                                </div>
                            </div>
                            <div class="row g-3 mt-2">
                                <div class="col-12">
                                    <label for="accidentDescription" class="form-label">Description</label>
                                    <textarea class="form-control" id="accidentDescription" name="accidentDescription" rows="3" required></textarea>
                                </div>
                            </div>
                             <div class="row g-3 mt-2">
                                <div class="col-md-6">
                                    <label for="vehiclePhoto" class="form-label">Vehicle Photo</label>
                                    <input type="file" class="form-control" id="vehiclePhoto" name="vehiclePhoto">
                                </div>
                                <div class="col-md-6">
                                    <label for="accidentPhoto" class="form-label">Accident Photo</label>
                                    <input type="file" class="form-control" id="accidentPhoto" name="accidentPhoto">
                                </div>
                            </div>
                            <div class="row g-3 mt-3">
                                <div class="col-12 d-flex align-items-end">
                                    <button type="submit" class="btn btn-success">Add Log</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <h4>Accident History</h4>
                <div class="table-responsive">
                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                                <th>Sr. No.</th>
                                <th>Vehicle Number</th>
                                <th>Driver Name</th>
                                <th>Date</th>
                                <th>Description</th>
                                <th>Cost</th>
                                <th>Vehicle Photo</th>
                                <th>Accident Photo</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                boolean hasAccidentLogs = false;
                                int accidentSrNo = 1;
                                try (Connection con = DBconnect.getConnection()) {
                                    String sql = "SELECT va.accident_date, va.accident_description, va.estimated_cost, va.vehicle_photo_path, va.accident_photo_path, v.vehicle_number, d.full_name FROM VehicleAccidentLogs va INNER JOIN Vehicles v ON va.vehicle_id = v.vehicle_id INNER JOIN Drivers d ON va.driver_id = d.driver_id ORDER BY va.accident_date DESC";
                                    PreparedStatement psAccidentLogs = con.prepareStatement(sql);
                                    ResultSet rsAccidentLogs = psAccidentLogs.executeQuery();
                                    while (rsAccidentLogs.next()) {
                                        hasAccidentLogs = true;
                            %>
                            <tr>
                                <td><%= accidentSrNo++ %></td>
                                <td><%= rsAccidentLogs.getString("vehicle_number") %></td>
                                <td><%= rsAccidentLogs.getString("full_name") %></td>
                                <td><%= rsAccidentLogs.getDate("accident_date") %></td>
                                <td><%= rsAccidentLogs.getString("accident_description") %></td>
                                <td><%= rsAccidentLogs.getDouble("estimated_cost") %></td>
                                <td><a href="<%= rsAccidentLogs.getString("vehicle_photo_path") %>" target="_blank">View Photo</a></td>
                                <td><a href="<%= rsAccidentLogs.getString("accident_photo_path") %>" target="_blank">View Photo</a></td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                            %>
                            <tr><td colspan="8" class="text-danger">Error loading accident logs.</td></tr>
                            <%
                                }
                                if (!hasAccidentLogs) {
                            %>
                            <tr><td colspan="8" class="text-center">No accident log history found.</td></tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <h4 class="mt-5">Police Complaint Details</h4>
                <div class="table-responsive">
                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                                <th>Sr. No.</th>
                                <th>Vehicle Number</th>
                                <th>Police Complaint No.</th>
                                <th>Police Officer</th>
                                <th>Police Station</th>
                                <th>Police Contact</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                boolean hasComplaintDetails = false;
                                int complaintSrNo = 1;
                                try (Connection con = DBconnect.getConnection()) {
                                    String sql = "SELECT va.police_complaint_number, va.police_officer_name, va.police_station_name, va.police_mobile_number, v.vehicle_number FROM VehicleAccidentLogs va INNER JOIN Vehicles v ON va.vehicle_id = v.vehicle_id ORDER BY va.accident_date DESC";
                                    PreparedStatement psComplaintLogs = con.prepareStatement(sql);
                                    ResultSet rsComplaintLogs = psComplaintLogs.executeQuery();
                                    while (rsComplaintLogs.next()) {
                                        hasComplaintDetails = true;
                            %>
                            <tr>
                                <td><%= complaintSrNo++ %></td>
                                <td><%= rsComplaintLogs.getString("vehicle_number") %></td>
                                <td><%= rsComplaintLogs.getString("police_complaint_number") != null ? rsComplaintLogs.getString("police_complaint_number") : "N/A" %></td>
                                <td><%= rsComplaintLogs.getString("police_officer_name") != null ? rsComplaintLogs.getString("police_officer_name") : "N/A" %></td>
                                <td><%= rsComplaintLogs.getString("police_station_name") != null ? rsComplaintLogs.getString("police_station_name") : "N/A" %></td>
                                <td><%= rsComplaintLogs.getString("police_mobile_number") != null ? rsComplaintLogs.getString("police_mobile_number") : "N/A" %></td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                            %>
                            <tr><td colspan="6" class="text-danger">Error loading complaint details.</td></tr>
                            <%
                                }
                                if (!hasComplaintDetails) {
                            %>
                            <tr><td colspan="6" class="text-center">No complaint details found.</td></tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            <% } %>

        </div>
    </div>
</div>

<div class="modal fade" id="updateVehicleModal" tabindex="-1" aria-labelledby="updateVehicleModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="UpdateVehicleServlet" method="post" enctype="multipart/form-data">
                <div class="modal-header">
                    <h5 class="modal-title" id="updateVehicleModalLabel">Update Vehicle Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" id="update_vehicle_id" name="vehicleId">
                    <div class="mb-3">
                        <label for="update_vehicle_name" class="form-label">Vehicle Name</label>
                        <input type="text" class="form-control" id="update_vehicle_name" name="vehicleName">
                    </div>
                    <div class="mb-3">
                        <label for="update_vehicle_number" class="form-label">Vehicle Number</label>
                        <input type="text" class="form-control" id="update_vehicle_number" name="vehicleNumber">
                    </div>
                    <div class="mb-3">
                        <label for="update_capacity" class="form-label">Passenger Capacity</label>
                        <input type="number" class="form-control" id="update_capacity" name="capacity">
                    </div>
                    <div class="mb-3">
                        <label for="update_insurance_policy_number" class="form-label">Insurance Policy Number</label>
                        <input type="text" class="form-control" id="update_insurance_policy_number" name="insurancePolicyNumber">
                    </div>
                    <div class="mb-3">
                        <label for="update_insurance_expiry_date" class="form-label">Insurance Expiry Date</label>
                        <input type="date" class="form-control" id="update_insurance_expiry_date" name="insuranceExpiryDate">
                    </div>
                    <div class="mb-3">
                        <label for="update_puc_certificate_number" class="form-label">PUC Certificate Number</label>
                        <input type="text" class="form-control" id="update_puc_certificate_number" name="pucCertificateNumber">
                    </div>
                    <div class="mb-3">
                        <label for="update_puc_expiry_date" class="form-label">PUC Expiry Date</label>
                        <input type="date" class="form-control" id="update_puc_expiry_date" name="pucExpiryDate">
                    </div>
                    <div class="mb-3">
                        <label for="update_other_policies" class="form-label">Other Policies</label>
                        <div id="current_policies_link"></div>
                        <input type="file" class="form-control" id="update_other_policies" name="otherPolicies">
                        <small class="text-muted">Upload a new file to replace the existing one.</small>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary">Save changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
	document.addEventListener('DOMContentLoaded', function () {
	    const updateVehicleModal = document.getElementById('updateVehicleModal');
	    updateVehicleModal.addEventListener('show.bs.modal', function (event) {
	        const button = event.relatedTarget;
	        const vehicleId = button.getAttribute('data-id');
	        const vehicleName = button.getAttribute('data-vehicle-name');
	        const vehicleNumber = button.getAttribute('data-vehicle-number');
	        const capacity = button.getAttribute('data-capacity');
	        const insurancePolicyNumber = button.getAttribute('data-insurance-policy-number');
	        const insuranceExpiryDate = button.getAttribute('data-insurance-expiry-date');
	        const pucCertificateNumber = button.getAttribute('data-puc-certificate-number');
	        const pucExpiryDate = button.getAttribute('data-puc-expiry-date');
	        const otherPoliciesPath = button.getAttribute('data-other-policies-path');
	
	        document.getElementById('update_vehicle_id').value = vehicleId;
	        document.getElementById('update_vehicle_name').value = vehicleName;
	        document.getElementById('update_vehicle_number').value = vehicleNumber;
	        document.getElementById('update_capacity').value = capacity;
	        document.getElementById('update_insurance_policy_number').value = insurancePolicyNumber;
	        document.getElementById('update_insurance_expiry_date').value = insuranceExpiryDate;
	        document.getElementById('update_puc_certificate_number').value = pucCertificateNumber;
	        document.getElementById('update_puc_expiry_date').value = pucExpiryDate;
	
	        const currentPoliciesLinkDiv = document.getElementById('current_policies_link');
	        if (otherPoliciesPath && otherPoliciesPath !== "null") {
	            // CORRECTED LINE
	            currentPoliciesLinkDiv.innerHTML = `<p class="mb-1"><strong>Current File:</strong> <a href="${otherPoliciesPath}" target="_blank">View Document</a></p>`;
	        } else {
	            currentPoliciesLinkDiv.innerHTML = `<p class="mb-1 text-muted">No file uploaded.</p>`;
	        }
	    });
	});
</script>
</body>
</html>