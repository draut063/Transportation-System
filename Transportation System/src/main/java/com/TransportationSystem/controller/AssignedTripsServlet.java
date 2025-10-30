//package com.TransportationSystem.controller;
//
//import jakarta.servlet.*;
//import jakarta.servlet.http.*;
//import java.io.IOException;
//import java.sql.*;
//import java.util.ArrayList;
//
//public class AssignedTripsServlet extends HttpServlet {
//    /**
//	 * 
//	 */
//	private static final long serialVersionUID = 1L;
//
//	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//        HttpSession session = request.getSession(false);
//        if (session == null || session.getAttribute("driver_id") == null) {
//            response.sendRedirect("TS-Driverlogin.jsp");
//            return;
//        }
//
//        int driverId = (Integer) session.getAttribute("driver_id");
//        ArrayList<String[]> tripList = new ArrayList<>();
//
//        try {
//            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
//            Connection con = DriverManager.getConnection("jdbc:sqlserver://localhost;databaseName=YourDB;integratedSecurity=true");
//
//            String sql = "SELECT assignment_id, pickup_location, drop_location, assigned_time, status FROM AssignedTrips WHERE driver_id = ? AND CAST(assigned_time AS DATE) >= CAST(GETDATE() AS DATE)";
//            PreparedStatement ps = con.prepareStatement(sql);
//            ps.setInt(1, driverId);
//            ResultSet rs = ps.executeQuery();
//
//            while (rs.next()) {
//                String[] trip = new String[5];
//                trip[0] = String.valueOf(rs.getInt("assignment_id"));
//                trip[1] = rs.getString("pickup_location");
//                trip[2] = rs.getString("drop_location");
//                trip[3] = rs.getTimestamp("assigned_time").toString();
//                trip[4] = rs.getString("status");
//                tripList.add(trip);
//            }
//
//            rs.close();
//            ps.close();
//            con.close();
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//
//        request.setAttribute("tripList", tripList);
//        RequestDispatcher rd = request.getRequestDispatcher("TS-DriverDashboard.jsp");
//        rd.forward(request, response);
//    }
//}
