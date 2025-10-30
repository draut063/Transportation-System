package com.TransportationSystem.logs;

import com.TransportationSystem.model.DBconnect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/AddPetrolServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 5, maxRequestSize = 1024 * 1024 * 5 * 5)
public class AddPetrolServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIR = "uploads/petrol_bills";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String driverEmail = (String) session.getAttribute("driver_email");
        if (driverEmail == null) {
            response.sendRedirect("TStrip-infopage.jsp");
            return;
        }
        
        String vehicleNumber = request.getParameter("vehicleNumber");
        String petrolLitersStr = request.getParameter("petrolLiters");
        String petrolAmountStr = request.getParameter("petrolAmount");
        Part filePart = request.getPart("petrolBill");

        // Validate input
        if (vehicleNumber == null || petrolLitersStr == null || petrolAmountStr == null || filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("TStrip-infopage.jsp?error=invalid_input");
            return;
        }

        try (Connection con = DBconnect.getConnection()) {
            // Get driver_id
            int driverId = -1;
            String getDriverIdSql = "SELECT driver_id FROM Drivers WHERE email = ?";
            PreparedStatement ps1 = con.prepareStatement(getDriverIdSql);
            ps1.setString(1, driverEmail);
            ResultSet rs1 = ps1.executeQuery();
            if (rs1.next()) {
                driverId = rs1.getInt("driver_id");
            } else {
                response.sendRedirect("TStrip-infopage.jsp?error=driver_not_found");
                return;
            }

            // Get vehicle_id
            int vehicleId = -1;
            String getVehicleIdSql = "SELECT vehicle_id FROM Vehicles WHERE vehicle_number = ?";
            PreparedStatement ps2 = con.prepareStatement(getVehicleIdSql);
            ps2.setString(1, vehicleNumber);
            ResultSet rs2 = ps2.executeQuery();
            if (rs2.next()) {
                vehicleId = rs2.getInt("vehicle_id");
            } else {
                response.sendRedirect("TStrip-infopage.jsp?error=vehicle_not_found");
                return;
            }
            
            // File upload logic
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            Path uploadDir = Paths.get(uploadPath);
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }
            Path filePath = uploadDir.resolve(fileName);
            try (InputStream fileContent = filePart.getInputStream()) {
                Files.copy(fileContent, filePath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            }
            String billPhotoPath = UPLOAD_DIR + "/" + fileName;

            // Insert into VehiclePetrolLogs table
            String insertSql = "INSERT INTO VehiclePetrolLogs (vehicle_id, driver_id, petrol_liters, cost, bill_photo_path, log_date) VALUES (?, ?, ?, ?, ?, GETDATE())";
            PreparedStatement ps3 = con.prepareStatement(insertSql);
            ps3.setInt(1, vehicleId);
            ps3.setInt(2, driverId);
            ps3.setDouble(3, Double.parseDouble(petrolLitersStr));
            ps3.setDouble(4, Double.parseDouble(petrolAmountStr));
            ps3.setString(5, billPhotoPath);
            
            int rowsAffected = ps3.executeUpdate();
            
            if (rowsAffected > 0) {
                response.sendRedirect("TStrip-infopage.jsp?success=petrol_log_added");
            } else {
                response.sendRedirect("TStrip-infopage.jsp?error=failed_to_add_petrol_log");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("TS-DriverDashboard.jsp?error=database_error");
        }
    }
}