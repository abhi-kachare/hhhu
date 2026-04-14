<%-- 
    Document   : public_player_details
    Created on : 05-Mar-2026, 11:11:48 pm
    Author     : abhishek
--%>



<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="false" %>

<%
    String idParam = request.getParameter("id");
    if (idParam == null) { response.sendRedirect("public_players.jsp"); return; }

    int playerId = 0;
    try {
        playerId = Integer.parseInt(idParam);
    } catch (NumberFormatException e) {
        response.sendRedirect("public_players.jsp"); return;
    }

    String name      = null;
    String role      = null;
    String country   = null;
    double basePrice = 0;
    Double soldPrice = null;
    String status    = null;
    String teamName  = null;
    boolean notFound = false;
    String  errorMsg = null;

    Connection        con = null;
    PreparedStatement ps  = null;
    ResultSet         rs  = null;

    try {
        con = DBConnection.getConnection();
        String sql =
            "SELECT p.player_name, p.role, p.country, p.base_price, " +
            "p.sold_price, p.status, t.team_name, t.status AS team_status " +
            "FROM player p " +
            "LEFT JOIN team t ON p.team_id = t.team_id " +
            "WHERE p.player_id = ?";
        ps = con.prepareStatement(sql);
        ps.setInt(1, playerId);
        rs = ps.executeQuery();

        if (rs.next()) {
            name      = rs.getString("player_name");
            role      = rs.getString("role");
            country   = rs.getString("country");
            basePrice = rs.getDouble("base_price");
            soldPrice = rs.getObject("sold_price") != null ? rs.getDouble("sold_price") : null;
            status    = rs.getString("status");
            String teamStatus = rs.getString("team_status");
            if ("SOLD".equals(status) && "APPROVED".equals(teamStatus))
                teamName = rs.getString("team_name");
        } else {
            notFound = true;
        }
    } catch (Exception e) {
        errorMsg = e.getMessage();
    } finally {
        try { if (rs  != null) rs.close();  } catch (Exception ignored) {}
        try { if (ps  != null) ps.close();  } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }

    // Derived
    String[] nameParts = (name != null ? name : "P").trim().split("\\s+");
    StringBuilder ini = new StringBuilder();
    for (int w = 0; w < Math.min(2, nameParts.length); w++)
        if (nameParts[w].length() > 0) ini.append(nameParts[w].charAt(0));
    String playerInitials = ini.toString().toUpperCase();

    String badgeClass = "badge-all";
    if ("BATSMAN".equals(role))           badgeClass = "badge-bat";
    else if ("BOWLER".equals(role))       badgeClass = "badge-bowl";
    else if ("WICKETKEEPER".equals(role)) badgeClass = "badge-wk";

    String statusClass = "AVAILABLE".equals(status) ? "AVAILABLE"
                       : "SOLD".equals(status)      ? "SOLD" : "UNSOLD";

    boolean isSold = "SOLD".equals(status);
    double profitPct = (soldPrice != null && basePrice > 0)
        ? Math.round(((soldPrice - basePrice) / basePrice) * 100) : 0;

    String[] teamParts = (teamName != null ? teamName : "T").trim().split("\\s+");
    StringBuilder tIni = new StringBuilder();
    for (int w = 0; w < Math.min(2, teamParts.length); w++)
        if (teamParts[w].length() > 0) tIni.append(teamParts[w].charAt(0));
    String teamInitials = tIni.toString().toUpperCase();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= name != null ? name + " – Player Details" : "Player Details" %></title>
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
            display: flex; flex-direction: column;
        }

        /* ── BG GLOW ── */
        .bg-glow {
            position: fixed; inset: 0; pointer-events: none; z-index: 0; overflow: hidden;
        }
        .bg-glow::before {
            content: ''; position: absolute;
            width: 600px; height: 600px; border-radius: 50%;
            background: radial-gradient(circle, rgba(79,140,255,0.05) 0%, transparent 70%);
            top: -150px; left: -150px;
        }
        .bg-glow::after {
            content: ''; position: absolute;
            width: 500px; height: 500px; border-radius: 50%;
            background: radial-gradient(circle, rgba(124,92,252,0.04) 0%, transparent 70%);
            bottom: -100px; right: -100px;
        }

        /* ── NAV ── */
        .nav {
            background: linear-gradient(135deg, #0d0f14 0%, #151c2e 100%);
            border-bottom: 1px solid var(--border);
            padding: 16px 40px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
            backdrop-filter: blur(12px);
        }

        .nav-brand { display: flex; align-items: center; gap: 12px; text-decoration: none; }
        .nav-icon {
            width: 38px; height: 38px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 9px;
            display: flex; align-items: center; justify-content: center; font-size: 1rem;
        }
        .nav-title {
            font-family: 'Syne', sans-serif; font-size: 1rem; font-weight: 800;
            background: linear-gradient(90deg, #fff 40%, var(--accent));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .back-btn {
            display: inline-flex; align-items: center; gap: 7px;
            color: var(--muted); text-decoration: none;
            font-size: 0.85rem; font-weight: 500;
            padding: 7px 14px; border: 1px solid var(--border);
            border-radius: 8px; background: var(--surface); transition: all 0.2s;
        }
        .back-btn:hover {
            color: var(--text); border-color: var(--accent);
            background: rgba(79,140,255,0.07);
        }

        /* ── CONTAINER ── */
        .container {
            max-width: 820px; margin: 0 auto;
            padding: 48px 24px; flex: 1;
            position: relative; z-index: 1;
        }

        /* ── ALERTS ── */
        .alert {
            display: flex; align-items: flex-start; gap: 12px;
            padding: 16px 20px; border-radius: var(--radius);
            margin-bottom: 24px; font-size: 0.9rem;
            animation: slideIn 0.3s ease;
        }
        .alert.error {
            background: rgba(255,79,106,0.08);
            border: 1px solid rgba(255,79,106,0.25); color: var(--red);
        }
        .alert-icon { font-size: 1.1rem; flex-shrink: 0; }
        .alert-body { display: flex; flex-direction: column; gap: 3px; }
        .alert-body strong { font-weight: 700; }
        .alert-body span   { font-size: 0.85rem; opacity: 0.85; }

        /* ── PROFILE HERO ── */
        .profile-hero {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 36px;
            display: flex; align-items: center; gap: 28px;
            margin-bottom: 24px;
            position: relative; overflow: hidden;
            animation: popIn 0.45s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .profile-hero::before {
            content: ''; position: absolute;
            top: 0; left: 0; right: 0; height: 4px;
            background: linear-gradient(90deg, var(--accent), var(--accent2), var(--green));
        }

        .avatar-lg {
            width: 96px; height: 96px; border-radius: 50%; flex-shrink: 0;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif; font-weight: 800;
            font-size: 2.2rem; color: white;
            border: 3px solid rgba(255,255,255,0.08);
            box-shadow: 0 8px 28px rgba(79,140,255,0.22);
        }

        .hero-info { flex: 1; display: flex; flex-direction: column; gap: 10px; }

        .hero-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.9rem; font-weight: 800; letter-spacing: -1px;
        }

        .hero-meta { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }

        .hero-country { font-size: 0.875rem; color: var(--muted); }

        .hero-right {
            display: flex; flex-direction: column; align-items: flex-end;
            gap: 8px; flex-shrink: 0;
        }

        .price-label {
            font-size: 0.7rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.08em; text-align: right;
        }
        .price-val {
            font-family: 'Syne', sans-serif; font-size: 1.65rem; font-weight: 800;
        }
        .price-val.sold { color: var(--green); }
        .price-val.base { color: var(--accent); }

        .profit-chip {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 3px 10px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 700;
            background: rgba(34,201,122,0.12);
            border: 1px solid rgba(34,201,122,0.25); color: var(--green);
        }

        /* ── TWO-COL ── */
        .two-col {
            display: grid; grid-template-columns: 1fr 1fr;
            gap: 20px; margin-bottom: 20px;
        }

        /* ── CARD ── */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius); overflow: hidden;
        }

        .card-header {
            padding: 15px 22px; border-bottom: 1px solid var(--border);
            background: var(--surface2);
            display: flex; align-items: center; gap: 10px;
        }
        .card-header h3 {
            font-family: 'Syne', sans-serif; font-size: 0.9rem; font-weight: 700;
        }

        .card-body { padding: 4px 0; }

        /* ── INFO LIST ── */
        .info-list { display: flex; flex-direction: column; }

        .info-row {
            display: flex; justify-content: space-between; align-items: center;
            padding: 13px 22px; border-bottom: 1px solid var(--border);
            transition: background 0.15s;
        }
        .info-row:last-child { border-bottom: none; }
        .info-row:hover { background: rgba(255,255,255,0.02); }

        .info-key {
            display: flex; align-items: center; gap: 8px;
            font-size: 0.78rem; color: var(--muted);
            font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em;
        }
        .info-key .ricon { font-size: 0.9rem; opacity: 0.7; }

        .info-val {
            font-family: 'Syne', sans-serif;
            font-size: 0.9rem; font-weight: 700; color: var(--text);
        }
        .info-val.green  { color: var(--green); }
        .info-val.accent { color: var(--accent); }
        .info-val.muted  { color: var(--muted); font-family: 'DM Sans',sans-serif; font-weight:400; }

        /* ── TEAM CARD (full width) ── */
        .team-banner {
            background: linear-gradient(135deg,
                rgba(34,201,122,0.06) 0%, rgba(79,140,255,0.06) 100%);
            border: 1px solid rgba(34,201,122,0.2);
            border-radius: var(--radius);
            padding: 22px 26px;
            display: flex; align-items: center; gap: 18px;
            margin-bottom: 20px;
        }

        .team-logo {
            width: 54px; height: 54px; border-radius: 12px; flex-shrink: 0;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif; font-weight: 800;
            font-size: 1rem; color: white;
        }

        .team-banner-info { display: flex; flex-direction: column; gap: 4px; }
        .team-banner-label {
            font-size: 0.7rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.08em; font-weight: 500;
        }
        .team-banner-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.1rem; font-weight: 800; color: var(--text);
        }

        /* ── BADGES ── */
        .badge {
            display: inline-block; padding: 3px 10px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            letter-spacing: 0.05em; text-transform: uppercase;
        }
        .badge-bat  { background: rgba(245,200,66,0.12); color: var(--yellow); border: 1px solid rgba(245,200,66,0.25); }
        .badge-bowl { background: rgba(79,140,255,0.12); color: var(--accent); border: 1px solid rgba(79,140,255,0.25); }
        .badge-all  { background: rgba(124,92,252,0.12); color: var(--accent2);border: 1px solid rgba(124,92,252,0.25); }
        .badge-wk   { background: rgba(34,201,122,0.12); color: var(--green);  border: 1px solid rgba(34,201,122,0.25); }

        .status-pill {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 3px 10px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            letter-spacing: 0.05em; text-transform: uppercase;
        }
        .status-pill.AVAILABLE {
            background: rgba(34,201,122,0.12);
            border: 1px solid rgba(34,201,122,0.3); color: var(--green);
        }
        .status-pill.AVAILABLE::before {
            content: ''; width: 5px; height: 5px; border-radius: 50%;
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

        /* ── CTA ROW ── */
        .cta-row {
            display: flex; gap: 12px; flex-wrap: wrap; justify-content: center;
            margin-top: 8px;
        }
        .btn {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 12px 22px; border-radius: 9px; text-decoration: none;
            font-family: 'Syne', sans-serif; font-size: 0.9rem; font-weight: 700;
            transition: all 0.2s;
        }
        .btn-primary {
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            color: white; box-shadow: 0 6px 20px rgba(79,140,255,0.2);
        }
        .btn-primary:hover { opacity: 0.88; transform: translateY(-1px); }
        .btn-outline {
            background: var(--surface); color: var(--muted);
            border: 1px solid var(--border);
        }
        .btn-outline:hover {
            color: var(--text); border-color: var(--accent);
            background: rgba(79,140,255,0.06);
        }

        /* footer */
        footer {
            border-top: 1px solid var(--border); padding: 18px 40px;
            text-align: center; font-size: 0.78rem; color: var(--muted);
            position: relative; z-index: 1;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50%       { opacity: 0.4; transform: scale(0.75); }
        }
        @keyframes popIn {
            from { opacity: 0; transform: scale(0.96) translateY(12px); }
            to   { opacity: 1; transform: scale(1)    translateY(0); }
        }
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-6px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 680px) {
            .profile-hero { flex-direction: column; align-items: flex-start; }
            .hero-right   { align-items: flex-start; }
            .two-col      { grid-template-columns: 1fr; }
            .nav          { padding: 14px 20px; }
            .container    { padding: 28px 16px; }
        }
    </style>
</head>
<body>

<div class="bg-glow"></div>

<!-- NAV -->
<nav class="nav">
    <a class="nav-brand" href="../index.jsp">
        <div class="nav-icon">🏏</div>
        <span class="nav-title">Cricket Auction</span>
    </a>
    <a class="back-btn" href="public_players.jsp">← All Players</a>
</nav>

<div class="container">

<%-- ── ERROR ── --%>
<% if (errorMsg != null) { %>
    <div class="alert error">
        <span class="alert-icon">⚠️</span>
        <div class="alert-body">
            <strong>Something went wrong</strong>
            <span><%= errorMsg %></span>
        </div>
    </div>
<% } %>

<%-- ── NOT FOUND ── --%>
<% if (notFound) { %>
    <div class="alert error">
        <span class="alert-icon">❌</span>
        <div class="alert-body">
            <strong>Player not found</strong>
            <span>No player exists with ID #<%= playerId %>.</span>
        </div>
    </div>

<%-- ── PLAYER DETAILS ── --%>
<% } else if (name != null) { %>

    <%-- HERO --%>
    <div class="profile-hero">
        <div class="avatar-lg"><%= playerInitials %></div>
        <div class="hero-info">
            <div class="hero-name"><%= name %></div>
            <div class="hero-meta">
                <span class="badge <%= badgeClass %>"><%= role %></span>
                <span class="status-pill <%= statusClass %>"><%= status %></span>
                <% if (country != null) { %>
                <span class="hero-country">🌍 <%= country %></span>
                <% } %>
            </div>
        </div>
        <div class="hero-right">
            <% if (isSold && soldPrice != null) { %>
                <div class="price-label">Sold For</div>
                <div class="price-val sold">₹<%= soldPrice %>Cr</div>
                <% if (profitPct > 0) { %>
                <span class="profit-chip">↑ +<%= (int) profitPct %>% above base</span>
                <% } %>
            <% } else { %>
                <div class="price-label">Base Price</div>
                <div class="price-val base">₹<%= basePrice %>Cr</div>
            <% } %>
        </div>
    </div>

    <%-- TEAM BANNER (only if sold) --%>
    <% if (teamName != null) { %>
    <div class="team-banner">
        <div class="team-logo"><%= teamInitials %></div>
        <div class="team-banner-info">
            <span class="team-banner-label">Current Team</span>
            <span class="team-banner-name"><%= teamName %></span>
        </div>
        <span style="margin-left:auto;font-size:0.8rem;color:var(--green);font-weight:600;">✓ Acquired</span>
    </div>
    <% } %>

    <%-- TWO-COL CARDS --%>
    <div class="two-col">

        <%-- PLAYER INFO --%>
        <div class="card">
            <div class="card-header">
                <span>👤</span>
                <h3>Player Info</h3>
            </div>
            <div class="card-body">
                <div class="info-list">
                    <div class="info-row">
                        <span class="info-key"><span class="ricon">🏏</span> Name</span>
                        <span class="info-val"><%= name %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-key"><span class="ricon">🎯</span> Role</span>
                        <span class="badge <%= badgeClass %>"><%= role %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-key"><span class="ricon">🌍</span> Country</span>
                        <span class="info-val"><%= country != null ? country : "N/A" %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-key"><span class="ricon">📊</span> Status</span>
                        <span class="status-pill <%= statusClass %>"><%= status %></span>
                    </div>
                </div>
            </div>
        </div>

        <%-- PRICE INFO --%>
        <div class="card">
            <div class="card-header">
                <span>💰</span>
                <h3>Auction Info</h3>
            </div>
            <div class="card-body">
                <div class="info-list">
                    <div class="info-row">
                        <span class="info-key"><span class="ricon">💰</span> Base Price</span>
                        <span class="info-val accent">₹<%= basePrice %>Cr</span>
                    </div>
                    <div class="info-row">
                        <span class="info-key"><span class="ricon">🏷️</span> Sold Price</span>
                        <% if (soldPrice != null) { %>
                        <span class="info-val green">₹<%= soldPrice %>Cr</span>
                        <% } else { %>
                        <span class="info-val muted">Not sold yet</span>
                        <% } %>
                    </div>
                    <div class="info-row">
                        <span class="info-key"><span class="ricon">📈</span> Premium</span>
                        <% if (profitPct > 0) { %>
                        <span class="info-val green">+<%= (int) profitPct %>%</span>
                        <% } else { %>
                        <span class="info-val muted">—</span>
                        <% } %>
                    </div>
                    <div class="info-row">
                        <span class="info-key"><span class="ricon">🏟️</span> Team</span>
                        <span class="info-val"><%= teamName != null ? teamName : "Unassigned" %></span>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <%-- CTA --%>
    <div class="cta-row">
        <a class="btn btn-primary" href="public_players.jsp">🏏 All Players</a>
        <a class="btn btn-outline"  href="public_teams.jsp">🏆 View Teams</a>
        <a class="btn btn-outline"  href="public/index.jsp">🏠 Home</a>
    </div>

<% } %>

</div>

<footer>
    🏏 Cricket Auction System &nbsp;·&nbsp; Public Directory
</footer>

</body>
</html>