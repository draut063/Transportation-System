package com.TransportationSystem.controller;

import java.io.File;
import java.io.IOException;
//import java.io.InputStream;
//import java.nio.file.Files;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.UUID;

import com.TransportationSystem.model.DBconnect;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/register-driver")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,  // 1MB
    maxFileSize = 2 * 1024 * 1024,    // 2MB
    maxRequestSize = 5 * 1024 * 1024  // 5MB total form data
)
public class driverRequestServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private static final String UPLOAD_DIR = "uploads"; // relative to webapp root

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get form fields
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String empId = request.getParameter("empId");
        String password = request.getParameter("password");
        String mobile = request.getParameter("mobile");
        String emergencyMobile = request.getParameter("emergencyMobile");
        String bloodGroup = request.getParameter("bloodGroup");

        // Handle file uploads
        Part photoPart = request.getPart("photo");
        Part licensePart = request.getPart("license");

        // Generate unique file names
        String photoFileName = UUID.randomUUID().toString() + "_" + getFileName(photoPart);
        String licenseFileName = UUID.randomUUID().toString() + "_" + getFileName(licensePart);

        // Absolute path to save files
        String appPath = request.getServletContext().getRealPath(""); // root path
        String uploadPath = appPath + File.separator + UPLOAD_DIR;

        // Create directory if it doesn't exist
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir();

        // Save files to disk
        String photoPath = UPLOAD_DIR + "/" + photoFileName;
        String licensePath = UPLOAD_DIR + "/" + licenseFileName;

        photoPart.write(uploadPath + File.separator + photoFileName);
        licensePart.write(uploadPath + File.separator + licenseFileName);

        // Insert into DB
        Connection conn = null;
        PreparedStatement ps = null;
        String sql = "INSERT INTO Drivers (full_name, emp_id, email, password, mobile_number, emergency_mobile, blood_group, photo_path, license_photo_path) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try {
            conn = DBconnect.getConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, name);
            ps.setString(2, empId);
            ps.setString(3, email);
            ps.setString(4, password); // Optional: hash password
            ps.setString(5, mobile);
            ps.setString(6, emergencyMobile);
            ps.setString(7, bloodGroup);
            ps.setString(8, photoPath);
            ps.setString(9, licensePath);

            int rowsInserted = ps.executeUpdate();
            if (rowsInserted > 0) {
                response.sendRedirect("driver-success.jsp");
            } else {
                response.getWriter().write("Error: Registration failed.");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("Database error: " + e.getMessage());
        } finally {
            try {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String token : contentDisp.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "default.png";
    }
}
