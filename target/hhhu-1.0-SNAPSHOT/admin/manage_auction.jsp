<%-- 
    Document   : manage_auction
    Created on : 03-Mar-2026, 10:48:50 pm
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

String message = null;
String messageType = "";

try (Connection con = DBConnection.getConnection()) {

    String action = request.getParameter("action");

    if ("create".equals(action)) {
        String name       = request.getParameter("auction_name");
        String date       = request.getParameter("auction_date");
        double increment  = Double.parseDouble(request.getParameter("bid_increment"));
        int squadSize     = Integer.parseInt(request.getParameter("max_squad_size"));
        double budgetCap  = Double.parseDouble(request.getParameter("budget_cap"));

        String sql = "INSERT INTO auction "
                   + "(auction_name, auction_date, bid_increment, max_squad_size, budget_cap, status) "
                   + "VALUES (?, ?, ?, ?, ?, 'SCHEDULED')";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, name);
        ps.setString(2, date);
        ps.setDouble(3, increment);
        ps.setInt(4, squadSize);
        ps.setDouble(5, budgetCap);
        ps.executeUpdate();
        message = "✓ Auction created successfully.";
        messageType = "success";
    }

    if ("start".equals(action)) {
        int id = Integer.parseInt(request.getParameter("auction_id"));
        con.createStatement().executeUpdate(
            "UPDATE auction SET status='LIVE' WHERE auction_id=" + id);
        message = "✓ Auction is now LIVE.";
        messageType = "success";
    }

    if ("close".equals(action)) {
        int id = Integer.parseInt(request.getParameter("auction_id"));
        con.createStatement().executeUpdate(
            "UPDATE auction SET status='CLOSED' WHERE auction_id=" + id);
        message = "✓ Auction has been closed.";
        messageType = "success";
    }

} catch (Exception e) {
    message = "✗ Error: " + e.getMessage();
    messageType = "error";
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Auction</title>
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
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px;
        }

        .header h2 {
            font-family: 'Syne', sans-serif;
            font-size: 1.5rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(90deg, #fff 40%, var(--accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .header-badge {
            font-size: 0.72rem;
            font-weight: 500;
            color: var(--muted);
            background: var(--surface2);
            border: 1px solid var(--border);
            padding: 4px 10px;
            border-radius: 20px;
            letter-spacing: 0.05em;
            text-transform: uppercase;
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

        /* ── TOAST ── */
        .toast {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 14px 20px;
            border-radius: var(--radius);
            margin-bottom: 28px;
            font-size: 0.9rem;
            font-weight: 500;
            animation: slideIn 0.3s ease;
        }
        .toast.success {
            background: rgba(34,201,122,0.1);
            border: 1px solid rgba(34,201,122,0.3);
            color: var(--green);
        }
        .toast.error {
            background: rgba(255,79,106,0.1);
            border: 1px solid rgba(255,79,106,0.3);
            color: var(--red);
        }
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-8px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── GRID ── */
        .grid {
            display: grid;
            grid-template-columns: 360px 1fr;
            gap: 24px;
            align-items: start;
        }

        /* ── CARD ── */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
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
            background: rgba(79,140,255,0.15);
            color: var(--accent);
            border: 1px solid rgba(79,140,255,0.25);
            font-weight: 600;
        }

        .card-body { padding: 24px; }

        /* ── FORM ── */
        .form-group { margin-bottom: 16px; }

        .form-group label {
            display: block;
            font-size: 0.78rem;
            font-weight: 600;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.06em;
            margin-bottom: 7px;
        }

        .form-group input {
            width: 100%;
            padding: 10px 14px;
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: 8px;
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 0.9rem;
            transition: border-color 0.2s, box-shadow 0.2s;
            outline: none;
        }

        .form-group input::placeholder { color: var(--muted); }

        .form-group input:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(79,140,255,0.15);
        }

        /* datetime-local icon color fix */
        input[type="datetime-local"]::-webkit-calendar-picker-indicator {
            filter: invert(0.6);
            cursor: pointer;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        .btn-submit {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            color: white;
            border: none;
            border-radius: 9px;
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem;
            font-weight: 700;
            cursor: pointer;
            letter-spacing: 0.02em;
            transition: opacity 0.2s, transform 0.15s;
            margin-top: 6px;
        }
        .btn-submit:hover { opacity: 0.9; transform: translateY(-1px); }
        .btn-submit:active { transform: translateY(0); }

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
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: rgba(255,255,255,0.03); }

        tbody td {
            padding: 13px 16px;
            color: var(--text);
            vertical-align: middle;
        }

        .auction-name {
            font-family: 'Syne', sans-serif;
            font-weight: 700;
            font-size: 0.95rem;
        }

        .mono {
            font-family: 'Courier New', monospace;
            font-size: 0.82rem;
            color: var(--muted);
        }

        .amount {
            font-family: 'Syne', sans-serif;
            font-weight: 700;
            color: var(--green);
        }

        /* ── STATUS BADGES ── */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 11px;
            border-radius: 20px;
            font-size: 0.72rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }
        .status-badge::before {
            content: '';
            width: 6px; height: 6px;
            border-radius: 50%;
            display: inline-block;
        }
        .badge-scheduled {
            background: rgba(245,200,66,0.12);
            color: var(--yellow);
            border: 1px solid rgba(245,200,66,0.25);
        }
        .badge-scheduled::before { background: var(--yellow); }

        .badge-live {
            background: rgba(34,201,122,0.12);
            color: var(--green);
            border: 1px solid rgba(34,201,122,0.3);
            animation: pulse 2s infinite;
        }
        .badge-live::before {
            background: var(--green);
            animation: pulseDot 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { box-shadow: 0 0 0 0 rgba(34,201,122,0.2); }
            50%       { box-shadow: 0 0 0 4px rgba(34,201,122,0); }
        }
        @keyframes pulseDot {
            0%, 100% { opacity: 1; }
            50%       { opacity: 0.4; }
        }

        .badge-closed {
            background: rgba(122,130,160,0.1);
            color: var(--muted);
            border: 1px solid rgba(122,130,160,0.2);
        }
        .badge-closed::before { background: var(--muted); }

        /* ── ACTION BUTTONS ── */
        .btn-start {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 14px;
            background: rgba(34,201,122,0.1);
            color: var(--green);
            border: 1px solid rgba(34,201,122,0.25);
            border-radius: 7px;
            text-decoration: none;
            font-size: 0.78rem;
            font-weight: 600;
            transition: all 0.2s;
        }
        .btn-start:hover {
            background: rgba(34,201,122,0.2);
            border-color: rgba(34,201,122,0.45);
        }

        .btn-close {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 14px;
            background: rgba(255,140,66,0.1);
            color: var(--orange);
            border: 1px solid rgba(255,140,66,0.25);
            border-radius: 7px;
            text-decoration: none;
            font-size: 0.78rem;
            font-weight: 600;
            transition: all 0.2s;
        }
        .btn-close:hover {
            background: rgba(255,140,66,0.2);
            border-color: rgba(255,140,66,0.45);
        }

        .closed-label {
            font-size: 0.78rem;
            color: var(--muted);
            font-weight: 500;
        }

        .empty-state {
            text-align: center;
            padding: 48px 24px;
            color: var(--muted);
        }
        .empty-state .icon { font-size: 2.5rem; margin-bottom: 12px; }

        @media (max-width: 900px) {
            .grid { grid-template-columns: 1fr; }
            .form-row { grid-template-columns: 1fr; }
            .header { padding: 16px 20px; }
            .container { padding: 20px 16px; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="header-left">
        <div class="header-icon">🔨</div>
        <h2>Manage Auction</h2>
    </div>
    <span class="header-badge">Admin Panel</span>
</div>

<div class="container">

    <a class="back" href="admin_dashboard.jsp">← Back to Dashboard</a>

    <% if (message != null) { %>
    <div class="toast <%= messageType %>">
        <%= message %>
    </div>
    <% } %>

    <div class="grid">

        <!-- CREATE AUCTION FORM -->
        <div class="card">
            <div class="card-header">
                <span>➕</span>
                <h3>Create Auction</h3>
            </div>
            <div class="card-body">
                <form method="post">
                    <input type="hidden" name="action" value="create"/>

                    <div class="form-group">
                        <label>Auction Name</label>
                        <input type="text" name="auction_name" placeholder="e.g. IPL 2025 Mega Auction" required/>
                    </div>

                    <div class="form-group">
                        <label>Auction Date &amp; Time</label>
                        <input type="datetime-local" name="auction_date" required/>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Bid Increment (₹)</label>
                            <input type="number" step="0.01" name="bid_increment" placeholder="e.g. 5.00" required/>
                        </div>
                        <div class="form-group">
                            <label>Max Squad Size</label>
                            <input type="number" name="max_squad_size" placeholder="e.g. 25" required/>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Budget Cap (₹ Crores)</label>
                        <input type="number" step="0.01" name="budget_cap" placeholder="e.g. 100.00" required/>
                    </div>

                    <button type="submit" class="btn-submit">🔨 Create Auction</button>
                </form>
            </div>
        </div>

        <!-- AUCTIONS TABLE -->
        <div class="card">
            <div class="card-header">
                <span>📋</span>
                <h3>All Auctions</h3>
                <span class="chip">Registry</span>
            </div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Name</th>
                            <th>Date</th>
                            <th>Increment</th>
                            <th>Squad</th>
                            <th>Budget Cap</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
<%
try (Connection con = DBConnection.getConnection()) {
    ResultSet rs = con.createStatement()
        .executeQuery("SELECT * FROM auction ORDER BY auction_id DESC");
    boolean hasRows = false;

    while (rs.next()) {
        hasRows = true;
        String status = rs.getString("status");
        String badgeClass = "badge-scheduled";
        if ("LIVE".equals(status))   badgeClass = "badge-live";
        if ("CLOSED".equals(status)) badgeClass = "badge-closed";
%>
                        <tr>
                            <td style="color:var(--muted); font-size:0.8rem;"><%= rs.getInt("auction_id") %></td>
                            <td class="auction-name"><%= rs.getString("auction_name") %></td>
                            <td class="mono"><%= rs.getString("auction_date") %></td>
                            <td class="amount">₹<%= rs.getBigDecimal("bid_increment") %></td>
                            <td style="color:var(--muted); text-align:center;"><%= rs.getInt("max_squad_size") %></td>
                            <td class="amount">₹<%= rs.getBigDecimal("budget_cap") %>Cr</td>
                            <td><span class="status-badge <%= badgeClass %>"><%= status %></span></td>
                            <td>
<% if ("SCHEDULED".equals(status)) { %>
                                <a class="btn-start"
                                   href="manage_auction.jsp?action=start&auction_id=<%= rs.getInt("auction_id") %>"
                                   onclick="return confirm('Start this auction now?');">
                                    ▶ Start
                                </a>
<% } else if ("LIVE".equals(status)) { %>
                                <a class="btn-close"
                                   href="manage_auction.jsp?action=close&auction_id=<%= rs.getInt("auction_id") %>"
                                   onclick="return confirm('Close this auction?');">
                                    ■ Close
                                </a>
<% } else { %>
                                <span class="closed-label">— Closed</span>
<% } %>
                            </td>
                        </tr>
<%
    }
    if (!hasRows) {
%>
                        <tr>
                            <td colspan="8">
                                <div class="empty-state">
                                    <div class="icon">🔨</div>
                                    <div>No auctions created yet.</div>
                                </div>
                            </td>
                        </tr>
<%
    }
} catch (Exception e) {
    out.println("<tr><td colspan='8' style='text-align:center;color:var(--red);padding:20px;'>Error loading auctions: " + e.getMessage() + "</td></tr>");
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