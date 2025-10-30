package com.TransportationSystem.mail;

import java.io.UnsupportedEncodingException;
import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class Mailer {

    
    public static void sendMail(String recipient, String subject, String body) throws MessagingException, UnsupportedEncodingException {
        
        Properties properties = new Properties();
        properties.put("mail.smtp.host", mailinfo.EMAIL_HOST);
        properties.put("mail.smtp.port", mailinfo.EMAIL_PORT);
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");

        
        Session session = Session.getInstance(properties, new Authenticator() {
            @Override // Use @Override for clarity
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(mailinfo.SENDER_EMAIL, mailinfo.SENDER_PASSWORD);
            }
        });

        // Create the message
        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(mailinfo.SENDER_EMAIL, mailinfo.SENDER_NAME));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipient));
        message.setSubject(subject);
        
        // Use setContent to send HTML
        message.setContent(body, "text/html");

        // Send the email
        Transport.send(message);
        System.out.println("Email sent successfully to " + recipient);
    }

    // Method to send an email with a carbon copy (CC)
    public static void sendMailWithCC(String recipient, String ccRecipient, String subject, String body) throws MessagingException, UnsupportedEncodingException {
        // Mailer configuration using the mailinfo interface
        Properties properties = new Properties();
        properties.put("mail.smtp.host", mailinfo.EMAIL_HOST);
        properties.put("mail.smtp.port", mailinfo.EMAIL_PORT);
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");

        // Create a new session with the email credentials
        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(mailinfo.SENDER_EMAIL, mailinfo.SENDER_PASSWORD);
            }
        });

        // Create the message
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(mailinfo.SENDER_EMAIL, mailinfo.SENDER_NAME));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipient));
        message.setRecipients(Message.RecipientType.CC, InternetAddress.parse(ccRecipient)); 
        message.setSubject(subject);
        
        // Use setContent to send HTML
        message.setContent(body, "text/html");

        // Send the email
        Transport.send(message);
        System.out.println("Email sent successfully to " + recipient + " with CC to " + ccRecipient);
    }
}