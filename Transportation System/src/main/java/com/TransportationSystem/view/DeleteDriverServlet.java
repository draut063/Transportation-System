package com.TransportationSystem.view;

import com.TransportationSystem.model.DBconnect;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/DeleteDriverServlet")
public class DeleteDriverServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String driverIdStr = request.getParameter("driverId");

        if (action != null && action.equals("delete") && driverIdStr != null && !driverIdStr.isEmpty()) {
            int driverId = -1;
            Connection con = null;
            PreparedStatement ps = null;

            try {
                driverId = Integer.parseInt(driverIdStr);
                con = DBconnect.getConnection();

                // Check for any assigned trips for this driver
                String checkSql = "SELECT COUNT(*) FROM AssignedTrips WHERE driver_id = ? AND trip_status = 'Assigned'";
                PreparedStatement checkPs = con.prepareStatement(checkSql);
                checkPs.setInt(1, driverId);
                java.sql.ResultSet rs = checkPs.executeQuery();
                rs.next();
                int assignedTripsCount = rs.getInt(1);
                checkPs.close();
                rs.close();

                if (assignedTripsCount > 0) {
                    response.sendRedirect("SystemAdminpage.jsp?view=drivers&status=error&message=Cannot+Deleted+driver+as+they+are+assigned+to+an+ongoing+trip.");
                    return;
                }

                // Update the IsActive column to 0 (soft delete)
                String sql = "UPDATE Drivers SET IsActive = 0 WHERE driver_id = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, driverId);

                int rowsAffected = ps.executeUpdate();

                if (rowsAffected > 0) {
                    response.sendRedirect("SystemAdminpage.jsp?view=drivers&status=success&message=Driver+deactivated+successfully.");
                } else {
                    response.sendRedirect("SystemAdminpage.jsp?view=drivers&status=error&message=Driver+not+found+or+could+not+be+deactivated.");
                }

            } catch (NumberFormatException e) {
                response.sendRedirect("SystemAdminpage.jsp?view=drivers&status=error&message=Invalid+driver+ID+format.");
            } catch (SQLException e) {
                e.printStackTrace();
                response.sendRedirect("SystemAdminpage.jsp?view=drivers&status=error&message=Database+error+occurred.");
            } finally {
                try {
                    if (ps != null) ps.close();
                    if (con != null) con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        } else {
            response.sendRedirect("SystemAdminpage.jsp?view=drivers&status=error&message=Invalid+request.");
        }
    }
}
