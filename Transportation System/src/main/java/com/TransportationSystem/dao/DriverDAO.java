package com.TransportationSystem.dao;

import com.TransportationSystem.model.DBconnect;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class DriverDAO {
    public static Driver validate(String email, String password) {
        String sql = "SELECT driver_id, full_name, photo_path FROM Drivers WHERE email = ? AND password = ?";
        try (Connection con = DBconnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Driver d = new Driver();
                d.setDriverId(rs.getInt("driver_id"));
                d.setFullName(rs.getString("full_name"));
                d.setEmail(email);
                d.setPhotoPath(rs.getString("photo_path"));
                return d;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
