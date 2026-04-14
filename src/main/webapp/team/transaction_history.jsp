<%-- 
    Document   : transaction_history
    Created on : 04-Mar-2026, 10:53:18 pm
    Author     : abhishek
--%>




<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="util.DBConnection" %>

<%
    if (session == null || !"TEAM".equals(session.getAttribute("role"))) {
        response.sendRedirect("team_login.jsp");
        return;
    }

    Integer teamId  = (Integer) session.getAttribute("team_id");
    String teamName = (String)  session.getAttribute("team_name");

    if (teamId == null) {
        response.sendRedirect("../team_login.jsp");
        return;
    }

    String[] words = (teamName != null ? teamName : "T").trim().split("\\s+");
    StringBuilder ini = new StringBuilder();
    for (int w = 0; w < Math.min(2, words.length); w++)
        if (words[w].length() > 0) ini.append(words[w].charAt(0));
    String teamInitials = ini.toString().toUpperCase();

    // Aggregates
    int    totalBids   = 0;
    int    wins        = 0;
    int    losses      = 0;
    int    pending     = 0;
    double totalStaked = 0;
    double totalWon    = 0;

    java.util.List<String[]> rows = new java.util.ArrayList<>();
    String errorMsg = null;
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DBConnection.getConnection();
        String sql =
            "SELECT b.bid_id, a.auction_name, p.player_name, " +
            "b.bid_amount, b.bid_time, " +
            "p.status AS player_status, p.team_id AS winner_team " +
            "FROM bids b " +
            "JOIN auction a ON b.auction_id = a.auction_id " +
            "JOIN player  p ON b.player_id  = p.player_id " +
            "WHERE b.team_id = ? ORDER BY b.bid_time DESC";
        ps = con.prepareStatement(sql);
        ps.setInt(1, teamId);
        rs = ps.executeQuery();

        while (rs.next()) {
            totalBids++;
            String playerStatus = rs.getString("player_status");
            int    winnerTeam   = rs.getInt("winner_team");
            double bidAmount    = rs.getDouble("bid_amount");
            totalStaked += bidAmount;

            String result;
            if ("SOLD".equals(playerStatus) && winnerTeam == teamId) {
                result = "WIN";    wins++;    totalWon += bidAmount;
            } else if ("SOLD".equals(playerStatus) && winnerTeam != teamId) {
                result = "LOSS";   losses++;
            } else {
                result = "PENDING"; pending++;
            }

            Timestamp ts = rs.getTimestamp("bid_time");
            String formattedTime = ts != null ? sdf.format(ts) : "—";

            rows.add(new String[]{
                rs.getString("auction_name"),
                rs.getString("player_name"),
                String.valueOf(bidAmount),
                formattedTime,
                result
            });
        }

    } catch (Exception e) {
        errorMsg = e.getMessage();
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception ignored) {}
        if (ps  != null) try { ps.close();  } catch (Exception ignored) {}
        if (con != null) try { con.close(); } catch (Exception ignored) {}
    }

    int winPct = totalBids > 0 ? (int) Math.round((wins * 100.0) / totalBids) : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaction History – <%= teamName %></title>
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
            grid-template-columns: repeat(5, 1fr);
            gap: 14px;
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
        .stat-card.red::before    { background: linear-gradient(90deg, var(--red), #ff9b44); }
        .stat-card.yellow::before { background: linear-gradient(90deg, var(--yellow), #ff9b44); }
        .stat-card.purple::before { background: linear-gradient(90deg, var(--accent2), #c56cfc); }

        .stat-icon { font-size: 1.2rem; margin-bottom: 2px; }

        .stat-label {
            font-size: 0.7rem; font-weight: 600; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.08em;
        }

        .stat-value {
            font-family: 'Syne', sans-serif;
            font-size: 1.45rem; font-weight: 800; letter-spacing: -0.5px;
        }
        .stat-value.blue   { color: var(--accent); }
        .stat-value.green  { color: var(--green); }
        .stat-value.red    { color: var(--red); }
        .stat-value.yellow { color: var(--yellow); }
        .stat-value.purple { color: var(--accent2); }

        .stat-sub { font-size: 0.74rem; color: var(--muted); }

        /* ── WIN RATE BAR ── */
        .winrate-wrap {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 18px 24px;
            margin-bottom: 24px;
        }

        .winrate-top {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 12px;
        }

        .winrate-top h4 {
            font-family: 'Syne', sans-serif;
            font-size: 0.9rem; font-weight: 700;
        }

        .winrate-top span { font-size: 0.8rem; color: var(--muted); }

        .bar-track {
            width: 100%; height: 9px;
            background: var(--surface2); border-radius: 99px; overflow: hidden;
        }

        .bar-fill {
            height: 100%; border-radius: 99px;
            background: linear-gradient(90deg, var(--green), #0fe38a);
            width: <%= winPct %>%;
            transition: width 1s ease;
        }

        .bar-labels {
            display: flex; justify-content: space-between;
            margin-top: 10px; font-size: 0.78rem;
        }
        .bar-labels .w { color: var(--green); font-weight: 600; }
        .bar-labels .l { color: var(--red);   font-weight: 600; }

        /* ── FILTER ROW ── */
        .filter-row {
            display: flex; align-items: center; gap: 10px;
            margin-bottom: 16px; flex-wrap: wrap;
        }

        .filter-btn {
            padding: 7px 16px; border-radius: 20px;
            font-size: 0.78rem; font-weight: 600;
            border: 1px solid var(--border);
            background: var(--surface); color: var(--muted);
            cursor: pointer; transition: all 0.2s;
        }
        .filter-btn:hover,
        .filter-btn.active {
            background: rgba(79,140,255,0.12);
            border-color: var(--accent); color: var(--accent);
        }
        .filter-btn.win.active   { background: rgba(34,201,122,0.12); border-color: var(--green); color: var(--green); }
        .filter-btn.loss.active  { background: rgba(255,79,106,0.12); border-color: var(--red);   color: var(--red); }
        .filter-btn.pend.active  { background: rgba(245,200,66,0.12); border-color: var(--yellow);color: var(--yellow); }

        /* ── CARD / TABLE ── */
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

        .auction-name {
            font-size: 0.78rem; color: var(--muted); font-weight: 500;
        }

        .player-cell { display: flex; align-items: center; gap: 10px; }

        .player-init {
            width: 32px; height: 32px; border-radius: 8px; flex-shrink: 0;
            background: var(--surface2); border: 1px solid var(--border);
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif; font-weight: 800;
            font-size: 0.8rem; color: var(--muted);
        }

        .player-name-text { font-weight: 600; font-size: 0.9rem; }

        .bid-amount {
            font-family: 'Syne', sans-serif;
            font-weight: 800; font-size: 0.95rem; color: var(--accent);
        }

        .bid-time { font-size: 0.8rem; color: var(--muted); white-space: nowrap; }

        /* result badges */
        .result-badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 12px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 700;
            letter-spacing: 0.05em; text-transform: uppercase;
        }
        .result-badge.WIN {
            background: rgba(34,201,122,0.12);
            border: 1px solid rgba(34,201,122,0.3);
            color: var(--green);
        }
        .result-badge.LOSS {
            background: rgba(255,79,106,0.12);
            border: 1px solid rgba(255,79,106,0.3);
            color: var(--red);
        }
        .result-badge.PENDING {
            background: rgba(245,200,66,0.12);
            border: 1px solid rgba(245,200,66,0.3);
            color: var(--yellow);
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
            padding: 16px 20px; font-size: 0.875rem; margin-bottom: 20px;
        }

        @media (max-width: 900px) {
            .stats-row { grid-template-columns: repeat(3, 1fr); }
        }
        @media (max-width: 600px) {
            .stats-row { grid-template-columns: repeat(2, 1fr); }
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
            <span>Bid History</span>
            <h2><%= teamName != null ? teamName : "My Transactions" %></h2>
        </div>
    </div>
    <a class="back-btn" href="team_dashboard.jsp">← Dashboard</a>
</div>

<div class="container">

    <% if (errorMsg != null) { %>
    <div class="error-card">✗ Error loading history: <%= errorMsg %></div>
    <% } %>

    <!-- STATS ROW -->
    <div class="stats-row">
        <div class="stat-card blue">
            <div class="stat-icon">🎯</div>
            <span class="stat-label">Total Bids</span>
            <span class="stat-value blue"><%= totalBids %></span>
            <span class="stat-sub">All time</span>
        </div>
        <div class="stat-card green">
            <div class="stat-icon">🏆</div>
            <span class="stat-label">Won</span>
            <span class="stat-value green"><%= wins %></span>
            <span class="stat-sub">Players secured</span>
        </div>
        <div class="stat-card red">
            <div class="stat-icon">❌</div>
            <span class="stat-label">Lost</span>
            <span class="stat-value red"><%= losses %></span>
            <span class="stat-sub">Outbid</span>
        </div>
        <div class="stat-card yellow">
            <div class="stat-icon">⏳</div>
            <span class="stat-label">Pending</span>
            <span class="stat-value yellow"><%= pending %></span>
            <span class="stat-sub">Awaiting result</span>
        </div>
        <div class="stat-card purple">
            <div class="stat-icon">💸</div>
            <span class="stat-label">Total Staked</span>
            <span class="stat-value purple">₹<%= totalStaked %>Cr</span>
            <span class="stat-sub">Across all bids</span>
        </div>
    </div>

    <!-- WIN RATE BAR -->
    <div class="winrate-wrap">
        <div class="winrate-top">
            <h4>Win Rate</h4>
            <span><%= winPct %>% of bids won</span>
        </div>
        <div class="bar-track">
            <div class="bar-fill"></div>
        </div>
        <div class="bar-labels">
            <span class="w"><%= wins %> wins</span>
            <span class="l"><%= losses %> losses</span>
        </div>
    </div>

    <!-- FILTER BUTTONS -->
    <div class="filter-row">
        <button class="filter-btn active" onclick="filterTable('ALL', this)">All</button>
        <button class="filter-btn win"  onclick="filterTable('WIN',  this)">🏆 Wins</button>
        <button class="filter-btn loss" onclick="filterTable('LOSS', this)">❌ Losses</button>
        <button class="filter-btn pend" onclick="filterTable('PENDING', this)">⏳ Pending</button>
    </div>

    <!-- HISTORY TABLE -->
    <div class="card">
        <div class="card-header">
            <span>📋</span>
            <h3>Bid History</h3>
            <span class="chip" id="rowCount"><%= totalBids %> Records</span>
        </div>
        <div class="table-wrapper">
            <table id="historyTable">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Auction</th>
                        <th>Player</th>
                        <th>Bid Amount</th>
                        <th>Bid Time</th>
                        <th>Result</th>
                    </tr>
                </thead>
                <tbody>
<%
    if (rows.isEmpty()) {
%>
                    <tr>
                        <td colspan="6">
                            <div class="empty-state">
                                <div class="icon">📋</div>
                                <p>No bids placed yet. Join a live auction to get started!</p>
                            </div>
                        </td>
                    </tr>
<%
    } else {
        int rowNum = 1;
        for (String[] row : rows) {
            String nameInit = row[1].trim().length() > 0
                ? String.valueOf(row[1].trim().charAt(0)).toUpperCase() : "?";
            String resultVal = row[4];
%>
                    <tr data-result="<%= resultVal %>">
                        <td style="color:var(--muted);font-size:0.78rem;"><%= rowNum++ %></td>
                        <td class="auction-name"><%= row[0] %></td>
                        <td>
                            <div class="player-cell">
                                <div class="player-init"><%= nameInit %></div>
                                <span class="player-name-text"><%= row[1] %></span>
                            </div>
                        </td>
                        <td class="bid-amount">₹<%= row[2] %>Cr</td>
                        <td class="bid-time"><%= row[3] %></td>
                        <td>
                            <span class="result-badge <%= resultVal %>">
                                <%= "WIN".equals(resultVal) ? "🏆" : "LOSS".equals(resultVal) ? "❌" : "⏳" %>
                                <%= resultVal %>
                            </span>
                        </td>
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

<script>
    function filterTable(result, btn) {
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        const rows = document.querySelectorAll('#historyTable tbody tr[data-result]');
        let visible = 0;
        rows.forEach(row => {
            const match = result === 'ALL' || row.dataset.result === result;
            row.style.display = match ? '' : 'none';
            if (match) visible++;
        });
        document.getElementById('rowCount').textContent = visible + ' Records';
    }
</script>

</body>
</html>