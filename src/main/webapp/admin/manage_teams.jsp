<%-- 
    Document   : manage_teams
    Created on : 03-Mar-2026, 10:23:42 pm
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

    if ("add".equals(request.getParameter("action"))) {
        String teamName   = request.getParameter("team_name");
        String ownerName  = request.getParameter("owner_name");
        String email      = request.getParameter("email");
        String password   = request.getParameter("password");
        String budgetStr  = request.getParameter("total_budget");

        if (teamName != null && ownerName != null &&
            email != null && password != null && budgetStr != null) {

            double totalBudget = Double.parseDouble(budgetStr);
            String sql = "INSERT INTO team "
                       + "(team_name, owner_name, email, password, total_budget, remaining_budget, status) "
                       + "VALUES (?, ?, ?, ?, ?, ?, 'APPROVED')";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, teamName);
            ps.setString(2, ownerName);
            ps.setString(3, email);
            ps.setString(4, password);
            ps.setDouble(5, totalBudget);
            ps.setDouble(6, totalBudget);
            ps.executeUpdate();

            message = "✓ Team added successfully.";
            messageType = "success";
        }
    }

    if ("delete".equals(request.getParameter("action"))) {
        int id = Integer.parseInt(request.getParameter("team_id"));
        String sql = "DELETE FROM team WHERE team_id=?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, id);
        ps.executeUpdate();
        message = "✓ Team deleted successfully.";
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
    <title>Manage Teams</title>
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
            --orange:   #ff9a3c;
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
            grid-template-columns: 340px 1fr;
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

        .form-divider {
            height: 1px;
            background: var(--border);
            margin: 20px 0;
        }

        .form-section-label {
            font-size: 0.72rem;
            font-weight: 700;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.08em;
            margin-bottom: 14px;
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

        .team-avatar {
            width: 34px; height: 34px;
            border-radius: 9px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            font-weight: 800;
            color: white;
            margin-right: 10px;
            vertical-align: middle;
            font-family: 'Syne', sans-serif;
            flex-shrink: 0;
        }

        .team-name-cell {
            display: flex;
            align-items: center;
        }

        .team-name {
            font-family: 'Syne', sans-serif;
            font-weight: 700;
            font-size: 0.92rem;
        }

        .email-cell {
            color: var(--muted);
            font-size: 0.82rem;
        }

        .budget-total {
            font-family: 'Syne', sans-serif;
            font-weight: 700;
            color: var(--text);
        }

        .budget-remaining {
            font-family: 'Syne', sans-serif;
            font-weight: 700;
            color: var(--green);
        }

        .budget-low { color: var(--red) !important; }

        /* Status badge */
        .status-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 0.7rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }
        .status-approved {
            background: rgba(34,201,122,0.12);
            color: var(--green);
            border: 1px solid rgba(34,201,122,0.25);
        }
        .status-pending {
            background: rgba(245,200,66,0.12);
            color: var(--yellow);
            border: 1px solid rgba(245,200,66,0.25);
        }
        .status-rejected {
            background: rgba(255,79,106,0.12);
            color: var(--red);
            border: 1px solid rgba(255,79,106,0.25);
        }

        .btn-delete {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 13px;
            background: rgba(255,79,106,0.1);
            color: var(--red);
            border: 1px solid rgba(255,79,106,0.2);
            border-radius: 7px;
            text-decoration: none;
            font-size: 0.78rem;
            font-weight: 600;
            transition: all 0.2s;
        }
        .btn-delete:hover {
            background: rgba(255,79,106,0.2);
            border-color: rgba(255,79,106,0.4);
        }

        .empty-state {
            text-align: center;
            padding: 48px 24px;
            color: var(--muted);
        }
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
        
        <h2>Manage Teams</h2>
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

        <!-- ADD TEAM FORM -->
        <div class="card">
            <div class="card-header">
                <span>➕</span>
                <h3>Add New Team</h3>
            </div>
            <div class="card-body">
                <form method="post">
                    <input type="hidden" name="action" value="add"/>

                    <p class="form-section-label">Team Info</p>

                    <div class="form-group">
                        <label>Team Name</label>
                        <input type="text" name="team_name" placeholder="e.g. Mumbai Indians" required/>
                    </div>

                    <div class="form-group">
                        <label>Owner Name</label>
                        <input type="text" name="owner_name" placeholder="e.g. Mukesh Ambani" required/>
                    </div>

                    <div class="form-group">
                        <label>Total Budget (₹ Crores)</label>
                        <input type="number" step="0.01" name="total_budget" placeholder="e.g. 100.00" required/>
                    </div>

                    <div class="form-divider"></div>
                    <p class="form-section-label">Login Credentials</p>

                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="email" placeholder="e.g. owner@team.com" required/>
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" name="password" placeholder="Set a strong password" required/>
                    </div>

                    <button class="btn-submit" type="submit">Add Team</button>
                </form>
            </div>
        </div>

        <!-- TEAMS TABLE -->
        <div class="card">
            <div class="card-header">
                <span>️</span>
                <h3>All Teams</h3>
                <span class="chip">Registry</span>
            </div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Team</th>
                            <th>Owner</th>
                            <th>Email</th>
                            <th>Total Budget</th>
                            <th>Remaining</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
<%
try (Connection con = DBConnection.getConnection()) {
    Statement st = con.createStatement();
    ResultSet rs = st.executeQuery("SELECT * FROM team ORDER BY team_id DESC");
    boolean hasRows = false;

    while (rs.next()) {
        hasRows = true;
        String teamName = rs.getString("team_name");
        String initials = teamName.length() >= 2
            ? teamName.substring(0,2).toUpperCase()
            : teamName.substring(0,1).toUpperCase();

        String status = rs.getString("status");
        String statusClass = "status-approved";
        if ("PENDING".equals(status))  statusClass = "status-pending";
        if ("REJECTED".equals(status)) statusClass = "status-rejected";

        double total     = rs.getBigDecimal("total_budget").doubleValue();
        double remaining = rs.getBigDecimal("remaining_budget").doubleValue();
        double pct       = total > 0 ? (remaining / total) * 100 : 100;
        String budgetClass = pct < 25 ? "budget-remaining budget-low" : "budget-remaining";
%>
                        <tr>
                            <td style="color:var(--muted);font-size:0.8rem;"><%= rs.getInt("team_id") %></td>
                            <td>
                                <div class="team-name-cell">
                                    <div class="team-avatar"><%= initials %></div>
                                    <span class="team-name"><%= teamName %></span>
                                </div>
                            </td>
                            <td style="color:var(--muted);"><%= rs.getString("owner_name") %></td>
                            <td class="email-cell"><%= rs.getString("email") %></td>
                            <td class="budget-total">₹<%= total %>Cr</td>
                            <td class="<%= budgetClass %>">₹<%= remaining %>Cr</td>
                            <td><span class="status-badge <%= statusClass %>"><%= status %></span></td>
                            <td>
                                <a class="btn-delete"
                                   href="manage_teams.jsp?action=delete&team_id=<%= rs.getInt("team_id") %>"
                                   onclick="return confirm('Are you sure you want to delete this team?');">
                                    Delete
                                </a>
                            </td>
                        </tr>
<%
    }
    if (!hasRows) {
%>
                        <tr>
                            <td colspan="8">
                                <div class="empty-state">
                                   
                                    <div>No teams registered yet.</div>
                                </div>
                            </td>
                        </tr>
<%
    }
} catch (Exception e) {
    out.println("<tr><td colspan='8' style='text-align:center;color:var(--red);padding:20px;'>Error loading teams: " + e.getMessage() + "</td></tr>");
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