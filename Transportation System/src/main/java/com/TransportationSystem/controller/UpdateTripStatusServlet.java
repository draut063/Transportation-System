package com.TransportationSystem.controller;

import java.io.IOException;
import java.sql.*;

import com.TransportationSystem.model.DBconnect;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/UpdateTripStatusServlet")
public class UpdateTripStatusServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String assignmentIdStr = request.getParameter("assignment_id");
        String action = request.getParameter("action");

        int assignmentId = Integer.parseInt(assignmentIdStr);
        String newStatus = switch (action) {
            case "start" -> "On Trip";
            case "complete" -> "Completed";
            default -> "Assigned";
        };

        try (Connection con = DBconnect.getConnection()) {

            // Step 1: Update trip status
            String updateTripSql = "UPDATE AssignedTrips SET trip_status = ? WHERE assignment_id = ?";
            try (PreparedStatement ps = con.prepareStatement(updateTripSql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, assignmentId);
                ps.executeUpdate();
            }

            // Step 2: Get driver_id and vehicle_id from AssignedTrips
            int driverId = 0, vehicleId = 0;
            String fetchIdsSql = "SELECT driver_id, vehicle_id FROM AssignedTrips WHERE assignment_id = ?";
            try (PreparedStatement ps = con.prepareStatement(fetchIdsSql)) {
                ps.setInt(1, assignmentId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    driverId = rs.getInt("driver_id");
                    vehicleId = rs.getInt("vehicle_id");
                }
            }

            // Step 3: Update availability
            boolean isAvailable = action.equals("complete");

            String updateDriverSql = "UPDATE Drivers SET IsAvailable = ? WHERE driver_id = ?";
            try (PreparedStatement ps = con.prepareStatement(updateDriverSql)) {
                ps.setBoolean(1, isAvailable);
                ps.setInt(2, driverId);
                ps.executeUpdate();
            }

            String updateVehicleSql = "UPDATE Vehicles SET IsAvailable = ? WHERE vehicle_id = ?";
            try (PreparedStatement ps = con.prepareStatement(updateVehicleSql)) {
                ps.setBoolean(1, isAvailable);
                ps.setInt(2, vehicleId);
                ps.executeUpdate();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("DriverTripServlet");
    }
}
