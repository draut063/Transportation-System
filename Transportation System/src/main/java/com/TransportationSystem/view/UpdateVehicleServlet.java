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
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/UpdateVehicleServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class UpdateVehicleServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(UpdateVehicleServlet.class.getName());

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String redirectURL = "SystemAdminpage.jsp?view=vehicles&action=check";
        
        try {
            // Get required parameters and validate them
            String vehicleIdStr = request.getParameter("vehicleId");
            String vehicleName = request.getParameter("vehicleName");
            String vehicleNumber = request.getParameter("vehicleNumber");
            String capacityStr = request.getParameter("capacity");

            if (vehicleIdStr == null || vehicleIdStr.isEmpty() ||
                vehicleName == null || vehicleName.isEmpty() ||
                vehicleNumber == null || vehicleNumber.isEmpty() ||
                capacityStr == null || capacityStr.isEmpty()) {
                response.sendRedirect(redirectURL + "&status=error&message=Required fields are missing.");
                return;
            }

            int vehicleId = Integer.parseInt(vehicleIdStr);
            int capacity = Integer.parseInt(capacityStr);
            
            // Get optional parameters
            String insurancePolicyNumber = request.getParameter("insurancePolicyNumber");
            String insuranceExpiryDate = request.getParameter("insuranceExpiryDate");
            String pucCertificateNumber = request.getParameter("pucCertificateNumber");
            String pucExpiryDate = request.getParameter("pucExpiryDate");
            
            // Handle file upload
            Part otherPoliciesPart = request.getPart("otherPolicies");
            String otherPoliciesPath = null;
            boolean newFileUploaded = false;

            if (otherPoliciesPart != null && otherPoliciesPart.getSize() > 0) {
                String fileName = Paths.get(otherPoliciesPart.getSubmittedFileName()).getFileName().toString();
                if (!fileName.isEmpty()) {
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "documents";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdir();
                    }
                    String filePath = uploadPath + File.separator + fileName;
                    otherPoliciesPart.write(filePath);
                    otherPoliciesPath = "documents" + File.separator + fileName;
                    newFileUploaded = true;
                }
            }

            // Build the SQL query dynamically
            StringBuilder sqlBuilder = new StringBuilder("UPDATE Vehicles SET vehicle_name=?, vehicle_number=?, capacity=?, insurance_policy_number=?, insurance_expiry_date=?, puc_certificate_number=?, puc_expiry_date=?");
            if (newFileUploaded) {
                sqlBuilder.append(", other_policies_path=?");
            }
            sqlBuilder.append(" WHERE vehicle_id=?");
            String sql = sqlBuilder.toString();

            try (Connection con = DBconnect.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                
                int paramIndex = 1;
                ps.setString(paramIndex++, vehicleName);
                ps.setString(paramIndex++, vehicleNumber);
                ps.setInt(paramIndex++, capacity);
                ps.setString(paramIndex++, insurancePolicyNumber);
                
                // Handle optional date fields by converting them to SQL Date or setting null
                if (insuranceExpiryDate != null && !insuranceExpiryDate.isEmpty()) {
                    ps.setDate(paramIndex++, java.sql.Date.valueOf(insuranceExpiryDate));
                } else {
                    ps.setNull(paramIndex++, java.sql.Types.DATE);
                }
                
                ps.setString(paramIndex++, pucCertificateNumber);

                if (pucExpiryDate != null && !pucExpiryDate.isEmpty()) {
                    ps.setDate(paramIndex++, java.sql.Date.valueOf(pucExpiryDate));
                } else {
                    ps.setNull(paramIndex++, java.sql.Types.DATE);
                }

                if (newFileUploaded) {
                    ps.setString(paramIndex++, otherPoliciesPath);
                }
                
                ps.setInt(paramIndex, vehicleId);

                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    response.sendRedirect(redirectURL + "&status=success&message=Vehicle updated successfully.");
                } else {
                    response.sendRedirect(redirectURL + "&status=error&message=Vehicle not found or no changes were made.");
                }
            }

        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Invalid number format", e);
            response.sendRedirect(redirectURL + "&status=error&message=Invalid ID or capacity format.");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error", e);
            // Check for unique constraint violation (if vehicle_number is unique)
            if (e.getErrorCode() == 2627) { // SQL Server error code for unique constraint violation
                response.sendRedirect(redirectURL + "&status=error&message=Vehicle number already exists.");
            } else {
                response.sendRedirect(redirectURL + "&status=error&message=Database error: " + e.getMessage());
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "An unexpected error occurred", e);
            response.sendRedirect(redirectURL + "&status=error&message=An unexpected error occurred.");
        }
    }
}