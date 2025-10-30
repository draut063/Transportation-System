package com.TransportationSystem.view;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.TransportationSystem.model.DBconnect;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/SystemUser-login")
public class SystemUserloginservlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Retrieve and sanitize input
        String email = request.getParameter("username");
        String password = request.getParameter("password");

        if (email != null) email = email.trim();
        if (password != null) password = password.trim();

        // Basic input validation
        if (email == null || password == null || email.isEmpty() || password.isEmpty()) {
            response.sendRedirect("TS-SecurityLogin.jsp?error=Please enter both email and password");
            return;
        }

        String sql = "SELECT * FROM SystemUsers WHERE email = ? AND password = ? AND is_active = 1";

        try (Connection con = DBconnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password); // If using hashed passwords, hash before comparing

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // Extract user details
                String name = rs.getString("name");
                String role = rs.getString("role");
                String department = rs.getString("department");
                String employeeId = rs.getString("employee_id");

                // Create session and store attributes
                HttpSession session = request.getSession();
                session.setAttribute("employeeName", name);
                session.setAttribute("employeeId", employeeId);
                session.setAttribute("userEmail", email);
                session.setAttribute("role", role);
                session.setAttribute("department", department);
                session.setMaxInactiveInterval(30 * 60); // Optional: 30-minute session timeout

                // Debug logging
                //System.out.println("Login successful for: " + name + " | Role: " + role);

                // Redirect based on role
                switch (role.toLowerCase()) {
                    case "admin":
                        response.sendRedirect("SystemAdminpage.jsp");
                        break;
                    case "hod":
                        response.sendRedirect("hod-dashboard.jsp");
                        break;
                    case "security":
                        session.setAttribute("securityUser", name); // Optional: for security page
                        response.sendRedirect("TS-SecurityPage.jsp");
                        break;
                    default:
                        response.sendRedirect("TS-SecurityLogin.jsp?error=Unauthorized role");
                        break;
                }

            } else {
                // Login failed
              //  System.out.println("Login failed for email: " + email);
                response.sendRedirect("login.html?error=Invalid email or password");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("TS-SecurityLogin.jsp?error=Server error");
        }
    }
}
