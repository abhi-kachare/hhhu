<%-- 
    Document   : player_login
    Created on : 05-Mar-2026, 10:00:54 pm
    Author     : abhishek
--%>



<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<%
    String errorMessage = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || password == null ||
            email.trim().isEmpty() || password.trim().isEmpty()) {
            errorMessage = "All fields are required.";
        } else {
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
                String sql = "SELECT player_id, player_name, password FROM player WHERE email = ?";
                ps = con.prepareStatement(sql);
                ps.setString(1, email.trim());
                rs = ps.executeQuery();
                if (rs.next()) {
                    String dbPassword = rs.getString("password");
                    if (dbPassword.equals(password)) {
                        int    playerId   = rs.getInt("player_id");
                        String playerName = rs.getString("player_name");
                        session.setAttribute("player_id",    playerId);
                        session.setAttribute("player_email", email);
                        session.setAttribute("player_name",  playerName);
                        session.setAttribute("role",         "PLAYER");
                        response.sendRedirect("player_dashboard.jsp");
                        return;
                    } else {
                        errorMessage = "Incorrect password. Please try again.";
                    }
                } else {
                    errorMessage = "No account found with that email.";
                }
            } catch (Exception e) {
                errorMessage = "Login error: " + e.getMessage();
            } finally {
                if (rs  != null) try { rs.close();  } catch (Exception ignored) {}
                if (ps  != null) try { ps.close();  } catch (Exception ignored) {}
                if (con != null) try { con.close(); } catch (Exception ignored) {}
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Player Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg:      #0d0f14;
            --surface: #151820;
            --surface2:#1c2030;
            --border:  #252a3a;
            --accent:  #4f8cff;
            --accent2: #7c5cfc;
            --green:   #22c97a;
            --red:     #ff4f6a;
            --text:    #e8ecf5;
            --muted:   #7a82a0;
            --radius:  12px;
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            display: flex; flex-direction: column;
        }

        /* ── BACKGROUND GLOW ── */
        .bg-glow {
            position: fixed; inset: 0; pointer-events: none; z-index: 0;
            overflow: hidden;
        }
        .bg-glow::before {
            content: '';
            position: absolute;
            width: 600px; height: 600px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(79,140,255,0.07) 0%, transparent 70%);
            top: -150px; left: -150px;
        }
        .bg-glow::after {
            content: '';
            position: absolute;
            width: 500px; height: 500px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(124,92,252,0.06) 0%, transparent 70%);
            bottom: -100px; right: -100px;
        }

        /* ── PAGE WRAPPER ── */
        .page {
            flex: 1; display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            padding: 40px 20px;
            position: relative; z-index: 1;
        }

        /* ── LOGO / BRAND ── */
        .brand {
            display: flex; flex-direction: column;
            align-items: center; gap: 12px;
            margin-bottom: 36px;
        }

        .brand-icon {
            width: 64px; height: 64px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 18px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.8rem;
            box-shadow: 0 8px 32px rgba(79,140,255,0.25);
        }

        .brand-title {
            font-family: 'Syne', sans-serif;
            font-size: 1.6rem; font-weight: 800; letter-spacing: -0.5px;
            background: linear-gradient(90deg, #fff 40%, var(--accent));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            background-clip: text;
            text-align: center;
        }

        .brand-sub {
            font-size: 0.82rem; color: var(--muted);
            text-align: center; margin-top: -4px;
        }

        /* ── LOGIN CARD ── */
        .login-card {
            width: 100%; max-width: 420px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 18px;
            overflow: hidden;
            box-shadow: 0 24px 64px rgba(0,0,0,0.4);
            animation: popIn 0.45s cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        .card-top {
            padding: 28px 32px 0;
            background: var(--surface2);
            border-bottom: 1px solid var(--border);
            padding-bottom: 24px;
        }

        .card-top h2 {
            font-family: 'Syne', sans-serif;
            font-size: 1.2rem; font-weight: 800;
            margin-bottom: 4px;
        }

        .card-top p {
            font-size: 0.82rem; color: var(--muted);
        }

        .card-body { padding: 28px 32px; }

        /* ── ERROR TOAST ── */
        .error-toast {
            display: flex; align-items: flex-start; gap: 10px;
            background: rgba(255,79,106,0.08);
            border: 1px solid rgba(255,79,106,0.25);
            border-radius: 9px;
            padding: 12px 14px;
            margin-bottom: 22px;
            animation: slideIn 0.3s ease;
        }

        .error-toast .err-icon {
            font-size: 1rem; flex-shrink: 0; margin-top: 1px;
        }

        .error-toast span {
            font-size: 0.85rem; color: var(--red); line-height: 1.5;
        }

        /* ── FORM ── */
        .form-group { margin-bottom: 20px; }

        .form-group label {
            display: block;
            font-size: 0.75rem; font-weight: 600; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.07em;
            margin-bottom: 8px;
        }

        .input-wrap { position: relative; }

        .input-icon {
            position: absolute; left: 14px; top: 50%;
            transform: translateY(-50%);
            font-size: 1rem; pointer-events: none;
            opacity: 0.5;
        }

        .form-group input {
            width: 100%;
            padding: 11px 14px 11px 40px;
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

        /* ── SUBMIT ── */
        .btn-login {
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            color: white; border: none; border-radius: 10px;
            font-family: 'Syne', sans-serif;
            font-size: 1rem; font-weight: 800;
            cursor: pointer; letter-spacing: 0.02em;
            transition: opacity 0.2s, transform 0.15s;
            margin-top: 6px;
        }
        .btn-login:hover  { opacity: 0.88; transform: translateY(-1px); }
        .btn-login:active { transform: translateY(0); }

        /* ── FOOTER LINKS ── */
        .card-footer {
            padding: 18px 32px 24px;
            border-top: 1px solid var(--border);
            text-align: center;
            font-size: 0.82rem; color: var(--muted);
        }

        .card-footer a {
            color: var(--accent); text-decoration: none; font-weight: 600;
            transition: opacity 0.2s;
        }
        .card-footer a:hover { opacity: 0.75; }

        .divider-links {
            display: flex; align-items: center;
            justify-content: center; gap: 16px;
            margin-top: 12px; flex-wrap: wrap;
        }

        .divider-links a {
            color: var(--muted); font-weight: 500;
            transition: color 0.2s;
        }
        .divider-links a:hover { color: var(--text); }

        .dot { color: var(--border); }

        /* ── BOTTOM NOTE ── */
        .page-footer {
            margin-top: 28px; text-align: center;
            font-size: 0.78rem; color: var(--muted);
        }

        @keyframes popIn {
            from { opacity: 0; transform: scale(0.95) translateY(16px); }
            to   { opacity: 1; transform: scale(1)    translateY(0); }
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-6px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 480px) {
            .card-top, .card-body, .card-footer { padding-left: 22px; padding-right: 22px; }
        }
    </style>
</head>
<body>

<div class="bg-glow"></div>

<div class="page">

    <!-- BRAND -->
    <div class="brand">
        <div class="brand-icon">🏏</div>
        <div class="brand-title">Cricket Auction</div>
        <div class="brand-sub">Player Portal</div>
    </div>

    <!-- LOGIN CARD -->
    <div class="login-card">

        <div class="card-top">
            <h2>Welcome back</h2>
            <p>Sign in to your player account</p>
        </div>

        <div class="card-body">

            <% if (errorMessage != null) { %>
            <div class="error-toast">
                <span class="err-icon">⚠️</span>
                <span><%= errorMessage %></span>
            </div>
            <% } %>

            <form method="post" action="">

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <div class="input-wrap">
                        <span class="input-icon">✉️</span>
                        <input
                            type="email"
                            id="email"
                            name="email"
                            placeholder="you@example.com"
                            value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>"
                            required
                            autocomplete="email"
                        >
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="input-wrap">
                        <span class="input-icon">🔒</span>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            placeholder="Enter your password"
                            required
                            autocomplete="current-password"
                        >
                    </div>
                </div>

                <button class="btn-login" type="submit">Sign In →</button>

            </form>
        </div>

        <div class="card-footer">
            <div>Not a player? <a href="../login_admin.jsp">Admin Login</a></div>
            <div class="divider-links">
                <a href="../team_login.jsp">Team Login</a>
                <span class="dot">•</span>
                <a href="../index.jsp">Back to Home</a>
            </div>
        </div>

    </div>

    <div class="page-footer">
        🏏 Cricket Auction System &nbsp;·&nbsp; Player Portal
    </div>

</div>

</body>
</html>