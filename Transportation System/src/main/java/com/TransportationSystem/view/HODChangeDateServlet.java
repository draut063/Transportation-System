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

@WebServlet("/HOD-ChangeDateServlet")
public class HODChangeDateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection con = DBconnect.getConnection()) {
            int requestId = Integer.parseInt(request.getParameter("request_id"));
            String newTravelDateStr = request.getParameter("newTravelDate");
            LocalDate newTravelDate = LocalDate.parse(newTravelDateStr);

            // --- Step 1: Validate new date is not in the past
            if (newTravelDate.isBefore(LocalDate.now())) {
                response.sendRedirect("hod-dashboard.jsp?status=error&message=New date cannot be in the past.");
                return;
            }

            // --- Step 2: Get employee details to send notification
            String employeeEmail = null;
            String employeeName = null;
            try (PreparedStatement selectPs = con.prepareStatement(
                    "SELECT E.email AS employee_email, TR.full_name FROM TransportRequests TR " +
                    "JOIN EmployeesRegistration E ON TR.full_name = E.full_name " +
                    "WHERE TR.request_id = ?")) {
                selectPs.setInt(1, requestId);
                try (ResultSet rs = selectPs.executeQuery()) {
                    if (rs.next()) {
                        employeeEmail = rs.getString("employee_email");
                        employeeName = rs.getString("full_name");
                    }
                }
            }

            if (employeeEmail == null) {
                response.sendRedirect("hod-dashboard.jsp?status=error&message=Request not found.");
                return;
            }

            // --- Step 3: Update the travel_date in the database
            try (PreparedStatement updatePs = con.prepareStatement(
                    "UPDATE TransportRequests SET travel_date = ? WHERE request_id = ?")) {
                updatePs.setObject(1, newTravelDate);
                updatePs.setInt(2, requestId);
                int updated = updatePs.executeUpdate();

                if (updated > 0) {
                    // --- Step 4: Send an email notification to the employee
                    String subject = "Your Transport Request Date Has Been Changed";
                    String body = String.format("Dear %s,<br><br>" +
                            "Your transport request (ID: %d) travel date has been changed to %s by your HOD.<br><br>" +
                            "Please log in to the system to view the updated details.<br><br>" +
                            "Regards,<br><br>SCDL Transportation System", employeeName, requestId, newTravelDateStr);
                    
                    final String finalEmployeeEmail = employeeEmail;
                    final String finalSubject = subject;
                    final String finalBody = body;
                    new Thread(() -> {
                        try {
                            Mailer.sendMail(finalEmployeeEmail, finalSubject, finalBody);
                        } catch (MessagingException | UnsupportedEncodingException e) {
                            System.err.println("Failed to send date change email: " + e.getMessage());
                            e.printStackTrace();
                        }
                    }).start();

                    response.sendRedirect("hod-dashboard.jsp?status=success&message=Travel date updated successfully.");
                } else {
                    response.sendRedirect("hod-dashboard.jsp?status=error&message=Failed to update travel date.");
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