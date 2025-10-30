//package com.TransportationSystem.mail;
//
//import com.TransportationSystem.model.DBconnect;
//import jakarta.mail.MessagingException;
//import java.io.UnsupportedEncodingException;
//import java.sql.Connection;
//import java.sql.PreparedStatement;
//import java.sql.ResultSet;
//import java.sql.SQLException;
//import java.text.SimpleDateFormat;
//import java.time.LocalDate;
//import java.time.temporal.ChronoUnit;
//import java.util.Date;
//import java.util.Timer;
//import java.util.TimerTask;
//
//public class PolicyReminderTask {
//
//    // Schedule the task to run daily
//    public void startScheduler() {
//        Timer timer = new Timer();
//        timer.scheduleAtFixedRate(new TimerTask() {
//            @Override
//            public void run() {
//                System.out.println("Running daily policy check...");
//                checkExpiringPolicies();
//            }
//        }, 0, 24 * 60 * 60 * 1000); // 24 hours in milliseconds
//    }
//
//    private void checkExpiringPolicies() {
//        checkExpiringPucCertificates();
//        checkExpiringInsurancePolicies();
//    }
//    
//    private String getAdminEmail() throws SQLException {
//        try (Connection con = DBconnect.getConnection()) {
//            String sql = "SELECT email FROM SystemUsers WHERE role = 'Admin'";
//            try (PreparedStatement ps = con.prepareStatement(sql);
//                 ResultSet rs = ps.executeQuery()) {
//                if (rs.next()) {
//                    return rs.getString("email");
//                }
//            }
//        }
//        return null; // Return null if no admin email is found
//    }
//
//    private void checkExpiringPucCertificates() {
//        try (Connection con = DBconnect.getConnection()) {
//            LocalDate today = LocalDate.now();
//
//            String sql = "SELECT vehicle_name, vehicle_number, puc_expiry_date FROM Vehicles WHERE DATEDIFF(day, GETDATE(), puc_expiry_date) <= 7";
//            
//            try (PreparedStatement ps = con.prepareStatement(sql);
//                 ResultSet rs = ps.executeQuery()) {
//                
//                while (rs.next()) {
//                    String vehicleName = rs.getString("vehicle_name");
//                    String vehicleNumber = rs.getString("vehicle_number");
//                    java.sql.Date expiryDateSql = rs.getDate("puc_expiry_date");
//                    
//                    LocalDate expiryDate = expiryDateSql.toLocalDate();
//                    
//                    long daysUntilExpiry = ChronoUnit.DAYS.between(today, expiryDate);
//
//                    if (daysUntilExpiry <= 7) {
//                        sendReminderEmail("PUC", vehicleName, vehicleNumber, expiryDateSql);
//                    }
//                }
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
//
//    private void checkExpiringInsurancePolicies() {
//        try (Connection con = DBconnect.getConnection()) {
//            String sql = "SELECT vehicle_name, vehicle_number, insurance_expiry_date FROM Vehicles WHERE DATEDIFF(day, GETDATE(), insurance_expiry_date) <= 27";
//            
//            try (PreparedStatement ps = con.prepareStatement(sql);
//                 ResultSet rs = ps.executeQuery()) {
//                
//                while (rs.next()) {
//                    String vehicleName = rs.getString("vehicle_name");
//                    String vehicleNumber = rs.getString("vehicle_number");
//                    java.sql.Date expiryDateSql = rs.getDate("insurance_expiry_date");
//                    
//                    sendReminderEmail("Insurance", vehicleName, vehicleNumber, expiryDateSql);
//                }
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
//
//    private void sendReminderEmail(String policyType, String vehicleName, String vehicleNumber, Date expiryDate) {
//        try {
//            String toEmail = getAdminEmail();
//            if (toEmail == null) {
//                System.out.println("No admin email found. Cannot send reminder.");
//                return;
//            }
//
//            String subject = String.format("Remainder: Vehicle %s Expiring Soon", policyType);
//
//            SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
//            String expiryDateStr = sdf.format(expiryDate);
//            
//            String emailContent = "Dear Admin,<br><br>"
//                                + "The **" + policyType + "** for the following vehicle is expiring soon:<br><br>"
//                                + "<b>Vehicle Name:</b> " + vehicleName + "<br>"
//                                + "<b>Vehicle Number:</b> " + vehicleNumber + "<br>"
//                                + "<b>Expiry Date:</b> " + expiryDateStr + "<br><br>";
//            
//            LocalDate today = LocalDate.now();
//            LocalDate localExpiryDate = new java.sql.Date(expiryDate.getTime()).toLocalDate();
//            long daysUntilExpiry = ChronoUnit.DAYS.between(today, localExpiryDate);
//            
//            if (daysUntilExpiry < 0) {
//                emailContent += "This policy is **already expired**! Please take immediate action.<br><br>";
//            } else {
//                emailContent += "Please take the necessary action to renew the policy.<br><br>";
//            }
//
//            emailContent += "Regards,<br>SCDL Transportation System";
//
//            Mailer.sendMail(toEmail, subject, emailContent);
//            System.out.println("Reminder email for " + policyType + " sent for vehicle: " + vehicleNumber);
//        } catch (MessagingException | UnsupportedEncodingException | SQLException e) {
//            e.printStackTrace();
//        }
//    }
//}