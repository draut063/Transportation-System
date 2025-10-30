package com.TransportationSystem.controller;

import com.TransportationSystem.dao.TripDAO;
import com.TransportationSystem.model.DBconnect;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/StartTripServlet")
public class StartTripServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int assnId = Integer.parseInt(req.getParameter("assignmentId"));
        TripDAO.updateTripStatus(assnId, "On Trip");
        resp.sendRedirect("DriverTripServlet");
        
        
        
       
            String sql = """
                UPDATE AssignedTrips
                   SET trip_status = ?,
                       open_time = CASE WHEN ? = 'On Trip' THEN GETDATE() ELSE open_time END,
                       return_time = CASE WHEN ? = 'Completed' THEN GETDATE() ELSE return_time END
                 WHERE assignment_id = ?
            """;

            try (Connection con = DBconnect.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                String status = null;
				ps.setString(1, status);
                ps.setString(2, status);
                ps.setString(3, status);
                int assignmentId = 0;
				ps.setInt(4, assignmentId);

                int updated = ps.executeUpdate();
                if (updated == 0) {
                    System.err.println("No trip found for assignment ID: " + assignmentId);
                }

            } catch (Exception e) {
                e.printStackTrace();
            }
        }

    }


