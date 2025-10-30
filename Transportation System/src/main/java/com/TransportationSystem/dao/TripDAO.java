package com.TransportationSystem.dao;

import com.TransportationSystem.model.DBconnect;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

public class TripDAO {

    /**
     * Fetch all trips for a given driver (status = Assigned or On Trip),
     * ordered by assigned_time.
     */
    public static List<String[]> getTripsByDriverId(int driverId) {
        List<String[]> list = new ArrayList<>();

        String sql = """
            SELECT 
              at.assignment_id,
              tr.pickup_location,
              tr.drop_location,
              CONVERT(varchar(5), at.assigned_time, 108) AS assigned_time,
              at.trip_status
            FROM AssignedTrips at
            JOIN TransportRequests tr
              ON at.request_id = tr.request_id
            WHERE at.driver_id = ?
              AND at.trip_status IN ('Assigned','On Trip')
            ORDER BY at.assigned_time
            """;

        try (Connection con = DBconnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, driverId);

            try (var rs = ps.executeQuery()) {
                while (rs.next()) {
                    String[] row = new String[5];
                    row[0] = rs.getString("assignment_id");
                    row[1] = rs.getString("pickup_location");
                    row[2] = rs.getString("drop_location");
                    row[3] = rs.getString("assigned_time");
                    row[4] = rs.getString("trip_status");
                    list.add(row);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * Update the status of a trip (e.g. to "Completed", "Cancelled", etc.)
     * for the given assignment_id.
     */
    public static void updateTripStatus(int assignmentId, String status) {
        String sql = """
            UPDATE AssignedTrips
               SET trip_status = ?
             WHERE assignment_id = ?
            """;

        try (Connection con = DBconnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, assignmentId);

            int updated = ps.executeUpdate();
            if (updated == 0) {
                // No row was updated—maybe invalid assignmentId?
                System.err.printf("No trip found with assignment_id=%d%n", assignmentId);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

	public static boolean assignTrip(int reqId, int drvId, int vehId, Time t) {
		// TODO Auto-generated method stub
		return false;
	}
}
