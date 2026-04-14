<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<%
    if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect("login_admin.jsp");
        return;
    }

    String message     = "";
    String messageType = "";

    try (Connection con = DBConnection.getConnection()) {

        if ("add".equals(request.getParameter("action"))) {
            String name      = request.getParameter("player_name");
            String role      = request.getParameter("role");
            String country   = request.getParameter("country");
            String email     = request.getParameter("email");
            String password  = request.getParameter("password");
            double basePrice = Double.parseDouble(request.getParameter("base_price"));

            // Basic validation
            if (name == null || name.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
                message     = "✗ Name, email and password are required.";
                messageType = "error";
            } else {
                String sql = "INSERT INTO player (player_name, role, country, base_price, email, password) " +
                             "VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1, name.trim());
                ps.setString(2, role);
                ps.setString(3, country.trim());
                ps.setDouble(4, basePrice);
                ps.setString(5, email.trim().toLowerCase());
                ps.setString(6, password); // hash in production
                ps.executeUpdate();
                message     = "✓ Player added successfully.";
                messageType = "success";
            }
        }

        if ("delete".equals(request.getParameter("action"))) {
            int playerId = Integer.parseInt(request.getParameter("player_id"));
            String sql = "DELETE FROM player WHERE player_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, playerId);
            ps.executeUpdate();
            message     = "✓ Player deleted successfully.";
            messageType = "success";
        }

    } catch (Exception e) {
        message     = "✗ Error: " + e.getMessage();
        messageType = "error";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Players</title>
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
            padding: 22px 40px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
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
            font-size: 1.5rem; font-weight: 800; letter-spacing: -0.5px;
            background: linear-gradient(90deg, #fff 40%, var(--accent));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .header-badge {
            font-size: 0.72rem; font-weight: 500; color: var(--muted);
            background: var(--surface2); border: 1px solid var(--border);
            padding: 4px 10px; border-radius: 20px;
            letter-spacing: 0.05em; text-transform: uppercase;
        }

        /* ── LAYOUT ── */
        .container { max-width: 1200px; margin: 0 auto; padding: 36px 24px; }

        .back {
            display: inline-flex; align-items: center; gap: 7px;
            color: var(--muted); text-decoration: none;
            font-size: 0.875rem; font-weight: 500;
            margin-bottom: 28px; padding: 8px 16px;
            border: 1px solid var(--border); border-radius: 8px;
            background: var(--surface); transition: all 0.2s;
        }
        .back:hover {
            color: var(--text); border-color: var(--accent);
            background: rgba(79,140,255,0.07);
        }

        /* ── TOAST ── */
        .toast {
            display: flex; align-items: center; gap: 10px;
            padding: 14px 20px; border-radius: var(--radius);
            margin-bottom: 28px; font-size: 0.9rem; font-weight: 500;
            animation: slideIn 0.3s ease;
        }
        .toast.success {
            background: rgba(34,201,122,0.1);
            border: 1px solid rgba(34,201,122,0.3); color: var(--green);
        }
        .toast.error {
            background: rgba(255,79,106,0.1);
            border: 1px solid rgba(255,79,106,0.3); color: var(--red);
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-8px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── GRID ── */
        .grid {
            display: grid;
            grid-template-columns: 380px 1fr;
            gap: 24px; align-items: start;
        }

        /* ── CARD ── */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius); overflow: hidden;
        }

        .card-header {
            padding: 18px 24px; border-bottom: 1px solid var(--border);
            background: var(--surface2);
            display: flex; align-items: center; gap: 10px;
        }

        .card-header h3 {
            font-family: 'Syne', sans-serif;
            font-size: 1rem; font-weight: 700; color: var(--text);
        }

        .card-header .chip {
            margin-left: auto; font-size: 0.7rem; padding: 3px 9px;
            border-radius: 20px;
            background: rgba(79,140,255,0.15); color: var(--accent);
            border: 1px solid rgba(79,140,255,0.25); font-weight: 600;
        }

        .card-body { padding: 24px; }

        /* ── FORM ── */
        .form-group { margin-bottom: 16px; }

        .form-group label {
            display: block; font-size: 0.75rem; font-weight: 600;
            color: var(--muted); text-transform: uppercase;
            letter-spacing: 0.06em; margin-bottom: 7px;
        }

        .input-wrap { position: relative; }

        .input-icon {
            position: absolute; left: 12px; top: 50%;
            transform: translateY(-50%);
            font-size: 0.9rem; pointer-events: none; opacity: 0.45;
        }

        .form-group input,
        .form-group select {
            width: 100%; padding: 10px 14px 10px 38px;
            background: var(--surface2); border: 1px solid var(--border);
            border-radius: 8px; color: var(--text);
            font-family: 'DM Sans', sans-serif; font-size: 0.9rem;
            transition: border-color 0.2s, box-shadow 0.2s; outline: none;
            appearance: none;
        }

        .form-group input::placeholder { color: var(--muted); }

        .form-group input:focus,
        .form-group select:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(79,140,255,0.15);
        }

        .form-group select {
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%237a82a0' d='M6 8L1 3h10z'/%3E%3C/svg%3E");
            background-repeat: no-repeat; background-position: right 14px center;
            padding-right: 36px; cursor: pointer;
        }
        .form-group select option { background: var(--surface2); }

        /* form divider */
        .form-divider {
            display: flex; align-items: center; gap: 10px;
            margin: 18px 0;
        }
        .form-divider span {
            font-size: 0.72rem; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.07em;
            font-weight: 600; white-space: nowrap;
        }
        .form-divider::before,
        .form-divider::after {
            content: ''; flex: 1; height: 1px; background: var(--border);
        }

        /* password strength hint */
        .password-hint {
            font-size: 0.72rem; color: var(--muted);
            margin-top: 5px; display: flex; align-items: center; gap: 5px;
        }

        .btn-submit {
            width: 100%; padding: 12px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            color: white; border: none; border-radius: 9px;
            font-family: 'Syne', sans-serif; font-size: 0.95rem; font-weight: 700;
            cursor: pointer; letter-spacing: 0.02em;
            transition: opacity 0.2s, transform 0.15s; margin-top: 6px;
        }
        .btn-submit:hover { opacity: 0.9; transform: translateY(-1px); }
        .btn-submit:active { transform: translateY(0); }

        /* ── TABLE ── */
        .table-wrapper { overflow-x: auto; }

        table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }

        thead tr { background: var(--surface2); border-bottom: 1px solid var(--border); }

        thead th {
            padding: 13px 16px; text-align: left;
            font-family: 'Syne', sans-serif; font-size: 0.72rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase;
            letter-spacing: 0.08em; white-space: nowrap;
        }

        tbody tr {
            border-bottom: 1px solid var(--border); transition: background 0.15s;
        }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: rgba(255,255,255,0.03); }

        tbody td {
            padding: 13px 16px; color: var(--text); vertical-align: middle;
        }

        .player-name { font-weight: 600; }

        /* email cell */
        .email-cell {
            font-size: 0.8rem; color: var(--muted);
            font-family: 'DM Sans', sans-serif;
        }

        /* password masked */
        .pwd-mask {
            font-size: 0.85rem; color: var(--muted);
            letter-spacing: 2px;
        }

        /* role badges */
        .badge {
            display: inline-block; padding: 3px 10px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            letter-spacing: 0.05em; text-transform: uppercase;
        }
        .badge-bat  { background: rgba(245,200,66,0.12);  color: var(--yellow); border: 1px solid rgba(245,200,66,0.25); }
        .badge-bowl { background: rgba(79,140,255,0.12);  color: var(--accent); border: 1px solid rgba(79,140,255,0.25); }
        .badge-all  { background: rgba(124,92,252,0.12);  color: var(--accent2); border: 1px solid rgba(124,92,252,0.25); }
        .badge-wk   { background: rgba(34,201,122,0.12);  color: var(--green); border: 1px solid rgba(34,201,122,0.25); }

        /* status */
        .status-available { color: var(--green); font-weight: 600; font-size: 0.8rem; }
        .status-sold      { color: var(--red);   font-weight: 600; font-size: 0.8rem; }
        .status-unsold    { color: var(--muted); font-weight: 600; font-size: 0.8rem; }

        .price {
            font-family: 'Syne', sans-serif; font-weight: 700; color: var(--green);
        }

        .btn-delete {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 6px 13px;
            background: rgba(255,79,106,0.1); color: var(--red);
            border: 1px solid rgba(255,79,106,0.2); border-radius: 7px;
            text-decoration: none; font-size: 0.78rem; font-weight: 600;
            transition: all 0.2s;
        }
        .btn-delete:hover {
            background: rgba(255,79,106,0.2);
            border-color: rgba(255,79,106,0.4);
        }

        .empty-state { text-align: center; padding: 48px 24px; color: var(--muted); }
        .empty-state .icon { font-size: 2.5rem; margin-bottom: 12px; }

        @media (max-width: 900px) {
            .grid { grid-template-columns: 1fr; }
            .header { padding: 16px 20px; }
            .container { padding: 20px 16px; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="header-left">
        <div class="header-icon">🏏</div>
        <h2>Manage Players</h2>
    </div>
    <span class="header-badge">Admin Panel</span>
</div>

<div class="container">

    <a class="back" href="admin_dashboard.jsp">← Back to Dashboard</a>

    <% if (!message.isEmpty()) { %>
    <div class="toast <%= messageType %>">
        <%= message %>
    </div>
    <% } %>

    <div class="grid">

        <!-- ── ADD PLAYER FORM ── -->
        <div class="card">
            <div class="card-header">
                <span>➕</span>
                <h3>Add New Player</h3>
            </div>
            <div class="card-body">
                <form method="post">
                    <input type="hidden" name="action" value="add">

                    <!-- Player Info -->
                    <div class="form-group">
                        <label>Player Name</label>
                        <div class="input-wrap">
                            <span class="input-icon">🏏</span>
                            <input type="text" name="player_name"
                                   placeholder="e.g. Virat Kohli" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Role</label>
                        <div class="input-wrap">
                            <span class="input-icon">🎯</span>
                            <select name="role" required>
                                <option value="BATSMAN">🏏 Batsman</option>
                                <option value="BOWLER">🎳 Bowler</option>
                                <option value="ALLROUNDER">⭐ All-Rounder</option>
                                <option value="WICKETKEEPER">🧤 Wicket Keeper</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Country</label>
                        <div class="input-wrap">
                            <span class="input-icon">🌍</span>
                            <input type="text" name="country"
                                   placeholder="e.g. India" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Base Price (₹ Cr)</label>
                        <div class="input-wrap">
                            <span class="input-icon">💰</span>
                            <input type="number" step="0.01" min="0"
                                   name="base_price" placeholder="e.g. 2.00" required>
                        </div>
                    </div>

                    <!-- Login Credentials divider -->
                    <div class="form-divider">
                        <span>Login Credentials</span>
                    </div>

                    <div class="form-group">
                        <label>Email Address</label>
                        <div class="input-wrap">
                            <span class="input-icon">✉️</span>
                            <input type="email" name="email"
                                   placeholder="e.g. virat@example.com" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <div class="input-wrap">
                            <span class="input-icon">🔒</span>
                            <input type="password" name="password"
                                   placeholder="Set login password"
                                   minlength="6" required>
                        </div>
                        <div class="password-hint">
                            ℹ️ Minimum 6 characters
                        </div>
                    </div>

                    <button type="submit" class="btn-submit">Add Player</button>
                </form>
            </div>
        </div>

        <!-- ── PLAYERS TABLE ── -->
        <div class="card">
            <div class="card-header">
                <span>👥</span>
                <h3>All Players</h3>
                <span class="chip">Registry</span>
            </div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Name</th>
                            <th>Role</th>
                            <th>Country</th>
                            <th>Base Price</th>
                            <th>Email</th>
                            <th>Password</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
<%
    try (Connection con = DBConnection.getConnection()) {
        Statement st = con.createStatement();
        ResultSet rs = st.executeQuery(
            "SELECT player_id, player_name, role, country, base_price, " +
            "status, email, password FROM player ORDER BY player_id DESC");
        boolean hasRows = false;

        while (rs.next()) {
            hasRows = true;
            String playerRole = rs.getString("role");
            String badgeClass = "badge-all";
            if ("BATSMAN".equals(playerRole))           badgeClass = "badge-bat";
            else if ("BOWLER".equals(playerRole))       badgeClass = "badge-bowl";
            else if ("WICKETKEEPER".equals(playerRole)) badgeClass = "badge-wk";

            String status      = rs.getString("status");
            String statusClass = "status-available";
            if ("SOLD".equals(status))        statusClass = "status-sold";
            else if ("UNSOLD".equals(status)) statusClass = "status-unsold";

            String emailVal = rs.getString("email");
            String pwdVal   = rs.getString("password");
            // Show first 3 chars then mask
            String pwdDisplay = (pwdVal != null && pwdVal.length() > 3)
                ? pwdVal.substring(0, 3) + "••••••"
                : "••••••";
%>
                        <tr>
                            <td style="color:var(--muted);font-size:0.8rem;font-family:'Syne',sans-serif;font-weight:600;">
                                <%= rs.getInt("player_id") %>
                            </td>
                            <td class="player-name"><%= rs.getString("player_name") %></td>
                            <td><span class="badge <%= badgeClass %>"><%= playerRole %></span></td>
                            <td style="color:var(--muted); font-size:0.875rem;"><%= rs.getString("country") %></td>
                            <td class="price">₹<%= rs.getDouble("base_price") %>Cr</td>
                            <td class="email-cell">
                                <%= emailVal != null ? emailVal : "<span style='color:var(--muted)'>—</span>" %>
                            </td>
                            <td>
                                <span class="pwd-mask" title="<%= pwdVal != null ? pwdVal : "" %>">
                                    <%= pwdDisplay %>
                                </span>
                            </td>
                            <td><span class="<%= statusClass %>"><%= status %></span></td>
                            <td>
                                <a class="btn-delete"
                                   href="manage_players.jsp?action=delete&player_id=<%= rs.getInt("player_id") %>"
                                   onclick="return confirm('Are you sure you want to delete this player?');">
                                    🗑 Delete
                                </a>
                            </td>
                        </tr>
<%
        }
        if (!hasRows) {
%>
                        <tr>
                            <td colspan="9">
                                <div class="empty-state">
                                    <div class="icon">🏏</div>
                                    <div>No players registered yet.</div>
                                </div>
                            </td>
                        </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='9' style='text-align:center;color:var(--red);padding:20px;'>" +
                    "Error loading players: " + e.getMessage() + "</td></tr>");
    }
%>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

</body>
</html>