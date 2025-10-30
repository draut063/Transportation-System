package com.TransportationSystem.controller;

import com.TransportationSystem.model.DBconnect;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/register-employee")
public class RegisterEmployeeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Retrieve all form parameters
        String fullName = request.getParameter("fullName");
        String employeeId = request.getParameter("employeeId");
        String email = request.getParameter("email");
        String mobileNumber = request.getParameter("mobileNumber");
        String department = request.getParameter("department");
        String password = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        String errorMessage = null;

       
        if (fullName == null || fullName.isEmpty() || employeeId == null || employeeId.isEmpty() ||
            email == null || email.isEmpty() || mobileNumber == null || mobileNumber.isEmpty() ||
            department == null || department.isEmpty() || password == null || password.isEmpty() ||
            confirmPassword == null || confirmPassword.isEmpty()) {
            errorMessage = "All fields are required.";
        } else if (!password.equals(confirmPassword)) {
            errorMessage = "Passwords do not match.";
        }

        if (errorMessage != null) {
            request.getSession().setAttribute("errorMessage", errorMessage);
            response.sendRedirect("registration form.html");
            return;
        }

        Connection con = null;
        try {
            con = DBconnect.getConnection();
            
           
            String sql = "INSERT INTO EmployeesRegistration (full_name, employee_id, email, mobile_number, department, password) VALUES (?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, fullName);
                ps.setString(2, employeeId);
                ps.setString(3, email);
                ps.setString(4, mobileNumber);
                ps.setString(5, department);
                ps.setString(6, password); 
                
                int rowsAffected = ps.executeUpdate();
                
                if (rowsAffected > 0) {
                    request.getSession().setAttribute("successMessage", "Registration successful. You can now log in.");
                    response.sendRedirect("login.html");
                } else {
                    request.getSession().setAttribute("errorMessage", "Registration failed. Please try again.");
                    response.sendRedirect("registration form.html");
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            // Check for unique constraint violation errors (SQL Server)
            if (e.getMessage().contains("Violation of UNIQUE KEY constraint")) {
                 errorMessage = "An account with this Employee ID, Email, or Mobile Number already exists.";
            } else {
                 errorMessage = "An unexpected error occurred during registration.";
            }
            request.getSession().setAttribute("errorMessage", errorMessage);
            response.sendRedirect("registration form.html");
        } finally {
            try {
                if (con != null) {
                    con.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}