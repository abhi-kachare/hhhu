<%-- 
    Document   : view_players
    Created on : 05-Mar-2026, 10:10:11 pm
    Author     : abhishek
--%>



<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<%
    if (session == null || !"PLAYER".equals(session.getAttribute("role"))) {
        response.sendRedirect("player_login.jsp");
        return;
    }

    Integer playerId = (Integer) session.getAttribute("player_id");
    String  teamName_s = (String) session.getAttribute("team_name");
    if (playerId == null) {
        response.sendRedirect("player_login.jsp");
        return;
    }

    // Collect rows + aggregates before rendering
    java.util.List<String[]> players = new java.util.ArrayList<>();
    int totalPlayers = 0, totalSold = 0, totalAvailable = 0;
    String errorMsg = null;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DBConnection.getConnection();
        String sql =
            "SELECT p.player_name, p.role, p.country, p.base_price, " +
            "p.status, t.team_name " +
            "FROM player p " +
            "LEFT JOIN team t ON p.team_id = t.team_id " +
            "WHERE p.player_id != ? " +
            "ORDER BY p.player_name";
        ps = con.prepareStatement(sql);
        ps.setInt(1, playerId);
        rs = ps.executeQuery();

        while (rs.next()) {
            totalPlayers++;
            String st = rs.getString("status");
            if ("SOLD".equals(st))      totalSold++;
            if ("AVAILABLE".equals(st)) totalAvailable++;
            String tn = rs.getString("team_name");
            players.add(new String[]{
                rs.getString("player_name"),
                rs.getString("role"),
                rs.getString("country"),
                String.valueOf(rs.getDouble("base_price")),
                st != null ? st : "UNKNOWN",
                tn != null ? tn : "—"
            });
        }
    } catch (Exception e) {
        errorMsg = e.getMessage();
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception ignored) {}
        if (ps  != null) try { ps.close();  } catch (Exception ignored) {}
        if (con != null) try { con.close(); } catch (Exception ignored) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Players</title>
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

        .header-icon {
            width: 44px; height: 44px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 11px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.2rem;
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
        .container { max-width: 1200px; margin: 0 auto; padding: 36px 24px; }

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
            padding: 20px 22px;
            display: flex; flex-direction: column; gap: 8px;
            position: relative; overflow: hidden;
        }
        .stat-card::before {
            content: ''; position: absolute;
            top: 0; left: 0; right: 0; height: 3px;
        }
        .stat-card.blue::before  { background: linear-gradient(90deg, var(--accent), var(--accent2)); }
        .stat-card.green::before { background: linear-gradient(90deg, var(--green), #0fe38a); }
        .stat-card.red::before   { background: linear-gradient(90deg, var(--red), #ff9b44); }

        .stat-icon { font-size: 1.3rem; margin-bottom: 2px; }
        .stat-label {
            font-size: 0.72rem; font-weight: 600; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.08em;
        }
        .stat-value {
            font-family: 'Syne', sans-serif;
            font-size: 1.6rem; font-weight: 800; letter-spacing: -1px;
        }
        .stat-value.blue  { color: var(--accent); }
        .stat-value.green { color: var(--green); }
        .stat-value.red   { color: var(--red); }
        .stat-sub { font-size: 0.74rem; color: var(--muted); }

        /* ── TOOLBAR ── */
        .toolbar {
            display: flex; align-items: center; gap: 12px;
            margin-bottom: 16px; flex-wrap: wrap;
        }

        .search-wrap { position: relative; flex: 1; min-width: 200px; max-width: 320px; }

        .search-wrap input {
            width: 100%;
            padding: 9px 14px 9px 38px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 9px;
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 0.875rem;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .search-wrap input::placeholder { color: var(--muted); }
        .search-wrap input:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(79,140,255,0.12);
        }
        .search-icon {
            position: absolute; left: 12px; top: 50%;
            transform: translateY(-50%);
            font-size: 0.9rem; opacity: 0.45; pointer-events: none;
        }

        .filter-btn {
            padding: 8px 16px; border-radius: 20px;
            font-size: 0.78rem; font-weight: 600;
            border: 1px solid var(--border);
            background: var(--surface); color: var(--muted);
            cursor: pointer; transition: all 0.2s;
        }
        .filter-btn:hover { color: var(--text); border-color: var(--muted); }
        .filter-btn.active {
            background: rgba(79,140,255,0.12);
            border-color: var(--accent); color: var(--accent);
        }
        .filter-btn.avail.active {
            background: rgba(34,201,122,0.12);
            border-color: var(--green); color: var(--green);
        }
        .filter-btn.sold.active {
            background: rgba(79,140,255,0.12);
            border-color: var(--accent); color: var(--accent);
        }
        .filter-btn.unsold.active {
            background: rgba(255,79,106,0.12);
            border-color: var(--red); color: var(--red);
        }

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
            cursor: pointer; user-select: none;
            transition: color 0.15s;
        }
        thead th:hover { color: var(--text); }

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

        /* player cell */
        .player-cell { display: flex; align-items: center; gap: 11px; }
        .player-init {
            width: 34px; height: 34px; border-radius: 9px; flex-shrink: 0;
            background: linear-gradient(135deg, var(--surface2), var(--border));
            border: 1px solid var(--border);
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif; font-weight: 800;
            font-size: 0.82rem; color: var(--muted);
        }
        .player-name { font-weight: 600; font-size: 0.9rem; }

        /* role badges */
        .badge {
            display: inline-block; padding: 3px 10px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            letter-spacing: 0.05em; text-transform: uppercase;
        }
        .badge-bat  { background: rgba(245,200,66,0.12); color: var(--yellow); border: 1px solid rgba(245,200,66,0.25); }
        .badge-bowl { background: rgba(79,140,255,0.12); color: var(--accent); border: 1px solid rgba(79,140,255,0.25); }
        .badge-all  { background: rgba(124,92,252,0.12); color: var(--accent2);border: 1px solid rgba(124,92,252,0.25); }
        .badge-wk   { background: rgba(34,201,122,0.12); color: var(--green);  border: 1px solid rgba(34,201,122,0.25); }

        /* status badges */
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

        .country { color: var(--muted); font-size: 0.875rem; }
        .base-price {
            font-family: 'Syne', sans-serif;
            font-weight: 700; color: var(--green); font-size: 0.9rem;
        }
        .team-name { font-size: 0.85rem; color: var(--muted); }
        .team-name.assigned { color: var(--text); font-weight: 500; }

        /* empty / error */
        .empty-state {
            text-align: center; padding: 56px 24px; color: var(--muted);
        }
        .empty-state .icon { font-size: 2.8rem; margin-bottom: 14px; }
        .empty-state p { font-size: 0.9rem; }

        .error-card {
            background: rgba(255,79,106,0.08);
            border: 1px solid rgba(255,79,106,0.2);
            color: var(--red); border-radius: var(--radius);
            padding: 16px 20px; font-size: 0.875rem; margin-bottom: 20px;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50%       { opacity: 0.4; transform: scale(0.75); }
        }

        @media (max-width: 900px) {
            .stats-row { grid-template-columns: 1fr 1fr; }
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
        <div class="header-icon">🏏</div>
        <div class="header-info">
            <span>Player Portal</span>
            <h2>All Players</h2>
        </div>
    </div>
    <a class="back-btn" href="player_dashboard.jsp">← Dashboard</a>
</div>

<div class="container">

    <% if (errorMsg != null) { %>
    <div class="error-card">✗ Error loading players: <%= errorMsg %></div>
    <% } %>

    <!-- STATS -->
    <div class="stats-row">
        <div class="stat-card blue">
            <div class="stat-icon">👥</div>
            <span class="stat-label">Total Players</span>
            <span class="stat-value blue"><%= totalPlayers %></span>
            <span class="stat-sub">In the registry</span>
        </div>
        <div class="stat-card green">
            <div class="stat-icon">✅</div>
            <span class="stat-label">Available</span>
            <span class="stat-value green"><%= totalAvailable %></span>
            <span class="stat-sub">Ready to bid</span>
        </div>
        <div class="stat-card red">
            <div class="stat-icon">🏷️</div>
            <span class="stat-label">Sold</span>
            <span class="stat-value red"><%= totalSold %></span>
            <span class="stat-sub">Already acquired</span>
        </div>
    </div>

    <!-- TOOLBAR -->
    <div class="toolbar">
        <div class="search-wrap">
            <span class="search-icon">🔍</span>
            <input type="text" id="searchInput" placeholder="Search players, country, team…" oninput="applyFilters()">
        </div>
        <button class="filter-btn active"        onclick="setFilter('ALL',       this)">All</button>
        <button class="filter-btn avail"         onclick="setFilter('AVAILABLE', this)">✅ Available</button>
        <button class="filter-btn sold"          onclick="setFilter('SOLD',      this)">🏷️ Sold</button>
        <button class="filter-btn unsold"        onclick="setFilter('UNSOLD',    this)">❌ Unsold</button>
    </div>

    <!-- TABLE -->
    <div class="card">
        <div class="card-header">
            <span>📋</span>
            <h3>Player Registry</h3>
            <span class="chip" id="rowCount"><%= totalPlayers %> Players</span>
        </div>
        <div class="table-wrapper">
            <table id="playersTable">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Player</th>
                        <th>Role</th>
                        <th>Country</th>
                        <th>Base Price</th>
                        <th>Status</th>
                        <th>Team</th>
                    </tr>
                </thead>
                <tbody id="tableBody">
<%
    if (players.isEmpty()) {
%>
                    <tr>
                        <td colspan="7">
                            <div class="empty-state">
                                <div class="icon">🏏</div>
                                <p>No other players found in the registry.</p>
                            </div>
                        </td>
                    </tr>
<%
    } else {
        int rowNum = 1;
        for (String[] p : players) {
            String pName   = p[0];
            String pRole   = p[1];
            String pCountry= p[2];
            String pPrice  = p[3];
            String pStatus = p[4];
            String pTeam   = p[5];

            String badgeClass = "badge-all";
            if ("BATSMAN".equals(pRole))           badgeClass = "badge-bat";
            else if ("BOWLER".equals(pRole))       badgeClass = "badge-bowl";
            else if ("WICKETKEEPER".equals(pRole)) badgeClass = "badge-wk";

            String nameInit = pName.trim().length() > 0
                ? String.valueOf(pName.trim().charAt(0)).toUpperCase() : "?";

            boolean teamAssigned = !"—".equals(pTeam);
%>
                    <tr data-status="<%= pStatus %>" data-search="<%= (pName + pCountry + pTeam).toLowerCase() %>">
                        <td style="color:var(--muted);font-size:0.78rem;font-family:'Syne',sans-serif;font-weight:600;"><%= rowNum++ %></td>
                        <td>
                            <div class="player-cell">
                                <div class="player-init"><%= nameInit %></div>
                                <span class="player-name"><%= pName %></span>
                            </div>
                        </td>
                        <td><span class="badge <%= badgeClass %>"><%= pRole %></span></td>
                        <td class="country"><%= pCountry %></td>
                        <td class="base-price">₹<%= pPrice %>Cr</td>
                        <td><span class="status-pill <%= pStatus %>"><%= pStatus %></span></td>
                        <td class="team-name <%= teamAssigned ? "assigned" : "" %>"><%= pTeam %></td>
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
    let activeFilter = 'ALL';

    function setFilter(filter, btn) {
        activeFilter = filter;
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        applyFilters();
    }

    function applyFilters() {
        const query = document.getElementById('searchInput').value.toLowerCase().trim();
        const rows  = document.querySelectorAll('#tableBody tr[data-status]');
        let visible = 0;

        rows.forEach(row => {
            const statusMatch = activeFilter === 'ALL' || row.dataset.status === activeFilter;
            const searchMatch = !query || row.dataset.search.includes(query);
            const show = statusMatch && searchMatch;
            row.style.display = show ? '' : 'none';
            if (show) visible++;
        });

        document.getElementById('rowCount').textContent = visible + ' Players';
    }
</script>

</body>
</html>