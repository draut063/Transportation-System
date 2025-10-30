package com.TransportationSystem.controller;

import com.TransportationSystem.dao.TripDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/DriverTripServlet")
public class DriverTripServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("driver_id")==null) {
            resp.sendRedirect("TS-Driverlogin.jsp");
            return;
        }

        int driverId = (Integer)s.getAttribute("driver_id");
        List<String[]> trips = TripDAO.getTripsByDriverId(driverId);
        req.setAttribute("tripList", trips);
        RequestDispatcher rd = req.getRequestDispatcher("TStrip-infopage.jsp");
        rd.forward(req, resp);
    }
}
