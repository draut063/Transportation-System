<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Driver Registration</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <link rel="website icon" type="png" href="scdl.png">
    
    <style>
        body {
            background-color: #f8f9fa;
        }
          /* Styles for the new transparent navigation bar */
    .navbar-custom {
      background-color: transparent !important; /* Transparent background */
      border-bottom: 1px solid #000; /* Black border at the bottom */
      position: relative; /* Relative position for normal flow */
      height: 70px; /* Fixed height for the navbar */
      width: 100%; /* Ensure it spans full width */
      z-index: 1060; /* Ensure it's above other content */
    }

    /* Center logo and text within the navbar */
    .navbar-center {
      position: absolute;
      left: 50%;
      top: 50%;
      transform: translate(-50%, -50%);
      display: flex;
      align-items: center;
    }

    .navbar-center img {
      height: 50px; /* Logo height in navbar */
      margin-right: 10px;
    }

    .navbar-title {
      font-size: 1.1rem;
      font-weight: 600;
      color: #000; /* Black text for company name */
      white-space: nowrap;
    }

    /* Login link in the navbar */
    .navbar-custom .nav-link {
      color: #000; /* Black color for navbar links */
    }

    .navbar-custom .nav-link:hover {
      text-decoration: underline;
    }

        .form-container {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0px 0px 10px #ccc;
        }
    </style>
</head>
<body>

<!-- SCDL Navbar -->
 <nav class="navbar navbar-expand-lg navbar-custom">
    <div class="container-fluid d-flex justify-content-end">
      <div class="navbar-center">
        <img src="scdl.png" alt="SCDL Logo">
        <span class="navbar-title">Symbiosis Centre for Distance Learning</span>
      </div>
      <ul class="navbar-nav">
        <li class="nav-item">
          <a class="nav-link" href="TS-Driverlogin.jsp">Login</a>
        </li>
      </ul>
    </div>
  </nav>

<!-- Form Container -->
<div class="container mt-5">
    <div class="form-container">
        <h3 class="mb-4 text-center">Registration</h3>
        <form action="register-driver" method="post" enctype="multipart/form-data" class="row g-3">

            <div class="col-md-6">
                <label for="name" class="form-label">Full Name</label>
                <input type="text" class="form-control" name="name" id="name" required placeholder="Enter name">
            </div>

            <div class="col-md-6">
                <label for="empId" class="form-label">Employee ID</label>
                <input type="text" class="form-control" name="empId" id="empId" required placeholder="E.g: N1111">
            </div>

            <div class="col-md-6">
                <label for="email" class="form-label">Email ID</label>
                <input type="email" class="form-control" name="email" id="email" required placeholder="E.g: abc@scdl.net">
            </div>

            <div class="col-md-6">
                <label for="password" class="form-label">Password</label>
                <input type="password" class="form-control" name="password" id="password" required>
            </div>

            <div class="col-md-6">
                <label for="mobile" class="form-label">Mobile Number</label>
                <input type="text" class="form-control" name="mobile" id="mobile" required placeholder="Enter Number">
            </div>

            <div class="col-md-6">
                <label for="emergencyMobile" class="form-label">Emergency Mobile</label>
                <input type="text" class="form-control" name="emergencyMobile" id="emergencyMobile" placeholder=" Enter Number">
            </div>

            <div class="col-md-6">
                  <label for="bloodGroup" class="form-label">Blood Group</label>
        <select class="form-select" id="bloodGroup" name="bloodGroup" required>
          <option value="" disabled selected>Select Blood Group</option>
          <option value="A+">A+</option>
          <option value="A-">A-</option>
          <option value="B+">B+</option>
          <option value="B-">B-</option>
          <option value="O+">O+</option>
          <option value="O-">O-</option>
          <option value="AB+">AB+</option>
          <option value="AB-">AB-</option>
        </select>
            </div>

            <div class="col-md-6">
                <label for="photo" class="form-label">Upload Photo (Max 2MB)</label>
                <input type="file" class="form-control" name="photo" id="photo" accept="image/*" required>
            </div>

            <div class="col-md-6">
                <label for="license" class="form-label">Upload License Photo (Max 2MB)</label>
                <input type="file" class="form-control" name="license" id="license" accept="image/*" required>
            </div>

            <div class="col-12 text-center">
                <button type="submit" class="btn btn-primary px-5">Register</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
