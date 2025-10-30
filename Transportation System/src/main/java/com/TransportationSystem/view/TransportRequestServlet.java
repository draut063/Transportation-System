package com.TransportationSystem.view;

import com.TransportationSystem.model.DBconnect;
import com.TransportationSystem.mail.Mailer;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import jakarta.mail.MessagingException;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.sql.*;

@WebServlet("/submit-transport-request")
public class TransportRequestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String department = request.getParameter("department");
        String reason = request.getParameter("reason");
        String travelDate = request.getParameter("travelDate");
        String pickupLocation = request.getParameter("pickupLocation");
        String dropLocation = request.getParameter("dropLocation");
        String pickupTime = request.getParameter("pickupTime");
        String returnTime = request.getParameter("returnTime");
        // Get the new parameters from the form
        String additionalEmployeesCountStr = request.getParameter("additionalEmployeesCount");
        String remarks = request.getParameter("remarks");
        
        // Convert the additionalEmployeesCount to an integer, handling potential null or empty values
        Integer additionalEmployeesCount = null;
        if (additionalEmployeesCountStr != null && !additionalEmployeesCountStr.trim().isEmpty()) {
            try {
                additionalEmployeesCount = Integer.parseInt(additionalEmployeesCountStr);
            } catch (NumberFormatException e) {
                // Log the error or handle it as needed, e.g., set a default value or throw an exception.
                System.err.println("Invalid number format for additionalEmployeesCount: " + additionalEmployeesCountStr);
            }
        }

        try (Connection con = DBconnect.getConnection()) {
            // Step 1: Insert transport request
            String insertSql = "INSERT INTO TransportRequests (full_name, department, reason, travel_date, pickup_location, drop_location, pickup_time, return_time, additional_employees_count, remarks, request_status) " +
                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement psInsert = con.prepareStatement(insertSql)) {
                psInsert.setString(1, fullName);
                psInsert.setString(2, department);
                psInsert.setString(3, reason);
                psInsert.setDate(4, Date.valueOf(travelDate));
                psInsert.setString(5, pickupLocation);
                psInsert.setString(6, dropLocation);
                psInsert.setTime(7, Time.valueOf(pickupTime + ":00"));
                psInsert.setTime(8, Time.valueOf(returnTime + ":00"));
                
                // Set the new parameters in the prepared statement
                if (additionalEmployeesCount != null) {
                    psInsert.setInt(9, additionalEmployeesCount);
                } else {
                    psInsert.setNull(9, java.sql.Types.INTEGER);
                }
                psInsert.setString(10, remarks);
                
                psInsert.setString(11, "Pending");

                int rowsInserted = psInsert.executeUpdate();

                if (rowsInserted > 0) {
                    // Step 2: Find HOD email
                    String hodEmail = null;
                    String findHodSql = "SELECT email FROM SystemUsers WHERE department = ? AND role = 'HOD' AND is_active = 1";
                    try (PreparedStatement psFindHod = con.prepareStatement(findHodSql)) {
                        psFindHod.setString(1, department);
                        ResultSet rs = psFindHod.executeQuery();
                        if (rs.next()) {
                            hodEmail = rs.getString("email");
                        }
                    }

                    // Step 3: Send email if HOD found
                    if (hodEmail != null) {
                        final String finalHodEmail = hodEmail;
                        final String subject = "New Transport Request for Your Approval";
                        final String body = "Dear HOD,<br><br>" +
                                "A new transport request has been submitted by <b>" + fullName + "</b> from the <b>" + department + "</b> department.<br><br>" +
                                "<b>Request Details:</b><br>" +
                                "<b>Date:</b> " + travelDate + "<br>" +
                                "<b>Pickup:</b> " + pickupLocation + " at " + pickupTime + "<br>" +
                                "<b>Drop:</b> " + dropLocation + " at " + returnTime + "<br>" +
                                "<b>Reason:</b> " + reason + "<br><br>" +
                                "<b>Additional Employees:</b> " + (additionalEmployeesCount != null ? additionalEmployeesCount : "N/A") + "<br>" +
                                "<b>Remarks:</b> " + (remarks != null && !remarks.trim().isEmpty() ? remarks : "N/A") + "<br><br>" +
                                "Please log in to the system to review and approve or reject it.<br><br>" +
                                "Regards,<br>SCDL Transportation System";

                        new Thread(() -> {
                            try {
                                Mailer.sendMail(finalHodEmail, subject, body);
                            } catch (MessagingException | UnsupportedEncodingException e) {
                                System.err.println("Failed to send email to HOD: " + e.getMessage());
                                e.printStackTrace();
                            }
                        }).start();

                        request.setAttribute("success", "Transport request submitted successfully! An email has been sent to your HOD for approval.");
                    } else {
                        request.setAttribute("error", "Request submitted, but HOD email not found for your department.");
                    }
                } else {
                    request.setAttribute("error", "Failed to submit transport request.");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.getRequestDispatcher("transport-request.jsp").forward(request, response);
    }
}