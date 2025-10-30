<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.TransportationSystem.model.DBconnect" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>

<%
    HttpSession sessionObj = request.getSession(false);
    if (sessionObj == null || sessionObj.getAttribute("driver_email") == null) {
        response.sendRedirect("TS-Driverlogin.jsp");
        return;
    }

    String driverName = (String) sessionObj.getAttribute("full_name");
    String driverEmail = (String) sessionObj.getAttribute("driver_email");
    
    String photoPathFromSession = (String) sessionObj.getAttribute("photo_path");

  
    String profilePic = (photoPathFromSession != null && !photoPathFromSession.isEmpty()) 
                      ? photoPathFromSession 
                      : "uploads/default.jpg";
    
    ArrayList<String[]> tripList = (ArrayList<String[]>) request.getAttribute("tripList");
    int driverId = -1;
    try (Connection con = DBconnect.getConnection()) {
        String getDriverIdSql = "SELECT driver_id FROM Drivers WHERE email = ?";
        PreparedStatement ps = con.prepareStatement(getDriverIdSql);
        ps.setString(1, driverEmail);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            driverId = rs.getInt("driver_id");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Driver Dashboard</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <link rel="website icon" type="png" href="scdl.png">
    <style>
        .navbar-custom {
            background-color: transparent !important;
            border-bottom: 1px solid #000;
            height: 70px;
            width: 100%;
        }
        .navbar-left { display: flex; align-items: center; gap: 12px; }
        .profile-pic {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #000;
        }
        .navbar-center {
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translate(-50%, -50%);
            display: flex;
            align-items: center;
        }
        .navbar-center img { height: 50px; margin-right: 10px; }
        .navbar-title { font-size: 1.1rem; font-weight: bold; color: #000; white-space: nowrap; }
        .nav-link-logout { color: #000; font-weight: bold; text-decoration: none; }
        .nav-link-logout:hover { text-decoration: underline; }
        .table-responsive-custom {
            overflow-x: auto;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-custom">
    <div class="container-fluid d-flex justify-content-between">
        <div class="navbar-left">
            <img src="<%= profilePic %>" alt="Profile Picture" class="profile-pic">
            <span class="fw-bold text-dark">Welcome, <%= driverName %></span>
        </div>
        <div class="navbar-center">
            <img src="scdl.png" alt="SCDL Logo">
            <span class="navbar-title">Symbiosis Centre for Distance Learning</span>
        </div>
        <a class="nav-link-logout" href="TS-logout.jsp">Logout</a>
    </div>
</nav>

<div class="container mt-4">
    <h2 class="mb-3">Driver Activity Portal</h2>
    <p><strong>Email:</strong> <%= driverEmail %></p>
    
    <div class="card mt-4">
        <div class="card-header bg-primary text-white">
            Your Assigned Trips
        </div>
        <div class="card-body">
            <%
                if (tripList != null && !tripList.isEmpty()) {
                    for (String[] trip : tripList) {
                        String tripStatus = trip[4];
                        String employeeName = "N/A";
                        String employeeMobile = "N/A";
                        String tripIdStr = trip[0]; // This is the assigned trip ID. We need the request ID.

                        // Get the request ID from the AssignedTrips table
                        int requestId = -1;
                        try (Connection con = DBconnect.getConnection()) {
                            String getRequestIdSql = "SELECT request_id FROM AssignedTrips WHERE assignment_id = ?";
                            PreparedStatement psRequestId = con.prepareStatement(getRequestIdSql);
                            psRequestId.setString(1, tripIdStr);
                            ResultSet rsRequestId = psRequestId.executeQuery();
                            if (rsRequestId.next()) {
                                requestId = rsRequestId.getInt("request_id");
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        // Now get employee details from TransportRequests and EmployeesRegistration tables
                        if (requestId != -1) {
                            try (Connection con = DBconnect.getConnection()) {
                                String getEmployeeNameSql = "SELECT full_name FROM TransportRequests WHERE request_id = ?";
                                PreparedStatement psEmployeeName = con.prepareStatement(getEmployeeNameSql);
                                psEmployeeName.setInt(1, requestId);
                                ResultSet rsEmployeeName = psEmployeeName.executeQuery();
                                if (rsEmployeeName.next()) {
                                    employeeName = rsEmployeeName.getString("full_name");

                                    // Use the employee name to get the mobile number
                                    String getMobileSql = "SELECT mobile_number FROM EmployeesRegistration WHERE full_name = ?";
                                    PreparedStatement psMobile = con.prepareStatement(getMobileSql);
                                    psMobile.setString(1, employeeName);
                                    ResultSet rsMobile = psMobile.executeQuery();
                                    if (rsMobile.next()) {
                                        employeeMobile = rsMobile.getString("mobile_number");
                                    }
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
            %>
            <div class="alert alert-info mb-3">
                <p><strong>Trip Status:</strong> <span class="badge bg-primary"><%= tripStatus %></span></p>
                <p><strong>Assigned Time:</strong> <%= trip[3] %></p>
                <p><strong>From:</strong> <%= trip[1] %></p>
                <p><strong>To:</strong> <%= trip[2] %></p>
                <p><strong>Employee:</strong> <%= employeeName %></p>
                <p><strong>Employee Mobile:</strong> <%= employeeMobile %></p>
            
                <% if ("Assigned".equals(tripStatus)) { %>
                <form action="StartTripServlet" method="post" onsubmit="return confirm('Are you sure you want to start this trip?');">
                    <input type="hidden" name="assignmentId" value="<%= trip[0] %>">
                    <button type="submit" class="btn btn-success mt-2">Start Trip</button>
                </form>
                <% } else if ("On Trip".equals(tripStatus)) { %>
                <form action="CompletedriverTripServlet" method="post" onsubmit="return confirm('Are you sure you want to complete this trip?');">
                    <input type="hidden" name="assignmentId" value="<%= trip[0] %>">
                    <button type="submit" class="btn btn-primary mt-2">Complete Trip</button>
                </form>
                <% } %>
            </div>
            <%
                    }
                } else {
            %>
            <p>No trips assigned yet. Please contact admin.</p>
            <%
                }
            %>
        </div>
    </div>
    
    <div class="card mt-4">
        <div class="card-header bg-primary text-white">
            Add Petrol/Diesel Details
        </div>
        <div class="card-body">
            <form action="AddPetrolServlet" method="post" enctype="multipart/form-data">
                <div class="mb-3">
                    <label for="vehicleNumber" class="form-label">Vehicle/Car Number</label>
                    <input type="text" class="form-control" id="vehicleNumber" name="vehicleNumber" required>
                </div>
                <div class="mb-3">
                    <label for="petrolLiters" class="form-label">Petrol in Liters</label>
                    <input type="number" step="0.01" class="form-control" id="petrolLiters" name="petrolLiters" required>
                </div>
                <div class="mb-3">
                    <label for="petrolAmount" class="form-label">Total Amount (₹)</label>
                    <input type="number" step="0.01" class="form-control" id="petrolAmount" name="petrolAmount" required>
                </div>
                <div class="mb-3">
                    <label for="petrolBill" class="form-label">Upload Bill Photo</label>
                    <input class="form-control" type="file" id="petrolBill" name="petrolBill" required>
                </div>
                <button type="submit" class="btn btn-success">Save Petrol Details</button>
            </form>
        </div>
    </div>

    <div class="card mt-4">
        <div class="card-header bg-primary text-white">
            Add Vehicle Service Details
        </div>
        <div class="card-body">
            <form action="AddServiceServlet" method="post" enctype="multipart/form-data">
                <div class="mb-3">
                    <label for="vehicleNumberService" class="form-label">Vehicle/Car Number</label>
                    <input type="text" class="form-control" id="vehicleNumberService" name="vehicleNumber" required>
                </div>
                <div class="mb-3">
                    <label for="serviceDescription" class="form-label">Service Description</label>
                    <input type="text" class="form-control" id="serviceDescription" name="serviceDescription" required>
                </div>
                <div class="mb-3">
                    <label for="serviceAmount" class="form-label">Service Amount (₹)</label>
                    <input type="number" step="0.01" class="form-control" id="serviceAmount" name="serviceAmount" required>
                </div>
                <div class="mb-3">
                    <label for="serviceBill" class="form-label">Upload Bill Photo</label>
                    <input class="form-control" type="file" id="serviceBill" name="serviceBill" required>
                </div>
                <button type="submit" class="btn btn-success">Save Service Details</button>
            </form>
        </div>
    </div>
    
    <div class="card mt-4">
        <div class="card-header bg-primary text-white">
            Petrol Log History
        </div>
        <div class="card-body">
            <div class="table-responsive-custom">
                <table class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th>Sr. No.</th>
                            <th>Vehicle Number</th>
                            <th>Liters</th>
                            <th>Cost (₹)</th>
                            <th>Date</th>
                            <th>Bill</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            boolean hasPetrolLogs = false;
                            int petrolSrNo = 1;
                            try (Connection con = DBconnect.getConnection()) {
                                String sql = "SELECT v.vehicle_number, vpl.petrol_liters, vpl.cost, vpl.log_date, vpl.bill_photo_path " +
                                             "FROM VehiclePetrolLogs vpl INNER JOIN Vehicles v ON vpl.vehicle_id = v.vehicle_id " +
                                             "WHERE vpl.driver_id = ? ORDER BY vpl.log_date DESC";
                                PreparedStatement ps = con.prepareStatement(sql);
                                ps.setInt(1, driverId);
                                ResultSet rs = ps.executeQuery();
                                while (rs.next()) {
                                    hasPetrolLogs = true;
                        %>
                        <tr>
                            <td><%= petrolSrNo++ %></td>
                            <td><%= rs.getString("vehicle_number") %></td>
                            <td><%= rs.getDouble("petrol_liters") %></td>
                            <td><%= rs.getDouble("cost") %></td>
                            <td><%= rs.getTimestamp("log_date") %></td>
                            <td><a href="<%= rs.getString("bill_photo_path") %>" target="_blank">View Bill</a></td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                        %>
                        <tr>
                            <td colspan="6" class="text-center text-danger">An error occurred while fetching petrol logs.</td>
                        </tr>
                        <%
                            }
                            if (!hasPetrolLogs) {
                        %>
                        <tr>
                            <td colspan="6" class="text-center">No petrol log history found.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <div class="card mt-4">
        <div class="card-header bg-primary text-white">
            Service Log History
        </div>
        <div class="card-body">
            <div class="table-responsive-custom">
                <table class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th>Sr. No.</th>
                            <th>Vehicle Number</th>
                            <th>Description</th>
                            <th>Cost (₹)</th>
                            <th>Date</th>
                            <th>Bill</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            boolean hasServiceLogs = false;
                            int serviceSrNo = 1;
                            try (Connection con = DBconnect.getConnection()) {
                                String sql = "SELECT v.vehicle_number, vsl.service_description, vsl.cost, vsl.service_date, vsl.bill_photo_path " +
                                             "FROM VehicleServiceLogs vsl INNER JOIN Vehicles v ON vsl.vehicle_id = v.vehicle_id " +
                                             "WHERE vsl.driver_id = ? ORDER BY vsl.service_date DESC";
                                PreparedStatement ps = con.prepareStatement(sql);
                                ps.setInt(1, driverId);
                                ResultSet rs = ps.executeQuery();
                                while (rs.next()) {
                                    hasServiceLogs = true;
                        %>
                        <tr>
                            <td><%= serviceSrNo++ %></td>
                            <td><%= rs.getString("vehicle_number") %></td>
                            <td><%= rs.getString("service_description") %></td>
                            <td><%= rs.getDouble("cost") %></td>
                            <td><%= rs.getTimestamp("service_date") %></td>
                            <td><a href="<%= rs.getString("bill_photo_path") %>" target="_blank">View Bill</a></td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                        %>
                        <tr>
                            <td colspan="6" class="text-center text-danger">An error occurred while fetching service logs.</td>
                        </tr>
                        <%
                            }
                            if (!hasServiceLogs) {
                        %>
                        <tr>
                            <td colspan="6" class="text-center">No service log history found.</td>
                        </tr>
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