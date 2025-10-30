package com.TransportationSystem.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.TransportationSystem.model.DBconnect;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/CompletedriverTripServlet")
public class completedrivertripservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
        String redirectURL = "TStrip-infopage.jsp?view=assignedtrips";
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBconnect.getConnection();
            con.setAutoCommit(false);

            // Step 1: Get vehicle_id and driver_id from the assigned trip
            String sqlSelect = "SELECT driver_id, vehicle_id FROM AssignedTrips WHERE assignment_id = ?";
            ps = con.prepareStatement(sqlSelect);
            ps.setInt(1, assignmentId);
            rs = ps.executeQuery();

            int driverId = -1;
            int vehicleId = -1;
            if (rs.next()) {
                driverId = rs.getInt("driver_id");
                vehicleId = rs.getInt("vehicle_id");
            }
            
            ps.close();
            rs.close();

            if (driverId != -1 && vehicleId != -1) {
                // Step 2: Update the trip status to 'Completed'
                String sqlUpdateTrip = "UPDATE AssignedTrips SET trip_status = 'Completed' WHERE assignment_id = ?";
                ps = con.prepareStatement(sqlUpdateTrip);
                ps.setInt(1, assignmentId);
                ps.executeUpdate();
                ps.close();

                // Step 3: Mark the driver as available again
                String sqlUpdateDriver = "UPDATE Drivers SET IsAvailable = 1 WHERE driver_id = ?";
                ps = con.prepareStatement(sqlUpdateDriver);
                ps.setInt(1, driverId);
                ps.executeUpdate();
                ps.close();

                // Step 4: Mark the vehicle as available again
                String sqlUpdateVehicle = "UPDATE Vehicles SET IsAvailable = 1 WHERE vehicle_id = ?";
                ps = con.prepareStatement(sqlUpdateVehicle);
                ps.setInt(1, vehicleId);
                ps.executeUpdate();
                
                con.commit();
                redirectURL += "&status=success&message=Trip marked as completed and resources freed.";

            } else {
                con.rollback();
                redirectURL += "&status=error&message=Trip not found.";
            }

        } catch (SQLException e) {
            try { if (con != null) con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            e.printStackTrace();
            redirectURL += "&status=error&message=Database error: " + e.getMessage();
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
        
        response.sendRedirect(redirectURL);
    }
}