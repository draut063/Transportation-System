<%@ page import="java.sql.*" %>
<%@ page import="com.TransportationSystem.model.DBconnect" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>TS-HOD Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="website icon" type="png" href="scdl.png">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: Arial, sans-serif;
        }

        .navbar-custom {
            background-color: transparent !important;
            border-bottom: 1px solid #000;
            position: relative;
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
            font-weight: 600;
            color: #000;
            white-space: nowrap;
        }

        .navbar-custom .nav-link {
            color: #000;
        }

        .navbar-custom .nav-link:hover {
            text-decoration: underline;
        }

        .container.mt-4 {
            padding-bottom: 20px;
        }

        table {
            width: 95%;
            border-collapse: collapse;
            margin: 20px auto;
            background-color: #fff;

        }

        th, td {
            padding: 10px;
            text-align: center;
            border: 1px solid #ccc;
        }

        th {
            background-color: #e9ecef;
        }

        h3 {
            text-align: center;
            color: #333;
            margin-top: 30px;
            margin-bottom: 20px;
        }

        .btn-success, .btn-danger {
            padding: 6px 12px;
            border: none;
            cursor: pointer;
            color: white;
            margin: 2px;
        }
        .alert-fixed {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1050;
        }
    </style>
</head>
<body>

<%
    HttpSession session1 = request.getSession(false);
    String department = (String) session1.getAttribute("department");
    String fullName = (String) session1.getAttribute("employeeName");

    if (department == null || fullName == null) {
        response.sendRedirect("login.html");
        return;
    }
%>

<nav class="navbar navbar-expand-lg navbar-custom">
    <div class="container-fluid position-relative">
        <div class="d-flex align-items-center">
            <span class="nav-link fw-bold">Welcome, <%= fullName %></span>
        </div>
        <div class="navbar-center">
            <img src="scdl.png" alt="SCDL Logo">
            <span class="navbar-title fw-bold">Symbiosis Centre for Distance Learning</span>
        </div>
        <div class="ms-auto d-flex align-items-center">
            <a class="nav-link fw-bold" href="TS-logout.jsp">Logout</a>
        </div>
    </div>
</nav>

<div class="container mt-4">
    <h3>Transport Requests for Department: <%= department %></h3>

    <%-- Display status messages --%>
    <%
        String status = request.getParameter("status");
        String message = request.getParameter("message");
        if ("success".equals(status)) {
    %>
    <div class="alert alert-success alert-dismissible fade show alert-fixed" role="alert">
        Request processed successfully!
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <%
    } else if ("error".equals(status)) {
    %>
    <div class="alert alert-danger alert-dismissible fade show alert-fixed" role="alert">
        <strong>Error!</strong> <%= message != null ? message : "An unknown error occurred." %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <%
        }
    %>

    <div class="table-responsive">
        <table class="table table-bordered mt-3">
            <thead class="table-light">
                <tr>
                    <th>Sr. No</th>
                    <th>Full Name</th>
                    <th>Reason</th>
                    <th>Travel Date</th>
                    <th>Pickup Location</th>
                    <th>Drop Location</th>
                    <th>Pickup Time</th>
                    <th>Return Time</th>
                    <th>Addl. Employees</th>
                    <th>Remarks</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
            <%
                Connection con = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                int count = 1;
                boolean hasRequests = false;
                
                // Define date and time formatters
                SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
                SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
                
                try {
                    con = DBconnect.getConnection();
                    String sql = "SELECT request_id, full_name, reason, travel_date, pickup_location, drop_location, pickup_time, return_time, additional_employees_count, remarks " +
                                 "FROM TransportRequests " +
                                 "WHERE department = ? AND request_status = 'Pending' AND travel_date >= CAST(GETDATE() AS DATE) " +
                                 "ORDER BY travel_date ASC, pickup_time ASC";

                    ps = con.prepareStatement(sql);
                    ps.setString(1, department);
                    rs = ps.executeQuery();
                    
                    while (rs.next()) {
                        hasRequests = true;
                        
                        // Retrieve and format the Date and Time objects
                        java.sql.Date travelDate = rs.getDate("travel_date");
                        java.sql.Time pickupTime = rs.getTime("pickup_time");
                        java.sql.Time returnTime = rs.getTime("return_time");
                        
                        String formattedDate = (travelDate != null) ? dateFormat.format(travelDate) : "N/A";
                        String formattedPickupTime = (pickupTime != null) ? timeFormat.format(pickupTime) : "N/A";
                        String formattedReturnTime = (returnTime != null) ? timeFormat.format(returnTime) : "N/A";
            %>
                <tr>
                    <td><%= count++ %></td>
                    <td><%= rs.getString("full_name") %></td>
                    <td><%= rs.getString("reason") %></td>
                    <td><%= formattedDate %></td>
                    <td><%= rs.getString("pickup_location") %></td>
                    <td><%= rs.getString("drop_location") %></td>
                    <td><%= formattedPickupTime %></td>
                    <td><%= formattedReturnTime %></td>
                    <td><%= rs.getInt("additional_employees_count") != 0 ? rs.getInt("additional_employees_count") : "N/A" %></td>
                    <td><%= rs.getString("remarks") != null && !rs.getString("remarks").isEmpty() ? rs.getString("remarks") : "N/A" %></td>
                    <td>
                        <div class="btn-group btn-group-sm" role="group" aria-label="HOD Actions">
                            <form method="post" action="HOD-ApprovalServlet">
                                <input type="hidden" name="request_id" value="<%= rs.getInt("request_id") %>">
                                <button type="submit" name="action" value="Approved" class="btn btn-success btn-sm">Approve</button>
                            </form>
                            <form method="post" action="HOD-ApprovalServlet">
                                <input type="hidden" name="request_id" value="<%= rs.getInt("request_id") %>">
                                <button type="submit" name="action" value="Rejected" class="btn btn-danger btn-sm">Reject</button>
                            </form>
                            <div>
                                <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#changeDateModal"
                                        data-request-id="<%= rs.getInt("request_id") %>">
                                    Change
                                </button>
                            </div>
                        </div>
                    </td>
                </tr>
            <%
                    }
                } catch (SQLException e) {
                    System.err.println("SQL Error in HOD Dashboard JSP: " + e.getMessage());
                    e.printStackTrace();
                    out.println("<tr><td colspan='11' class='text-danger'>Error retrieving data: " + e.getMessage() + "</td></tr>");
                } catch (Exception e) {
                    System.err.println("General Error in HOD Dashboard JSP: " + e.getMessage());
                    e.printStackTrace();
                    out.println("<tr><td colspan='11' class='text-danger'>An unexpected error occurred: " + e.getMessage() + "</td></tr>");
                } finally {
                    try { if (rs != null) rs.close(); } catch (SQLException e) { /* log error */ }
                    try { if (ps != null) ps.close(); } catch (SQLException e) { /* log error */ }
                    try { if (con != null) con.close(); } catch (SQLException e) { /* log error */ }
                }

                if (!hasRequests) {
            %>
                <tr>
                    <td colspan="11" class="text-center text-muted">No pending transport requests for your department.</td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>
</div>

<div class="modal fade" id="changeDateModal" tabindex="-1" aria-labelledby="changeDateModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="changeDateModalLabel">Change Travel Date</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="HOD-ChangeDateServlet">
                <div class="modal-body">
                    <input type="hidden" name="request_id" id="modalRequestId">
                    <div class="mb-3">
                        <label for="newTravelDate" class="form-label">New Travel Date</label>
                        <input type="date" class="form-control" id="newTravelDate" name="newTravelDate" required>
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
    var changeDateModal = document.getElementById('changeDateModal')
    changeDateModal.addEventListener('show.bs.modal', function (event) {
        // Button that triggered the modal
        var button = event.relatedTarget
        // Extract info from data-bs-* attributes
        var requestId = button.getAttribute('data-request-id')

        // Update the modal's content.
        var modalRequestIdInput = changeDateModal.querySelector('#modalRequestId')
        modalRequestIdInput.value = requestId
    })
</script>
</body>
</html>