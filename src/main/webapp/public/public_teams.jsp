<%-- 
    Document   : public_teams
    Created on : 05-Mar-2026, 11:17:31 pm
    Author     : abhishek
--%>




<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="util.DBConnection" %>
<%@ page session="false" %>

<%
    java.util.List<String[]> teams = new java.util.ArrayList<>();
    String errorMsg = null;
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");

    Connection        con = null;
    PreparedStatement ps  = null;
    ResultSet         rs  = null;

    try {
        con = DBConnection.getConnection();
        String sql =
            "SELECT team_id, team_name, owner_name, created_at, " +
            "total_budget, remaining_budget, " +
            "(SELECT COUNT(*) FROM player WHERE team_id = t.team_id AND status='SOLD') AS squad_size " +
            "FROM team t WHERE status = 'APPROVED' ORDER BY team_name ASC";
        ps = con.prepareStatement(sql);
        rs = ps.executeQuery();

        while (rs.next()) {
            Timestamp ts = rs.getTimestamp("created_at");
            teams.add(new String[]{
                String.valueOf(rs.getInt("team_id")),
                rs.getString("team_name"),
                rs.getString("owner_name"),
                ts != null ? sdf.format(ts) : "—",
                String.valueOf(rs.getDouble("total_budget")),
                String.valueOf(rs.getDouble("remaining_budget")),
                String.valueOf(rs.getInt("squad_size"))
            });
        }
    } catch (Exception e) {
        errorMsg = e.getMessage();
    } finally {
        try { if (rs  != null) rs.close();  } catch (Exception ignored) {}
        try { if (ps  != null) ps.close();  } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }

    int totalTeams = teams.size();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Approved Teams – Cricket Auction</title>
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

        /* ── BG GLOW ── */
        .bg-glow {
            position: fixed; inset: 0; pointer-events: none; z-index: 0; overflow: hidden;
        }
        .bg-glow::before {
            content: ''; position: absolute;
            width: 600px; height: 600px; border-radius: 50%;
            background: radial-gradient(circle, rgba(79,140,255,0.05) 0%, transparent 70%);
            top: -150px; left: -150px;
        }
        .bg-glow::after {
            content: ''; position: absolute;
            width: 500px; height: 500px; border-radius: 50%;
            background: radial-gradient(circle, rgba(124,92,252,0.04) 0%, transparent 70%);
            bottom: -100px; right: -100px;
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
            display: flex; align-items: center; justify-content: center; font-size: 1rem;
        }
        .nav-title {
            font-family: 'Syne', sans-serif; font-size: 1rem; font-weight: 800;
            background: linear-gradient(90deg, #fff 40%, var(--accent));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .nav-right { display: flex; align-items: center; gap: 10px; }

        .nav-link {
            display: inline-flex; align-items: center; gap: 6px;
            color: var(--muted); text-decoration: none;
            font-size: 0.85rem; font-weight: 500;
            padding: 7px 14px; border: 1px solid var(--border);
            border-radius: 8px; background: var(--surface); transition: all 0.2s;
        }
        .nav-link:hover {
            color: var(--text); border-color: var(--accent);
            background: rgba(79,140,255,0.07);
        }

        /* ── CONTAINER ── */
        .container {
            max-width: 1200px; margin: 0 auto;
            padding: 40px 24px; flex: 1;
            position: relative; z-index: 1;
        }

        /* ── PAGE HEADER ── */
        .page-header {
            display: flex; align-items: flex-start;
            justify-content: space-between; gap: 16px;
            margin-bottom: 32px; flex-wrap: wrap;
        }

        .page-header-left { display: flex; flex-direction: column; gap: 6px; }
        .page-header-left span {
            font-size: 0.72rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.1em; font-weight: 500;
        }
        .page-header-left h1 {
            font-family: 'Syne', sans-serif;
            font-size: 1.9rem; font-weight: 800; letter-spacing: -1px;
            background: linear-gradient(90deg, #fff 40%, var(--accent));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .total-chip {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 20px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            align-self: flex-start;
        }
        .total-chip span { font-size: 0.72rem; color: var(--muted); text-transform: uppercase; letter-spacing: 0.07em; }
        .total-chip strong {
            font-family: 'Syne', sans-serif;
            font-size: 1.3rem; font-weight: 800; color: var(--accent);
        }

        /* ── TOOLBAR ── */
        .toolbar {
            display: flex; align-items: center; gap: 10px;
            margin-bottom: 20px; flex-wrap: wrap;
        }

        .search-wrap { position: relative; flex: 1; min-width: 200px; max-width: 320px; }
        .search-wrap input {
            width: 100%;
            padding: 9px 14px 9px 38px;
            background: var(--surface); border: 1px solid var(--border);
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

        /* ── TEAMS GRID ── */
        .teams-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 18px;
        }

        /* ── TEAM CARD ── */
        .team-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            transition: border-color 0.2s, transform 0.2s;
            display: flex; flex-direction: column;
            animation: popIn 0.4s ease both;
        }
        .team-card:hover {
            border-color: rgba(79,140,255,0.4);
            transform: translateY(-3px);
        }

        .team-card-top {
            padding: 22px;
            display: flex; align-items: center; gap: 16px;
            border-bottom: 1px solid var(--border);
            position: relative; overflow: hidden;
        }
        .team-card-top::before {
            content: ''; position: absolute;
            top: 0; left: 0; right: 0; height: 3px;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
            opacity: 0; transition: opacity 0.2s;
        }
        .team-card:hover .team-card-top::before { opacity: 1; }

        .team-logo {
            width: 48px; height: 48px; border-radius: 11px; flex-shrink: 0;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif; font-weight: 800;
            font-size: 0.9rem; color: white; letter-spacing: -0.5px;
        }

        .team-card-info { flex: 1; }
        .team-card-name {
            font-family: 'Syne', sans-serif;
            font-size: 1rem; font-weight: 800; margin-bottom: 4px;
        }
        .team-card-owner { font-size: 0.82rem; color: var(--muted); }

        .approved-pill {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 3px 9px; border-radius: 20px;
            font-size: 0.68rem; font-weight: 700;
            letter-spacing: 0.05em; text-transform: uppercase;
            background: rgba(34,201,122,0.1);
            border: 1px solid rgba(34,201,122,0.25);
            color: var(--green); flex-shrink: 0;
        }

        /* stats row inside card */
        .team-card-stats {
            display: grid; grid-template-columns: repeat(3, 1fr);
            padding: 14px 22px; gap: 8px;
            border-bottom: 1px solid var(--border);
        }

        .tc-stat { display: flex; flex-direction: column; gap: 3px; }
        .tc-stat span {
            font-size: 0.67rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.07em; font-weight: 500;
        }
        .tc-stat strong {
            font-family: 'Syne', sans-serif; font-size: 0.9rem; font-weight: 700;
        }
        .tc-stat strong.blue   { color: var(--accent); }
        .tc-stat strong.green  { color: var(--green); }
        .tc-stat strong.purple { color: var(--accent2); }

        /* mini budget bar */
        .team-card-bar { padding: 12px 22px; border-bottom: 1px solid var(--border); }
        .bar-top {
            display: flex; justify-content: space-between;
            font-size: 0.72rem; color: var(--muted); margin-bottom: 7px;
        }
        .bar-track {
            width: 100%; height: 5px;
            background: var(--surface2); border-radius: 99px; overflow: hidden;
        }
        .bar-fill {
            height: 100%; border-radius: 99px;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
        }

        /* card footer */
        .team-card-footer {
            padding: 14px 22px;
            display: flex; align-items: center; justify-content: space-between;
        }

        .card-date { font-size: 0.78rem; color: var(--muted); }

        .btn-view {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 7px 16px;
            background: rgba(79,140,255,0.1);
            color: var(--accent);
            border: 1px solid rgba(79,140,255,0.2);
            border-radius: 8px; text-decoration: none;
            font-size: 0.8rem; font-weight: 700;
            font-family: 'Syne', sans-serif;
            transition: all 0.2s;
        }
        .btn-view:hover {
            background: rgba(79,140,255,0.2);
            border-color: rgba(79,140,255,0.4);
        }

        /* empty / error */
        .empty-state {
            grid-column: 1 / -1;
            text-align: center; padding: 64px 24px; color: var(--muted);
        }
        .empty-state .icon { font-size: 3rem; margin-bottom: 16px; }
        .empty-state p { font-size: 0.9rem; }

        .error-bar {
            background: rgba(255,79,106,0.08);
            border: 1px solid rgba(255,79,106,0.2);
            color: var(--red); border-radius: var(--radius);
            padding: 12px 18px; font-size: 0.875rem; margin-bottom: 24px;
        }

        /* footer */
        footer {
            border-top: 1px solid var(--border); padding: 18px 40px;
            text-align: center; font-size: 0.78rem; color: var(--muted);
            position: relative; z-index: 1;
        }

        @keyframes popIn {
            from { opacity: 0; transform: scale(0.96) translateY(10px); }
            to   { opacity: 1; transform: scale(1)    translateY(0); }
        }

        @media (max-width: 768px) {
            .nav { padding: 14px 20px; }
            .container { padding: 24px 16px; }
            .page-header { flex-direction: column; }
            .teams-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<div class="bg-glow"></div>

<!-- NAV -->
<nav class="nav">
    <a class="nav-brand" href="../index.jsp">
        <div class="nav-icon">🏏</div>
        <span class="nav-title">Cricket Auction</span>
    </a>
    <div class="nav-right">
        <a class="nav-link" href="public_players.jsp">🏏 Players</a>
        <a class="nav-link" href="index.jsp">🏠 Home</a>
    </div>
</nav>

<div class="container">

    <% if (errorMsg != null) { %>
    <div class="error-bar">⚠️ System error: <%= errorMsg %></div>
    <% } %>

    <!-- PAGE HEADER -->
    <div class="page-header">
        <div class="page-header-left">
            <span>Public Directory</span>
            <h1>Approved Teams</h1>
        </div>
        <div class="total-chip">
            <span>Total</span>
            <strong><%= totalTeams %></strong>
            <span>Franchises</span>
        </div>
    </div>

    <!-- TOOLBAR -->
    <div class="toolbar">
        <div class="search-wrap">
            <span class="search-icon">🔍</span>
            <input type="text" id="searchInput"
                   placeholder="Search team or owner…"
                   oninput="filterCards()">
        </div>
    </div>

    <!-- TEAMS GRID -->
    <div class="teams-grid" id="teamsGrid">

<%
    if (teams.isEmpty()) {
%>
        <div class="empty-state">
            <div class="icon">🏆</div>
            <p>No approved teams found yet.</p>
        </div>
<%
    } else {
        int cardDelay = 0;
        for (String[] t : teams) {
            String tid    = t[0];
            String tName  = t[1];
            String tOwner = t[2];
            String tDate  = t[3];
            double tTotal = Double.parseDouble(t[4]);
            double tRem   = Double.parseDouble(t[5]);
            int    tSquad = Integer.parseInt(t[6]);
            double tSpent = tTotal - tRem;
            int    tPct   = tTotal > 0 ? (int) Math.round((tSpent / tTotal) * 100) : 0;

            String nameInit = tName.trim().length() >= 2
                ? tName.trim().substring(0, 2).toUpperCase()
                : tName.trim().substring(0, 1).toUpperCase();
%>
        <div class="team-card"
             data-search="<%= (tName + tOwner).toLowerCase() %>"
             style="animation-delay: <%= cardDelay %>ms">

            <div class="team-card-top">
                <div class="team-logo"><%= nameInit %></div>
                <div class="team-card-info">
                    <div class="team-card-name"><%= tName %></div>
                    <div class="team-card-owner">👤 <%= tOwner %></div>
                </div>
                <span class="approved-pill">✓ Approved</span>
            </div>

            <div class="team-card-stats">
                <div class="tc-stat">
                    <span>Budget</span>
                    <strong class="blue">₹<%= tTotal %>Cr</strong>
                </div>
                <div class="tc-stat">
                    <span>Remaining</span>
                    <strong class="green">₹<%= tRem %>Cr</strong>
                </div>
                <div class="tc-stat">
                    <span>Squad</span>
                    <strong class="purple"><%= tSquad %></strong>
                </div>
            </div>

            <div class="team-card-bar">
                <div class="bar-top">
                    <span>Budget used</span>
                    <span><%= tPct %>%</span>
                </div>
                <div class="bar-track">
                    <div class="bar-fill" style="width:<%= tPct %>%"></div>
                </div>
            </div>

            <div class="team-card-footer">
                <span class="card-date">📅 Since <%= tDate %></span>
                <a class="btn-view" href="public_team_details.jsp?id=<%= tid %>">
                    View Details →
                </a>
            </div>

        </div>
<%
            cardDelay += 60;
        }
    }
%>

    </div>
</div>

<footer>
    🏏 Cricket Auction System &nbsp;·&nbsp; Public Directory
</footer>

<script>
    function filterCards() {
        const query = document.getElementById('searchInput').value.toLowerCase().trim();
        const cards = document.querySelectorAll('.team-card[data-search]');
        cards.forEach(card => {
            card.style.display = (!query || card.dataset.search.includes(query)) ? '' : 'none';
        });
    }
</script>

</body>
</html>