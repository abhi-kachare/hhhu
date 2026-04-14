<%-- 
    Document   : my_team
    Created on : 05-Mar-2026, 10:26:08 pm
    Author     : abhishek
--%>



<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
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

    // Player fields
    String  playerName      = null;
    String  role            = null;
    String  country         = null;
    String  status          = null;
    double  soldPrice       = 0;
    double  basePrice       = 0;
    Integer teamId          = null;

    // Team fields
    String  teamName        = null;
    String  ownerName       = null;
    double  totalBudget     = 0;
    double  remainingBudget = 0;

    String  errorMsg        = null;
    boolean notFound        = false;

    Connection        con      = null;
    PreparedStatement psPlayer = null;
    PreparedStatement psTeam   = null;
    ResultSet         rsPlayer = null;
    ResultSet         rsTeam   = null;

    try {
        con = DBConnection.getConnection();

        psPlayer = con.prepareStatement("SELECT * FROM player WHERE player_id = ?");
        psPlayer.setInt(1, playerId);
        rsPlayer = psPlayer.executeQuery();

        if (rsPlayer.next()) {
            playerName = rsPlayer.getString("player_name");
            role       = rsPlayer.getString("role");
            country    = rsPlayer.getString("country");
            status     = rsPlayer.getString("status");
            soldPrice  = rsPlayer.getDouble("sold_price");
            basePrice  = rsPlayer.getDouble("base_price");
            teamId     = (Integer) rsPlayer.getObject("team_id");
        } else {
            notFound = true;
        }

        if (!notFound && teamId != null && "SOLD".equals(status)) {
            psTeam = con.prepareStatement("SELECT * FROM team WHERE team_id = ?");
            psTeam.setInt(1, teamId);
            rsTeam = psTeam.executeQuery();
            if (rsTeam.next()) {
                teamName        = rsTeam.getString("team_name");
                ownerName       = rsTeam.getString("owner_name");
                totalBudget     = rsTeam.getDouble("total_budget");
                remainingBudget = rsTeam.getDouble("remaining_budget");
            }
        }

    } catch (Exception e) {
        errorMsg = e.getMessage();
    } finally {
        try { if (rsPlayer != null) rsPlayer.close(); } catch (Exception ignored) {}
        try { if (rsTeam   != null) rsTeam.close();   } catch (Exception ignored) {}
        try { if (psPlayer != null) psPlayer.close(); } catch (Exception ignored) {}
        try { if (psTeam   != null) psTeam.close();   } catch (Exception ignored) {}
        try { if (con      != null) con.close();      } catch (Exception ignored) {}
    }

    // Derived
    String[] nameParts = (playerName != null ? playerName : "P").trim().split("\\s+");
    StringBuilder ini = new StringBuilder();
    for (int w = 0; w < Math.min(2, nameParts.length); w++)
        if (nameParts[w].length() > 0) ini.append(nameParts[w].charAt(0));
    String playerInitials = ini.toString().toUpperCase();

    String[] teamParts = (teamName != null ? teamName : "T").trim().split("\\s+");
    StringBuilder tIni = new StringBuilder();
    for (int w = 0; w < Math.min(2, teamParts.length); w++)
        if (teamParts[w].length() > 0) tIni.append(teamParts[w].charAt(0));
    String teamInitials = tIni.toString().toUpperCase();

    String badgeClass = "badge-all";
    if ("BATSMAN".equals(role))           badgeClass = "badge-bat";
    else if ("BOWLER".equals(role))       badgeClass = "badge-bowl";
    else if ("WICKETKEEPER".equals(role)) badgeClass = "badge-wk";

    boolean isSold    = "SOLD".equals(status);
    boolean isUnsold  = "UNSOLD".equals(status);
    double  spentPct  = totalBudget > 0
        ? Math.round((totalBudget - remainingBudget) / totalBudget * 100) : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Team – <%= playerName != null ? playerName : "Player" %></title>
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

        .player-avatar-sm {
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
        .container { max-width: 900px; margin: 0 auto; padding: 36px 24px; }

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
        .alert.warning {
            background: rgba(245,200,66,0.08);
            border: 1px solid rgba(245,200,66,0.25); color: var(--yellow);
        }
        .alert-icon { font-size: 1.1rem; flex-shrink: 0; margin-top: 1px; }
        .alert-body { display: flex; flex-direction: column; gap: 4px; }
        .alert-body strong { font-weight: 700; font-size: 0.95rem; }
        .alert-body span   { font-size: 0.85rem; opacity: 0.85; }

        /* ── HERO BANNER (sold) ── */
        .hero-banner {
            background: linear-gradient(135deg,
                rgba(34,201,122,0.07) 0%,
                rgba(79,140,255,0.07) 100%);
            border: 1px solid rgba(34,201,122,0.2);
            border-radius: 16px;
            padding: 28px 32px;
            display: flex; align-items: center; gap: 20px;
            margin-bottom: 24px;
            position: relative; overflow: hidden;
        }
        .hero-banner::before {
            content: ''; position: absolute;
            top: 0; left: 0; right: 0; height: 3px;
            background: linear-gradient(90deg, var(--green), var(--accent), var(--accent2));
        }

        .sold-badge-large {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 6px 16px; border-radius: 20px;
            font-size: 0.78rem; font-weight: 700;
            letter-spacing: 0.06em; text-transform: uppercase;
            background: rgba(34,201,122,0.12);
            border: 1px solid rgba(34,201,122,0.3);
            color: var(--green); width: fit-content;
        }

        .hero-text { display: flex; flex-direction: column; gap: 6px; }
        .hero-text h3 {
            font-family: 'Syne', sans-serif;
            font-size: 1rem; font-weight: 700; color: var(--text);
        }
        .hero-text p { font-size: 0.85rem; color: var(--muted); line-height: 1.5; }
        .hero-sold-price {
            margin-left: auto; text-align: right; flex-shrink: 0;
        }
        .hero-sold-price span {
            font-size: 0.72rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.07em;
            display: block; margin-bottom: 4px;
        }
        .hero-sold-price strong {
            font-family: 'Syne', sans-serif;
            font-size: 1.6rem; font-weight: 800; color: var(--green);
        }

        /* ── TWO-COL GRID ── */
        .two-col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 22px;
            margin-bottom: 24px;
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

        /* ── PLAYER PROFILE HEADER ── */
        .profile-top {
            display: flex; align-items: center; gap: 16px;
            margin-bottom: 20px; padding-bottom: 18px;
            border-bottom: 1px solid var(--border);
        }

        .player-avatar-lg {
            width: 60px; height: 60px; border-radius: 50%; flex-shrink: 0;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif; font-weight: 800;
            font-size: 1.3rem; color: white;
            border: 2px solid rgba(255,255,255,0.08);
        }

        .profile-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.1rem; font-weight: 800;
            margin-bottom: 6px;
        }

        .profile-meta { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }

        /* ── TEAM LOGO ── */
        .team-logo {
            width: 60px; height: 60px; border-radius: 12px; flex-shrink: 0;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif; font-weight: 800;
            font-size: 1rem; color: white; letter-spacing: -0.5px;
        }

        .team-header-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.1rem; font-weight: 800; margin-bottom: 4px;
        }
        .team-header-owner { font-size: 0.85rem; color: var(--muted); }

        /* ── INFO LIST ── */
        .info-list { display: flex; flex-direction: column; }

        .info-row {
            display: flex; justify-content: space-between; align-items: center;
            padding: 12px 0; border-bottom: 1px solid var(--border);
        }
        .info-row:last-child { border-bottom: none; padding-bottom: 0; }

        .info-key {
            font-size: 0.78rem; color: var(--muted);
            font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em;
        }
        .info-val {
            font-family: 'Syne', sans-serif;
            font-size: 0.9rem; font-weight: 700; color: var(--text);
        }
        .info-val.green  { color: var(--green); }
        .info-val.accent { color: var(--accent); }

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

        /* ── BUDGET BAR (team card) ── */
        .budget-section { margin-top: 16px; }

        .budget-section-top {
            display: flex; justify-content: space-between;
            margin-bottom: 8px; font-size: 0.78rem;
        }
        .budget-section-top span { color: var(--muted); }
        .budget-section-top strong { color: var(--text); font-weight: 600; }

        .bar-track {
            width: 100%; height: 8px;
            background: var(--surface2); border-radius: 99px; overflow: hidden;
        }
        .bar-fill {
            height: 100%; border-radius: 99px;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
            transition: width 1s ease;
        }
        .bar-labels {
            display: flex; justify-content: space-between;
            margin-top: 8px; font-size: 0.74rem;
        }
        .bar-labels .spent { color: var(--accent); font-weight: 600; }
        .bar-labels .left  { color: var(--green);  font-weight: 600; }

        /* ── FREE AGENT CARD ── */
        .free-agent-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 32px;
            display: flex; gap: 24px; align-items: flex-start;
            margin-bottom: 24px;
        }

        .free-agent-avatar {
            width: 72px; height: 72px; border-radius: 50%; flex-shrink: 0;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif; font-weight: 800;
            font-size: 1.5rem; color: white;
            border: 2px solid rgba(255,255,255,0.08);
        }

        .free-agent-info { flex: 1; }
        .free-agent-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.3rem; font-weight: 800; margin-bottom: 8px;
        }
        .free-agent-meta { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 16px; }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-6px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 700px) {
            .two-col       { grid-template-columns: 1fr; }
            .hero-banner   { flex-direction: column; align-items: flex-start; }
            .hero-sold-price { margin-left: 0; text-align: left; }
            .free-agent-card { flex-direction: column; }
            .header        { padding: 16px 20px; }
            .container     { padding: 20px 16px; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="header-left">
        <div class="player-avatar-sm"><%= playerInitials %></div>
        <div class="header-info">
            <span>Player Portal</span>
            <h2>My Team</h2>
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

<%-- ── PLAYER NOT FOUND ── --%>
<% if (notFound) { %>
    <div class="alert error">
        <span class="alert-icon">❌</span>
        <div class="alert-body">
            <strong>Player not found</strong>
            <span>Your player record could not be located in the database.</span>
        </div>
    </div>

<%-- ── NOT ASSIGNED TO TEAM YET ── --%>
<% } else if (teamId == null || !isSold) { %>

    <div class="free-agent-card">
        <div class="free-agent-avatar"><%= playerInitials %></div>
        <div class="free-agent-info">
            <div class="free-agent-name"><%= playerName %></div>
            <div class="free-agent-meta">
                <span class="badge <%= badgeClass %>"><%= role %></span>
                <span style="font-size:0.85rem;color:var(--muted);">🌍 <%= country %></span>
            </div>
            <div class="info-list">
                <div class="info-row">
                    <span class="info-key">Current Status</span>
                    <span class="info-val" style="color:var(--yellow);"><%= status %></span>
                </div>
                <div class="info-row">
                    <span class="info-key">Base Price</span>
                    <span class="info-val accent">₹<%= basePrice %>Cr</span>
                </div>
            </div>
        </div>
    </div>

    <div class="alert warning">
        <span class="alert-icon">⏳</span>
        <div class="alert-body">
            <strong>Not assigned to any team yet</strong>
            <span>You will appear here once you are sold at auction.</span>
        </div>
    </div>

<%-- ── SOLD — show player + team info ── --%>
<% } else if (teamName != null) { %>

    <%-- SOLD HERO BANNER --%>
    <div class="hero-banner">
        <div>
            <div class="sold-badge-large">✓ Sold</div>
            <div class="hero-text" style="margin-top:10px;">
                <h3>You have been acquired by <%= teamName %></h3>
                <p>Congratulations! You are now an official member of <%= teamName %>.</p>
            </div>
        </div>
        <div class="hero-sold-price">
            <span>Sold Price</span>
            <strong>₹<%= soldPrice %>Cr</strong>
        </div>
    </div>

    <%-- TWO-COL: player info + team info --%>
    <div class="two-col">

        <%-- PLAYER CARD --%>
        <div class="card">
            <div class="card-header">
                <span>👤</span>
                <h3>Player Information</h3>
            </div>
            <div class="card-body">
                <div class="profile-top">
                    <div class="player-avatar-lg"><%= playerInitials %></div>
                    <div>
                        <div class="profile-name"><%= playerName %></div>
                        <div class="profile-meta">
                            <span class="badge <%= badgeClass %>"><%= role %></span>
                            <span style="font-size:0.8rem;color:var(--muted);">🌍 <%= country %></span>
                        </div>
                    </div>
                </div>
                <div class="info-list">
                    <div class="info-row">
                        <span class="info-key">Status</span>
                        <span class="info-val green">SOLD</span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Country</span>
                        <span class="info-val"><%= country %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Base Price</span>
                        <span class="info-val accent">₹<%= basePrice %>Cr</span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Sold Price</span>
                        <span class="info-val green">₹<%= soldPrice %>Cr</span>
                    </div>
                </div>
            </div>
        </div>

        <%-- TEAM CARD --%>
        <div class="card">
            <div class="card-header">
                <span>🏟️</span>
                <h3>Team Information</h3>
            </div>
            <div class="card-body">
                <div class="profile-top">
                    <div class="team-logo"><%= teamInitials %></div>
                    <div>
                        <div class="team-header-name"><%= teamName %></div>
                        <div class="team-header-owner">👤 <%= ownerName %></div>
                    </div>
                </div>
                <div class="info-list">
                    <div class="info-row">
                        <span class="info-key">Owner</span>
                        <span class="info-val"><%= ownerName %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Total Budget</span>
                        <span class="info-val accent">₹<%= totalBudget %>Cr</span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Remaining Budget</span>
                        <span class="info-val green">₹<%= remainingBudget %>Cr</span>
                    </div>
                </div>
                <div class="budget-section">
                    <div class="budget-section-top">
                        <span>Budget Utilisation</span>
                        <strong><%= (int) spentPct %>% spent</strong>
                    </div>
                    <div class="bar-track">
                        <div class="bar-fill" style="width:<%= (int) spentPct %>%"></div>
                    </div>
                    <div class="bar-labels">
                        <span class="spent">₹<%= totalBudget - remainingBudget %>Cr spent</span>
                        <span class="left">₹<%= remainingBudget %>Cr left</span>
                    </div>
                </div>
            </div>
        </div>

    </div>

<% } else { %>
    <div class="alert error">
        <span class="alert-icon">❌</span>
        <div class="alert-body">
            <strong>Team not found</strong>
            <span>Your assigned team could not be located in the database.</span>
        </div>
    </div>
<% } %>

</div>
</body>
</html>