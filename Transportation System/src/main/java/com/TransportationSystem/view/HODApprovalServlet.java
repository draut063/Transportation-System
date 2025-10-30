package com.TransportationSystem.view;

import com.TransportationSystem.mail.Mailer;
import com.TransportationSystem.model.DBconnect;
import jakarta.mail.MessagingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

@WebServlet("/HOD-ApprovalServlet")
public class HODApprovalServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Use a single database connection throughout the request lifecycle
        try (Connection con = DBconnect.getConnection()) {
            int requestId = Integer.parseInt(request.getParameter("request_id"));
            String action = request.getParameter("action");

            // --- Step 1: Get employee details for the email, and ensure the request is valid
            String employeeEmail = null;
            String employeeName = null;

            // Using a single PreparedStatement for efficiency
            try (PreparedStatement selectPs = con.prepareStatement(
                    "SELECT E.email AS employee_email, TR.full_name FROM TransportRequests TR " +
                    "JOIN EmployeesRegistration E ON TR.full_name = E.full_name " +
                    "WHERE TR.request_id = ? AND TR.request_status = 'Pending' AND TR.travel_date >= ?")) { // Updated query with date check

                selectPs.setInt(1, requestId);
                selectPs.setObject(2, LocalDate.now()); // Set today's date for the check
                try (ResultSet rs = selectPs.executeQuery()) {
                    if (rs.next()) {
                        employeeEmail = rs.getString("employee_email");
                        employeeName = rs.getString("full_name");
                    }
                }
            }

            // --- Validation: If employee details are not found, or the request is not pending/in the future, redirect.
            if (employeeEmail == null) {
                response.sendRedirect("hod-dashboard.jsp?status=error&message=Invalid, already processed, or past request.");
                return;
            }

            // --- Step 2: Update the request status in the database
            try (PreparedStatement updatePs = con.prepareStatement(
                    "UPDATE TransportRequests SET request_status = ? WHERE request_id = ?")) {

                updatePs.setString(1, action); // "Approved" or "Rejected"
                updatePs.setInt(2, requestId);
                int updated = updatePs.executeUpdate();

                if (updated > 0) {
                    // --- Step 3: Send email notifications based on the action
                    String subject;
                    String body;
                    final String finalEmployeeEmail = employeeEmail;
                    final String finalEmployeeName = employeeName;
                    final int finalRequestId = requestId;

                    if ("Approved".equals(action)) {
                        String adminEmail = null;
                        try (PreparedStatement psAdmin = con.prepareStatement(
                                "SELECT email FROM SystemUsers WHERE role = 'Admin'")) {
                            try (ResultSet rsAdmin = psAdmin.executeQuery()) {
                                if (rsAdmin.next()) {
                                    adminEmail = rsAdmin.getString("email");
                                }
                            }
                        }

                        if (adminEmail != null) {
                            subject = "Transport Request Approved: Ready for Assignment";
                             body = String.format("Dear Admin,<br><br>" +
                                    "A transport request for <b>%s</b> has been approved by the HOD. Please assign a vehicle and driver for this request.<br><br>" +
                                    "Regards,<br>SCDL Transportation System", finalEmployeeName, finalRequestId);

                            final String finalAdminEmail = adminEmail;
                            new Thread(() -> {
                                try {
                                    Mailer.sendMailWithCC(finalAdminEmail, finalEmployeeEmail, subject, body);
                                } catch (MessagingException | UnsupportedEncodingException e) {
                                    System.err.println("Failed to send approval email: " + e.getMessage());
                                    e.printStackTrace();
                                }
                            }).start();
                        } else {
                            System.err.println("Admin email not found in the database. Cannot send approval notification.");
                        }

                    } else if ("Rejected".equals(action)) {
                        subject = "Your Transport Request Has Been Rejected";
                        body = String.format("Dear %s,\n\nWe regret to inform you that your transport request (ID: %d) has been rejected by your HOD. Please log in to the system for more details.\n\nRegards,\nSCDL Transportation System", finalEmployeeName, finalRequestId);

                        new Thread(() -> {
                            try {
                                Mailer.sendMail(finalEmployeeEmail, subject, body);
                            } catch (MessagingException | UnsupportedEncodingException e) {
                                System.err.println("Failed to send rejection email: " + e.getMessage());
                                e.printStackTrace();
                            }
                        }).start();
                    }

                    response.sendRedirect("hod-dashboard.jsp?status=success");
                } else {
                    response.sendRedirect("hod-dashboard.jsp?status=error&message=Failed to update request status.");
                }
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("hod-dashboard.jsp?status=error&message=Invalid request ID format.");
        } catch (SQLException e) {
            System.err.println("SQL error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("hod-dashboard.jsp?status=error&message=Database error occurred.");
        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("hod-dashboard.jsp?status=error&message=An unexpected error occurred.");
        }
    }
}