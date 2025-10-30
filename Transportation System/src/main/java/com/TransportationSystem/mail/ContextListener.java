//package com.TransportationSystem.mail;
//
//import jakarta.servlet.ServletContextEvent;
//import jakarta.servlet.ServletContextListener;
//import jakarta.servlet.annotation.WebListener;
//
//@WebListener
//public class ContextListener implements ServletContextListener {
//
//    @Override
//    public void contextInitialized(ServletContextEvent sce) {
//        System.out.println("Application starting up... Starting policy reminder task.");
//        new PolicyReminderTask().startScheduler();
//    }
//
//    @Override
//    public void contextDestroyed(ServletContextEvent sce) {
//        System.out.println("Application shutting down.");
//    }
//}