<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SCDL Transportation System Login</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="website icon" type="png" href="scdl.png">
  <style>
    html, body {
      margin: 0; padding: 0; height: 100%;
      background: url('SCDLimg.webp') no-repeat center center fixed;
      background-size: cover;
      font-family: Arial, sans-serif;
    }

    body {
      display: flex;
      justify-content: center;
      align-items: center;
      overflow: auto;
      position: relative;
    }

    .form-container {
      background-color: rgba(0, 0, 0, 0.5);
      padding: 30px;
      border-radius: 10px;
      max-width: 400px;
      width: 100%;
      color: white;
      backdrop-filter: blur(2px);
    }

    .logo {
      display: block;
      max-width: 90px;
      height: auto;
      margin: 0 auto 20px auto;
      filter: drop-shadow(0 0 5px rgba(0,0,0,0.7));
    }

    .form-control {
      background-color: rgba(255, 255, 255, 0.2);
      color: #fff;
      border: 1px solid rgba(255, 255, 255, 0.5);
    }

    .form-control::placeholder {
      color: rgba(255, 255, 255, 0.7);
    }

    .form-control:focus {
      background-color: rgba(255, 255, 255, 0.3);
      color: white;
    }

    .btn-primary {
      background-color: #007bff;
      border-color: #007bff;
    }

    .btn-primary:hover {
      background-color: #0069d9;
    }

    .text-link {
      color: #ffffff;
      text-decoration: none;
    }

    .text-link:hover {
      text-decoration: underline;
    }

    /* Hamburger Icon */
    .hamburger {
      position: absolute;
      top: 20px;
      left: 20px;
      font-size: 28px;
      color: #fff;
      cursor: pointer;
      z-index: 1001;
    }

    /* Dropdown Menu */
    .dropdown-menu-custom {
      position: absolute;
      top: 65px;
      left: 20px;
      display: none;
      background-color: white;
      border-radius: 5px;
      min-width: 150px;
      z-index: 1000;
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
    }

    .dropdown-menu-custom.show {
      display: block;
    }

    .dropdown-menu-custom a {
      display: block;
      padding: 10px 15px;
      color: black;
      text-decoration: none;
    }

    .dropdown-menu-custom a:hover {
      background-color: #f1f1f1;
    }
  </style>
</head>

<body>

  <div class="hamburger" onclick="toggleMenu()">☰</div>

  <div id="menu" class="dropdown-menu-custom">
  	<a href="login.html">Home</a>
    <a href="TS-login page.jsp">Admin</a>
    <a href="TS-login page.jsp">HOD</a>
    <a href="TS-Driverlogin.jsp">Driver</a>
    <a href="about.html">About</a>
  </div>

  <div class="form-container">
    <img src="scdl.png" alt="SCDL Logo" class="logo">

    <div id="error" class="alert alert-danger d-none" role="alert">
      Invalid email or password.
    </div>

    <form action="TS-DriverLoginServlet" method="POST">
      <div class="mb-3">
        <label for="username" class="form-label">Username (Email)</label>
        <input type="text" class="form-control" id="username" name="username" placeholder="Enter Email" required />
      </div>
      <div class="mb-3">
        <label for="password" class="form-label">Password</label>
        <input type="password" class="form-control" id="password" name="password" placeholder="Enter password" required />
      </div>
      <button type="submit" class="btn btn-primary w-100">Login</button>
    </form>

    <div class="text-center mt-3">
      <p>Don't have an account? <a href="driver-registration.jsp" class="text-link">Register Here</a></p>
    </div>
  </div>

  <script>
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('error') === 'invalid') {
      document.getElementById('error').classList.remove('d-none');
    }

    function toggleMenu() {
      const menu = document.getElementById("menu");
      menu.classList.toggle("show");
    }

    document.addEventListener("click", function (e) {
      const menu = document.getElementById("menu");
      const hamburger = document.querySelector(".hamburger");

      if (!menu.contains(e.target) && !hamburger.contains(e.target)) {
        menu.classList.remove("show");
      }
    });
  </script>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>