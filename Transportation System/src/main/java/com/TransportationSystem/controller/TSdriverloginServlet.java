package com.TransportationSystem.controller;

import com.TransportationSystem.model.DBconnect;
import com.TransportationSystem.dao.TripDAO;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.List;

@WebServlet("/TS-DriverLoginServlet")
public class TSdriverloginServlet extends HttpServlet {
	
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
                          throws ServletException, IOException {

        String email    = request.getParameter("username");
        String password = request.getParameter("password");

        String sql = """
            SELECT driver_id, full_name, photo_path
              FROM Drivers
             WHERE email = ? AND password = ?
            """;

        try (Connection con = DBconnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // --- 1) Read driver info ---
                    int    driverId  = rs.getInt("driver_id");
                    String fullName  = rs.getString("full_name");
                    String photoPath = rs.getString("photo_path");

                    // --- 2) Store in session ---
                    HttpSession session = request.getSession();
                    session.setAttribute("driver_id",    driverId);
                    session.setAttribute("driver_email", email);
                    session.setAttribute("full_name",    fullName);
                    session.setAttribute("photo_path",   photoPath);

                    // --- 3) Fetch assigned trips for this driver ---
                    List<String[]> tripList = TripDAO.getTripsByDriverId(driverId);

                    // --- 4) Put into request and forward to JSP ---
                    request.setAttribute("tripList", tripList);
                    RequestDispatcher rd = request.getRequestDispatcher("TStrip-infopage.jsp");
                    rd.forward(request, response);
                    return;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // if DB error, return to login with an error flag
            response.sendRedirect("TS-Driverlogin.jsp?error=database");
            return;
        }

        // --- invalid credentials: back to login ---
        response.sendRedirect("TS-Driverlogin.jsp?error=invalid");
    }
}
