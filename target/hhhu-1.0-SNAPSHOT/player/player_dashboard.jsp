<%-- 
    Document   : player_dashboard
    Created on : 05-Mar-2026, 9:54:16 pm
    Author     : abhishek
--%>



<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<%
    if (session == null || !"PLAYER".equals(session.getAttribute("role"))) {
        response.sendRedirect("player_login.jsp");
        return;
    }

    Integer playerId = (Integer) session.getAttribute("player_id");
    if (playerId == null) {
        response.sendRedirect("player_login.jsp");
        return;
    }

    String playerName = "";
    String role       = "";
    String status     = "";
    String teamName   = "Free Agent";
    double basePrice  = 0;
    double soldPrice  = 0;
    String errorMsg   = null;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DBConnection.getConnection();
        String sql =
            "SELECT p.player_name, p.role, p.status, p.base_price, p.sold_price, t.team_name " +
            "FROM player p " +
            "LEFT JOIN team t ON p.team_id = t.team_id " +
            "WHERE p.player_id = ?";
        ps = con.prepareStatement(sql);
        ps.setInt(1, playerId);
        rs = ps.executeQuery();
        if (rs.next()) {
            playerName = rs.getString("player_name");
            role       = rs.getString("role");
            status     = rs.getString("status");
            basePrice  = rs.getDouble("base_price");
            soldPrice  = rs.getDouble("sold_price");
            if (rs.getString("team_name") != null) teamName = rs.getString("team_name");
        }
    } catch (Exception e) {
        errorMsg = e.getMessage();
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception ignored) {}
        if (ps  != null) try { ps.close();  } catch (Exception ignored) {}
        if (con != null) try { con.close(); } catch (Exception ignored) {}
    }

    // Avatar initials
    String[] nameParts = playerName.trim().split("\\s+");
    StringBuilder ini = new StringBuilder();
    for (int w = 0; w < Math.min(2, nameParts.length); w++)
        if (nameParts[w].length() > 0) ini.append(nameParts[w].charAt(0));
    String playerInitials = ini.toString().toUpperCase();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Player Dashboard – <%= playerName %></title>
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
            --yellow:  #f5c842;
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
        }

        /* ── HEADER ── */
        .header {
            background: linear-gradient(135deg, #0d0f14 0%, #151c2e 100%);
            border-bottom: 1px solid var(--border);
            padding: 20px 40px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
            backdrop-filter: blur(12px);
        }

        .header-left { display: flex; align-items: center; gap: 14px; }

        .player-avatar-header {
            width: 44px; height: 44px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif;
            font-weight: 800; font-size: 1rem; color: white;
            flex-shrink: 0;
        }

        .header-info { display: flex; flex-direction: column; gap: 2px; }
        .header-info span {
            font-size: 0.7rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.1em; font-weight: 500;
        }
        .header-info h2 {
            font-family: 'Syne', sans-serif;
            font-size: 1.2rem; font-weight: 800; letter-spacing: -0.5px;
            background: linear-gradient(90deg, #fff 40%, var(--accent));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .logout-btn {
            display: inline-flex; align-items: center; gap: 7px;
            color: var(--muted); text-decoration: none;
            font-size: 0.85rem; font-weight: 500;
            padding: 8px 16px;
            border: 1px solid var(--border); border-radius: 8px;
            background: var(--surface); transition: all 0.2s;
        }
        .logout-btn:hover {
            color: var(--red);
            border-color: rgba(255,79,106,0.4);
            background: rgba(255,79,106,0.07);
        }

        /* ── CONTAINER ── */
        .container { max-width: 1000px; margin: 0 auto; padding: 36px 24px; }

        /* ── PROFILE HERO ── */
        .profile-hero {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 32px;
            display: flex; align-items: center; gap: 28px;
            margin-bottom: 24px;
            position: relative; overflow: hidden;
        }

        .profile-hero::before {
            content: '';
            position: absolute; top: 0; left: 0; right: 0; height: 4px;
            background: linear-gradient(90deg, var(--accent), var(--accent2), var(--green));
        }

        .player-avatar-lg {
            width: 88px; height: 88px; flex-shrink: 0;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif;
            font-weight: 800; font-size: 2rem; color: white;
            border: 3px solid rgba(255,255,255,0.08);
        }

        .hero-info { flex: 1; display: flex; flex-direction: column; gap: 10px; }

        .hero-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.8rem; font-weight: 800; letter-spacing: -1px;
        }

        .hero-meta { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }

        /* role badge */
        .badge {
            display: inline-block; padding: 4px 12px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 700;
            letter-spacing: 0.05em; text-transform: uppercase;
        }
        .badge-bat  { background: rgba(245,200,66,0.12); color: var(--yellow); border: 1px solid rgba(245,200,66,0.25); }
        .badge-bowl { background: rgba(79,140,255,0.12); color: var(--accent); border: 1px solid rgba(79,140,255,0.25); }
        .badge-all  { background: rgba(124,92,252,0.12); color: var(--accent2);border: 1px solid rgba(124,92,252,0.25); }
        .badge-wk   { background: rgba(34,201,122,0.12); color: var(--green);  border: 1px solid rgba(34,201,122,0.25); }

        /* status badge */
        .status-pill {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 4px 12px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 700;
            letter-spacing: 0.06em; text-transform: uppercase;
        }
        .status-pill.AVAILABLE {
            background: rgba(34,201,122,0.12);
            border: 1px solid rgba(34,201,122,0.3); color: var(--green);
        }
        .status-pill.AVAILABLE::before {
            content: ''; width: 6px; height: 6px; border-radius: 50%;
            background: var(--green); animation: pulse 1.4s infinite;
        }
        .status-pill.SOLD {
            background: rgba(79,140,255,0.12);
            border: 1px solid rgba(79,140,255,0.3); color: var(--accent);
        }
        .status-pill.UNSOLD {
            background: rgba(255,79,106,0.12);
            border: 1px solid rgba(255,79,106,0.3); color: var(--red);
        }

        .hero-team {
            display: flex; align-items: center; gap: 8px;
            font-size: 0.875rem; color: var(--muted);
        }
        .hero-team strong { color: var(--text); font-weight: 600; }

        /* ── STATS ROW ── */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 20px 22px;
            display: flex; flex-direction: column; gap: 8px;
            position: relative; overflow: hidden;
        }
        .stat-card::before {
            content: ''; position: absolute;
            top: 0; left: 0; right: 0; height: 3px;
        }
        .stat-card.blue::before   { background: linear-gradient(90deg, var(--accent), var(--accent2)); }
        .stat-card.green::before  { background: linear-gradient(90deg, var(--green), #0fe38a); }
        .stat-card.purple::before { background: linear-gradient(90deg, var(--accent2), #c56cfc); }

        .stat-icon { font-size: 1.3rem; margin-bottom: 2px; }
        .stat-label {
            font-size: 0.72rem; font-weight: 600; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.08em;
        }
        .stat-value {
            font-family: 'Syne', sans-serif;
            font-size: 1.45rem; font-weight: 800; letter-spacing: -0.5px;
        }
        .stat-value.blue   { color: var(--accent); }
        .stat-value.green  { color: var(--green); }
        .stat-value.purple { color: var(--accent2); }
        .stat-sub { font-size: 0.74rem; color: var(--muted); }

        /* ── BOTTOM GRID ── */
        .bottom-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }

        /* ── CARD ── */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
        }

        .card-header {
            padding: 16px 22px;
            border-bottom: 1px solid var(--border);
            background: var(--surface2);
            display: flex; align-items: center; gap: 10px;
        }

        .card-header h3 {
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem; font-weight: 700;
        }

        .card-body { padding: 20px 22px; }

        /* ── INFO LIST ── */
        .info-list { display: flex; flex-direction: column; gap: 0; }

        .info-row {
            display: flex; justify-content: space-between; align-items: center;
            padding: 13px 0;
            border-bottom: 1px solid var(--border);
        }
        .info-row:last-child { border-bottom: none; }

        .info-key {
            font-size: 0.78rem; color: var(--muted);
            font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em;
        }

        .info-val {
            font-family: 'Syne', sans-serif;
            font-size: 0.9rem; font-weight: 700; color: var(--text);
        }

        /* ── QUICK ACTIONS ── */
        .actions-list { display: flex; flex-direction: column; gap: 10px; }

        .action-link {
            display: flex; align-items: center; justify-content: space-between;
            padding: 13px 16px;
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: 9px;
            text-decoration: none;
            color: var(--text);
            font-size: 0.9rem; font-weight: 500;
            transition: all 0.2s;
        }
        .action-link:hover {
            border-color: var(--accent);
            background: rgba(79,140,255,0.07);
            color: var(--accent);
        }
        .action-link.danger { color: var(--red); }
        .action-link.danger:hover {
            border-color: rgba(255,79,106,0.4);
            background: rgba(255,79,106,0.07);
        }

        .action-left { display: flex; align-items: center; gap: 12px; }

        .action-icon {
            width: 34px; height: 34px; border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem;
        }
        .action-icon.a { background: rgba(79,140,255,0.12); }
        .action-icon.b { background: rgba(124,92,252,0.12); }
        .action-icon.c { background: rgba(34,201,122,0.12); }
        .action-icon.d { background: rgba(245,200,66,0.12); }
        .action-icon.e { background: rgba(255,79,106,0.12); }

        .action-arrow { color: var(--muted); }

        /* ── ERROR ── */
        .error-card {
            background: rgba(255,79,106,0.08);
            border: 1px solid rgba(255,79,106,0.2);
            color: var(--red); border-radius: var(--radius);
            padding: 16px 20px; font-size: 0.875rem; margin-bottom: 20px;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50%       { opacity: 0.4; transform: scale(0.75); }
        }

        @media (max-width: 768px) {
            .profile-hero { flex-direction: column; text-align: center; }
            .hero-meta { justify-content: center; }
            .hero-team { justify-content: center; }
            .stats-row { grid-template-columns: 1fr; }
            .bottom-grid { grid-template-columns: 1fr; }
            .header { padding: 16px 20px; }
            .container { padding: 20px 16px; }
        }
    </style>
</head>
<body>

<%
    String badgeClass = "badge-all";
    if ("BATSMAN".equals(role))           badgeClass = "badge-bat";
    else if ("BOWLER".equals(role))       badgeClass = "badge-bowl";
    else if ("WICKETKEEPER".equals(role)) badgeClass = "badge-wk";

    String statusClass = "AVAILABLE".equals(status) ? "AVAILABLE"
                       : "SOLD".equals(status)      ? "SOLD" : "UNSOLD";
%>

<div class="header">
    <div class="header-left">
        <div class="player-avatar-header"><%= playerInitials %></div>
        <div class="header-info">
            <span>Player Dashboard</span>
            <h2><%= playerName %></h2>
        </div>
    </div>
    <a class="logout-btn" href="logout.jsp">⎋ Logout</a>
</div>

<div class="container">

    <% if (errorMsg != null) { %>
    <div class="error-card">✗ Error loading profile: <%= errorMsg %></div>
    <% } %>

    <!-- PROFILE HERO -->
    <div class="profile-hero">
        <div class="player-avatar-lg"><%= playerInitials %></div>
        <div class="hero-info">
            <div class="hero-name"><%= playerName %></div>
            <div class="hero-meta">
                <span class="badge <%= badgeClass %>"><%= role %></span>
                <span class="status-pill <%= statusClass %>"><%= status %></span>
            </div>
            <div class="hero-team">
                🏟️ Currently with: <strong><%= teamName %></strong>
            </div>
        </div>
    </div>

    <!-- STATS ROW -->
    <div class="stats-row">
        <div class="stat-card blue">
            <div class="stat-icon">💰</div>
            <span class="stat-label">Base Price</span>
            <span class="stat-value blue">₹<%= basePrice %>Cr</span>
            <span class="stat-sub">Auction starting value</span>
        </div>
        <div class="stat-card green">
            <div class="stat-icon">🏷️</div>
            <span class="stat-label">Sold Price</span>
            <span class="stat-value green">
                <%= soldPrice > 0 ? "₹" + soldPrice + "Cr" : "—" %>
            </span>
            <span class="stat-sub"><%= soldPrice > 0 ? "Final auction price" : "Not sold yet" %></span>
        </div>
        <div class="stat-card purple">
            <div class="stat-icon">🏏</div>
            <span class="stat-label">Role</span>
            <span class="stat-value purple" style="font-size:1.1rem;"><%= role %></span>
            <span class="stat-sub">Playing position</span>
        </div>
    </div>

    <!-- BOTTOM GRID -->
    <div class="bottom-grid">

        <!-- PROFILE DETAILS -->
        <div class="card">
            <div class="card-header">
                <span>👤</span>
                <h3>Profile Details</h3>
            </div>
            <div class="card-body">
                <div class="info-list">
                    <div class="info-row">
                        <span class="info-key">Full Name</span>
                        <span class="info-val"><%= playerName %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Role</span>
                        <span class="badge <%= badgeClass %>"><%= role %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Status</span>
                        <span class="status-pill <%= statusClass %>"><%= status %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Current Team</span>
                        <span class="info-val"><%= teamName %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Base Price</span>
                        <span class="info-val" style="color:var(--accent);">₹<%= basePrice %>Cr</span>
                    </div>
                    <% if (soldPrice > 0) { %>
                    <div class="info-row">
                        <span class="info-key">Sold Price</span>
                        <span class="info-val" style="color:var(--green);">₹<%= soldPrice %>Cr</span>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- QUICK ACTIONS -->
        <div class="card">
            <div class="card-header">
                <span>⚡</span>
                <h3>Quick Actions</h3>
            </div>
            <div class="card-body">
                <div class="actions-list">
                    <a class="action-link" href="view_players.jsp">
                        <div class="action-left">
                            <div class="action-icon a">🏏</div>
                            <span>View All Players</span>
                        </div>
                        <span class="action-arrow">›</span>
                    </a>
                    <a class="action-link" href="view_teams.jsp">
                        <div class="action-left">
                            <div class="action-icon b">🏟️</div>
                            <span>View Teams</span>
                        </div>
                        <span class="action-arrow">›</span>
                    </a>
                    <a class="action-link" href="my_team.jsp">
                        <div class="action-left">
                            <div class="action-icon c">👥</div>
                            <span>My Team</span>
                        </div>
                        <span class="action-arrow">›</span>
                    </a>
                    <a class="action-link" href="my_profile.jsp">
                        <div class="action-left">
                            <div class="action-icon d">👤</div>
                            <span>My Profile</span>
                        </div>
                        <span class="action-arrow">›</span>
                    </a>
                    <a class="action-link danger" href="../index.jsp">
                        <div class="action-left">
                            <div class="action-icon e">⎋</div>
                            <span>Logout</span>
                        </div>
                        <span class="action-arrow">›</span>
                    </a>
                </div>
            </div>
        </div>

    </div>
</div>

</body>
</html>
