<%@ page import="java.sql.*" %>
<%@ page import="com.TransportationSystem.model.DBconnect" %>
<%@ page session="true" %>

<%
    // Session validation for security
    String securityUserName = (String) session.getAttribute("securityUser");
    if (securityUserName == null) {
        response.sendRedirect("TS-SecurityLogin.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Security Checkpoint</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="icon" type="image/png" href="scdl.png">
    <style>
        body { background-color: #f8f9fa; }
        .container-fluid { max-width: 95%; } /* Increased width for better viewing */
        .table-responsive { overflow-x: auto; }
        .form-control-sm { width: 100px; }
        
        .action-cell {
            text-align: center;
            vertical-align: middle;
        }

        /* Custom styles for the navbar */
        .navbar-custom {
            background-color: transparent !important;
            border-bottom: 1px solid #000;
            height: 70px;
            width: 100%;
        }
        .navbar-left { display: flex; align-items: center; gap: 12px; }
        .navbar-center {
            position: absolute; left: 50%; top: 50%;
            transform: translate(-50%, -50%); display: flex; align-items: center;
        }
        .navbar-center img { height: 50px; margin-right: 10px; }
        .navbar-title { font-size: 1.1rem; font-weight: bold; color: #000; white-space: nowrap; }
        .nav-link-logout { color: #000; font-weight: bold; text-decoration: none; }
        .nav-link-logout:hover { text-decoration: underline; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-custom">
    <div class="container-fluid d-flex justify-content-between">
        <div class="navbar-left">
            <span class="fw-bold text-dark">Welcome, <%= securityUserName %></span>
        </div>
        <div class="navbar-center">
            <img src="scdl.png" alt="SCDL Logo">
            <span class="navbar-title">Symbiosis Centre for Distance Learning</span>
        </div>
        <a class="nav-link-logout" href="TS-logout.jsp">Logout</a>
    </div>
</nav>


<div class="container-fluid mt-5">
    <h2 class="mb-4">Active Trips</h2>

    <%-- Success/Error Message Display --%>
    <%
        String status = request.getParameter("status");
        String message = request.getParameter("message");
        if ("success".equals(status) && message != null) {
    %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <strong>Success!</strong> <%= message %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <%
        } else if ("error".equals(status) && message != null) {
    %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <strong>Error!</strong> <%= message %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <%
        }
    %>

    <div class="card shadow-sm">
        <div class="card-header bg-primary text-white">
            <h5 class="mb-0">Trip Details</h5>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped table-bordered align-middle">
                    <thead>
                        <tr>
                            <th>Trip ID</th>
                            <th>Vehicle Number</th>
                            <th>Driver Name</th>
                            <th>Odometer Start</th>
                            <th>Odometer End</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection con = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            boolean hasActiveTrips = false;
                            try {
                                con = DBconnect.getConnection();
                                String sql = "SELECT AT.assignment_id, V.vehicle_number, D.full_name AS driver_name, " +
                                             "AT.odometer_start, AT.odometer_end, AT.trip_status " +
                                             "FROM AssignedTrips AT " +
                                             "JOIN Vehicles V ON AT.vehicle_id = V.vehicle_id " +
                                             "JOIN Drivers D ON AT.driver_id = D.driver_id " +
                                             "WHERE AT.trip_status IN ('Assigned', 'On Trip') " +
                                             "ORDER BY AT.assigned_on DESC";
                                ps = con.prepareStatement(sql);
                                rs = ps.executeQuery();

                                while (rs.next()) {
                                    hasActiveTrips = true;
                                    int assignmentId = rs.getInt("assignment_id");
                                    String vehicleNumber = rs.getString("vehicle_number");
                                    String driverName = rs.getString("driver_name");
                                    int odometerStart = rs.getInt("odometer_start");
                                    int odometerEnd = rs.getInt("odometer_end");
                                    String tripStatus = rs.getString("trip_status");
                        %>
                        <tr>
                            <form action="SecurityCheckServlet" method="post">
                                <input type="hidden" name="assignmentId" value="<%= assignmentId %>">
                                <td><%= assignmentId %></td>
                                <td><%= vehicleNumber %></td>
                                <td><%= driverName %></td>
                                <td>
                                    <% if (tripStatus.equals("Assigned")) { %>
                                        <input type="number" class="form-control form-control-sm" name="odometer_start" value="<%= odometerStart == 0 ? "" : odometerStart %>" required>
                                    <% } else { %>
                                        <%= odometerStart %>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (tripStatus.equals("On Trip")) { %>
                                        <input type="number" class="form-control form-control-sm" name="odometer_end" value="<%= odometerEnd == 0 ? "" : odometerEnd %>" required>
                                    <% } else { %>
                                        -
                                    <% } %>
                                </td>
                                <td class="action-cell">
                                    <% if (tripStatus.equals("Assigned")) { %>
                                        <button type="submit" name="action" value="start" class="btn btn-success btn-sm">
                                            Start Trip
                                        </button>
                                    <% } else if (tripStatus.equals("On Trip")) { %>
                                        <button type="submit" name="action" value="end" class="btn btn-primary btn-sm">
                                            End Trip
                                        </button>
                                    <% } %>
                                </td>
                            </form>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                        %>
                            <tr><td colspan="6" class="text-center text-danger">Error fetching trip data.</td></tr>
                        <%
                            } finally {
                                try { if (rs != null) rs.close(); } catch (SQLException e) {}
                                try { if (ps != null) ps.close(); } catch (SQLException e) {}
                                try { if (con != null) con.close(); } catch (SQLException e) {}
                            }
                            if (!hasActiveTrips) {
                        %>
                            <tr><td colspan="6" class="text-center">No active trips currently.</td></tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>