package com.example;

import java.io.IOException;
import java.util.Date;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class MainServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Date currentDate = new Date();
        resp.setContentType("text/html");
        resp.getWriter().write("<h1>Hello, Docker! Current date: " + currentDate + "</h1>");
    }
}
