<%-- 
    Document   : team_dashboard
    Created on : 03-Mar-2026, 11:44:17 pm
    Author     : abhishek
--%>



<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="util.DBConnection" %>

<%
    if (session == null || !"TEAM".equals(session.getAttribute("role"))) {
        response.sendRedirect("team_login.jsp");
        return;
    }

    int teamId = (Integer) session.getAttribute("team_id");
    String teamName = "";
    String ownerName = "";
    BigDecimal totalBudget = BigDecimal.ZERO;
    BigDecimal remainingBudget = BigDecimal.ZERO;
    int squadSize = 0;
    String auctionStatus = "OFFLINE";
    String auctionName = "";

    try (Connection con = DBConnection.getConnection()) {

        PreparedStatement psTeam = con.prepareStatement(
            "SELECT team_name, owner_name, total_budget, remaining_budget FROM team WHERE team_id=?");
        psTeam.setInt(1, teamId);
        ResultSet rsTeam = psTeam.executeQuery();
        if (rsTeam.next()) {
            teamName       = rsTeam.getString("team_name");
            ownerName      = rsTeam.getString("owner_name");
            totalBudget    = rsTeam.getBigDecimal("total_budget");
            remainingBudget = rsTeam.getBigDecimal("remaining_budget");
        }

        PreparedStatement psSquad = con.prepareStatement(
            "SELECT COUNT(*) FROM player WHERE team_id=? AND status='SOLD'");
        psSquad.setInt(1, teamId);
        ResultSet rsSquad = psSquad.executeQuery();
        if (rsSquad.next()) squadSize = rsSquad.getInt(1);

        ResultSet rsAuction = con.createStatement().executeQuery(
            "SELECT auction_name, status FROM auction WHERE status='LIVE' LIMIT 1");
        if (rsAuction.next()) {
            auctionName   = rsAuction.getString("auction_name");
            auctionStatus = rsAuction.getString("status");
        }

    } catch (Exception e) {
        // handled below
    }

    BigDecimal usedBudget = totalBudget.subtract(remainingBudget);
    int budgetPct = totalBudget.compareTo(BigDecimal.ZERO) > 0
        ? usedBudget.multiply(new BigDecimal(100)).divide(totalBudget, 0, java.math.RoundingMode.HALF_UP).intValue()
        : 0;

    String[] words = teamName.trim().split("\\s+");
    StringBuilder ini = new StringBuilder();
    for (int w = 0; w < Math.min(2, words.length); w++)
        if (words[w].length() > 0) ini.append(words[w].charAt(0));
    String teamInitials = ini.toString().toUpperCase();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Team Dashboard – <%= teamName %></title>
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
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
            backdrop-filter: blur(12px);
        }

        .header-left { display: flex; align-items: center; gap: 14px; }

        .team-avatar {
            width: 46px; height: 46px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif;
            font-weight: 800; font-size: 1rem;
            color: white; letter-spacing: -0.5px;
            flex-shrink: 0;
        }

        .header-info { display: flex; flex-direction: column; gap: 2px; }

        .header-info span {
            font-size: 0.7rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.1em; font-weight: 500;
        }

        .header-info h2 {
            font-family: 'Syne', sans-serif;
            font-size: 1.25rem; font-weight: 800; letter-spacing: -0.5px;
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
        .container { max-width: 1100px; margin: 0 auto; padding: 36px 24px; }

        /* ── LIVE BANNER ── */
        .live-banner {
            display: flex; align-items: center; justify-content: space-between;
            background: linear-gradient(135deg, rgba(34,201,122,0.08), rgba(79,140,255,0.08));
            border: 1px solid rgba(34,201,122,0.25);
            border-radius: var(--radius);
            padding: 18px 24px;
            margin-bottom: 24px;
            animation: slideIn 0.4s ease;
        }

        .live-banner-left { display: flex; flex-direction: column; gap: 4px; }

        .live-pill {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 4px 12px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 700;
            letter-spacing: 0.06em; text-transform: uppercase;
            width: fit-content; margin-bottom: 4px;
        }
        .live-pill.on {
            background: rgba(34,201,122,0.12);
            border: 1px solid rgba(34,201,122,0.3);
            color: var(--green);
        }
        .live-pill.on::before {
            content: '';
            width: 7px; height: 7px; border-radius: 50%;
            background: var(--green);
            animation: pulse 1.4s infinite;
        }

        .live-banner strong {
            font-family: 'Syne', sans-serif;
            font-size: 1rem; font-weight: 700; color: var(--text);
        }

        .live-banner span { font-size: 0.82rem; color: var(--muted); }

        .btn-live {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 11px 22px;
            background: linear-gradient(135deg, var(--green), #0fe38a);
            color: #0d0f14; border-radius: 9px; text-decoration: none;
            font-family: 'Syne', sans-serif;
            font-size: 0.9rem; font-weight: 800; letter-spacing: 0.02em;
            transition: opacity 0.2s, transform 0.15s; flex-shrink: 0;
        }
        .btn-live:hover { opacity: 0.9; transform: translateY(-1px); }

        /* ── STATS GRID ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
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
        .stat-card.yellow::before { background: linear-gradient(90deg, var(--yellow), #ff9b44); }
        .stat-card.purple::before { background: linear-gradient(90deg, var(--accent2), #c56cfc); }

        .stat-icon {
            font-size: 1.4rem;
            margin-bottom: 2px;
        }

        .stat-label {
            font-size: 0.72rem; font-weight: 600; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.08em;
        }

        .stat-value {
            font-family: 'Syne', sans-serif;
            font-size: 1.55rem; font-weight: 800; letter-spacing: -1px;
        }
        .stat-value.blue   { color: var(--accent); }
        .stat-value.green  { color: var(--green); }
        .stat-value.yellow { color: var(--yellow); }
        .stat-value.purple { color: var(--accent2); }

        .stat-sub { font-size: 0.78rem; color: var(--muted); }

        /* ── BUDGET BAR ── */
        .budget-bar-wrap {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 22px 26px;
            margin-bottom: 24px;
        }

        .budget-bar-top {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 14px;
        }

        .budget-bar-top h4 {
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem; font-weight: 700;
        }

        .budget-bar-top span { font-size: 0.82rem; color: var(--muted); }

        .bar-track {
            width: 100%; height: 10px;
            background: var(--surface2);
            border-radius: 99px; overflow: hidden;
        }

        .bar-fill {
            height: 100%;
            border-radius: 99px;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
            width: <%= budgetPct %>%;
            transition: width 1s ease;
        }

        .budget-labels {
            display: flex; justify-content: space-between;
            margin-top: 10px; font-size: 0.78rem;
        }

        .budget-labels .used  { color: var(--accent); font-weight: 600; }
        .budget-labels .left  { color: var(--green);  font-weight: 600; }

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
            font-size: 0.95rem; font-weight: 700; color: var(--text);
        }

        .card-body { padding: 20px 22px; }

        /* ── INFO LIST ── */
        .info-list { display: flex; flex-direction: column; gap: 14px; }

        .info-row {
            display: flex; justify-content: space-between; align-items: center;
            padding-bottom: 14px;
            border-bottom: 1px solid var(--border);
        }
        .info-row:last-child { border-bottom: none; padding-bottom: 0; }

        .info-key {
            font-size: 0.8rem; color: var(--muted);
            font-weight: 500; text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .info-val {
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem; font-weight: 700; color: var(--text);
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

        .action-link .action-left { display: flex; align-items: center; gap: 12px; }

        .action-icon {
            width: 34px; height: 34px;
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem;
        }
        .action-icon.a { background: rgba(34,201,122,0.12); }
        .action-icon.b { background: rgba(79,140,255,0.12); }
        .action-icon.c { background: rgba(245,200,66,0.12); }
        .action-icon.d { background: rgba(255,79,106,0.12); }

        .action-arrow { color: var(--muted); font-size: 1rem; }

        .action-link.danger { color: var(--red); }
        .action-link.danger:hover {
            border-color: rgba(255,79,106,0.4);
            background: rgba(255,79,106,0.07);
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-8px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50%       { opacity: 0.4; transform: scale(0.75); }
        }

        @media (max-width: 900px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .bottom-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 600px) {
            .stats-grid { grid-template-columns: 1fr; }
            .header { padding: 16px 20px; }
            .container { padding: 20px 16px; }
            .live-banner { flex-direction: column; gap: 14px; align-items: flex-start; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="header-left">
        <div class="team-avatar"><%= teamInitials %></div>
        <div class="header-info">
            <span>Team Dashboard</span>
            <h2><%= teamName %></h2>
        </div>
    </div>
    <a class="logout-btn" href="../logout.jsp">⎋ Logout</a>
</div>

<div class="container">

    <!-- LIVE AUCTION BANNER -->
    <% if ("LIVE".equals(auctionStatus)) { %>
    <div class="live-banner">
        <div class="live-banner-left">
            <span class="live-pill on">Live Now</span>
            <strong><%= auctionName %></strong>
            <span>Auction is currently running — place your bids!</span>
        </div>
        <a class="btn-live" href="live_auction.jsp">Enter Auction →</a>
    </div>
    <% } %>

    <!-- STATS GRID -->
    <div class="stats-grid">
        <div class="stat-card blue">
            <div class="stat-icon">💰</div>
            <span class="stat-label">Total Budget</span>
            <span class="stat-value blue">₹<%= totalBudget %>Cr</span>
            <span class="stat-sub">Season allocation</span>
        </div>
        <div class="stat-card green">
            <div class="stat-icon">🏦</div>
            <span class="stat-label">Remaining</span>
            <span class="stat-value green">₹<%= remainingBudget %>Cr</span>
            <span class="stat-sub">Available to bid</span>
        </div>
        <div class="stat-card yellow">
            <div class="stat-icon">📤</div>
            <span class="stat-label">Spent</span>
            <span class="stat-value yellow">₹<%= usedBudget %>Cr</span>
            <span class="stat-sub"><%= budgetPct %>% of budget used</span>
        </div>
        <div class="stat-card purple">
            <div class="stat-icon">👥</div>
            <span class="stat-label">Squad Size</span>
            <span class="stat-value purple"><%= squadSize %></span>
            <span class="stat-sub">Players acquired</span>
        </div>
    </div>

    <!-- BUDGET PROGRESS BAR -->
    <div class="budget-bar-wrap">
        <div class="budget-bar-top">
            <h4>Budget Utilisation</h4>
            <span><%= budgetPct %>% spent</span>
        </div>
        <div class="bar-track">
            <div class="bar-fill"></div>
        </div>
        <div class="budget-labels">
            <span class="used">₹<%= usedBudget %>Cr used</span>
            <span class="left">₹<%= remainingBudget %>Cr remaining</span>
        </div>
    </div>

    <!-- BOTTOM GRID -->
    <div class="bottom-grid">

        <!-- TEAM INFO -->
        <div class="card">
            <div class="card-header">
                <span>🏟️</span>
                <h3>Team Information</h3>
            </div>
            <div class="card-body">
                <div class="info-list">
                    <div class="info-row">
                        <span class="info-key">Team Name</span>
                        <span class="info-val"><%= teamName %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Owner</span>
                        <span class="info-val"><%= ownerName %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Auction Status</span>
                        <span class="info-val">
                            <% if ("LIVE".equals(auctionStatus)) { %>
                                <span style="color:var(--green);">● Live</span>
                            <% } else { %>
                                <span style="color:var(--muted);">○ Offline</span>
                            <% } %>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Players Bought</span>
                        <span class="info-val"><%= squadSize %></span>
                    </div>
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
                    <a class="action-link" href="live_auction.jsp">
                        <div class="action-left">
                            <div class="action-icon a">🔴</div>
                            <span>Live Auction</span>
                        </div>
                        <span class="action-arrow">›</span>
                    </a>
                    <a class="action-link" href="squad.jsp">
                        <div class="action-left">
                            <div class="action-icon b">👥</div>
                            <span>View Squad</span>
                        </div>
                        <span class="action-arrow">›</span>
                    </a>
                    <a class="action-link" href="transaction_history.jsp">
                        <div class="action-left">
                            <div class="action-icon c">📋</div>
                            <span>Transaction History</span>
                        </div>
                        <span class="action-arrow">›</span>
                    </a>
                    <a class="action-link danger" href="team_login.jsp">
                        <div class="action-left">
                            <div class="action-icon d">⎋</div>
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