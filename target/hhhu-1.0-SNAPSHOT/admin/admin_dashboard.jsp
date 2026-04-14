<%-- 
    Document   : admin_dashboard
    Created on : 03-Mar-2026, 8:14:31 pm
    Author     : abhishek
--%>

<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<%
    // Session Protection
    if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect("login_admin.jsp");
        return;
    }

    int totalPlayers = 0;
    int totalTeams = 0;
    int liveAuctions = 0;

    try (Connection con = DBConnection.getConnection()) {
        Statement st = con.createStatement();

        ResultSet rs1 = st.executeQuery("SELECT COUNT(*) FROM player");
        if (rs1.next()) totalPlayers = rs1.getInt(1);

        ResultSet rs2 = st.executeQuery("SELECT COUNT(*) FROM team");
        if (rs2.next()) totalTeams = rs2.getInt(1);

        ResultSet rs3 = st.executeQuery("SELECT COUNT(*) FROM auction WHERE status='LIVE'");
        if (rs3.next()) liveAuctions = rs3.getInt(1);

    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            min-height: 100vh;
            color: #fff;
        }

        /* ?? Header ?? */
        .header {
            background: rgba(0, 0, 0, 0.35);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            padding: 18px 40px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .header-left {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .header-icon {
            width: 42px;
            height: 42px;
            background: linear-gradient(135deg, #e94560, #c62a47);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 14px rgba(233, 69, 96, 0.4);
        }

        .header-icon svg {
            width: 22px;
            height: 22px;
            fill: white;
        }

        .header h2 {
            font-size: 20px;
            font-weight: 700;
            letter-spacing: 0.4px;
            color: #fff;
        }

        .header-subtitle {
            font-size: 12px;
            color: rgba(255,255,255,0.4);
            margin-top: 2px;
        }

        .logout-btn {
            display: flex;
            align-items: center;
            gap: 7px;
            background: rgba(233, 69, 96, 0.15);
            border: 1px solid rgba(233, 69, 96, 0.35);
            color: #ff6b81;
            text-decoration: none;
            padding: 9px 18px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .logout-btn:hover {
            background: rgba(233, 69, 96, 0.3);
            border-color: #e94560;
            color: #fff;
        }

        .logout-btn svg {
            width: 16px;
            height: 16px;
            stroke: currentColor;
            fill: none;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        /* ?? Main Container ?? */
        .container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 40px 24px;
        }

        .section-label {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.2px;
            color: rgba(255,255,255,0.35);
            margin-bottom: 16px;
        }

        /* ?? Stats Row ?? */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 36px;
        }

        .stat-card {
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.09);
            border-radius: 16px;
            padding: 28px 24px;
            display: flex;
            align-items: center;
            gap: 18px;
            backdrop-filter: blur(10px);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 32px rgba(0,0,0,0.3);
        }

        .stat-icon {
            width: 52px;
            height: 52px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .stat-icon svg {
            width: 26px;
            height: 26px;
            stroke: white;
            fill: none;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        .stat-icon.players  { background: linear-gradient(135deg, #4facfe, #00f2fe); box-shadow: 0 6px 18px rgba(79,172,254,0.35); }
        .stat-icon.teams    { background: linear-gradient(135deg, #43e97b, #38f9d7); box-shadow: 0 6px 18px rgba(67,233,123,0.35); }
        .stat-icon.auctions { background: linear-gradient(135deg, #e94560, #c62a47); box-shadow: 0 6px 18px rgba(233,69,96,0.35); }

        .stat-info .stat-value {
            font-size: 32px;
            font-weight: 800;
            line-height: 1;
            color: #fff;
        }

        .stat-info .stat-label {
            font-size: 13px;
            color: rgba(255,255,255,0.45);
            margin-top: 4px;
        }

        .live-badge {
            display: inline-block;
            background: rgba(233,69,96,0.2);
            border: 1px solid rgba(233,69,96,0.4);
            color: #ff6b81;
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 2px 8px;
            border-radius: 20px;
            margin-top: 6px;
        }

        .live-dot {
            display: inline-block;
            width: 6px;
            height: 6px;
            background: #e94560;
            border-radius: 50%;
            margin-right: 4px;
            animation: pulse 1.4s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.5; transform: scale(0.7); }
        }

        /* ?? Management Panel ?? */
        .panel-card {
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 20px;
            padding: 32px;
            backdrop-filter: blur(10px);
        }

        .panel-card h3 {
            font-size: 18px;
            font-weight: 700;
            color: #fff;
            margin-bottom: 24px;
            padding-bottom: 16px;
            border-bottom: 1px solid rgba(255,255,255,0.07);
        }

        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 14px;
        }

        .menu-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px 18px;
            background: rgba(255,255,255,0.06);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 14px;
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .menu-link:hover {
            background: rgba(233,69,96,0.15);
            border-color: rgba(233,69,96,0.4);
            color: #fff;
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.2);
        }

        .menu-link svg {
            width: 20px;
            height: 20px;
            stroke: #e94560;
            fill: none;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
            flex-shrink: 0;
        }

        .menu-link .arrow {
            margin-left: auto;
            stroke: rgba(255,255,255,0.2);
            width: 16px;
            height: 16px;
        }

        @media (max-width: 640px) {
            .stats-grid { grid-template-columns: 1fr; }
            .header { padding: 14px 20px; }
            .container { padding: 24px 16px; }
        }
    </style>
</head>
<body>

<!-- Header -->
<div class="header">
    <div class="header-left">
        <div class="header-icon">
            <svg viewBox="0 0 24 24"><path d="M12 2L3 7v5c0 5.25 3.75 10.15 9 11.35C17.25 22.15 21 17.25 21 12V7L12 2z"/></svg>
        </div>
        <div>
            <h2>Admin Dashboard</h2>
            <div class="header-subtitle">Auction Management System</div>
        </div>
    </div>
    <a class="logout-btn" href="login_admin.jsp?logout=true">
        <svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
        Logout
    </a>
</div>

<!-- Main Content -->
<div class="container">

    <!-- Stats -->
    <div class="section-label">System Overview</div>
    <div class="stats-grid">

        <div class="stat-card">
            <div class="stat-icon players">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </div>
            <div class="stat-info">
                <div class="stat-value"><%= totalPlayers %></div>
                <div class="stat-label">Total Players</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon teams">
                <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            </div>
            <div class="stat-info">
                <div class="stat-value"><%= totalTeams %></div>
                <div class="stat-label">Total Teams</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon auctions">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
            <div class="stat-info">
                <div class="stat-value"><%= liveAuctions %></div>
                <div class="stat-label">Live Auctions</div>
                <% if (liveAuctions > 0) { %>
                <div class="live-badge"><span class="live-dot"></span>Active Now</div>
                <% } %>
            </div>
        </div>

    </div>

    <!-- Management Panel -->
    <div class="section-label">Management Panel</div>
    <div class="panel-card">
        <h3>Quick Actions</h3>
        <div class="menu-grid">

            <a href="manage_players.jsp" class="menu-link">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg>
                Manage Players
                <svg class="arrow" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
            </a>

            <a href="manage_teams.jsp" class="menu-link">
                <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                Manage Teams
                <svg class="arrow" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
            </a>

            <a href="manage_auction.jsp" class="menu-link">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                Manage Auction
                <svg class="arrow" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
            </a>

            <a href="monitor_bids.jsp" class="menu-link">
                <svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                Monitor Bids
                <svg class="arrow" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
            </a>

            <a href="reports.jsp" class="menu-link">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                Reports
                <svg class="arrow" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
            </a>

        </div>
    </div>

</div>

</body>
</html>