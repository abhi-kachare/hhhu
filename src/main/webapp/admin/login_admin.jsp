<%-- 
    Document   : login_admin
    Created on : 03-Mar-2026, 8:13:09 pm
    Author     : abhishek
--%>



<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%
if ("true".equals(request.getParameter("logout"))) {
    session.invalidate();
}
%>
<%
    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM admin WHERE username=? AND password=SHA2(?,256)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                session.setAttribute("role", "ADMIN");
                session.setAttribute("admin_id", rs.getInt  ("admin_id"));
                response.sendRedirect("admin_dashboard.jsp");
                return;
            } else {
                message = "Invalid credentials";
            }
        } catch (Exception e) {
            message = e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .login-wrapper {
            width: 100%;
            max-width: 420px;
            padding: 20px;
        }

        .login-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 48px 40px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.4);
        }

        .login-header {
            text-align: center;
            margin-bottom: 36px;
        }

        .shield-icon {
            width: 64px;
            height: 64px;
            background: linear-gradient(135deg, #e94560, #c62a47);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            box-shadow: 0 8px 24px rgba(233, 69, 96, 0.4);
        }

        .shield-icon svg {
            width: 32px;
            height: 32px;
            fill: white;
        }

        .login-header h2 {
            color: #ffffff;
            font-size: 26px;
            font-weight: 700;
            letter-spacing: 0.5px;
            margin-bottom: 6px;
        }

        .login-header p {
            color: rgba(255, 255, 255, 0.45);
            font-size: 14px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            color: rgba(255, 255, 255, 0.7);
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            margin-bottom: 8px;
        }

        .input-wrapper {
            position: relative;
        }

        .input-wrapper svg {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            width: 18px;
            height: 18px;
            stroke: rgba(255, 255, 255, 0.3);
            fill: none;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
            pointer-events: none;
        }

        .form-group input {
            width: 100%;
            padding: 13px 16px 13px 44px;
            background: rgba(255, 255, 255, 0.07);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 12px;
            color: #ffffff;
            font-size: 15px;
            transition: all 0.3s ease;
            outline: none;
        }

        .form-group input::placeholder {
            color: rgba(255, 255, 255, 0.25);
        }

        .form-group input:focus {
            background: rgba(255, 255, 255, 0.1);
            border-color: #e94560;
            box-shadow: 0 0 0 3px rgba(233, 69, 96, 0.15);
        }

        .btn-login {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #e94560, #c62a47);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 8px;
            letter-spacing: 0.5px;
            box-shadow: 0 4px 16px rgba(233, 69, 96, 0.35);
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(233, 69, 96, 0.5);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .error-message {
            display: flex;
            align-items: center;
            gap: 8px;
            background: rgba(233, 69, 96, 0.12);
            border: 1px solid rgba(233, 69, 96, 0.3);
            border-radius: 10px;
            padding: 12px 14px;
            margin-top: 20px;
            color: #ff6b81;
            font-size: 14px;
        }

        .error-message svg {
            width: 16px;
            height: 16px;
            flex-shrink: 0;
            fill: #ff6b81;
        }

        .divider {
            height: 1px;
            background: rgba(255, 255, 255, 0.08);
            margin: 28px 0 20px;
        }

        .footer-note {
            text-align: center;
            color: rgba(255, 255, 255, 0.25);
            font-size: 12px;
        }
    </style>
</head>
<body>

<div class="login-wrapper">
    <div class="login-card">
        <div class="login-header">
            <div class="shield-icon">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 2L3 7v5c0 5.25 3.75 10.15 9 11.35C17.25 22.15 21 17.25 21 12V7L12 2z"/>
                </svg>
            </div>
            <h2>Admin Portal</h2>
            <p>Sign in to access the dashboard</p>
        </div>

        <form method="post">
            <div class="form-group">
                <label for="username">Username</label>
                <div class="input-wrapper">
                    <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    <input type="text" id="username" name="username" placeholder="Enter your username" required>
                </div>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-wrapper">
                    <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    <input type="password" id="password" name="password" placeholder="Enter your password" required>
                </div>
            </div>

            <button type="submit" class="btn-login">Sign In</button>

            <% if (!message.isEmpty()) { %>
            <div class="error-message">
                <svg viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/></svg>
                <%= message %>
            </div>
            <% } %>
        </form>

        <div class="divider"></div>
        <p class="footer-note">Restricted access &mdash; authorized personnel only</p>
    </div>
</div>

</body>
</html>
