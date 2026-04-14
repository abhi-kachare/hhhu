<%-- 
    Document   : view_teams
    Created on : 05-Mar-2026, 10:16:32 pm
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
    if (playerId == null) {
        response.sendRedirect("player_login.jsp");
        return;
    }

    java.util.List<String[]> teams = new java.util.ArrayList<>();
    int    totalTeams   = 0;
    double totalBudgets = 0;
    double totalRemaining = 0;
    String errorMsg = null;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DBConnection.getConnection();
        String sql =
            "SELECT team_name, owner_name, total_budget, remaining_budget " +
            "FROM team WHERE status = 'APPROVED' ORDER BY team_name";
        ps = con.prepareStatement(sql);
        rs = ps.executeQuery();

        while (rs.next()) {
            totalTeams++;
            double tb = rs.getDouble("total_budget");
            double rb = rs.getDouble("remaining_budget");
            totalBudgets   += tb;
            totalRemaining += rb;
            teams.add(new String[]{
                rs.getString("team_name"),
                rs.getString("owner_name"),
                String.valueOf(tb),
                String.valueOf(rb)
            });
        }
    } catch (Exception e) {
        errorMsg = e.getMessage();
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception ignored) {}
        if (ps  != null) try { ps.close();  } catch (Exception ignored) {}
        if (con != null) try { con.close(); } catch (Exception ignored) {}
    }

    double totalSpent = totalBudgets - totalRemaining;
    int spentPct = totalBudgets > 0
        ? (int) Math.round((totalSpent / totalBudgets) * 100) : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Teams</title>
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
            font-size: 1.45rem; font-weight: 800; letter-spacing: -0.5px;
        }
        .stat-value.blue   { color: var(--accent); }
        .stat-value.green  { color: var(--green); }
        .stat-value.yellow { color: var(--yellow); }
        .stat-value.purple { color: var(--accent2); }
        .stat-sub { font-size: 0.74rem; color: var(--muted); }

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
            background: var(--surface2); border-radius: 99px; overflow: hidden;
        }
        .bar-fill {
            height: 100%; border-radius: 99px;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
            width: <%= spentPct %>%; transition: width 1s ease;
        }
        .bar-labels {
            display: flex; justify-content: space-between;
            margin-top: 10px; font-size: 0.78rem;
        }
        .bar-labels .spent { color: var(--accent);  font-weight: 600; }
        .bar-labels .left  { color: var(--green); font-weight: 600; }

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
            font-size: 0.875rem; outline: none;
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
            padding: 14px 16px;
            color: var(--text); vertical-align: middle;
        }

        /* team cell */
        .team-cell { display: flex; align-items: center; gap: 12px; }

        .team-init {
            width: 36px; height: 36px; border-radius: 9px; flex-shrink: 0;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif; font-weight: 800;
            font-size: 0.82rem; color: white;
        }

        .team-name-text { font-weight: 700; font-size: 0.95rem; }

        .owner-name { color: var(--muted); font-size: 0.875rem; }

        .budget-total {
            font-family: 'Syne', sans-serif;
            font-weight: 700; color: var(--accent); font-size: 0.9rem;
        }

        .budget-remaining {
            font-family: 'Syne', sans-serif;
            font-weight: 700; color: var(--green); font-size: 0.9rem;
        }

        /* inline mini bar */
        .mini-bar-wrap { display: flex; flex-direction: column; gap: 5px; min-width: 100px; }
        .mini-bar-track {
            width: 100%; height: 5px;
            background: var(--surface2); border-radius: 99px; overflow: hidden;
        }
        .mini-bar-fill {
            height: 100%; border-radius: 99px;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
        }
        .mini-bar-label {
            font-size: 0.7rem; color: var(--muted);
        }

        /* approved badge */
        .approved-pill {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 3px 9px; border-radius: 20px;
            font-size: 0.68rem; font-weight: 700;
            letter-spacing: 0.05em; text-transform: uppercase;
            background: rgba(34,201,122,0.1);
            border: 1px solid rgba(34,201,122,0.25);
            color: var(--green);
        }

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
        <div class="header-icon">🏆</div>
        <div class="header-info">
            <span>Player Portal</span>
            <h2>Approved Teams</h2>
        </div>
    </div>
    <a class="back-btn" href="player_dashboard.jsp">← Dashboard</a>
</div>

<div class="container">

    <% if (errorMsg != null) { %>
    <div class="error-card">✗ Error loading teams: <%= errorMsg %></div>
    <% } %>

    <!-- STATS -->
    <div class="stats-row">
        <div class="stat-card blue">
            <div class="stat-icon">🏟️</div>
            <span class="stat-label">Total Teams</span>
            <span class="stat-value blue"><%= totalTeams %></span>
            <span class="stat-sub">Approved franchises</span>
        </div>
        <div class="stat-card purple">
            <div class="stat-icon">💰</div>
            <span class="stat-label">Combined Budget</span>
            <span class="stat-value purple" style="font-size:1.1rem;">₹<%= totalBudgets %>Cr</span>
            <span class="stat-sub">Total allocation</span>
        </div>
        <div class="stat-card green">
            <div class="stat-icon">🏦</div>
            <span class="stat-label">Total Remaining</span>
            <span class="stat-value green" style="font-size:1.1rem;">₹<%= totalRemaining %>Cr</span>
            <span class="stat-sub">Available across teams</span>
        </div>
        <div class="stat-card yellow">
            <div class="stat-icon">📤</div>
            <span class="stat-label">Total Spent</span>
            <span class="stat-value yellow" style="font-size:1.1rem;">₹<%= totalSpent %>Cr</span>
            <span class="stat-sub"><%= spentPct %>% of combined budget</span>
        </div>
    </div>

    <!-- COMBINED BUDGET BAR -->
    <div class="budget-bar-wrap">
        <div class="budget-bar-top">
            <h4>Combined Budget Utilisation</h4>
            <span><%= spentPct %>% spent across all teams</span>
        </div>
        <div class="bar-track">
            <div class="bar-fill"></div>
        </div>
        <div class="bar-labels">
            <span class="spent">₹<%= totalSpent %>Cr spent</span>
            <span class="left">₹<%= totalRemaining %>Cr remaining</span>
        </div>
    </div>

    <!-- TOOLBAR -->
    <div class="toolbar">
        <div class="search-wrap">
            <span class="search-icon">🔍</span>
            <input type="text" id="searchInput"
                   placeholder="Search teams or owners…"
                   oninput="filterTeams()">
        </div>
    </div>

    <!-- TABLE -->
    <div class="card">
        <div class="card-header">
            <span>🏟️</span>
            <h3>Team Registry</h3>
            <span class="chip" id="rowCount"><%= totalTeams %> Teams</span>
        </div>
        <div class="table-wrapper">
            <table id="teamsTable">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Team</th>
                        <th>Owner</th>
                        <th>Total Budget</th>
                        <th>Remaining</th>
                        <th>Usage</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody id="tableBody">
<%
    if (teams.isEmpty()) {
%>
                    <tr>
                        <td colspan="7">
                            <div class="empty-state">
                                <div class="icon">🏆</div>
                                <p>No approved teams found.</p>
                            </div>
                        </td>
                    </tr>
<%
    } else {
        int rowNum = 1;
        for (String[] t : teams) {
            String tName  = t[0];
            String tOwner = t[1];
            double tTotal = Double.parseDouble(t[2]);
            double tRem   = Double.parseDouble(t[3]);
            double tSpent = tTotal - tRem;
            int tPct = tTotal > 0 ? (int) Math.round((tSpent / tTotal) * 100) : 0;

            String nameInit = tName.trim().length() >= 2
                ? tName.trim().substring(0, 2).toUpperCase()
                : tName.trim().substring(0, 1).toUpperCase();
%>
                    <tr data-search="<%= (tName + tOwner).toLowerCase() %>">
                        <td style="color:var(--muted);font-size:0.78rem;font-family:'Syne',sans-serif;font-weight:600;"><%= rowNum++ %></td>
                        <td>
                            <div class="team-cell">
                                <div class="team-init"><%= nameInit %></div>
                                <span class="team-name-text"><%= tName %></span>
                            </div>
                        </td>
                        <td class="owner-name"><%= tOwner %></td>
                        <td class="budget-total">₹<%= tTotal %>Cr</td>
                        <td class="budget-remaining">₹<%= tRem %>Cr</td>
                        <td>
                            <div class="mini-bar-wrap">
                                <div class="mini-bar-track">
                                    <div class="mini-bar-fill" style="width:<%= tPct %>%"></div>
                                </div>
                                <span class="mini-bar-label"><%= tPct %>% spent</span>
                            </div>
                        </td>
                        <td><span class="approved-pill">✓ Approved</span></td>
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
    function filterTeams() {
        const query = document.getElementById('searchInput').value.toLowerCase().trim();
        const rows  = document.querySelectorAll('#tableBody tr[data-search]');
        let visible = 0;
        rows.forEach(row => {
            const show = !query || row.dataset.search.includes(query);
            row.style.display = show ? '' : 'none';
            if (show) visible++;
        });
        document.getElementById('rowCount').textContent = visible + ' Teams';
    }
</script>

</body>
</html>