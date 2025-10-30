package com.TransportationSystem.view;

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

@WebServlet("/CombineTripServlet")
public class CombineTripServle extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
        String redirectURL = "SystemAdminpage.jsp?view=triprequests";

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBconnect.getConnection();
            con.setAutoCommit(false);

            // Step 1: Find the assigned trip for the selected vehicle that is not full
            String sqlFindTrip = "SELECT assignment_id FROM AssignedTrips WHERE vehicle_id = ? AND trip_status = 'Assigned'";
            ps = con.prepareStatement(sqlFindTrip);
            ps.setInt(1, vehicleId);
            rs = ps.executeQuery();
            
            int assignmentId = -1;
            if (rs.next()) {
                assignmentId = rs.getInt("assignment_id");
            }
            
            rs.close();
            ps.close();

            if (assignmentId != -1) {
                // Step 2: Increment the person_count for the existing trip
                String sqlUpdateTrip = "UPDATE AssignedTrips SET person_count = person_count + 1 WHERE assignment_id = ?";
                ps = con.prepareStatement(sqlUpdateTrip);
                ps.setInt(1, assignmentId);
                ps.executeUpdate();
                ps.close();

                // Step 3: Update the original request status
                String sqlUpdateRequest = "UPDATE TransportRequests SET request_status = 'Assigned' WHERE request_id = ?";
                ps = con.prepareStatement(sqlUpdateRequest);
                ps.setInt(1, requestId);
                ps.executeUpdate();

                con.commit();
                redirectURL += "&status=success&message=Employee added to existing trip successfully.";
            } else {
                con.rollback();
                redirectURL += "&status=error&message=Could not find an ongoing trip to add employee to.";
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