<%-- 
    Document   : index
    Created on : 03-Mar-2026, 4:15:24 pm
    Author     : abhishek
--%>

<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cricket Auction System</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --gold: #D4A843;
            --gold-light: #F0C86A;
            --dark: #0A0A0F;
            --dark-2: #12121A;
            --dark-3: #1C1C28;
            --green: #1DB954;
            --text-muted: #6B6B80;
            --text-light: #B0B0C0;
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background-color: var(--dark);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        .bg-layer {
            position: fixed;
            inset: 0;
            z-index: 0;
        }

        .bg-layer::before {
            content: '';
            position: absolute;
            inset: 0;
            background:
                radial-gradient(ellipse 80% 60% at 70% 20%, rgba(212, 168, 67, 0.08) 0%, transparent 60%),
                radial-gradient(ellipse 60% 80% at 10% 80%, rgba(29, 185, 84, 0.05) 0%, transparent 50%),
                radial-gradient(ellipse 100% 100% at 50% 50%, #0D0D18 0%, #060608 100%);
        }

        .field-arc {
            position: fixed;
            bottom: -300px;
            left: 50%;
            transform: translateX(-50%);
            width: 900px;
            height: 900px;
            border: 1px solid rgba(212, 168, 67, 0.06);
            border-radius: 50%;
            z-index: 0;
        }

        .field-arc::before {
            content: '';
            position: absolute;
            inset: 40px;
            border: 1px solid rgba(212, 168, 67, 0.04);
            border-radius: 50%;
        }

        .field-arc::after {
            content: '';
            position: absolute;
            inset: 80px;
            border: 1px solid rgba(212, 168, 67, 0.03);
            border-radius: 50%;
        }

        .dots {
            position: fixed;
            inset: 0;
            z-index: 0;
            overflow: hidden;
        }

        .dot {
            position: absolute;
            border-radius: 50%;
            background: var(--gold);
            opacity: 0;
            animation: floatDot linear infinite;
        }

        @keyframes floatDot {
            0% { transform: translateY(100vh) scale(0); opacity: 0; }
            10% { opacity: 0.3; }
            90% { opacity: 0.1; }
            100% { transform: translateY(-10vh) scale(1); opacity: 0; }
        }

        .container {
            position: relative;
            z-index: 10;
            width: 480px;
            animation: fadeUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) both;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .header {
            text-align: center;
            margin-bottom: 48px;
        }

        .logo-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 72px;
            height: 72px;
            background: linear-gradient(135deg, var(--gold) 0%, var(--gold-light) 100%);
            border-radius: 20px;
            margin-bottom: 20px;
            box-shadow: 0 0 40px rgba(212, 168, 67, 0.3), 0 8px 32px rgba(0,0,0,0.4);
            animation: pulseGlow 3s ease-in-out infinite;
            font-size: 32px;
        }

        @keyframes pulseGlow {
            0%, 100% { box-shadow: 0 0 40px rgba(212, 168, 67, 0.3), 0 8px 32px rgba(0,0,0,0.4); }
            50% { box-shadow: 0 0 60px rgba(212, 168, 67, 0.5), 0 8px 32px rgba(0,0,0,0.4); }
        }

        .badge {
            display: inline-block;
            font-size: 10px;
            font-weight: 600;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            color: var(--gold);
            border: 1px solid rgba(212, 168, 67, 0.3);
            padding: 4px 12px;
            border-radius: 100px;
            margin-bottom: 14px;
            background: rgba(212, 168, 67, 0.05);
        }

        h1 {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 52px;
            letter-spacing: 0.04em;
            line-height: 1;
            color: #fff;
            margin-bottom: 10px;
        }

        h1 span {
            color: var(--gold);
        }

        .subtitle {
            font-size: 14px;
            color: var(--text-muted);
            font-weight: 400;
            letter-spacing: 0.01em;
        }

        .card {
            background: var(--dark-2);
            border: 1px solid rgba(255,255,255,0.05);
            border-radius: 24px;
            padding: 32px;
            box-shadow: 0 32px 80px rgba(0,0,0,0.5), inset 0 1px 0 rgba(255,255,255,0.04);
        }

        .section-label {
            font-size: 10px;
            font-weight: 600;
            letter-spacing: 0.18em;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 16px;
        }

        .nav-links {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 16px 20px;
            text-decoration: none;
            border-radius: 14px;
            background: var(--dark-3);
            border: 1px solid rgba(255,255,255,0.04);
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            overflow: hidden;
            animation: slideIn 0.6s cubic-bezier(0.16, 1, 0.3, 1) both;
        }

        .nav-link:nth-child(1) { animation-delay: 0.1s; }
        .nav-link:nth-child(2) { animation-delay: 0.18s; }
        .nav-link:nth-child(3) { animation-delay: 0.26s; }
        .nav-link:nth-child(4) { animation-delay: 0.34s; }

        @keyframes slideIn {
            from { opacity: 0; transform: translateX(-20px); }
            to { opacity: 1; transform: translateX(0); }
        }

        .nav-link::before {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, var(--gold), var(--gold-light));
            opacity: 0;
            transition: opacity 0.25s;
        }

        .nav-link:hover::before {
            opacity: 0.08;
        }

        .nav-link:hover {
            border-color: rgba(212, 168, 67, 0.25);
            transform: translateX(4px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.3), -3px 0 0 var(--gold);
        }

        .link-icon {
            position: relative;
            z-index: 1;
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            font-size: 18px;
            transition: transform 0.25s;
        }

        .nav-link:hover .link-icon {
            transform: scale(1.1);
        }

        .icon-admin  { background: rgba(239, 83, 80, 0.15); }
        .icon-team   { background: rgba(29, 185, 84, 0.12); }
        .icon-player { background: rgba(33, 150, 243, 0.12); }
        .icon-public { background: rgba(212, 168, 67, 0.12); }

        .link-text {
            position: relative;
            z-index: 1;
            flex: 1;
        }

        .link-title {
            display: block;
            font-size: 15px;
            font-weight: 600;
            color: #fff;
            letter-spacing: 0.01em;
        }

        .link-desc {
            display: block;
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 2px;
        }

        .link-arrow {
            position: relative;
            z-index: 1;
            color: var(--text-muted);
            font-size: 16px;
            transition: transform 0.25s, color 0.25s;
        }

        .nav-link:hover .link-arrow {
            transform: translateX(3px);
            color: var(--gold);
        }

        .divider {
            height: 1px;
            background: rgba(255,255,255,0.05);
            margin: 4px 0;
        }

        .footer {
            text-align: center;
            margin-top: 24px;
            font-size: 12px;
            color: var(--text-muted);
            letter-spacing: 0.02em;
        }

        .footer span {
            color: var(--gold);
        }

        .live-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 500;
            color: var(--green);
            background: rgba(29, 185, 84, 0.1);
            border: 1px solid rgba(29, 185, 84, 0.2);
            padding: 4px 10px;
            border-radius: 100px;
            margin-top: 10px;
        }

        .live-dot {
            width: 6px;
            height: 6px;
            background: var(--green);
            border-radius: 50%;
            animation: blink 1.4s ease-in-out infinite;
        }

        @keyframes blink {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.3; }
        }
    </style>
</head>
<body>

<div class="bg-layer"></div>
<div class="field-arc"></div>
<div class="dots" id="dots"></div>

<div class="container">
    <div class="header">
       
        <div class="badge">IPL Style Auction</div>
        <h1>Cricket <span>Auction</span></h1>
        <p class="subtitle">Bid. Build. Dominate the league.</p>
        <div class="live-badge">
            <span class="live-dot"></span>
            Auction Season Active
        </div>
    </div>

    <div class="card">
        <p class="section-label">Select Portal</p>
        <div class="nav-links">
            <a href="admin/login_admin.jsp" class="nav-link">
                
                <div class="link-text">
                    <span class="link-title">Admin</span>
                    <span class="link-desc">Manage auction &amp; players</span>
                </div>
                <span class="link-arrow">?</span>
            </a>    

            <a href="team/team_login.jsp" class="nav-link">
                
                <div class="link-text">
                    <span class="link-title">Team Owner</span>
                    <span class="link-desc">Bid &amp; manage your squad</span>
                </div>
                <span class="link-arrow">?</span>
            </a>

            <a href="player/player_login.jsp" class="nav-link">
                
                <div class="link-text">
                    <span class="link-title">Player</span>
                    <span class="link-desc">View your auction status</span>
                </div>
                <span class="link-arrow">?</span>
            </a>

            <div class="divider"></div>

            <a href="public/index.jsp" class="nav-link">
                
                <div class="link-text">
                    <span class="link-title">Public Dashboard</span>
                    <span class="link-desc">Live results &amp; standings</span>
                </div>
                <span class="link-arrow">?</span>
            </a>
        </div>
    </div>

    <p class="footer">Powered by <span>Cricket Auction System</span> &mdash; Season 2025</p>
</div>

<script>
    const dotsContainer = document.getElementById('dots');
    for (let i = 0; i < 18; i++) {
        const dot = document.createElement('div');
        dot.className = 'dot';
        const size = Math.random() * 3 + 1;
        dot.style.cssText = `
            width: ${size}px;
            height: ${size}px;
            left: ${Math.random() * 100}%;
            animation-duration: ${Math.random() * 15 + 12}s;
            animation-delay: ${Math.random() * 12}s;
        `;
        dotsContainer.appendChild(dot);
    }
</script>
</body>
</html>