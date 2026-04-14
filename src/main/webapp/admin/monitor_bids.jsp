<%-- 
    Document   : monitor_bids
    Created on : 03-Mar-2026, 10:57:33 pm
    Author     : abhishek
--%>




<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<%
if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
    response.sendRedirect("login_admin.jsp");
    return;
}

int liveAuctionId = -1;

try (Connection con = DBConnection.getConnection()) {
    ResultSet rs = con.createStatement()
        .executeQuery("SELECT auction_id FROM auction WHERE status='LIVE' LIMIT 1");
    if (rs.next()) {
        liveAuctionId = rs.getInt("auction_id");
    }
} catch (Exception e) {
    out.println("Error: " + e.getMessage());
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="5">
    <title>Monitor Live Bids</title>
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
            --yellow:   #f5c842;
            --orange:   #ff8c42;
            --text:     #e8ecf5;
            --muted:    #7a82a0;
            --radius:   12px;
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

        .header-left {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .header-icon {
            width: 42px; height: 42px;
            background: linear-gradient(135deg, var(--red), var(--orange));
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px;
        }

        .header h2 {
            font-family: 'Syne', sans-serif;
            font-size: 1.5rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(90deg, #fff 40%, var(--red));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .live-pill {
            display: flex;
            align-items: center;
            gap: 7px;
            background: rgba(255,79,106,0.12);
            border: 1px solid rgba(255,79,106,0.3);
            color: var(--red);
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .live-dot {
            width: 8px; height: 8px;
            background: var(--red);
            border-radius: 50%;
            animation: pulse 1.2s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50%       { opacity: 0.4; transform: scale(0.7); }
        }

        .refresh-badge {
            font-size: 0.72rem;
            font-weight: 500;
            color: var(--muted);
            background: var(--surface2);
            border: 1px solid var(--border);
            padding: 4px 10px;
            border-radius: 20px;
            letter-spacing: 0.05em;
        }

        /* ── LAYOUT ── */
        .container {
            max-width: 1200px;
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
            margin-bottom: 28px;
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

        /* ── AUCTION INFO BAR ── */
        .auction-bar {
            display: flex;
            align-items: center;
            gap: 16px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-left: 4px solid var(--red);
            border-radius: var(--radius);
            padding: 16px 24px;
            margin-bottom: 28px;
        }

        .auction-bar .label {
            font-size: 0.75rem;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.07em;
            font-weight: 600;
        }

        .auction-bar .value {
            font-family: 'Syne', sans-serif;
            font-size: 1.1rem;
            font-weight: 800;
            color: var(--text);
        }

        .auction-bar .divider {
            width: 1px;
            height: 36px;
            background: var(--border);
            margin: 0 4px;
        }

        /* ── CARD ── */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            margin-bottom: 24px;
        }

        .card-header {
            padding: 18px 24px;
            border-bottom: 1px solid var(--border);
            background: var(--surface2);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-header h3 {
            font-family: 'Syne', sans-serif;
            font-size: 1rem;
            font-weight: 700;
            color: var(--text);
        }

        .card-header .chip {
            margin-left: auto;
            font-size: 0.7rem;
            padding: 3px 9px;
            border-radius: 20px;
            font-weight: 600;
        }

        .chip-red {
            background: rgba(255,79,106,0.15);
            color: var(--red);
            border: 1px solid rgba(255,79,106,0.25);
        }

        .chip-yellow {
            background: rgba(245,200,66,0.15);
            color: var(--yellow);
            border: 1px solid rgba(245,200,66,0.25);
        }

        /* ── TABLE ── */
        .table-wrapper { overflow-x: auto; }

        table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }

        thead tr {
            background: var(--surface2);
            border-bottom: 1px solid var(--border);
        }

        thead th {
            padding: 13px 16px;
            text-align: left;
            font-family: 'Syne', sans-serif;
            font-size: 0.72rem;
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
        tbody tr:first-child td { position: relative; }
        tbody tr:first-child { background: rgba(245,200,66,0.04); }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: rgba(255,255,255,0.03); }

        tbody td {
            padding: 13px 16px;
            color: var(--text);
            vertical-align: middle;
        }

        .bid-id {
            color: var(--muted);
            font-size: 0.8rem;
        }

        .player-name {
            font-weight: 600;
            color: var(--text);
        }

        .team-tag {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(79,140,255,0.1);
            border: 1px solid rgba(79,140,255,0.2);
            color: var(--accent);
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.78rem;
            font-weight: 600;
        }

        .bid-amount {
            font-family: 'Syne', sans-serif;
            font-weight: 800;
            font-size: 1rem;
            color: var(--green);
        }

        .top-bid {
            color: var(--yellow);
        }

        .bid-time {
            color: var(--muted);
            font-size: 0.8rem;
            font-variant-numeric: tabular-nums;
        }

        /* ── NO AUCTION STATE ── */
        .no-auction {
            text-align: center;
            padding: 80px 24px;
        }

        .no-auction .icon {
            font-size: 3.5rem;
            margin-bottom: 16px;
            opacity: 0.4;
        }

        .no-auction h3 {
            font-family: 'Syne', sans-serif;
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--muted);
            margin-bottom: 8px;
        }

        .no-auction p {
            color: var(--muted);
            font-size: 0.9rem;
            opacity: 0.7;
        }

        .empty-state {
            text-align: center;
            padding: 40px 24px;
            color: var(--muted);
        }
        .empty-state .icon { font-size: 2rem; margin-bottom: 10px; }

        /* ── LEADING BADGE ── */
        .leading-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: rgba(34,201,122,0.1);
            border: 1px solid rgba(34,201,122,0.25);
            color: var(--green);
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.78rem;
            font-weight: 700;
        }

        @media (max-width: 768px) {
            .header { padding: 16px 20px; }
            .container { padding: 20px 16px; }
            .auction-bar { flex-wrap: wrap; gap: 12px; }
            .auction-bar .divider { display: none; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="header-left">
        <div class="header-icon">🔴</div>
        <h2>Live Bid Monitor</h2>
    </div>
    <div class="header-right">
        <% if (liveAuctionId != -1) { %>
        <div class="live-pill">
            <div class="live-dot"></div>
            Live
        </div>
        <% } %>
        <span class="refresh-badge">⟳ Auto-refresh 5s</span>
    </div>
</div>

<div class="container">

    <a class="back" href="admin_dashboard.jsp">← Back to Dashboard</a>

    <% if (liveAuctionId == -1) { %>

    <div class="card">
        <div class="no-auction">
            <div class="icon">📭</div>
            <h3>No Live Auction Running</h3>
            <p>Start an auction from the dashboard to monitor bids here.</p>
        </div>
    </div>

    <% } else { %>

    <!-- AUCTION INFO BAR -->
    <div class="auction-bar">
        <div>
            <div class="label">Auction ID</div>
            <div class="value">#<%= liveAuctionId %></div>
        </div>
        <div class="divider"></div>
        <div>
            <div class="label">Status</div>
            <div class="value" style="color:var(--red);">● LIVE</div>
        </div>
        <div class="divider"></div>
        <div>
            <div class="label">Next Refresh</div>
            <div class="value" style="font-size:0.9rem; color:var(--muted);">in 5 seconds</div>
        </div>
    </div>

    <!-- ALL BIDS TABLE -->
    <div class="card">
        <div class="card-header">
            <span>📋</span>
            <h3>All Bids — Latest First</h3>
            <span class="chip chip-red">Live Feed</span>
        </div>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Bid ID</th>
                        <th>Player</th>
                        <th>Team</th>
                        <th>Bid Amount</th>
                        <th>Time</th>
                    </tr>
                </thead>
                <tbody>
<%
try (Connection con = DBConnection.getConnection()) {
    String sql =
        "SELECT b.bid_id, p.player_name, t.team_name, "
      + "b.bid_amount, b.bid_time "
      + "FROM bids b "
      + "JOIN player p ON b.player_id = p.player_id "
      + "JOIN team t ON b.team_id = t.team_id "
      + "WHERE b.auction_id = ? "
      + "ORDER BY b.bid_time DESC";

    PreparedStatement ps = con.prepareStatement(sql);
    ps.setInt(1, liveAuctionId);
    ResultSet rs = ps.executeQuery();
    boolean hasRows = false;
    boolean isFirst = true;

    while (rs.next()) {
        hasRows = true;
%>
                    <tr>
                        <td class="bid-id">#<%= rs.getInt("bid_id") %></td>
                        <td class="player-name"><%= rs.getString("player_name") %></td>
                        <td><span class="team-tag">🏏 <%= rs.getString("team_name") %></span></td>
                        <td><span class="bid-amount <%= isFirst ? "top-bid" : "" %>">
                            ₹<%= rs.getBigDecimal("bid_amount") %>L
                            <% if (isFirst) { %> 🔥<% } %>
                        </span></td>
                        <td class="bid-time"><%= rs.getTimestamp("bid_time") %></td>
                    </tr>
<%
        isFirst = false;
    }
    if (!hasRows) {
%>
                    <tr><td colspan="5">
                        <div class="empty-state">
                            <div class="icon">📭</div>
                            <div>No bids placed yet.</div>
                        </div>
                    </td></tr>
<%
    }
} catch (Exception e) {
    out.println("<tr><td colspan='5' style='text-align:center;color:var(--red);padding:20px;'>Error: " + e.getMessage() + "</td></tr>");
}
%>
                </tbody>
            </table>
        </div>
    </div>

    <!-- HIGHEST BID PER PLAYER -->
    <div class="card">
        <div class="card-header">
            <span>🏆</span>
            <h3>Highest Bid Per Player</h3>
            <span class="chip chip-yellow">Leaderboard</span>
        </div>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Player</th>
                        <th>Highest Bid</th>
                        <th>Leading Team</th>
                    </tr>
                </thead>
                <tbody>
<%
try (Connection con = DBConnection.getConnection()) {
    String sql =
      "SELECT p.player_name, MAX(b.bid_amount) AS max_bid, t.team_name "
    + "FROM bids b "
    + "JOIN player p ON b.player_id = p.player_id "
    + "JOIN team t ON b.team_id = t.team_id "
    + "WHERE b.auction_id = ? "
    + "GROUP BY b.player_id";

    PreparedStatement ps = con.prepareStatement(sql);
    ps.setInt(1, liveAuctionId);
    ResultSet rs = ps.executeQuery();
    boolean hasRows = false;

    while (rs.next()) {
        hasRows = true;
%>
                    <tr>
                        <td class="player-name"><%= rs.getString("player_name") %></td>
                        <td><span class="bid-amount">₹<%= rs.getBigDecimal("max_bid") %>L</span></td>
                        <td><span class="leading-badge">🏆 <%= rs.getString("team_name") %></span></td>
                    </tr>
<%
    }
    if (!hasRows) {
%>
                    <tr><td colspan="3">
                        <div class="empty-state">
                            <div class="icon">📭</div>
                            <div>No bids yet.</div>
                        </div>
                    </td></tr>
<%
    }
} catch (Exception e) {
    out.println("<tr><td colspan='3' style='text-align:center;color:var(--red);padding:20px;'>Error: " + e.getMessage() + "</td></tr>");
}
%>
                </tbody>
            </table>
        </div>
    </div>

    <% } %>

</div>
</body>
</html>