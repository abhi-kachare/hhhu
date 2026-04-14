<%-- 
    Document   : reports
    Created on : 03-Mar-2026, 11:20:21 pm
    Author     : abhishek
--%>




<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="util.DBConnection" %>
<%
    if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect("login_admin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Auction Reports</title>
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
            --orange:  #ff8c42;
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
            padding: 22px 40px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
            backdrop-filter: blur(12px);
        }
        .header-left { display: flex; align-items: center; gap: 14px; }
        .header-icon {
            width: 42px; height: 42px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px;
        }
        .header h2 {
            font-family: 'Syne', sans-serif;
            font-size: 1.5rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(90deg, #fff 40%, var(--accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .header-badge {
            font-size: 0.72rem;
            font-weight: 500;
            color: var(--muted);
            background: var(--surface2);
            border: 1px solid var(--border);
            padding: 4px 10px;
            border-radius: 20px;
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }

        /* ── LAYOUT ── */
        .container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 36px 24px;
        }

        .back {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            color: var(--muted);
            text-decoration: none;
            font-size: 0.875rem;
            font-weight: 500;
            margin-bottom: 32px;
            padding: 8px 16px;
            border: 1px solid var(--border);
            border-radius: 8px;
            background: var(--surface);
            transition: all 0.2s;
        }
        .back:hover {
            color: var(--text);
            border-color: var(--accent);
            background: rgba(79,140,255,0.07);
        }

        /* ── SECTION TITLE ── */
        .section-title {
            font-family: 'Syne', sans-serif;
            font-size: 0.72rem;
            font-weight: 700;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.12em;
            margin-bottom: 16px;
            margin-top: 36px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .section-title::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--border);
        }

        /* ── STAT GRID ── */
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
            margin-bottom: 8px;
        }

        .stat-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 20px 22px;
            position: relative;
            overflow: hidden;
            transition: border-color 0.2s, transform 0.2s;
        }
        .stat-card:hover { border-color: var(--accent); transform: translateY(-2px); }
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
        }
        .stat-card.blue::before  { background: linear-gradient(90deg, var(--accent), var(--accent2)); }
        .stat-card.green::before { background: linear-gradient(90deg, var(--green), #16a060); }
        .stat-card.red::before   { background: linear-gradient(90deg, var(--red), #c0392b); }
        .stat-card.yellow::before{ background: linear-gradient(90deg, var(--yellow), var(--orange)); }

        .stat-label {
            font-size: 0.72rem;
            font-weight: 600;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.08em;
            margin-bottom: 10px;
        }
        .stat-value {
            font-family: 'Syne', sans-serif;
            font-size: 2rem;
            font-weight: 800;
            line-height: 1;
        }
        .stat-card.blue  .stat-value { color: var(--accent); }
        .stat-card.green .stat-value { color: var(--green); }
        .stat-card.red   .stat-value { color: var(--red); }
        .stat-card.yellow .stat-value{ color: var(--yellow); }
        .stat-icon {
            position: absolute;
            right: 16px; top: 16px;
            font-size: 1.6rem;
            opacity: 0.18;
        }

        /* ── REVENUE HERO ── */
        .revenue-card {
            background: linear-gradient(135deg, #0f1a2e 0%, #151c2e 100%);
            border: 1px solid rgba(79,140,255,0.25);
            border-radius: var(--radius);
            padding: 28px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 8px;
            position: relative;
            overflow: hidden;
        }
        .revenue-card::before {
            content: '';
            position: absolute;
            inset: 0;
            background: radial-gradient(ellipse at 80% 50%, rgba(79,140,255,0.08) 0%, transparent 70%);
            pointer-events: none;
        }
        .revenue-label {
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.1em;
            margin-bottom: 8px;
        }
        .revenue-amount {
            font-family: 'Syne', sans-serif;
            font-size: 2.6rem;
            font-weight: 800;
            color: var(--green);
            letter-spacing: -1px;
        }
        .revenue-icon { font-size: 3.5rem; opacity: 0.15; }

        /* ── CARD ── */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            margin-bottom: 8px;
        }
        .card-header {
            padding: 16px 24px;
            border-bottom: 1px solid var(--border);
            background: var(--surface2);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .card-header h3 {
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem;
            font-weight: 700;
        }
        .card-header .chip {
            margin-left: auto;
            font-size: 0.7rem;
            padding: 3px 9px;
            border-radius: 20px;
            background: rgba(79,140,255,0.15);
            color: var(--accent);
            border: 1px solid rgba(79,140,255,0.25);
            font-weight: 600;
        }

        /* ── TABLE ── */
        .table-wrapper { overflow-x: auto; }

        table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }

        thead tr {
            background: var(--surface2);
            border-bottom: 1px solid var(--border);
        }
        thead th {
            padding: 12px 16px;
            text-align: left;
            font-family: 'Syne', sans-serif;
            font-size: 0.7rem;
            font-weight: 700;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.08em;
            white-space: nowrap;
        }
        tbody tr {
            border-bottom: 1px solid var(--border);
            transition: background 0.15s;
        }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: rgba(255,255,255,0.03); }
        tbody td { padding: 13px 16px; vertical-align: middle; }

        .rank-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 26px; height: 26px;
            border-radius: 6px;
            font-family: 'Syne', sans-serif;
            font-size: 0.75rem;
            font-weight: 800;
        }
        .rank-1 { background: rgba(245,200,66,0.15); color: var(--yellow); border: 1px solid rgba(245,200,66,0.3); }
        .rank-2 { background: rgba(229,229,229,0.1); color: #ccc; border: 1px solid rgba(229,229,229,0.2); }
        .rank-3 { background: rgba(255,140,66,0.12); color: var(--orange); border: 1px solid rgba(255,140,66,0.25); }
        .rank-other { background: var(--surface2); color: var(--muted); border: 1px solid var(--border); }

        .price-high { font-family: 'Syne', sans-serif; font-weight: 700; color: var(--green); }
        .team-tag {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 20px;
            background: rgba(79,140,255,0.1);
            color: var(--accent);
            border: 1px solid rgba(79,140,255,0.2);
            font-size: 0.78rem;
            font-weight: 600;
        }

        /* Spending bar */
        .spend-row td { padding: 10px 16px; }
        .spend-bar-wrap {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .spend-bar-bg {
            flex: 1;
            height: 6px;
            background: var(--surface2);
            border-radius: 99px;
            overflow: hidden;
        }
        .spend-bar-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
            border-radius: 99px;
        }
        .spend-amount {
            font-family: 'Syne', sans-serif;
            font-weight: 700;
            color: var(--green);
            font-size: 0.85rem;
            white-space: nowrap;
            min-width: 90px;
            text-align: right;
        }

        .error-card {
            background: rgba(255,79,106,0.08);
            border: 1px solid rgba(255,79,106,0.25);
            border-radius: var(--radius);
            padding: 20px 24px;
            color: var(--red);
            font-size: 0.9rem;
        }

        @media (max-width: 768px) {
            .header { padding: 16px 20px; }
            .container { padding: 20px 16px; }
            .revenue-amount { font-size: 1.8rem; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="header-left">
        <div class="header-icon">📊</div>
        <h2>Auction Reports</h2>
    </div>
    <span class="header-badge">Admin Panel</span>
</div>

<div class="container">

    <a class="back" href="admin_dashboard.jsp">← Back to Dashboard</a>

<%
try (Connection con = DBConnection.getConnection()) {
    Statement st = con.createStatement();

    // Auction Summary
    ResultSet rsAuction = st.executeQuery(
        "SELECT COUNT(*) total, " +
        "SUM(status='LIVE') live_count, " +
        "SUM(status='CLOSED') closed_count " +
        "FROM auction");
    rsAuction.next();
    int totalAuctions  = rsAuction.getInt("total");
    int liveAuctions   = rsAuction.getInt("live_count");
    int closedAuctions = rsAuction.getInt("closed_count");

    // Revenue
    ResultSet rsRevenue = st.executeQuery(
        "SELECT IFNULL(SUM(sold_price),0) total_revenue FROM player WHERE status='SOLD'");
    rsRevenue.next();
    BigDecimal totalRevenue = rsRevenue.getBigDecimal("total_revenue");

    // Player Status
    ResultSet rsPlayers = st.executeQuery(
        "SELECT SUM(status='SOLD') sold_count, " +
        "SUM(status='UNSOLD') unsold_count, " +
        "SUM(status='AVAILABLE') available_count FROM player");
    rsPlayers.next();
    int soldCount      = rsPlayers.getInt("sold_count");
    int unsoldCount    = rsPlayers.getInt("unsold_count");
    int availableCount = rsPlayers.getInt("available_count");
%>

    <!-- AUCTION SUMMARY STATS -->
    <div class="section-title">Auction Overview</div>
    <div class="stat-grid">
        <div class="stat-card blue">
            <div class="stat-icon">🏟️</div>
            <div class="stat-label">Total Auctions</div>
            <div class="stat-value"><%= totalAuctions %></div>
        </div>
        <div class="stat-card green">
            <div class="stat-icon">🔴</div>
            <div class="stat-label">Live Now</div>
            <div class="stat-value"><%= liveAuctions %></div>
        </div>
        <div class="stat-card red">
            <div class="stat-icon">✅</div>
            <div class="stat-label">Closed</div>
            <div class="stat-value"><%= closedAuctions %></div>
        </div>
    </div>

    <!-- REVENUE HERO -->
    <div class="section-title">Revenue</div>
    <div class="revenue-card">
        <div>
            <div class="revenue-label">Total Revenue Generated</div>
            <div class="revenue-amount">₹ <%= totalRevenue %></div>
        </div>
        <div class="revenue-icon">💰</div>
    </div>

    <!-- PLAYER STATUS STATS -->
    <div class="section-title">Player Status</div>
    <div class="stat-grid">
        <div class="stat-card green">
            <div class="stat-icon">🏏</div>
            <div class="stat-label">Sold Players</div>
            <div class="stat-value"><%= soldCount %></div>
        </div>
        <div class="stat-card red">
            <div class="stat-icon">❌</div>
            <div class="stat-label">Unsold Players</div>
            <div class="stat-value"><%= unsoldCount %></div>
        </div>
        <div class="stat-card yellow">
            <div class="stat-icon">⏳</div>
            <div class="stat-label">Available</div>
            <div class="stat-value"><%= availableCount %></div>
        </div>
    </div>

    <!-- TEAM-WISE SPENDING -->
    <div class="section-title">Team Spending</div>
    <div class="card">
        <div class="card-header">
            <span>💸</span>
            <h3>Team-wise Spending</h3>
            <span class="chip">Ranked</span>
        </div>
        <div class="table-wrapper">
<%
    // Find max for bar scaling
    ResultSet rsMaxSpend = st.executeQuery(
        "SELECT IFNULL(MAX(total_spent),1) max_val FROM (" +
        "SELECT IFNULL(SUM(p.sold_price),0) total_spent FROM team t " +
        "LEFT JOIN player p ON t.team_id = p.team_id AND p.status='SOLD' " +
        "GROUP BY t.team_id) sub");
    rsMaxSpend.next();
    double maxSpend = rsMaxSpend.getDouble("max_val");
    if (maxSpend == 0) maxSpend = 1;

    ResultSet rsTeam = st.executeQuery(
        "SELECT t.team_name, IFNULL(SUM(p.sold_price),0) total_spent " +
        "FROM team t " +
        "LEFT JOIN player p ON t.team_id = p.team_id AND p.status='SOLD' " +
        "GROUP BY t.team_id ORDER BY total_spent DESC");
%>
            <table>
                <thead>
                    <tr>
                        <th style="width:50px">#</th>
                        <th>Team</th>
                        <th>Spending</th>
                        <th style="width:120px; text-align:right;">Amount</th>
                    </tr>
                </thead>
                <tbody>
<%
    int teamRank = 0;
    while (rsTeam.next()) {
        teamRank++;
        double spent = rsTeam.getDouble("total_spent");
        int barWidth = (int)((spent / maxSpend) * 100);
        String rankClass = teamRank == 1 ? "rank-1" : teamRank == 2 ? "rank-2" : teamRank == 3 ? "rank-3" : "rank-other";
%>
                    <tr class="spend-row">
                        <td><span class="rank-badge <%= rankClass %>"><%= teamRank %></span></td>
                        <td><span class="team-tag">🏆 <%= rsTeam.getString("team_name") %></span></td>
                        <td>
                            <div class="spend-bar-wrap">
                                <div class="spend-bar-bg">
                                    <div class="spend-bar-fill" style="width:<%= barWidth %>%"></div>
                                </div>
                            </div>
                        </td>
                        <td style="text-align:right"><span class="spend-amount">₹ <%= rsTeam.getBigDecimal("total_spent") %></span></td>
                    </tr>
<%
    }
%>
                </tbody>
            </table>
        </div>
    </div>

    <!-- TOP 5 HIGHEST BIDS -->
    <div class="section-title">Top Transfers</div>
    <div class="card">
        <div class="card-header">
            <span>🏅</span>
            <h3>Top 5 Highest Sold Players</h3>
            <span class="chip">Hall of Fame</span>
        </div>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th style="width:50px">Rank</th>
                        <th>Player</th>
                        <th>Team</th>
                        <th style="text-align:right;">Sold Price</th>
                    </tr>
                </thead>
                <tbody>
<%
    ResultSet rsTop = st.executeQuery(
        "SELECT p.player_name, t.team_name, p.sold_price " +
        "FROM player p JOIN team t ON p.team_id = t.team_id " +
        "WHERE p.status='SOLD' ORDER BY p.sold_price DESC LIMIT 5");
    int topRank = 0;
    while (rsTop.next()) {
        topRank++;
        String rc = topRank == 1 ? "rank-1" : topRank == 2 ? "rank-2" : topRank == 3 ? "rank-3" : "rank-other";
        String medal = topRank == 1 ? "🥇" : topRank == 2 ? "🥈" : topRank == 3 ? "🥉" : "  ";
%>
                    <tr>
                        <td><span class="rank-badge <%= rc %>"><%= medal.trim().isEmpty() ? topRank+"" : medal %></span></td>
                        <td style="font-weight:600"><%= rsTop.getString("player_name") %></td>
                        <td><span class="team-tag">🏆 <%= rsTop.getString("team_name") %></span></td>
                        <td style="text-align:right"><span class="price-high">₹ <%= rsTop.getBigDecimal("sold_price") %></span></td>
                    </tr>
<%
    }
%>
                </tbody>
            </table>
        </div>
    </div>

<%
} catch (Exception e) {
%>
    <div class="error-card">
        ✗ Error loading reports: <%= e.getMessage() %>
    </div>
<%
}
%>

</div>
</body>
</html>