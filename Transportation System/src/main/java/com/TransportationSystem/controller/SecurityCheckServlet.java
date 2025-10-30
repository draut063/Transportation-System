package com.TransportationSystem.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDateTime;

import com.TransportationSystem.model.DBconnect;

@WebServlet("/SecurityCheckServlet")
public class SecurityCheckServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Session validation
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("securityUser") == null) {
            response.sendRedirect("TS-SecurityLogin.jsp");
            return;
        }

        // 2. Get parameters from the form
        int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
        String action = request.getParameter("action");
        String redirectURL = "TS-SecurityPage.jsp";
        
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            con = DBconnect.getConnection();
            String sql;
            
            if ("start".equals(action)) {
                // Safely get the odometer value and check for null before parsing
                String odometerStartStr = request.getParameter("odometer_start");
                if (odometerStartStr == null || odometerStartStr.trim().isEmpty()) {
                    response.sendRedirect(redirectURL + "?status=error&message=Odometer start value is required.");
                    return;
                }
                int odometerStart = Integer.parseInt(odometerStartStr);

                sql = "UPDATE AssignedTrips SET odometer_start = ?, trip_status = 'On Trip', open_time = ? WHERE assignment_id = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, odometerStart);
                ps.setObject(2, LocalDateTime.now());
                ps.setInt(3, assignmentId);
                
            } else if ("end".equals(action)) {
                // Safely get the odometer value and check for null before parsing
                String odometerEndStr = request.getParameter("odometer_end");
                if (odometerEndStr == null || odometerEndStr.trim().isEmpty()) {
                    response.sendRedirect(redirectURL + "?status=error&message=Odometer end value is required.");
                    return;
                }
                int odometerEnd = Integer.parseInt(odometerEndStr);
                
                sql = "UPDATE AssignedTrips SET odometer_end = ?, trip_status = 'Completed', return_time = ? WHERE assignment_id = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, odometerEnd);
                ps.setObject(2, LocalDateTime.now());
                ps.setInt(3, assignmentId);
                
            } else {
                response.sendRedirect(redirectURL + "?status=error&message=Invalid action.");
                return;
            }

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                response.sendRedirect(redirectURL + "?status=success&message=Trip " + action + " successful!");
            } else {
                response.sendRedirect(redirectURL + "?status=error&message=Failed to update trip record.");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect(redirectURL + "?status=error&message=Invalid odometer value. Please enter a valid number.");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(redirectURL + "?status=error&message=Database error occurred.");
        } finally {
            // Close resources
            try { if (ps != null) ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}