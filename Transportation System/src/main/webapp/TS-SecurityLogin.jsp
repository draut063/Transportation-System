<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SCDL Security Login</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="icon" type="image/png" href="scdl.png">
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
  </style>
</head>

<body>

  <div class="form-container">
    <img src="scdl.png" alt="SCDL Logo" class="logo">
 <!--     <h4 class="text-center mb-3">Security Login</h4>  -->

    <%-- Error message display --%>
    <% 
        String error = request.getParameter("error");
        if (error != null) {
    %>
        <div class="alert alert-danger" role="alert">
            <%= error %>
        </div>
    <% 
        } 
    %>

    <form action="SystemUser-login" method="POST">
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
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>