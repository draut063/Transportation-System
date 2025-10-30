package com.TransportationSystem.controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

import com.TransportationSystem.model.DBconnect;


@WebServlet("/login-employee")
public class LoginServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("username");
        String password = request.getParameter("password");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        
        try {
            con = DBconnect.getConnection();

            // Query
            String sql = "SELECT * FROM EmployeesRegistration WHERE email = ? AND password = ?";
             ps = con.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);

            rs = ps.executeQuery();

            if (rs.next()) {
                // Login success
                HttpSession session = request.getSession();
                session.setAttribute("employeeName", rs.getString("full_name"));
                session.setAttribute("employeeId", rs.getString("employee_id"));
                response.sendRedirect("transport-request.jsp"); 
            } else {
                // Login fail
                response.sendRedirect("login.html?error=invalid");
            }

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.html?error=invalid");
        }
    }
}
