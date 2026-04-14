<%-- 
    Document   : index
    Created on : 05-Mar-2026, 10:50:28 pm
    Author     : abhishek
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="false" %>

<%
    int    totalPlayers     = 0;
    int    availablePlayers = 0;
    int    soldPlayers      = 0;
    int    approvedTeams    = 0;
    String errorMsg         = null;

    Connection        con = null;
    PreparedStatement ps  = null;
    ResultSet         rs  = null;

    try {
        con = DBConnection.getConnection();

        ps = con.prepareStatement("SELECT COUNT(*) FROM player");
        rs = ps.executeQuery();
        if (rs.next()) totalPlayers = rs.getInt(1);
        rs.close(); ps.close();

        ps = con.prepareStatement("SELECT COUNT(*) FROM player WHERE status='AVAILABLE'");
        rs = ps.executeQuery();
        if (rs.next()) availablePlayers = rs.getInt(1);
        rs.close(); ps.close();

        ps = con.prepareStatement("SELECT COUNT(*) FROM player WHERE status='SOLD'");
        rs = ps.executeQuery();
        if (rs.next()) soldPlayers = rs.getInt(1);
        rs.close(); ps.close();

        ps = con.prepareStatement("SELECT COUNT(*) FROM team WHERE status='APPROVED'");
        rs = ps.executeQuery();
        if (rs.next()) approvedTeams = rs.getInt(1);
        rs.close(); ps.close();

    } catch (Exception e) {
        errorMsg = e.getMessage();
    } finally {
        try { if (rs  != null) rs.close();  } catch (Exception ignored) {}
        try { if (ps  != null) ps.close();  } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }

    int soldPct = totalPlayers > 0
        ? (int) Math.round((soldPlayers * 100.0) / totalPlayers) : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cricket Auction System</title>
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
            content: '';
            position: absolute; width: 700px; height: 700px; border-radius: 50%;
            background: radial-gradient(circle, rgba(79,140,255,0.06) 0%, transparent 70%);
            top: -200px; left: -200px;
        }
        .bg-glow::after {
            content: '';
            position: absolute; width: 600px; height: 600px; border-radius: 50%;
            background: radial-gradient(circle, rgba(124,92,252,0.05) 0%, transparent 70%);
            bottom: -150px; right: -150px;
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

        .nav-brand { display: flex; align-items: center; gap: 12px; }

        .nav-icon {
            width: 40px; height: 40px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem;
        }

        .nav-title {
            font-family: 'Syne', sans-serif;
            font-size: 1.1rem; font-weight: 800; letter-spacing: -0.5px;
            background: linear-gradient(90deg, #fff 40%, var(--accent));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .nav-right { display: flex; align-items: center; gap: 10px; }

        .nav-link {
            display: inline-flex; align-items: center; gap: 6px;
            color: var(--muted); text-decoration: none;
            font-size: 0.85rem; font-weight: 500;
            padding: 7px 14px;
            border: 1px solid var(--border); border-radius: 8px;
            background: var(--surface); transition: all 0.2s;
        }
        .nav-link:hover {
            color: var(--text); border-color: var(--accent);
            background: rgba(79,140,255,0.07);
        }

        .nav-link.primary {
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-color: transparent; color: white;
        }
        .nav-link.primary:hover { opacity: 0.88; }

        /* ── MAIN ── */
        main {
            flex: 1; position: relative; z-index: 1;
            max-width: 1100px; margin: 0 auto;
            width: 100%; padding: 64px 24px 48px;
        }

        /* ── HERO ── */
        .hero {
            text-align: center;
            margin-bottom: 56px;
        }

        .hero-eyebrow {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 5px 14px; border-radius: 20px;
            font-size: 0.75rem; font-weight: 700;
            letter-spacing: 0.07em; text-transform: uppercase;
            background: rgba(34,201,122,0.1);
            border: 1px solid rgba(34,201,122,0.25);
            color: var(--green);
            margin-bottom: 20px;
        }
        .hero-eyebrow::before {
            content: ''; width: 7px; height: 7px; border-radius: 50%;
            background: var(--green); animation: pulse 1.4s infinite;
        }

        .hero h1 {
            font-family: 'Syne', sans-serif;
            font-size: clamp(2rem, 5vw, 3.4rem);
            font-weight: 800; letter-spacing: -2px;
            line-height: 1.1;
            margin-bottom: 18px;
        }

        .hero h1 span {
            background: linear-gradient(90deg, var(--accent) 0%, var(--accent2) 50%, var(--green) 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .hero-sub {
            font-size: 1rem; color: var(--muted);
            max-width: 520px; margin: 0 auto 36px;
            line-height: 1.7;
        }

        /* ── CTA BUTTONS ── */
        .cta-row {
            display: flex; align-items: center; justify-content: center;
            gap: 12px; flex-wrap: wrap;
            margin-bottom: 64px;
        }

        .btn {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 13px 26px; border-radius: 10px;
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem; font-weight: 700;
            text-decoration: none; transition: all 0.2s;
            cursor: pointer; border: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            color: white;
            box-shadow: 0 8px 24px rgba(79,140,255,0.25);
        }
        .btn-primary:hover { opacity: 0.88; transform: translateY(-2px); }

        .btn-secondary {
            background: var(--surface);
            border: 1px solid var(--border);
            color: var(--text);
        }
        .btn-secondary:hover {
            border-color: var(--green);
            color: var(--green);
            background: rgba(34,201,122,0.06);
        }

        .btn-outline {
            background: transparent;
            border: 1px solid var(--border);
            color: var(--muted);
        }
        .btn-outline:hover {
            border-color: var(--accent);
            color: var(--accent);
            background: rgba(79,140,255,0.06);
        }

        /* ── STATS GRID ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-bottom: 48px;
        }

        .stat-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 24px 22px;
            display: flex; flex-direction: column; gap: 10px;
            position: relative; overflow: hidden;
            transition: border-color 0.2s, transform 0.2s;
        }
        .stat-card:hover { border-color: var(--accent); transform: translateY(-2px); }

        .stat-card::before {
            content: ''; position: absolute;
            top: 0; left: 0; right: 0; height: 3px;
        }
        .stat-card.blue::before   { background: linear-gradient(90deg, var(--accent), var(--accent2)); }
        .stat-card.green::before  { background: linear-gradient(90deg, var(--green), #0fe38a); }
        .stat-card.yellow::before { background: linear-gradient(90deg, var(--yellow), #ff9b44); }
        .stat-card.purple::before { background: linear-gradient(90deg, var(--accent2), #c56cfc); }

        .stat-icon { font-size: 1.5rem; }

        .stat-label {
            font-size: 0.72rem; font-weight: 600; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.08em;
        }

        .stat-value {
            font-family: 'Syne', sans-serif;
            font-size: 2.2rem; font-weight: 800; letter-spacing: -2px;
            line-height: 1;
        }
        .stat-value.blue   { color: var(--accent); }
        .stat-value.green  { color: var(--green); }
        .stat-value.yellow { color: var(--yellow); }
        .stat-value.purple { color: var(--accent2); }

        .stat-sub { font-size: 0.76rem; color: var(--muted); }

        /* ── SOLD BAR ── */
        .sold-bar-wrap {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 22px 28px;
            margin-bottom: 48px;
        }

        .sold-bar-top {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 14px;
        }
        .sold-bar-top h4 {
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem; font-weight: 700;
        }
        .sold-bar-top span { font-size: 0.82rem; color: var(--muted); }

        .bar-track {
            width: 100%; height: 10px;
            background: var(--surface2); border-radius: 99px; overflow: hidden;
        }
        .bar-fill {
            height: 100%; border-radius: 99px;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
            width: <%= soldPct %>%; transition: width 1.2s ease;
        }
        .bar-labels {
            display: flex; justify-content: space-between;
            margin-top: 10px; font-size: 0.78rem;
        }
        .bar-labels .sold-lbl  { color: var(--accent); font-weight: 600; }
        .bar-labels .avail-lbl { color: var(--green);  font-weight: 600; }

        /* ── PORTAL CARDS ── */
        .portals-section h2 {
            font-family: 'Syne', sans-serif;
            font-size: 1.2rem; font-weight: 800;
            margin-bottom: 20px; text-align: center;
            color: var(--muted); letter-spacing: 0.02em;
        }

        .portals-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
        }

        .portal-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 24px 22px;
            text-decoration: none; color: var(--text);
            display: flex; flex-direction: column; gap: 12px;
            transition: all 0.2s;
            position: relative; overflow: hidden;
        }
        .portal-card::before {
            content: ''; position: absolute;
            top: 0; left: 0; right: 0; height: 3px;
            opacity: 0; transition: opacity 0.2s;
        }
        .portal-card.p1::before { background: linear-gradient(90deg, var(--accent), var(--accent2)); }
        .portal-card.p2::before { background: linear-gradient(90deg, var(--green), #0fe38a); }
        .portal-card.p3::before { background: linear-gradient(90deg, var(--yellow), #ff9b44); }

        .portal-card:hover { border-color: var(--accent); transform: translateY(-3px); }
        .portal-card:hover::before { opacity: 1; }

        .portal-icon {
            width: 48px; height: 48px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem;
        }
        .portal-icon.a { background: rgba(79,140,255,0.12); }
        .portal-icon.b { background: rgba(34,201,122,0.12); }
        .portal-icon.c { background: rgba(245,200,66,0.12); }

        .portal-title {
            font-family: 'Syne', sans-serif;
            font-size: 1rem; font-weight: 800;
        }
        .portal-desc { font-size: 0.82rem; color: var(--muted); line-height: 1.5; }
        .portal-arrow { font-size: 1.1rem; color: var(--muted); margin-top: auto; }

        /* ── FOOTER ── */
        footer {
            position: relative; z-index: 1;
            border-top: 1px solid var(--border);
            padding: 20px 40px;
            text-align: center;
            font-size: 0.78rem; color: var(--muted);
        }

        /* ── ERROR ── */
        .error-bar {
            background: rgba(255,79,106,0.08);
            border: 1px solid rgba(255,79,106,0.2);
            color: var(--red); border-radius: var(--radius);
            padding: 12px 18px; font-size: 0.875rem;
            margin-bottom: 24px; text-align: center;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50%       { opacity: 0.4; transform: scale(0.75); }
        }

        @media (max-width: 900px) {
            .stats-grid   { grid-template-columns: repeat(2, 1fr); }
            .portals-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 600px) {
            .stats-grid { grid-template-columns: 1fr; }
            .nav        { padding: 14px 20px; }
            .nav-right  { gap: 6px; }
            main        { padding: 40px 16px 32px; }
        }
    </style>
</head>
<body>

<div class="bg-glow"></div>

<!-- NAV -->
<nav class="nav">
    <div class="nav-brand">
        <div class="nav-icon">🏏</div>
        <span class="nav-title">Cricket Auction</span>
    </div>
    <div class="nav-right">
        <a class="nav-link" href="public_players.jsp">Players</a>
        <a class="nav-link" href="public_teams.jsp">Teams</a>
        <a class="nav-link primary" href="../index.jsp">Login →</a>
    </div>
</nav>

<main>

    <% if (errorMsg != null) { %>
    <div class="error-bar">⚠️ System error: <%= errorMsg %></div>
    <% } %>

    <!-- HERO -->
    <div class="hero">
        <div class="hero-eyebrow">Season Live</div>
        <h1>Cricket Players<br><span>Auction System</span></h1>
        <p class="hero-sub">
            The ultimate platform for managing cricket auctions —
            bid on players, build your dream squad, and track every transaction in real time.
        </p>
    </div>

    <!-- CTA BUTTONS -->
    <div class="cta-row">
        <a class="btn btn-primary" href="../index.jsp">🚀 Get Started</a>
        <a class="btn btn-secondary" href="public_players.jsp">🏏 View Players</a>
        <a class="btn btn-outline" href="public_teams.jsp">🏆 View Teams</a>
    </div>

    <!-- STATS -->
    <div class="stats-grid">
        <div class="stat-card blue">
            <div class="stat-icon">👥</div>
            <span class="stat-label">Total Players</span>
            <span class="stat-value blue"><%= totalPlayers %></span>
            <span class="stat-sub">Registered in system</span>
        </div>
        <div class="stat-card green">
            <div class="stat-icon">✅</div>
            <span class="stat-label">Available</span>
            <span class="stat-value green"><%= availablePlayers %></span>
            <span class="stat-sub">Ready to be bid on</span>
        </div>
        <div class="stat-card yellow">
            <div class="stat-icon">🏷️</div>
            <span class="stat-label">Sold Players</span>
            <span class="stat-value yellow"><%= soldPlayers %></span>
            <span class="stat-sub">Acquired by teams</span>
        </div>
        <div class="stat-card purple">
            <div class="stat-icon">🏆</div>
            <span class="stat-label">Approved Teams</span>
            <span class="stat-value purple"><%= approvedTeams %></span>
            <span class="stat-sub">Active franchises</span>
        </div>
    </div>

    <!-- SOLD PROGRESS BAR -->
    <div class="sold-bar-wrap">
        <div class="sold-bar-top">
            <h4>Player Sale Progress</h4>
            <span><%= soldPct %>% of players sold</span>
        </div>
        <div class="bar-track">
            <div class="bar-fill"></div>
        </div>
        <div class="bar-labels">
            <span class="sold-lbl"><%= soldPlayers %> sold</span>
            <span class="avail-lbl"><%= availablePlayers %> available</span>
        </div>
    </div>

    <!-- PORTALS -->
    <div class="portals-section">
        <h2>— Access Portals —</h2>
        <div class="portals-grid">
            <a class="portal-card p1" href="../admin/login_admin.jsp">
                <div class="portal-icon a">🛡️</div>
                <div class="portal-title">Admin Portal</div>
                <p class="portal-desc">
                    Manage players, teams, auctions, and oversee the entire system from one dashboard.
                </p>
                <span class="portal-arrow">→</span>
            </a>
            <a class="portal-card p2" href="../team/team_login.jsp">
                <div class="portal-icon b">🏟️</div>
                <div class="portal-title">Team Portal</div>
                <p class="portal-desc">
                    Join live auctions, place bids on players, and build your ultimate cricket squad.
                </p>
                <span class="portal-arrow">→</span>
            </a>
            <a class="portal-card p3" href="../player/player_login.jsp">
                <div class="portal-icon c">🏏</div>
                <div class="portal-title">Player Portal</div>
                <p class="portal-desc">
                    View your profile, check your auction status, and track which team acquired you.
                </p>
                <span class="portal-arrow">→</span>
            </a>
        </div>
    </div>

</main>

<footer>
    🏏 Cricket Auction System &nbsp;·&nbsp; All rights reserved
</footer>

</body>
</html>
