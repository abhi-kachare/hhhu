<%-- 
    Document   : team_login
    Created on : 03-Mar-2026, 11:35:00 pm
    Author     : abhishek
--%>



<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%
    String message = null;
    String messageType = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        if (email != null && password != null) {
            try (Connection con = DBConnection.getConnection()) {
                String sql = "SELECT * FROM team WHERE email=? AND password=? AND status='APPROVED'";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1, email);
                ps.setString(2, password);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    session.setAttribute("role", "TEAM");
                    session.setAttribute("team_id", rs.getInt("team_id"));
                    session.setAttribute("team_name", rs.getString("team_name"));
                    response.sendRedirect("team_dashboard.jsp");
                    return;
                } else {
                    message = "Invalid credentials or account not approved.";
                    messageType = "error";
                }
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "error";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Team Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg:       #0d0f14;
            --surface:  #151820;
            --surface2: #1c2030;
            --border:   #252a3a;
            --accent:   #4f8cff;
            --accent2:  #7c5cfc;
            --green:    #22c97a;
            --red:      #ff4f6a;
            --text:     #e8ecf5;
            --muted:    #7a82a0;
            --radius:   14px;
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            position: relative;
            overflow: hidden;
        }

        /* Ambient background glow */
        body::before {
            content: '';
            position: fixed;
            top: -200px; left: 50%;
            transform: translateX(-50%);
            width: 700px; height: 500px;
            background: radial-gradient(ellipse, rgba(79,140,255,0.1) 0%, transparent 70%);
            pointer-events: none;
        }
        body::after {
            content: '';
            position: fixed;
            bottom: -200px; left: 30%;
            width: 500px; height: 400px;
            background: radial-gradient(ellipse, rgba(124,92,252,0.08) 0%, transparent 70%);
            pointer-events: none;
        }

        /* ── CARD ── */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 40px 36px;
            width: 100%;
            max-width: 420px;
            position: relative;
            z-index: 1;
            animation: fadeUp 0.4s ease;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* Top accent line */
        .card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
            border-radius: var(--radius) var(--radius) 0 0;
        }

        /* ── LOGO / HEADER ── */
        .card-top {
            text-align: center;
            margin-bottom: 32px;
        }

        .logo-icon {
            width: 56px; height: 56px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            margin-bottom: 18px;
            box-shadow: 0 8px 24px rgba(79,140,255,0.25);
        }

        .card-top h2 {
            font-family: 'Syne', sans-serif;
            font-size: 1.65rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(90deg, #fff 40%, var(--accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 6px;
        }

        .card-top p {
            font-size: 0.875rem;
            color: var(--muted);
        }

        /* ── TOAST ── */
        .toast {
            display: flex;
            align-items: center;
            gap: 9px;
            padding: 12px 16px;
            border-radius: 9px;
            margin-bottom: 24px;
            font-size: 0.875rem;
            font-weight: 500;
            animation: slideIn 0.3s ease;
        }
        .toast.error {
            background: rgba(255,79,106,0.1);
            border: 1px solid rgba(255,79,106,0.25);
            color: var(--red);
        }
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-6px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── FORM ── */
        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            font-size: 0.78rem;
            font-weight: 600;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.06em;
            margin-bottom: 7px;
        }

        .input-wrapper {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 13px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 15px;
            opacity: 0.5;
            pointer-events: none;
        }

        .form-group input {
            width: 100%;
            padding: 11px 14px 11px 38px;
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: 9px;
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 0.9rem;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .form-group input::placeholder { color: var(--muted); }

        .form-group input:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(79,140,255,0.15);
        }

        /* ── SUBMIT BUTTON ── */
        .btn-submit {
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            color: white;
            border: none;
            border-radius: 9px;
            font-family: 'Syne', sans-serif;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            letter-spacing: 0.02em;
            transition: opacity 0.2s, transform 0.15s, box-shadow 0.2s;
            margin-top: 6px;
            box-shadow: 0 4px 16px rgba(79,140,255,0.25);
        }
        .btn-submit:hover {
            opacity: 0.92;
            transform: translateY(-1px);
            box-shadow: 0 8px 24px rgba(79,140,255,0.35);
        }
        .btn-submit:active { transform: translateY(0); }

        /* ── FOOTER LINK ── */
        .card-footer {
            text-align: center;
            margin-top: 24px;
            font-size: 0.82rem;
            color: var(--muted);
        }
        .card-footer a {
            color: var(--accent);
            text-decoration: none;
            font-weight: 500;
        }
        .card-footer a:hover { text-decoration: underline; }

        .divider {
            height: 1px;
            background: var(--border);
            margin: 24px 0;
        }
    </style>
</head>
<body>

<div class="card">

    <div class="card-top">
        <div class="logo-icon">🏆</div>
        <h2>Team Login</h2>
        <p>Sign in to access your team dashboard</p>
    </div>

    <% if (message != null) { %>
    <div class="toast <%= messageType %>">
        ⚠ <%= message %>
    </div>
    <% } %>

    <form method="post">

        <div class="form-group">
            <label>Email Address</label>
            <div class="input-wrapper">
                <span class="input-icon">✉</span>
                <input type="email" name="email" placeholder="your@email.com" required/>
            </div>
        </div>

        <div class="form-group">
            <label>Password</label>
            <div class="input-wrapper">
                <span class="input-icon">🔒</span>
                <input type="password" name="password" placeholder="Enter your password" required/>
            </div>
        </div>

        <button class="btn-submit" type="submit">Sign In →</button>

    </form>

    <div class="divider"></div>

    <div class="card-footer">
        Admin?&nbsp;<a href="../admin/login_admin.jsp">Login here</a>
    </div>

</div>

</body>
</html>
