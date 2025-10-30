package com.TransportationSystem.view;

import com.TransportationSystem.model.DBconnect;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/VehicleServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class VehicleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String redirectURL = "SystemAdminpage.jsp?view=vehicles";

        if ("delete".equals(action)) {
            deleteVehicle(request, response, redirectURL);
        } else if ("add".equals(action)) {
            addVehicle(request, response, redirectURL);
        } else if ("update".equals(action)) {
            // Placeholder for update logic, which should be in UpdateVehicleServlet based on previous code.
            // You can move the logic from UpdateVehicleServlet here if you want to consolidate.
            response.sendRedirect(redirectURL + "&status=error&message=Update action not handled by this servlet.");
        } else {
            response.sendRedirect(redirectURL + "&status=error&message=Invalid action.");
        }
    }

    private void deleteVehicle(HttpServletRequest request, HttpServletResponse response, String redirectURL) throws IOException {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
            
            con = DBconnect.getConnection();
            String sql = "UPDATE Vehicles SET IsActive = 0 WHERE vehicle_id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, vehicleId);
            int rowsAffected = ps.executeUpdate();

            if (rowsAffected > 0) {
                redirectURL += "&status=success&message=Vehicle deleted successfully.";
            } else {
                redirectURL += "&status=error&message=Vehicle not found or could not be deleted.";
            }

        } catch (SQLException e) {
            // Check for foreign key constraint violation
            if (e.getErrorCode() == 547) { // SQL Server error code for foreign key violation
                redirectURL += "&status=error&message=Cannot delete vehicle. It is associated with a driver or trip.";
            } else {
                e.printStackTrace();
                redirectURL += "&status=error&message=Database error: " + e.getMessage();
            }
        } catch (NumberFormatException e) {
            redirectURL += "&status=error&message=Invalid vehicle ID.";
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect(redirectURL);
    }
    
    private void addVehicle(HttpServletRequest request, HttpServletResponse response, String redirectURL) throws ServletException, IOException {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            // Get required parameters
            String vehicleName = request.getParameter("vehicleName");
            String vehicleNumber = request.getParameter("vehicleNumber");
            String capacityStr = request.getParameter("capacity");

            // Validate required fields
            if (vehicleName == null || vehicleName.isEmpty() ||
                vehicleNumber == null || vehicleNumber.isEmpty() ||
                capacityStr == null || capacityStr.isEmpty()) {
                response.sendRedirect(redirectURL + "&status=error&message=Vehicle name, number, and capacity are required.");
                return;
            }

            int capacity = Integer.parseInt(capacityStr);
            
            // Get optional parameters
            String insurancePolicyNumber = request.getParameter("insurancePolicyNumber");
            String insuranceExpiryDate = request.getParameter("insuranceExpiryDate");
            String pucCertificateNumber = request.getParameter("pucCertificateNumber");
            String pucExpiryDate = request.getParameter("pucExpiryDate");
            Part otherPoliciesPart = request.getPart("otherPolicies");

            // Handle file upload
            String otherPoliciesPath = null;
            if (otherPoliciesPart != null && otherPoliciesPart.getSize() > 0) {
                String uploadsPath = getServletContext().getRealPath("") + File.separator + "documents";
                File uploadsDir = new File(uploadsPath);
                if (!uploadsDir.exists()) {
                    uploadsDir.mkdirs();
                }
                String fileName = new File(otherPoliciesPart.getSubmittedFileName()).getName();
                if (!fileName.isEmpty()) {
                    String filePath = uploadsPath + File.separator + fileName;
                    otherPoliciesPart.write(filePath);
                    otherPoliciesPath = "documents" + File.separator + fileName;
                }
            }

            con = DBconnect.getConnection();
            String sql = "INSERT INTO Vehicles (vehicle_name, vehicle_number, capacity, insurance_policy_number, insurance_expiry_date, puc_certificate_number, puc_expiry_date, other_policies_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            
            ps = con.prepareStatement(sql);
            ps.setString(1, vehicleName);
            ps.setString(2, vehicleNumber);
            ps.setInt(3, capacity);
            ps.setString(4, insurancePolicyNumber);
            
            if (insuranceExpiryDate != null && !insuranceExpiryDate.isEmpty()) {
                ps.setDate(5, java.sql.Date.valueOf(insuranceExpiryDate));
            } else {
                ps.setNull(5, java.sql.Types.DATE);
            }
            
            ps.setString(6, pucCertificateNumber);

            if (pucExpiryDate != null && !pucExpiryDate.isEmpty()) {
                ps.setDate(7, java.sql.Date.valueOf(pucExpiryDate));
            } else {
                ps.setNull(7, java.sql.Types.DATE);
            }

            ps.setString(8, otherPoliciesPath);
            
            int rowsAffected = ps.executeUpdate();

            if (rowsAffected > 0) {
                response.sendRedirect(redirectURL + "&status=success&message=Vehicle added successfully.");
            } else {
                response.sendRedirect(redirectURL + "&status=error&message=Failed to add vehicle.");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(redirectURL + "&status=error&message=Invalid capacity format. Please enter a number.");
        } catch (SQLException e) {
            e.printStackTrace();
            if (e.getErrorCode() == 2627) { // SQL Server error code for unique constraint violation
                response.sendRedirect(redirectURL + "&status=error&message=Vehicle number already exists.");
            } else {
                response.sendRedirect(redirectURL + "&status=error&message=Database error: " + e.getMessage());
            }
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}