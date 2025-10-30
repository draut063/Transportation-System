package com.TransportationSystem.model;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class DBconnect {

	
    public static Connection getConnection() {
        Connection conn = null;

        try {
            Class.forName(DBinfo.DRIVER); 
            conn = DriverManager.getConnection(DBinfo.URL,DBinfo.USERNAME,DBinfo.PASSWORD);
            System.out.println("Connection Created!!!");
        }
        catch (ClassNotFoundException e) {
            System.out.println("JDBC Driver not found!");
            e.printStackTrace();
        } 
        catch (SQLException e) {
            System.out.println("Connection failed!");
            e.printStackTrace();
        }

        return conn;
    }
}
