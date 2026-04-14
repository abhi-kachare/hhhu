<%-- 
    Document   : live_auction
    Created on : 04-Mar-2026, 10:15:19 pm
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
    String teamName = (String) session.getAttribute("team_name");
    int liveAuctionId = -1;
    String auctionName = "";
    BigDecimal bidIncrement = BigDecimal.ZERO;
    BigDecimal remainingBudget = BigDecimal.ZERO;

    try (Connection con = DBConnection.getConnection()) {
        ResultSet rsAuction = con.createStatement().executeQuery(
            "SELECT auction_id, auction_name, bid_increment FROM auction WHERE status='LIVE' LIMIT 1");
        if (rsAuction.next()) {
            liveAuctionId = rsAuction.getInt("auction_id");
            auctionName   = rsAuction.getString("auction_name");
            bidIncrement  = rsAuction.getBigDecimal("bid_increment");
        }
        PreparedStatement psBudget = con.prepareStatement(
            "SELECT remaining_budget FROM team WHERE team_id=?");
        psBudget.setInt(1, teamId);
        ResultSet rsBudget = psBudget.executeQuery();
        if (rsBudget.next()) remainingBudget = rsBudget.getBigDecimal("remaining_budget");

    } catch (Exception e) { /* handled below */ }

    String[] words = (teamName != null ? teamName : "T").trim().split("\\s+");
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
    <meta http-equiv="refresh" content="15">
    <title>Live Auction – <%= auctionName %></title>
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

        .header-right { display: flex; align-items: center; gap: 12px; }

        .budget-chip {
            display: flex; flex-direction: column; align-items: flex-end;
            gap: 2px;
        }
        .budget-chip span {
            font-size: 0.68rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.07em;
        }
        .budget-chip strong {
            font-family: 'Syne', sans-serif;
            font-size: 1rem; font-weight: 800; color: var(--green);
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
        .container { max-width: 1200px; margin: 0 auto; padding: 36px 24px; }

        /* ── AUCTION INFO BAR ── */
        .auction-bar {
            display: flex; align-items: center; justify-content: space-between;
            background: linear-gradient(135deg, rgba(34,201,122,0.07), rgba(79,140,255,0.07));
            border: 1px solid rgba(34,201,122,0.2);
            border-radius: var(--radius);
            padding: 18px 26px;
            margin-bottom: 24px;
            flex-wrap: wrap; gap: 14px;
        }

        .auction-bar-left { display: flex; align-items: center; gap: 16px; }

        .live-pill {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 5px 14px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 700;
            letter-spacing: 0.07em; text-transform: uppercase;
            background: rgba(34,201,122,0.12);
            border: 1px solid rgba(34,201,122,0.3);
            color: var(--green); flex-shrink: 0;
        }
        .live-pill::before {
            content: '';
            width: 7px; height: 7px; border-radius: 50%;
            background: var(--green);
            animation: pulse 1.4s infinite;
        }

        .auction-bar-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.1rem; font-weight: 800; color: var(--text);
        }

        .auction-bar-right { display: flex; align-items: center; gap: 24px; }

        .meta-item { display: flex; flex-direction: column; gap: 2px; }
        .meta-item span {
            font-size: 0.68rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.07em;
        }
        .meta-item strong {
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem; font-weight: 700; color: var(--yellow);
        }

        .refresh-note {
            font-size: 0.75rem; color: var(--muted);
            display: flex; align-items: center; gap: 5px;
        }

        /* ── NO AUCTION ── */
        .empty-auction {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 64px 32px;
            text-align: center;
        }
        .empty-auction .icon { font-size: 3rem; margin-bottom: 16px; }
        .empty-auction h3 {
            font-family: 'Syne', sans-serif;
            font-size: 1.1rem; font-weight: 700; margin-bottom: 8px;
        }
        .empty-auction p { color: var(--muted); font-size: 0.9rem; }

        /* ── CARD ── */
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

        .player-name { font-weight: 600; font-size: 0.95rem; }

        .badge {
            display: inline-block; padding: 3px 10px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            letter-spacing: 0.05em; text-transform: uppercase;
        }
        .badge-bat  { background: rgba(245,200,66,0.12); color: var(--yellow); border: 1px solid rgba(245,200,66,0.25); }
        .badge-bowl { background: rgba(79,140,255,0.12); color: var(--accent); border: 1px solid rgba(79,140,255,0.25); }
        .badge-all  { background: rgba(124,92,252,0.12); color: var(--accent2); border: 1px solid rgba(124,92,252,0.25); }
        .badge-wk   { background: rgba(34,201,122,0.12); color: var(--green);  border: 1px solid rgba(34,201,122,0.25); }

        .price-base { color: var(--muted); font-size: 0.875rem; }

        .price-current {
            font-family: 'Syne', sans-serif;
            font-weight: 800; font-size: 1rem; color: var(--green);
        }
        .price-current.elevated { color: var(--yellow); }

        /* ── BID BUTTON ── */
        .bid-form { display: inline-flex; align-items: center; gap: 8px; }

        /* FIX: bid amount input field */
        .bid-input {
            width: 100px;
            padding: 7px 10px;
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: 7px;
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 0.82rem;
            outline: none;
            transition: border-color 0.2s;
        }
        .bid-input:focus { border-color: var(--accent); }
        .bid-input::placeholder { color: var(--muted); }

        .btn-bid {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 8px 18px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            color: white; border: none; border-radius: 8px;
            font-family: 'Syne', sans-serif;
            font-size: 0.82rem; font-weight: 700;
            cursor: pointer; letter-spacing: 0.03em;
            transition: opacity 0.2s, transform 0.15s;
            white-space: nowrap;
        }
        .btn-bid:hover { opacity: 0.88; transform: translateY(-1px); }
        .btn-bid:active { transform: translateY(0); }

        .empty-state {
            text-align: center; padding: 48px 24px; color: var(--muted);
        }
        .empty-state .icon { font-size: 2.5rem; margin-bottom: 12px; }

        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50%       { opacity: 0.4; transform: scale(0.75); }
        }

        @media (max-width: 768px) {
            .header { padding: 16px 20px; }
            .container { padding: 20px 16px; }
            .auction-bar { flex-direction: column; align-items: flex-start; }
            .auction-bar-right { flex-wrap: wrap; }
            .header-right .budget-chip { display: none; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="header-left">
        <div class="team-avatar"><%= teamInitials %></div>
        <div class="header-info">
            <span>Live Auction Room</span>
            <h2><%= teamName != null ? teamName : "Team" %></h2>
        </div>
    </div>
    <div class="header-right">
        <div class="budget-chip">
            <span>Remaining Budget</span>
            <strong>₹<%= remainingBudget %>Cr</strong>
        </div>
        <a class="back-btn" href="team_dashboard.jsp">← Dashboard</a>
    </div>
</div>

<div class="container">

<% if (liveAuctionId == -1) { %>

    <div class="empty-auction">
        <div class="icon">🏏</div>
        <h3>No Live Auction Running</h3>
        <p>Check back later or return to your dashboard to monitor the status.</p>
    </div>

<% } else { %>

    <!-- AUCTION INFO BAR -->
    <div class="auction-bar">
        <div class="auction-bar-left">
            <span class="live-pill">Live</span>
            <span class="auction-bar-name"><%= auctionName %></span>
        </div>
        <div class="auction-bar-right">
            <div class="meta-item">
                <span>Bid Increment</span>
                <strong>₹<%= bidIncrement %>Cr</strong>
            </div>
            <div class="meta-item">
                <span>Your Budget</span>
                <strong style="color:var(--green);">₹<%= remainingBudget %>Cr</strong>
            </div>
            <span class="refresh-note">🔄 Auto-refreshes every 15s</span>
        </div>
    </div>

    <!-- PLAYERS TABLE -->
    <div class="card">
        <div class="card-header">
            <span>🏏</span>
            <h3>Available Players</h3>
            <span class="chip">Bidding Open</span>
        </div>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Player</th>
                        <th>Role</th>
                        <th>Base Price</th>
                        <th>Current Highest Bid</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
<%
    try (Connection con = DBConnection.getConnection()) {
        String sql =
            "SELECT p.player_id, p.player_name, p.role, p.base_price, " +
            "IFNULL(MAX(b.bid_amount), 0) AS highest_bid " +
            "FROM player p " +
            "LEFT JOIN bids b ON p.player_id = b.player_id AND b.auction_id=? " +
            "WHERE p.status='AVAILABLE' " +
            "GROUP BY p.player_id ORDER BY p.player_name";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, liveAuctionId);
        ResultSet rs = ps.executeQuery();
        boolean hasRows = false;

        while (rs.next()) {
            hasRows = true;
            BigDecimal highestBid = rs.getBigDecimal("highest_bid");
            BigDecimal basePrice  = rs.getBigDecimal("base_price");
            BigDecimal displayBid = highestBid.compareTo(BigDecimal.ZERO) > 0 ? highestBid : basePrice;
            boolean isBidElevated = highestBid.compareTo(BigDecimal.ZERO) > 0;

            String role = rs.getString("role");
            String badgeClass = "badge-all";
            if ("BATSMAN".equals(role))          badgeClass = "badge-bat";
            else if ("BOWLER".equals(role))      badgeClass = "badge-bowl";
            else if ("WICKETKEEPER".equals(role)) badgeClass = "badge-wk";
%>
                    <tr>
                        <td class="player-name"><%= rs.getString("player_name") %></td>
                        <td><span class="badge <%= badgeClass %>"><%= role %></span></td>
                        <td class="price-base">₹<%= basePrice %>Cr</td>
                        <td>
                            <span class="price-current <%= isBidElevated ? "elevated" : "" %>">
                                ₹<%= displayBid %>Cr
                                <% if (isBidElevated) { %><span style="font-size:0.7rem;color:var(--muted);font-family:'DM Sans',sans-serif;font-weight:400;"> highest</span><% } %>
                            </span>
                        </td>
                        <td>
                            <form class="bid-form" action="place_bid.jsp" method="get">
                                <input type="hidden" name="player_id"  value="<%= rs.getInt("player_id") %>"/>
                                <input type="hidden" name="auction_id" value="<%= liveAuctionId %>"/>
                                <%-- FIX: bid_amount input added so place_bid.jsp receives it --%>
                                <input type="number" name="bid_amount" class="bid-input"
                                       min="<%= displayBid %>" step="<%= bidIncrement %>"
                                       placeholder="Amt (Cr)" required />
                                <button class="btn-bid" type="submit">🏷 Place Bid</button>
                            </form>
                        </td>
                    </tr>
<%
        }
        if (!hasRows) {
%>
                    <tr>
                        <td colspan="5">
                            <div class="empty-state">
                                <div class="icon">✅</div>
                                <div>All players have been sold or none are available.</div>
                            </div>
                        </td>
                    </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='5' style='text-align:center;color:var(--red);padding:20px;'>Error loading players: " + e.getMessage() + "</td></tr>");
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