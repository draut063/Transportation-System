package com.TransportationSystem.view;

import com.TransportationSystem.model.DBconnect;
import com.TransportationSystem.mail.Mailer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.mail.MessagingException;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDateTime;

@WebServlet("/AssignTripServlet")
public class AssignTripServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int requestId = Integer.parseInt(request.getParameter("requestId"));
        int driverId = Integer.parseInt(request.getParameter("driverId"));
        int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
        String timeStr = request.getParameter("assignedTime"); // Format: HH:mm
        Time assignedTime = Time.valueOf(timeStr + ":00");

        String assignSql = "INSERT INTO AssignedTrips (request_id, driver_id, vehicle_id, assigned_on, assigned_time, trip_status) " +
                           "VALUES (?, ?, ?, ?, ?, 'Assigned')";
        String updateReq = "UPDATE TransportRequests SET request_status = 'Assigned' WHERE request_id = ?";
        String updateDriver = "UPDATE Drivers SET IsAvailable = 0 WHERE driver_id = ?";
        String updateVehicle = "UPDATE Vehicles SET IsAvailable = 0 WHERE vehicle_id = ?";
        
        boolean success = false;
        String message = "";

        Connection con = null;
        try {
            con = DBconnect.getConnection();
            con.setAutoCommit(false); // Start transaction

            try (PreparedStatement ps1 = con.prepareStatement(assignSql);
                 PreparedStatement ps2 = con.prepareStatement(updateReq);
                 PreparedStatement ps3 = con.prepareStatement(updateDriver);
                 PreparedStatement ps4 = con.prepareStatement(updateVehicle)) {

                // Step 1: Insert into AssignedTrips
                ps1.setInt(1, requestId);
                ps1.setInt(2, driverId);
                ps1.setInt(3, vehicleId);
                ps1.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now()));
                ps1.setTime(5, assignedTime);
                ps1.executeUpdate();

                // Step 2: Update TransportRequest status
                ps2.setInt(1, requestId);
                ps2.executeUpdate();

                // Step 3: Update Driver and Vehicle availability
                ps3.setInt(1, driverId);
                ps3.executeUpdate();

                ps4.setInt(1, vehicleId);
                ps4.executeUpdate();

                // Step 4: Get trip details for email
                String sqlSelectTripDetails = "SELECT TR.full_name, TR.travel_date, TR.pickup_location, TR.drop_location, TR.pickup_time, V.vehicle_name, V.vehicle_number, D.full_name AS driver_name, D.mobile_number, TR.additional_employees_count, TR.remarks " +
                                              "FROM TransportRequests TR JOIN Vehicles V ON V.vehicle_id = ? JOIN Drivers D ON D.driver_id = ? WHERE TR.request_id = ?";
                
                String employeeName = null;
                String employeeEmail = null;

                try (PreparedStatement psSelectTripDetails = con.prepareStatement(sqlSelectTripDetails)) {
                    psSelectTripDetails.setInt(1, vehicleId);
                    psSelectTripDetails.setInt(2, driverId);
                    psSelectTripDetails.setInt(3, requestId);
                    
                    try (ResultSet rs = psSelectTripDetails.executeQuery()) {
                        if (rs.next()) {
                            employeeName = rs.getString("full_name");
                            String travelDate = rs.getString("travel_date");
                            String pickupLocation = rs.getString("pickup_location");
                            String dropLocation = rs.getString("drop_location");
                            String pickupTime = rs.getString("pickup_time");
                            String vehicleName = rs.getString("vehicle_name");
                            String vehicleNumber = rs.getString("vehicle_number");
                            String driverName = rs.getString("driver_name");
                            String driverMobile = rs.getString("mobile_number");
                            int additionalEmployees = rs.getInt("additional_employees_count");
                            String remarks = rs.getString("remarks");

                            // Step 5: Get employee email from EmployeesRegistration table
                            String sqlSelectEmail = "SELECT email FROM EmployeesRegistration WHERE full_name = ?";
                            try (PreparedStatement psSelectEmail = con.prepareStatement(sqlSelectEmail)) {
                                psSelectEmail.setString(1, employeeName);
                                try (ResultSet rsEmail = psSelectEmail.executeQuery()) {
                                    if (rsEmail.next()) {
                                        employeeEmail = rsEmail.getString("email");
                                    }
                                }
                            }
                            
                            // Step 6: Construct and send email using the new Mailer class
                            if (employeeEmail != null) {
                            	final String finalEmployeeEmail = employeeEmail;
                            	final String subject = "Your Trip Has Been Assigned!";
                            	final String body = "Dear " + employeeName + ",<br><br>"
                            	        + "Your transportation request has been successfully assigned.<br><br>"
                            	        + "<b>Trip Details:</b><br>"
                            	        + " - <b>Date:</b> " + travelDate + "<br>"
                            	        + " - <b>Pickup Location:</b> " + pickupLocation + "<br>"
                            	        + " - <b>Drop Location:</b> " + dropLocation + "<br>"
                            	        + " - <b>Pickup Time:</b> " + pickupTime + "<br>"
                            	        + " - <b>Additional Employees:</b> " + (additionalEmployees > 0 ? additionalEmployees : "N/A") + "<br>"
                            	        + " - <b>Remarks:</b> " + (remarks != null && !remarks.trim().isEmpty() ? remarks : "N/A") + "<br><br>"
                            	        + "<b>Vehicle:</b> " + vehicleName + " (" + vehicleNumber + ")<br>"
                            	        + "<b>Driver:</b> " + driverName + " (" + driverMobile + ")<br><br>"
                            	        + "Thank you,<br>"
                            	        + "SCDL Transportation Team";
                                new Thread(() -> {
                                    try {
                                        Mailer.sendMail(finalEmployeeEmail, subject, body);
                                    } catch (MessagingException e) {
                                        System.err.println("Failed to send email: " + e.getMessage());
                                        e.printStackTrace();
                                    } catch (UnsupportedEncodingException e) {
										// TODO Auto-generated catch block
										e.printStackTrace();
									}
                                }).start();
                            }
                        }
                    }
                }

                con.commit();
                success = true;
                message = "Trip successfully assigned and email sent.";

            } catch (SQLException e) {
                con.rollback();
                e.printStackTrace();
                message = "Database error: " + e.getMessage();
            }

        } catch (Exception e) {
            e.printStackTrace();
            message = "An unexpected error occurred: " + e.getMessage();
        } finally {
            if (con != null) {
                try {
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        String redirectURL = "SystemAdminpage.jsp?view=triprequests&status=" + (success ? "success" : "error")
                               + "&message=" + message.replace(" ", "%20");
        response.sendRedirect(redirectURL);
    }
}