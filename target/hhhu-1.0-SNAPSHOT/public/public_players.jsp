<%-- 
    Document   : public_players
    Created on : 05-Mar-2026, 11:08:45 pm
    Author     : abhishek
--%>




<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="false" %>

<%
    String roleFilter = request.getParameter("role");
    String search     = request.getParameter("q");
    if (search != null && search.trim().isEmpty()) search = null;

    java.util.List<String[]> players = new java.util.ArrayList<>();
    int total = 0, availCount = 0, soldCount = 0;
    String errorMsg = null;

    Connection        con = null;
    PreparedStatement ps  = null;
    ResultSet         rs  = null;

    try {
        con = DBConnection.getConnection();
        StringBuilder sql = new StringBuilder(
            "SELECT player_id, player_name, role, country, base_price, status FROM player WHERE 1=1 ");
        java.util.List<Object> params = new java.util.ArrayList<>();

        if (roleFilter != null && !roleFilter.trim().isEmpty()) {
            sql.append("AND role = ? ");
            params.add(roleFilter);
        }
        if (search != null) {
            sql.append("AND (player_name LIKE ? OR country LIKE ?) ");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        sql.append("ORDER BY player_name ASC");

        ps = con.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
        rs = ps.executeQuery();

        while (rs.next()) {
            total++;
            String st = rs.getString("status");
            if ("AVAILABLE".equals(st)) availCount++;
            if ("SOLD".equals(st))      soldCount++;
            players.add(new String[]{
                String.valueOf(rs.getInt("player_id")),
                rs.getString("player_name"),
                rs.getString("role"),
                rs.getString("country") != null ? rs.getString("country") : "N/A",
                String.valueOf(rs.getDouble("base_price")),
                st != null ? st : "UNKNOWN"
            });
        }
    } catch (Exception e) {
        errorMsg = e.getMessage();
    } finally {
        try { if (rs  != null) rs.close();  } catch (Exception ignored) {}
        try { if (ps  != null) ps.close();  } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Players List – Cricket Auction</title>
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
            display: flex; flex-direction: column;
        }

        /* ── NAV ── */
        .nav {
            background: linear-gradient(135deg, #0d0f14 0%, #151c2e 100%);
            border-bottom: 1px solid var(--border);
            padding: 16px 40px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
            backdrop-filter: blur(12px);
        }

        .nav-brand { display: flex; align-items: center; gap: 12px; text-decoration: none; }

        .nav-icon {
            width: 38px; height: 38px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 9px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem;
        }

        .nav-title {
            font-family: 'Syne', sans-serif;
            font-size: 1rem; font-weight: 800;
            background: linear-gradient(90deg, #fff 40%, var(--accent));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .back-btn {
            display: inline-flex; align-items: center; gap: 7px;
            color: var(--muted); text-decoration: none;
            font-size: 0.85rem; font-weight: 500;
            padding: 7px 14px;
            border: 1px solid var(--border); border-radius: 8px;
            background: var(--surface); transition: all 0.2s;
        }
        .back-btn:hover {
            color: var(--text); border-color: var(--accent);
            background: rgba(79,140,255,0.07);
        }

        /* ── CONTAINER ── */
        .container { max-width: 1200px; margin: 0 auto; padding: 36px 24px; flex: 1; }

        /* ── PAGE HEADER ── */
        .page-header {
            display: flex; align-items: flex-start;
            justify-content: space-between; gap: 16px;
            margin-bottom: 28px; flex-wrap: wrap;
        }

        .page-header-left { display: flex; flex-direction: column; gap: 6px; }
        .page-header-left span {
            font-size: 0.72rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.1em; font-weight: 500;
        }
        .page-header-left h1 {
            font-family: 'Syne', sans-serif;
            font-size: 1.8rem; font-weight: 800; letter-spacing: -1px;
            background: linear-gradient(90deg, #fff 40%, var(--accent));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* ── STATS MINI ── */
        .stats-mini {
            display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        }

        .stat-chip {
            display: flex; flex-direction: column; align-items: center;
            padding: 10px 18px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            gap: 2px; min-width: 80px;
        }
        .stat-chip span { font-size: 0.68rem; color: var(--muted); text-transform: uppercase; letter-spacing: 0.07em; }
        .stat-chip strong { font-family: 'Syne', sans-serif; font-size: 1.2rem; font-weight: 800; }
        .stat-chip strong.blue   { color: var(--accent); }
        .stat-chip strong.green  { color: var(--green); }
        .stat-chip strong.yellow { color: var(--yellow); }

        /* ── TOOLBAR ── */
        .toolbar {
            display: flex; align-items: center; gap: 10px;
            margin-bottom: 16px; flex-wrap: wrap;
        }

        .search-wrap { position: relative; flex: 1; min-width: 200px; max-width: 300px; }
        .search-wrap input {
            width: 100%;
            padding: 9px 14px 9px 38px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 9px; color: var(--text);
            font-family: 'DM Sans', sans-serif; font-size: 0.875rem; outline: none;
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

        /* role filter pills */
        .filter-pills { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }

        .filter-pill {
            padding: 7px 16px; border-radius: 20px;
            font-size: 0.78rem; font-weight: 600;
            border: 1px solid var(--border);
            background: var(--surface); color: var(--muted);
            text-decoration: none; transition: all 0.2s;
            white-space: nowrap;
        }
        .filter-pill:hover { color: var(--text); border-color: var(--muted); }
        .filter-pill.active {
            background: rgba(79,140,255,0.12);
            border-color: var(--accent); color: var(--accent);
        }
        .filter-pill.bat.active  { background: rgba(245,200,66,0.12); border-color: var(--yellow); color: var(--yellow); }
        .filter-pill.bowl.active { background: rgba(79,140,255,0.12); border-color: var(--accent); color: var(--accent); }
        .filter-pill.all.active  { background: rgba(124,92,252,0.12); border-color: var(--accent2); color: var(--accent2); }
        .filter-pill.wk.active   { background: rgba(34,201,122,0.12); border-color: var(--green); color: var(--green); }

        /* ── CARD / TABLE ── */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius); overflow: hidden;
        }

        .card-header {
            padding: 16px 24px; border-bottom: 1px solid var(--border);
            background: var(--surface2);
            display: flex; align-items: center; gap: 10px;
        }
        .card-header h3 {
            font-family: 'Syne', sans-serif; font-size: 0.95rem; font-weight: 700;
        }
        .card-header .chip {
            margin-left: auto; font-size: 0.7rem; padding: 3px 9px; border-radius: 20px;
            background: rgba(79,140,255,0.15); color: var(--accent);
            border: 1px solid rgba(79,140,255,0.25); font-weight: 600;
        }

        .table-wrapper { overflow-x: auto; }

        table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }

        thead tr { background: var(--surface2); border-bottom: 1px solid var(--border); }
        thead th {
            padding: 13px 16px; text-align: left;
            font-family: 'Syne', sans-serif; font-size: 0.72rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase;
            letter-spacing: 0.08em; white-space: nowrap;
        }

        tbody tr { border-bottom: 1px solid var(--border); transition: background 0.15s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: rgba(255,255,255,0.03); }
        tbody td { padding: 13px 16px; color: var(--text); vertical-align: middle; }

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
        .country-txt { color: var(--muted); font-size: 0.875rem; }
        .price-txt {
            font-family: 'Syne', sans-serif; font-weight: 700;
            color: var(--green); font-size: 0.9rem;
        }

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

        /* status pills */
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

        /* view button */
        .btn-view {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 6px 14px;
            background: rgba(79,140,255,0.1);
            color: var(--accent);
            border: 1px solid rgba(79,140,255,0.2);
            border-radius: 7px; text-decoration: none;
            font-size: 0.78rem; font-weight: 600;
            transition: all 0.2s;
        }
        .btn-view:hover {
            background: rgba(79,140,255,0.2);
            border-color: rgba(79,140,255,0.4);
        }

        /* empty / error */
        .empty-state { text-align: center; padding: 56px 24px; color: var(--muted); }
        .empty-state .icon { font-size: 2.8rem; margin-bottom: 14px; }
        .empty-state p { font-size: 0.9rem; }

        .error-bar {
            background: rgba(255,79,106,0.08);
            border: 1px solid rgba(255,79,106,0.2);
            color: var(--red); border-radius: var(--radius);
            padding: 12px 18px; font-size: 0.875rem; margin-bottom: 20px;
        }

        /* footer */
        footer {
            border-top: 1px solid var(--border);
            padding: 18px 40px;
            text-align: center; font-size: 0.78rem; color: var(--muted);
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50%       { opacity: 0.4; transform: scale(0.75); }
        }

        @media (max-width: 768px) {
            .nav { padding: 14px 20px; }
            .container { padding: 24px 16px; }
            .page-header { flex-direction: column; }
        }
    </style>
</head>
<body>
    
<!-- NAV -->
<nav class="nav">
    <a class="nav-brand" href="index.jsp">
        <div class="nav-icon">🏏</div>
        <span class="nav-title">Cricket Auction</span>
    </a>
    <a class="back-btn" href="index.jsp">← Home</a>
</nav>

<div class="container">

    <% if (errorMsg != null) { %>
    <div class="error-bar">⚠️ System error: <%= errorMsg %></div>
    <% } %>

    <!-- PAGE HEADER -->
    <div class="page-header">
        <div class="page-header-left">
            <span>Public Directory</span>
            <h1>Players List</h1>
        </div>
        <div class="stats-mini">
            <div class="stat-chip">
                <span>Total</span>
                <strong class="blue"><%= total %></strong>
            </div>
            <div class="stat-chip">
                <span>Available</span>
                <strong class="green"><%= availCount %></strong>
            </div>
            <div class="stat-chip">
                <span>Sold</span>
                <strong class="yellow"><%= soldCount %></strong>
            </div>
        </div>
    </div>

    <!-- TOOLBAR -->
    <div class="toolbar">
        <!-- Search -->
        <form method="get" action="public_players.jsp" style="display:contents;">
            <% if (roleFilter != null) { %>
            <input type="hidden" name="role" value="<%= roleFilter %>">
            <% } %>
            <div class="search-wrap">
                <span class="search-icon">🔍</span>
                <input type="text" name="q"
                       placeholder="Search name or country…"
                       value="<%= search != null ? search : "" %>">
            </div>
        </form>

        <!-- Role filters -->
        <div class="filter-pills">
            <a class="filter-pill <%= (roleFilter == null) ? "active" : "" %>"
               href="public_players.jsp<%= search != null ? "?q=" + search : "" %>">All</a>
            <a class="filter-pill bat <%= "BATSMAN".equals(roleFilter) ? "active" : "" %>"
               href="public_players.jsp?role=BATSMAN<%= search != null ? "&q=" + search : "" %>">🏏 Batsman</a>
            <a class="filter-pill bowl <%= "BOWLER".equals(roleFilter) ? "active" : "" %>"
               href="public_players.jsp?role=BOWLER<%= search != null ? "&q=" + search : "" %>">🎳 Bowler</a>
            <a class="filter-pill all <%= "ALLROUNDER".equals(roleFilter) ? "active" : "" %>"
               href="public_players.jsp?role=ALLROUNDER<%= search != null ? "&q=" + search : "" %>">⭐ All-Rounder</a>
            <a class="filter-pill wk <%= "WICKETKEEPER".equals(roleFilter) ? "active" : "" %>"
               href="public_players.jsp?role=WICKETKEEPER<%= search != null ? "&q=" + search : "" %>">🧤 Keeper</a>
        </div>
    </div>

    <!-- TABLE CARD -->
    <div class="card">
        <div class="card-header">
            <span>🏏</span>
            <h3>
                <%= roleFilter != null ? roleFilter.charAt(0) + roleFilter.substring(1).toLowerCase() + "s" : "All Players" %>
            </h3>
            <span class="chip" id="rowCount"><%= total %> Players</span>
        </div>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Player</th>
                        <th>Role</th>
                        <th>Country</th>
                        <th>Base Price</th>
                        <th>Status</th>
                        <th>Details</th>
                    </tr>
                </thead>
                <tbody>
<%
    if (players.isEmpty()) {
%>
                    <tr>
                        <td colspan="7">
                            <div class="empty-state">
                                <div class="icon">🏏</div>
                                <p>No players found<%= roleFilter != null ? " for role: " + roleFilter : "" %>.</p>
                            </div>
                        </td>
                    </tr>
<%
    } else {
        int rowNum = 1;
        for (String[] p : players) {
            String pid    = p[0];
            String pName  = p[1];
            String pRole  = p[2];
            String pCountry = p[3];
            String pPrice = p[4];
            String pStatus = p[5];

            String bClass = "badge-all";
            if ("BATSMAN".equals(pRole))           bClass = "badge-bat";
            else if ("BOWLER".equals(pRole))       bClass = "badge-bowl";
            else if ("WICKETKEEPER".equals(pRole)) bClass = "badge-wk";

            String nameInit = pName.trim().length() > 0
                ? String.valueOf(pName.trim().charAt(0)).toUpperCase() : "?";
%>
                    <tr>
                        <td style="color:var(--muted);font-size:0.78rem;font-family:'Syne',sans-serif;font-weight:600;"><%= rowNum++ %></td>
                        <td>
                            <div class="player-cell">
                                <div class="player-init"><%= nameInit %></div>
                                <span class="player-name"><%= pName %></span>
                            </div>
                        </td>
                        <td><span class="badge <%= bClass %>"><%= pRole %></span></td>
                        <td class="country-txt"><%= pCountry %></td>
                        <td class="price-txt">₹<%= pPrice %>Cr</td>
                        <td><span class="status-pill <%= pStatus %>"><%= pStatus %></span></td>
                        <td>
                            <a class="btn-view" href="public_player_details.jsp?id=<%= pid %>">
                                View →
                            </a>
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

<footer>
    🏏 Cricket Auction System &nbsp;·&nbsp; Public Directory
</footer>

</body>
</html>