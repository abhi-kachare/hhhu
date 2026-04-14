<%-- 
    Document   : place_bid
    Created on : 04-Mar-2026, 10:30:30 pm
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

    Integer teamId = (Integer) session.getAttribute("team_id");
    String teamName = (String) session.getAttribute("team_name");

    if (teamId == null) {
        response.sendRedirect("../team_login.jsp");
        return;
    }

    String message    = "";
    String msgType    = "";
    String playerName = "";
    String playerRole = "";
    double bidAmount  = 0;
    double minRequired = 0;
    double remainingAfter = 0;
    boolean success   = false;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        int auctionId = Integer.parseInt(request.getParameter("auction_id"));
        int playerId  = Integer.parseInt(request.getParameter("player_id"));

        // FIX: null check before parsing bid_amount to prevent NullPointerException
        String bidParam = request.getParameter("bid_amount");
        if (bidParam == null || bidParam.trim().isEmpty())
            throw new Exception("Bid amount is required.");
        bidAmount = Double.parseDouble(bidParam.trim());

        con = DBConnection.getConnection();
        con.setAutoCommit(false);

        // 1. Check Auction Status
        ps = con.prepareStatement(
            "SELECT status, bid_increment FROM auction WHERE auction_id=? FOR UPDATE");
        ps.setInt(1, auctionId);
        rs = ps.executeQuery();
        if (!rs.next()) throw new Exception("Auction not found.");
        String auctionStatus = rs.getString("status");
        double bidIncrement  = rs.getDouble("bid_increment");
        if (!"LIVE".equals(auctionStatus)) throw new Exception("Auction is not LIVE.");
        rs.close(); ps.close();

        // 2. Get Current Highest Bid
        ps = con.prepareStatement(
            "SELECT MAX(bid_amount) AS highest_bid FROM bids WHERE auction_id=? AND player_id=? FOR UPDATE");
        ps.setInt(1, auctionId); ps.setInt(2, playerId);
        rs = ps.executeQuery();
        double highestBid = rs.next() ? rs.getDouble("highest_bid") : 0;
        rs.close(); ps.close();

        // 3. Get Player Info
        ps = con.prepareStatement(
            "SELECT player_name, role, base_price, status FROM player WHERE player_id=? FOR UPDATE");
        ps.setInt(1, playerId);
        rs = ps.executeQuery();
        if (!rs.next()) throw new Exception("Player not found.");
        playerName = rs.getString("player_name");
        playerRole = rs.getString("role");
        double basePrice    = rs.getDouble("base_price");
        String playerStatus = rs.getString("status");
        if (!"AVAILABLE".equals(playerStatus)) throw new Exception("Player is not available for bidding.");
        rs.close(); ps.close();

        // 4. Validate Bid Amount
        minRequired = (highestBid == 0) ? basePrice : highestBid + bidIncrement;
        if (bidAmount < minRequired)
            throw new Exception("Bid must be at least ₹" + minRequired + "Cr");

        // 5. Check Team Budget
        ps = con.prepareStatement(
            "SELECT remaining_budget FROM team WHERE team_id=? FOR UPDATE");
        ps.setInt(1, teamId);
        rs = ps.executeQuery();
        if (!rs.next()) throw new Exception("Team not found.");
        double remainingBudget = rs.getDouble("remaining_budget");
        if (bidAmount > remainingBudget) throw new Exception("Insufficient remaining budget.");
        remainingAfter = remainingBudget - bidAmount;
        rs.close(); ps.close();

        // 6. Insert Bid
        ps = con.prepareStatement(
            "INSERT INTO bids (auction_id, player_id, team_id, bid_amount) VALUES (?, ?, ?, ?)");
        ps.setInt(1, auctionId); ps.setInt(2, playerId);
        ps.setInt(3, teamId);    ps.setDouble(4, bidAmount);
        ps.executeUpdate(); ps.close();

        con.commit();
        message = "Bid placed successfully!";
        msgType = "success";
        success = true;

    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (Exception ignored) {}
        message = e.getMessage();
        msgType = "error";
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception ignored) {}
        if (ps  != null) try { ps.close();  } catch (Exception ignored) {}
        if (con != null) try { con.close(); } catch (Exception ignored) {}
    }

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
    <title>Place Bid – <%= playerName.isEmpty() ? "Result" : playerName %></title>
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
        .container {
            max-width: 560px;
            margin: 0 auto;
            padding: 48px 24px;
            display: flex; flex-direction: column; align-items: center; gap: 24px;
        }

        /* ── RESULT CARD ── */
        .result-card {
            width: 100%;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            animation: popIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        .result-card.success { border-color: rgba(34,201,122,0.3); }
        .result-card.error   { border-color: rgba(255,79,106,0.3); }

        .result-top {
            padding: 36px 32px 28px;
            display: flex; flex-direction: column; align-items: center;
            text-align: center; gap: 16px;
        }

        .result-icon-wrap {
            width: 72px; height: 72px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 2rem;
        }
        .result-icon-wrap.success {
            background: rgba(34,201,122,0.12);
            border: 2px solid rgba(34,201,122,0.3);
        }
        .result-icon-wrap.error {
            background: rgba(255,79,106,0.12);
            border: 2px solid rgba(255,79,106,0.3);
        }

        .result-title {
            font-family: 'Syne', sans-serif;
            font-size: 1.4rem; font-weight: 800;
        }
        .result-title.success { color: var(--green); }
        .result-title.error   { color: var(--red); }

        .result-message {
            font-size: 0.9rem; color: var(--muted);
            line-height: 1.6; max-width: 340px;
        }

        /* ── DIVIDER ── */
        .divider {
            height: 1px; background: var(--border); margin: 0 32px;
        }

        /* ── BID DETAILS ── */
        .bid-details {
            padding: 24px 32px;
            display: flex; flex-direction: column; gap: 14px;
        }

        .detail-row {
            display: flex; justify-content: space-between; align-items: center;
        }

        .detail-key {
            font-size: 0.78rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.07em; font-weight: 500;
        }

        .detail-val {
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem; font-weight: 700; color: var(--text);
        }
        .detail-val.green  { color: var(--green); }
        .detail-val.yellow { color: var(--yellow); }
        .detail-val.red    { color: var(--red); }

        .badge {
            display: inline-block; padding: 3px 10px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            letter-spacing: 0.05em; text-transform: uppercase;
        }
        .badge-bat  { background: rgba(245,200,66,0.12); color: var(--yellow); border: 1px solid rgba(245,200,66,0.25); }
        .badge-bowl { background: rgba(79,140,255,0.12); color: var(--accent); border: 1px solid rgba(79,140,255,0.25); }
        .badge-all  { background: rgba(124,92,252,0.12); color: var(--accent2); border: 1px solid rgba(124,92,252,0.25); }
        .badge-wk   { background: rgba(34,201,122,0.12); color: var(--green);  border: 1px solid rgba(34,201,122,0.25); }

        /* ── ACTIONS ── */
        .result-actions {
            padding: 20px 32px 28px;
            display: flex; flex-direction: column; gap: 10px;
        }

        .btn-primary {
            display: flex; align-items: center; justify-content: center; gap: 8px;
            padding: 13px 20px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            color: white; border: none; border-radius: 9px;
            text-decoration: none;
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem; font-weight: 800;
            cursor: pointer; transition: opacity 0.2s, transform 0.15s;
        }
        .btn-primary:hover { opacity: 0.88; transform: translateY(-1px); }

        .btn-secondary {
            display: flex; align-items: center; justify-content: center; gap: 8px;
            padding: 12px 20px;
            background: var(--surface2);
            color: var(--muted); border: 1px solid var(--border);
            border-radius: 9px; text-decoration: none;
            font-size: 0.9rem; font-weight: 500;
            transition: all 0.2s;
        }
        .btn-secondary:hover {
            color: var(--text); border-color: var(--accent);
            background: rgba(79,140,255,0.07);
        }

        @keyframes popIn {
            from { opacity: 0; transform: scale(0.94) translateY(12px); }
            to   { opacity: 1; transform: scale(1) translateY(0); }
        }

        @media (max-width: 600px) {
            .header { padding: 16px 20px; }
            .container { padding: 28px 16px; }
            .result-top, .bid-details, .result-actions { padding-left: 20px; padding-right: 20px; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="header-left">
        <div class="team-avatar"><%= teamInitials %></div>
        <div class="header-info">
            <span>Place Bid</span>
            <h2><%= teamName != null ? teamName : "Team" %></h2>
        </div>
    </div>
    <a class="back-btn" href="live_auction.jsp">← Live Auction</a>
</div>

<div class="container">

    <div class="result-card <%= msgType %>">

        <!-- TOP: icon + title + message -->
        <div class="result-top">
            <div class="result-icon-wrap <%= msgType %>">
                <%= success ? "✅" : "❌" %>
            </div>
            <div class="result-title <%= msgType %>">
                <%= success ? "Bid Placed!" : "Bid Failed" %>
            </div>
            <p class="result-message"><%= message %></p>
        </div>

        <% if (success && !playerName.isEmpty()) { %>

        <div class="divider"></div>

        <!-- BID DETAILS -->
        <div class="bid-details">

            <div class="detail-row">
                <span class="detail-key">Player</span>
                <span class="detail-val"><%= playerName %></span>
            </div>

            <% if (!playerRole.isEmpty()) {
                String badgeClass = "badge-all";
                if ("BATSMAN".equals(playerRole))           badgeClass = "badge-bat";
                else if ("BOWLER".equals(playerRole))       badgeClass = "badge-bowl";
                else if ("WICKETKEEPER".equals(playerRole)) badgeClass = "badge-wk";
            %>
            <div class="detail-row">
                <span class="detail-key">Role</span>
                <span class="badge <%= badgeClass %>"><%= playerRole %></span>
            </div>
            <% } %>

            <div class="detail-row">
                <span class="detail-key">Your Bid</span>
                <span class="detail-val yellow">₹<%= bidAmount %>Cr</span>
            </div>

            <div class="detail-row">
                <span class="detail-key">Budget Remaining</span>
                <span class="detail-val green">₹<%= remainingAfter %>Cr</span>
            </div>

        </div>

        <% } else if (!success) { %>

        <div class="divider"></div>

        <div class="bid-details">
            <div class="detail-row">
                <span class="detail-key">Minimum Required</span>
                <span class="detail-val red">
                    <%= minRequired > 0 ? "₹" + minRequired + "Cr" : "—" %>
                </span>
            </div>
            <% if (bidAmount > 0) { %>
            <div class="detail-row">
                <span class="detail-key">You Bid</span>
                <span class="detail-val">₹<%= bidAmount %>Cr</span>
            </div>
            <% } %>
        </div>

        <% } %>

        <!-- ACTIONS -->
        <div class="result-actions">
            <a class="btn-primary" href="live_auction.jsp">🏏 Back to Live Auction</a>
            <a class="btn-secondary" href="team_dashboard.jsp">← Team Dashboard</a>
        </div>

    </div>

</div>

</body>
</html>