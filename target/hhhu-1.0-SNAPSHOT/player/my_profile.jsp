<%-- 
    Document   : my_profile
    Created on : 05-Mar-2026, 10:32:27 pm
    Author     : abhishek
--%>




<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>

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

    String    playerName = null;
    String    role       = null;
    String    country    = null;
    double    basePrice  = 0;
    Double    soldPrice  = null;
    String    status     = null;
    String    email      = null;
    Timestamp createdAt  = null;
    String    errorMsg   = null;
    boolean   notFound   = false;

    Connection        con = null;
    PreparedStatement ps  = null;
    ResultSet         rs  = null;

    try {
        con = DBConnection.getConnection();
        ps  = con.prepareStatement("SELECT * FROM player WHERE player_id = ?");
        ps.setInt(1, playerId);
        rs = ps.executeQuery();

        if (rs.next()) {
            playerName = rs.getString("player_name");
            role       = rs.getString("role");
            country    = rs.getString("country");
            basePrice  = rs.getDouble("base_price");
            soldPrice  = rs.getObject("sold_price") != null ? rs.getDouble("sold_price") : null;
            status     = rs.getString("status");
            email      = rs.getString("email");
            createdAt  = rs.getTimestamp("created_at");
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
    String[] nameParts = (playerName != null ? playerName : "P").trim().split("\\s+");
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

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
    String formattedDate = createdAt != null ? sdf.format(createdAt) : "—";

    boolean isSold = "SOLD".equals(status);
    double profitPct = (soldPrice != null && basePrice > 0)
        ? Math.round(((soldPrice - basePrice) / basePrice) * 100) : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile – <%= playerName != null ? playerName : "Player" %></title>
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

        .avatar-sm {
            width: 44px; height: 44px; border-radius: 50%; flex-shrink: 0;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif; font-weight: 800;
            font-size: 1rem; color: white;
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

        .back-btn {
            display: inline-flex; align-items: center; gap: 7px;
            color: var(--muted); text-decoration: none;
            font-size: 0.85rem; font-weight: 500;
            padding: 8px 16px;
            border: 1px solid var(--border); border-radius: 8px;
            background: var(--surface); transition: all 0.2s;
        }
        .back-btn:hover {
            color: var(--text); border-color: var(--accent);
            background: rgba(79,140,255,0.07);
        }

        /* ── CONTAINER ── */
        .container { max-width: 860px; margin: 0 auto; padding: 36px 24px; }

        /* ── ALERTS ── */
        .alert {
            display: flex; align-items: flex-start; gap: 12px;
            padding: 16px 20px; border-radius: var(--radius);
            margin-bottom: 24px; font-size: 0.9rem;
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
            border-radius: 16px;
            padding: 32px;
            display: flex; align-items: center; gap: 26px;
            margin-bottom: 24px;
            position: relative; overflow: hidden;
            animation: popIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .profile-hero::before {
            content: ''; position: absolute;
            top: 0; left: 0; right: 0; height: 4px;
            background: linear-gradient(90deg, var(--accent), var(--accent2), var(--green));
        }

        .avatar-lg {
            width: 90px; height: 90px; border-radius: 50%; flex-shrink: 0;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif; font-weight: 800;
            font-size: 2rem; color: white;
            border: 3px solid rgba(255,255,255,0.08);
            box-shadow: 0 8px 24px rgba(79,140,255,0.2);
        }

        .hero-info { flex: 1; display: flex; flex-direction: column; gap: 10px; }

        .hero-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.75rem; font-weight: 800; letter-spacing: -1px;
        }

        .hero-meta { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }

        .hero-email {
            display: flex; align-items: center; gap: 6px;
            font-size: 0.85rem; color: var(--muted);
            margin-top: 2px;
        }

        .hero-right {
            display: flex; flex-direction: column; align-items: flex-end;
            gap: 8px; flex-shrink: 0;
        }

        .hero-price-label {
            font-size: 0.7rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.08em;
            text-align: right;
        }
        .hero-price-val {
            font-family: 'Syne', sans-serif;
            font-size: 1.5rem; font-weight: 800;
        }
        .hero-price-val.sold  { color: var(--green); }
        .hero-price-val.base  { color: var(--accent); }

        .profit-chip {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 3px 10px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 700;
            background: rgba(34,201,122,0.12);
            border: 1px solid rgba(34,201,122,0.25);
            color: var(--green);
        }

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
            padding: 18px 20px;
            display: flex; flex-direction: column; gap: 7px;
            position: relative; overflow: hidden;
        }
        .stat-card::before {
            content: ''; position: absolute;
            top: 0; left: 0; right: 0; height: 3px;
        }
        .stat-card.blue::before   { background: linear-gradient(90deg, var(--accent), var(--accent2)); }
        .stat-card.green::before  { background: linear-gradient(90deg, var(--green), #0fe38a); }
        .stat-card.yellow::before { background: linear-gradient(90deg, var(--yellow), #ff9b44); }

        .stat-icon { font-size: 1.2rem; margin-bottom: 2px; }
        .stat-label {
            font-size: 0.7rem; font-weight: 600; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.08em;
        }
        .stat-value {
            font-family: 'Syne', sans-serif;
            font-size: 1.35rem; font-weight: 800; letter-spacing: -0.5px;
        }
        .stat-value.blue   { color: var(--accent); }
        .stat-value.green  { color: var(--green); }
        .stat-value.yellow { color: var(--yellow); }
        .stat-sub { font-size: 0.72rem; color: var(--muted); }

        /* ── CARD ── */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            margin-bottom: 22px;
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

        .card-body { padding: 4px 0; }

        /* ── INFO LIST ── */
        .info-list { display: flex; flex-direction: column; }

        .info-row {
            display: flex; justify-content: space-between; align-items: center;
            padding: 14px 22px; border-bottom: 1px solid var(--border);
            transition: background 0.15s;
        }
        .info-row:last-child { border-bottom: none; }
        .info-row:hover { background: rgba(255,255,255,0.02); }

        .info-key {
            display: flex; align-items: center; gap: 9px;
            font-size: 0.8rem; color: var(--muted);
            font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em;
        }
        .info-key .row-icon { font-size: 0.95rem; opacity: 0.7; }

        .info-val {
            font-family: 'Syne', sans-serif;
            font-size: 0.9rem; font-weight: 700; color: var(--text);
        }
        .info-val.green  { color: var(--green); }
        .info-val.accent { color: var(--accent); }
        .info-val.muted  { color: var(--muted); font-family: 'DM Sans', sans-serif; font-weight: 400; }

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

        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50%       { opacity: 0.4; transform: scale(0.75); }
        }
        @keyframes popIn {
            from { opacity: 0; transform: scale(0.97) translateY(10px); }
            to   { opacity: 1; transform: scale(1)    translateY(0); }
        }

        @media (max-width: 700px) {
            .profile-hero  { flex-direction: column; align-items: flex-start; }
            .hero-right    { align-items: flex-start; }
            .stats-row     { grid-template-columns: 1fr; }
            .header        { padding: 16px 20px; }
            .container     { padding: 20px 16px; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="header-left">
        <div class="avatar-sm"><%= playerInitials %></div>
        <div class="header-info">
            <span>Player Portal</span>
            <h2>My Profile</h2>
        </div>
    </div>
    <a class="back-btn" href="player_dashboard.jsp">← Dashboard</a>
</div>

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
            <span>Your profile could not be located in the database.</span>
        </div>
    </div>

<%-- ── PROFILE ── --%>
<% } else if (playerName != null) { %>

    <%-- HERO --%>
    <div class="profile-hero">
        <div class="avatar-lg"><%= playerInitials %></div>
        <div class="hero-info">
            <div class="hero-name"><%= playerName %></div>
            <div class="hero-meta">
                <span class="badge <%= badgeClass %>"><%= role %></span>
                <span class="status-pill <%= statusClass %>"><%= status %></span>
                <% if (country != null) { %>
                <span style="font-size:0.85rem;color:var(--muted);">🌍 <%= country %></span>
                <% } %>
            </div>
            <div class="hero-email">
                ✉️ <%= email != null ? email : "—" %>
            </div>
        </div>
        <div class="hero-right">
            <% if (isSold && soldPrice != null) { %>
                <div class="hero-price-label">Sold For</div>
                <div class="hero-price-val sold">₹<%= soldPrice %>Cr</div>
                <% if (profitPct > 0) { %>
                <span class="profit-chip">↑ +<%= (int) profitPct %>% above base</span>
                <% } %>
            <% } else { %>
                <div class="hero-price-label">Base Price</div>
                <div class="hero-price-val base">₹<%= basePrice %>Cr</div>
            <% } %>
        </div>
    </div>

    <%-- STATS --%>
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
                <%= soldPrice != null ? "₹" + soldPrice + "Cr" : "—" %>
            </span>
            <span class="stat-sub"><%= soldPrice != null ? "Final auction price" : "Not sold yet" %></span>
        </div>
        <div class="stat-card yellow">
            <div class="stat-icon">📅</div>
            <span class="stat-label">Registered</span>
            <span class="stat-value yellow" style="font-size:0.95rem;letter-spacing:0;">
                <%= createdAt != null ? new SimpleDateFormat("MMM yyyy").format(createdAt) : "—" %>
            </span>
            <span class="stat-sub">Account created</span>
        </div>
    </div>

    <%-- PROFILE DETAILS CARD --%>
    <div class="card">
        <div class="card-header">
            <span>👤</span>
            <h3>Profile Details</h3>
        </div>
        <div class="card-body">
            <div class="info-list">
                <div class="info-row">
                    <span class="info-key"><span class="row-icon">🏏</span> Full Name</span>
                    <span class="info-val"><%= playerName %></span>
                </div>
                <div class="info-row">
                    <span class="info-key"><span class="row-icon">✉️</span> Email</span>
                    <span class="info-val muted"><%= email != null ? email : "—" %></span>
                </div>
                <div class="info-row">
                    <span class="info-key"><span class="row-icon">🎯</span> Role</span>
                    <span class="badge <%= badgeClass %>"><%= role %></span>
                </div>
                <div class="info-row">
                    <span class="info-key"><span class="row-icon">🌍</span> Country</span>
                    <span class="info-val"><%= country != null ? country : "N/A" %></span>
                </div>
                <div class="info-row">
                    <span class="info-key"><span class="row-icon">📊</span> Status</span>
                    <span class="status-pill <%= statusClass %>"><%= status %></span>
                </div>
                <div class="info-row">
                    <span class="info-key"><span class="row-icon">💰</span> Base Price</span>
                    <span class="info-val accent">₹<%= basePrice %>Cr</span>
                </div>
                <div class="info-row">
                    <span class="info-key"><span class="row-icon">🏷️</span> Sold Price</span>
                    <% if (soldPrice != null) { %>
                    <span class="info-val green">₹<%= soldPrice %>Cr</span>
                    <% } else { %>
                    <span class="info-val muted">Not sold yet</span>
                    <% } %>
                </div>
                <div class="info-row">
                    <span class="info-key"><span class="row-icon">📅</span> Registered On</span>
                    <span class="info-val muted"><%= formattedDate %></span>
                </div>
            </div>
        </div>
    </div>

<% } %>

</div>
</body>
</html>