<%-- 
    Document   : squad
    Created on : 04-Mar-2026, 10:47:09 pm
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

    Integer teamId   = (Integer) session.getAttribute("team_id");
    String teamName  = (String)  session.getAttribute("team_name");

    if (teamId == null) {
        response.sendRedirect("../team_login.jsp");
        return;
    }

    String[] words = (teamName != null ? teamName : "T").trim().split("\\s+");
    StringBuilder ini = new StringBuilder();
    for (int w = 0; w < Math.min(2, words.length); w++)
        if (words[w].length() > 0) ini.append(words[w].charAt(0));
    String teamInitials = ini.toString().toUpperCase();

    // Will be filled from DB
    double totalSpending  = 0;
    double remainingBudget = 0;
    double totalBudget    = 0;
    int    squadSize      = 0;

    // Collect rows so we can render after header stats
    java.util.List<String[]> players = new java.util.ArrayList<>();

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String errorMsg = null;

    try {
        con = DBConnection.getConnection();

        // Budget info
        PreparedStatement psBudget = con.prepareStatement(
            "SELECT total_budget, remaining_budget FROM team WHERE team_id=?");
        psBudget.setInt(1, teamId);
        ResultSet rsBudget = psBudget.executeQuery();
        if (rsBudget.next()) {
            totalBudget     = rsBudget.getDouble("total_budget");
            remainingBudget = rsBudget.getDouble("remaining_budget");
        }
        rsBudget.close(); psBudget.close();

        // Squad
        ps = con.prepareStatement(
            "SELECT player_name, role, country, sold_price " +
            "FROM player WHERE team_id=? AND status='SOLD' ORDER BY sold_price DESC");
        ps.setInt(1, teamId);
        rs = ps.executeQuery();
        while (rs.next()) {
            squadSize++;
            double soldPrice = rs.getDouble("sold_price");
            totalSpending += soldPrice;
            players.add(new String[]{
                rs.getString("player_name"),
                rs.getString("role"),
                rs.getString("country"),
                String.valueOf(soldPrice)
            });
        }

    } catch (Exception e) {
        errorMsg = e.getMessage();
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception ignored) {}
        if (ps  != null) try { ps.close();  } catch (Exception ignored) {}
        if (con != null) try { con.close(); } catch (Exception ignored) {}
    }

    int budgetPct = totalBudget > 0
        ? (int) Math.round((totalSpending / totalBudget) * 100)
        : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Squad – <%= teamName %></title>
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

        .team-avatar {
            width: 44px; height: 44px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 11px;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif;
            font-weight: 800; font-size: 1rem; color: white;
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
        .container { max-width: 1100px; margin: 0 auto; padding: 36px 24px; }

        /* ── STATS ROW ── */
        .stats-row {
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

        .stat-icon { font-size: 1.3rem; margin-bottom: 2px; }

        .stat-label {
            font-size: 0.72rem; font-weight: 600; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.08em;
        }

        .stat-value {
            font-family: 'Syne', sans-serif;
            font-size: 1.5rem; font-weight: 800; letter-spacing: -1px;
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
            padding: 20px 26px;
            margin-bottom: 24px;
        }

        .budget-bar-top {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 12px;
        }

        .budget-bar-top h4 {
            font-family: 'Syne', sans-serif;
            font-size: 0.9rem; font-weight: 700;
        }

        .budget-bar-top span { font-size: 0.8rem; color: var(--muted); }

        .bar-track {
            width: 100%; height: 9px;
            background: var(--surface2);
            border-radius: 99px; overflow: hidden;
        }

        .bar-fill {
            height: 100%; border-radius: 99px;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
            width: <%= budgetPct %>%;
            transition: width 1s ease;
        }

        .budget-labels {
            display: flex; justify-content: space-between;
            margin-top: 10px; font-size: 0.78rem;
        }
        .budget-labels .spent { color: var(--accent); font-weight: 600; }
        .budget-labels .left  { color: var(--green);  font-weight: 600; }

        /* ── SQUAD CARD ── */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
        }

        .card-header {
            padding: 16px 24px;
            border-bottom: 1px solid var(--border);
            background: var(--surface2);
            display: flex; align-items: center; gap: 10px;
        }

        .card-header h3 {
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem; font-weight: 700;
        }

        .card-header .chip {
            margin-left: auto;
            font-size: 0.7rem; padding: 3px 9px; border-radius: 20px;
            background: rgba(79,140,255,0.15); color: var(--accent);
            border: 1px solid rgba(79,140,255,0.25); font-weight: 600;
        }

        /* ── TABLE ── */
        .table-wrapper { overflow-x: auto; }

        table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }

        thead tr {
            background: var(--surface2);
            border-bottom: 1px solid var(--border);
        }

        thead th {
            padding: 13px 16px; text-align: left;
            font-family: 'Syne', sans-serif;
            font-size: 0.72rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase;
            letter-spacing: 0.08em; white-space: nowrap;
        }

        tbody tr {
            border-bottom: 1px solid var(--border);
            transition: background 0.15s;
        }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: rgba(255,255,255,0.03); }

        tbody td {
            padding: 13px 16px;
            color: var(--text); vertical-align: middle;
        }

        /* player row number */
        .row-num {
            font-size: 0.78rem; color: var(--muted);
            font-family: 'Syne', sans-serif; font-weight: 600;
        }

        /* player name with avatar initial */
        .player-cell { display: flex; align-items: center; gap: 12px; }

        .player-init {
            width: 34px; height: 34px; border-radius: 9px; flex-shrink: 0;
            background: linear-gradient(135deg, var(--surface2), var(--border));
            border: 1px solid var(--border);
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif; font-weight: 800;
            font-size: 0.85rem; color: var(--muted);
        }

        .player-name { font-weight: 600; font-size: 0.9rem; }

        /* badges */
        .badge {
            display: inline-block; padding: 3px 10px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            letter-spacing: 0.05em; text-transform: uppercase;
        }
        .badge-bat  { background: rgba(245,200,66,0.12); color: var(--yellow); border: 1px solid rgba(245,200,66,0.25); }
        .badge-bowl { background: rgba(79,140,255,0.12); color: var(--accent); border: 1px solid rgba(79,140,255,0.25); }
        .badge-all  { background: rgba(124,92,252,0.12); color: var(--accent2);border: 1px solid rgba(124,92,252,0.25); }
        .badge-wk   { background: rgba(34,201,122,0.12); color: var(--green);  border: 1px solid rgba(34,201,122,0.25); }

        .country { color: var(--muted); font-size: 0.875rem; }

        .sold-price {
            font-family: 'Syne', sans-serif;
            font-weight: 800; font-size: 0.95rem; color: var(--green);
        }

        /* ── EMPTY STATE ── */
        .empty-state {
            text-align: center; padding: 56px 24px; color: var(--muted);
        }
        .empty-state .icon { font-size: 2.8rem; margin-bottom: 14px; }
        .empty-state p { font-size: 0.9rem; }

        /* ── ERROR ── */
        .error-card {
            background: rgba(255,79,106,0.08);
            border: 1px solid rgba(255,79,106,0.2);
            color: var(--red); border-radius: var(--radius);
            padding: 16px 20px; font-size: 0.875rem;
            margin-bottom: 20px;
        }

        @media (max-width: 900px) {
            .stats-row { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 600px) {
            .stats-row { grid-template-columns: 1fr; }
            .header { padding: 16px 20px; }
            .container { padding: 20px 16px; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="header-left">
        <div class="team-avatar"><%= teamInitials %></div>
        <div class="header-info">
            <span>Squad Roster</span>
            <h2><%= teamName != null ? teamName : "My Squad" %></h2>
        </div>
    </div>
    <a class="back-btn" href="team_dashboard.jsp">← Dashboard</a>
</div>

<div class="container">

    <% if (errorMsg != null) { %>
    <div class="error-card">✗ Error loading squad: <%= errorMsg %></div>
    <% } %>

    <!-- STATS ROW -->
    <div class="stats-row">
        <div class="stat-card purple">
            <div class="stat-icon">👥</div>
            <span class="stat-label">Squad Size</span>
            <span class="stat-value purple"><%= squadSize %></span>
            <span class="stat-sub">Players acquired</span>
        </div>
        <div class="stat-card yellow">
            <div class="stat-icon">📤</div>
            <span class="stat-label">Total Spent</span>
            <span class="stat-value yellow">₹<%= totalSpending %>Cr</span>
            <span class="stat-sub">Across all bids</span>
        </div>
        <div class="stat-card green">
            <div class="stat-icon">🏦</div>
            <span class="stat-label">Remaining</span>
            <span class="stat-value green">₹<%= remainingBudget %>Cr</span>
            <span class="stat-sub">Available to bid</span>
        </div>
        <div class="stat-card blue">
            <div class="stat-icon">💰</div>
            <span class="stat-label">Total Budget</span>
            <span class="stat-value blue">₹<%= totalBudget %>Cr</span>
            <span class="stat-sub">Season allocation</span>
        </div>
    </div>

    <!-- BUDGET BAR -->
    <div class="budget-bar-wrap">
        <div class="budget-bar-top">
            <h4>Budget Utilisation</h4>
            <span><%= budgetPct %>% spent</span>
        </div>
        <div class="bar-track">
            <div class="bar-fill"></div>
        </div>
        <div class="budget-labels">
            <span class="spent">₹<%= totalSpending %>Cr spent</span>
            <span class="left">₹<%= remainingBudget %>Cr remaining</span>
        </div>
    </div>

    <!-- SQUAD TABLE -->
    <div class="card">
        <div class="card-header">
            <span>🏏</span>
            <h3>My Squad</h3>
            <span class="chip"><%= squadSize %> Players</span>
        </div>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Player</th>
                        <th>Role</th>
                        <th>Country</th>
                        <th>Sold Price</th>
                    </tr>
                </thead>
                <tbody>
<%
    if (players.isEmpty()) {
%>
                    <tr>
                        <td colspan="5">
                            <div class="empty-state">
                                <div class="icon">🏏</div>
                                <p>No players in your squad yet. Head to the auction to start bidding!</p>
                            </div>
                        </td>
                    </tr>
<%
    } else {
        int rowNum = 1;
        for (String[] p : players) {
            String pName  = p[0];
            String pRole  = p[1];
            String pCountry = p[2];
            double pPrice = Double.parseDouble(p[3]);

            String badgeClass = "badge-all";
            if ("BATSMAN".equals(pRole))           badgeClass = "badge-bat";
            else if ("BOWLER".equals(pRole))       badgeClass = "badge-bowl";
            else if ("WICKETKEEPER".equals(pRole)) badgeClass = "badge-wk";

            String nameInit = pName.trim().length() > 0
                ? String.valueOf(pName.trim().charAt(0)).toUpperCase() : "?";
%>
                    <tr>
                        <td class="row-num"><%= rowNum++ %></td>
                        <td>
                            <div class="player-cell">
                                <div class="player-init"><%= nameInit %></div>
                                <span class="player-name"><%= pName %></span>
                            </div>
                        </td>
                        <td><span class="badge <%= badgeClass %>"><%= pRole %></span></td>
                        <td class="country"><%= pCountry %></td>
                        <td class="sold-price">₹<%= pPrice %>Cr</td>
                    </tr>
<%
        }
    }
%>
                </tbody>
            </table>
        </div>
    </div>

</div>
</body>
</html>