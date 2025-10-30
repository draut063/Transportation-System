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
import java.util.UUID;
import java.nio.file.Paths;

@WebServlet("/AccidentLogServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,       // 10MB
                 maxRequestSize = 1024 * 1024 * 50)    // 50MB
public class AccidentLogServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIRECTORY = "documents/accidents";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection con = null;
        PreparedStatement ps = null;
        String message = "";
        String status = "error";

        try {
            // Get form parameters
            int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
            int driverId = Integer.parseInt(request.getParameter("driverId"));
            String accidentDate = request.getParameter("accidentDate");
            double estimatedCost = Double.parseDouble(request.getParameter("estimatedCost"));
            String accidentDescription = request.getParameter("accidentDescription");

            // Get police complaint details
            String policeComplaintNumber = request.getParameter("policeComplaintNumber");
            String policeOfficerName = request.getParameter("policeOfficerName");
            String policeStationName = request.getParameter("policeStationName");
            String policeMobileNumber = request.getParameter("policeMobileNumber");

            // Define the upload path
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIRECTORY;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // Handle vehicle photo upload
            Part vehiclePhotoPart = request.getPart("vehiclePhoto");
            String vehiclePhotoPath = null;
            if (vehiclePhotoPart != null && vehiclePhotoPart.getSubmittedFileName() != null && !vehiclePhotoPart.getSubmittedFileName().isEmpty()) {
                String vehicleFileName = Paths.get(vehiclePhotoPart.getSubmittedFileName()).getFileName().toString();
                String uniqueVehicleFileName = UUID.randomUUID().toString() + "_" + vehicleFileName;
                String vehicleFilePath = uploadPath + File.separator + uniqueVehicleFileName;
                vehiclePhotoPart.write(vehicleFilePath);
                vehiclePhotoPath = UPLOAD_DIRECTORY + "/" + uniqueVehicleFileName;
            }

            // Handle accident photo upload
            Part accidentPhotoPart = request.getPart("accidentPhoto");
            String accidentPhotoPath = null;
            if (accidentPhotoPart != null && accidentPhotoPart.getSubmittedFileName() != null && !accidentPhotoPart.getSubmittedFileName().isEmpty()) {
                String accidentFileName = Paths.get(accidentPhotoPart.getSubmittedFileName()).getFileName().toString();
                String uniqueAccidentFileName = UUID.randomUUID().toString() + "_" + accidentFileName;
                String accidentFilePath = uploadPath + File.separator + uniqueAccidentFileName;
                accidentPhotoPart.write(accidentFilePath);
                accidentPhotoPath = UPLOAD_DIRECTORY + "/" + uniqueAccidentFileName;
            }

            // Database insertion
            con = DBconnect.getConnection();
            String sql = "INSERT INTO VehicleAccidentLogs (vehicle_id, driver_id, accident_date, accident_description, estimated_cost, police_complaint_number, police_officer_name, police_station_name, police_mobile_number, vehicle_photo_path, accident_photo_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            ps = con.prepareStatement(sql);
            ps.setInt(1, vehicleId);
            ps.setInt(2, driverId);
            ps.setString(3, accidentDate);
            ps.setString(4, accidentDescription);
            ps.setDouble(5, estimatedCost);
            ps.setString(6, policeComplaintNumber);
            ps.setString(7, policeOfficerName);
            ps.setString(8, policeStationName);
            ps.setString(9, policeMobileNumber);
            ps.setString(10, vehiclePhotoPath);
            ps.setString(11, accidentPhotoPath);

            int rowsAffected = ps.executeUpdate();

            if (rowsAffected > 0) {
                message = "Accident log added successfully.";
                status = "success";
            } else {
                message = "Failed to add accident log.";
            }

        } catch (Exception e) {
            e.printStackTrace();
            message = "An error occurred: " + e.getMessage();
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        response.sendRedirect("SystemAdminpage.jsp?view=accidents&status=" + status + "&message=" + java.net.URLEncoder.encode(message, "UTF-8"));
    }
}
