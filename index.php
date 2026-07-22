<?php
/**
 * BDApps Gateway - Landing Page
 * Documents all API endpoints, their request format, and Flutter usage.
 */
$baseUrl = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http')
         . '://' . $_SERVER['HTTP_HOST']
         . rtrim(dirname($_SERVER['SCRIPT_NAME']), '/');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BDApps Gateway</title>
    <style>
        :root {
            --bg: #0f172a;
            --card: #1e293b;
            --text: #e2e8f0;
            --muted: #94a3b8;
            --accent: #38bdf8;
            --green: #10b981;
            --purple: #a855f7;
            --border: #334155;
            --code-bg: #0b1220;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: var(--bg);
            color: var(--text);
            line-height: 1.6;
        }
        .container { max-width: 980px; margin: 0 auto; padding: 40px 20px; }
        header { text-align: center; margin-bottom: 32px; }
        h1 { color: var(--accent); margin: 0 0 8px; font-size: 2rem; }
        .subtitle { color: var(--muted); margin: 0; }
        .note {
            background: #1e293b;
            border-left: 4px solid var(--accent);
            padding: 12px 16px;
            border-radius: 4px;
            color: var(--muted);
            font-size: 0.9rem;
            margin: 0 0 24px;
        }
        .note strong { color: var(--accent); }

        .section-title {
            margin: 32px 0 12px;
            font-size: 1.1rem;
            color: var(--accent);
            border-bottom: 1px solid var(--border);
            padding-bottom: 6px;
        }

        .card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 16px;
        }
        .card h2 {
            margin: 0 0 6px;
            font-size: 1.15rem;
            color: var(--text);
        }
        .card p { color: var(--muted); margin: 6px 0; font-size: 0.92rem; }

        .badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 0.72rem;
            font-weight: 700;
            color: #fff;
            margin-right: 6px;
            vertical-align: middle;
        }
        .badge.post { background: var(--green); }
        .badge.inbound { background: var(--purple); }

        .path {
            font-family: "Courier New", monospace;
            font-size: 0.9rem;
            color: var(--text);
            margin: 6px 0;
        }

        .tabs { display: flex; gap: 4px; margin: 12px 0 0; border-bottom: 1px solid var(--border); }
        .tab {
            padding: 6px 12px;
            cursor: pointer;
            color: var(--muted);
            font-size: 0.85rem;
            border-bottom: 2px solid transparent;
            user-select: none;
        }
        .tab.active { color: var(--accent); border-bottom-color: var(--accent); }
        .panel { display: none; }
        .panel.active { display: block; }

        pre {
            background: var(--code-bg);
            border: 1px solid var(--border);
            border-radius: 4px;
            padding: 12px;
            overflow-x: auto;
            font-size: 0.8rem;
            margin: 8px 0 0;
            white-space: pre;
        }
        .key { color: #7dd3fc; }
        .str { color: #86efac; }
        .com { color: #64748b; font-style: italic; }
        .fn  { color: #fbbf24; }

        footer {
            text-align: center;
            color: var(--muted);
            margin-top: 40px;
            font-size: 0.85rem;
        }
    </style>
</head>
<body>
<div class="container">
    <header>
        <h1>BDApps Gateway</h1>
        <p class="subtitle">Subscription, USSD, SMS, and OTP services</p>
    </header>

    <div class="note">
        <strong>Important:</strong> The PHP endpoints in this project read from
        <code>$_POST</code> form fields, not raw JSON. When using Postman, set the
        body type to <strong>x-www-form-urlencoded</strong> (or <strong>multipart/form-data</strong>),
        not <em>raw JSON</em>. A raw JSON body will be ignored and the script will report
        "Invalid mobile number format" or "Missing OTP / referenceNo".
    </div>

    <div class="section-title">Outbound endpoints (you call these)</div>

    <!-- send_otp -->
    <div class="card">
        <h2>Send OTP</h2>
        <span class="badge post">POST</span><span class="path"><?= $baseUrl ?>/send_otp.php</span>
        <p>Initiates subscription by sending an OTP to the user's phone.</p>
        <div class="tabs">
            <div class="tab active" data-target="t-send">Form fields</div>
            <div class="tab" data-target="f-send">Flutter</div>
        </div>
        <div id="t-send" class="panel active">
<pre>POST <?= $baseUrl ?>/send_otp.php
Content-Type: application/x-www-form-urlencoded

<span class="key">user_mobile</span>=<span class="str">8801815644470</span>   <span class="com">// 01XXXXXXXXX, 8801XXXXXXXXX, or 881XXXXXXXXX</span></pre>
        </div>
        <div id="f-send" class="panel">
<pre><span class="key">import</span> 'package:http/http.dart' <span class="key">as</span> http;

<span class="key">final</span> res = <span class="key">await</span> http.post(
  Uri.parse(<span class="str">'<?= $baseUrl ?>/send_otp.php'</span>),
  headers: {<span class="str">'Content-Type'</span>: <span class="str">'application/x-www-form-urlencoded'</span>},
  body: {<span class="str">'user_mobile'</span>: <span class="str">'8801815644470'</span>},
);
<span class="com">// res.body -&gt; { "success": true, "referenceNo": "...", "statusCode": "S1000", ... }</span></pre>
        </div>
    </div>

    <!-- verify_otp -->
    <div class="card">
        <h2>Verify OTP</h2>
        <span class="badge post">POST</span><span class="path"><?= $baseUrl ?>/verify_otp.php</span>
        <p>Verifies the OTP and completes the subscription.</p>
        <div class="tabs">
            <div class="tab active" data-target="t-verify">Form fields</div>
            <div class="tab" data-target="f-verify">Flutter</div>
        </div>
        <div id="t-verify" class="panel active">
<pre>POST <?= $baseUrl ?>/verify_otp.php
Content-Type: application/x-www-form-urlencoded

<span class="key">Otp</span>=<span class="str">123456</span>
&amp;<span class="key">referenceNo</span>=<span class="str">abc123</span></pre>
        </div>
        <div id="f-verify" class="panel">
<pre><span class="key">final</span> res = <span class="key">await</span> http.post(
  Uri.parse(<span class="str">'<?= $baseUrl ?>/verify_otp.php'</span>),
  headers: {<span class="str">'Content-Type'</span>: <span class="str">'application/x-www-form-urlencoded'</span>},
  body: {
    <span class="str">'Otp'</span>: <span class="str">'123456'</span>,
    <span class="str">'referenceNo'</span>: <span class="str">'abc123'</span>,
  },
);
<span class="com">// res.body -&gt; { "statusCode": "S1000", "subscriptionStatus": "REGISTERED", ... }</span></pre>
        </div>
    </div>

    <!-- check_subscription -->
    <div class="card">
        <h2>Check Subscription</h2>
        <span class="badge post">POST</span><span class="path"><?= $baseUrl ?>/check_subscription.php</span>
        <p>Checks whether a subscriber is currently REGISTERED.</p>
        <div class="tabs">
            <div class="tab active" data-target="t-check">Form fields</div>
            <div class="tab" data-target="f-check">Flutter</div>
        </div>
        <div id="t-check" class="panel active">
<pre>POST <?= $baseUrl ?>/check_subscription.php
Content-Type: application/x-www-form-urlencoded

<span class="key">user_mobile</span>=<span class="str">8801815644470</span></pre>
        </div>
        <div id="f-check" class="panel">
<pre><span class="key">final</span> res = <span class="key">await</span> http.post(
  Uri.parse(<span class="str">'<?= $baseUrl ?>/check_subscription.php'</span>),
  headers: {<span class="str">'Content-Type'</span>: <span class="str">'application/x-www-form-urlencoded'</span>},
  body: {<span class="str">'user_mobile'</span>: <span class="str">'8801815644470'</span>},
);
<span class="com">// res.body -&gt; { "subscriptionStatus": "REGISTERED", "isSubscribed": true, ... }</span></pre>
        </div>
    </div>

    <!-- unsubscribe -->
    <div class="card">
        <h2>Unsubscribe</h2>
        <span class="badge post">POST</span><span class="path"><?= $baseUrl ?>/unsubscribe.php</span>
        <p>Unsubscribes a user from the service.</p>
        <div class="tabs">
            <div class="tab active" data-target="t-unsub">Form fields</div>
            <div class="tab" data-target="f-unsub">Flutter</div>
        </div>
        <div id="t-unsub" class="panel active">
<pre>POST <?= $baseUrl ?>/unsubscribe.php
Content-Type: application/x-www-form-urlencoded

<span class="key">user_mobile</span>=<span class="str">8801815644470</span>
<span class="com">// or: subscriberId=tel:8801815644470</span></pre>
        </div>
        <div id="f-unsub" class="panel">
<pre><span class="key">final</span> res = <span class="key">await</span> http.post(
  Uri.parse(<span class="str">'<?= $baseUrl ?>/unsubscribe.php'</span>),
  headers: {<span class="str">'Content-Type'</span>: <span class="str">'application/x-www-form-urlencoded'</span>},
  body: {<span class="str">'user_mobile'</span>: <span class="str">'8801815644470'</span>},
);
<span class="com">// res.body -&gt; { "success": true, "subscriptionStatus": "UNREGISTERED", ... }</span></pre>
        </div>
    </div>

    <div class="section-title">Inbound webhooks (BDApps calls these)</div>

    <div class="card">
        <h2>USSD Receiver</h2>
        <span class="badge inbound">INBOUND</span><span class="path"><?= $baseUrl ?>/ussd.php</span>
        <p>Handles inbound USSD sessions from the BDApps platform. No caller body — configured in the BDApps dashboard.</p>
    </div>

    <div class="card">
        <h2>SMS Receiver</h2>
        <span class="badge inbound">INBOUND</span><span class="path"><?= $baseUrl ?>/sms.php</span>
        <p>Handles inbound MO SMS messages and sends MT replies. No caller body — configured in the BDApps dashboard.</p>
    </div>

    <div class="card">
        <h2>Subscription Listener</h2>
        <span class="badge inbound">INBOUND</span><span class="path"><?= $baseUrl ?>/subscription_listener.php</span>
        <p>Receives subscription status callbacks (timeStamp, status, subscriberId, applicationId, frequency) from BDApps. No caller body.</p>
    </div>

    <div class="section-title">Flutter helper</div>
    <div class="card">
        <p>A small service to keep all your calls in one place:</p>
<pre><span class="key">import</span> 'package:http/http.dart' <span class="key">as</span> http;

<span class="key">class</span> <span class="fn">BdappsService</span> {
  <span class="key">static const</span> _base = <span class="str">'<?= $baseUrl ?>'</span>;
  <span class="key">static const</span> _headers = {<span class="str">'Content-Type'</span>: <span class="str">'application/x-www-form-urlencoded'</span>};

  <span class="key">static</span> Future&lt;http.Response&gt; <span class="fn">sendOtp</span>(String mobile) =&gt;
      http.post(Uri.parse(<span class="str">'$_base/send_otp.php'</span>), headers: _headers, body: {<span class="str">'user_mobile'</span>: mobile});

  <span class="key">static</span> Future&lt;http.Response&gt; <span class="fn">verifyOtp</span>(String otp, String referenceNo) =&gt;
      http.post(Uri.parse(<span class="str">'$_base/verify_otp.php'</span>), headers: _headers, body: {<span class="str">'Otp'</span>: otp, <span class="str">'referenceNo'</span>: referenceNo});

  <span class="key">static</span> Future&lt;http.Response&gt; <span class="fn">checkSubscription</span>(String mobile) =&gt;
      http.post(Uri.parse(<span class="str">'$_base/check_subscription.php'</span>), headers: _headers, body: {<span class="str">'user_mobile'</span>: mobile});

  <span class="key">static</span> Future&lt;http.Response&gt; <span class="fn">unsubscribe</span>(String mobile) =&gt;
      http.post(Uri.parse(<span class="str">'$_base/unsubscribe.php'</span>), headers: _headers, body: {<span class="str">'user_mobile'</span>: mobile});
}</pre>
    </div>

    <footer>
        <p>Application ID: APP_137539 &middot; Gateway endpoint: developer.bdapps.com</p>
        <p>API Documentation by: S.a. Sadik | Flutter Instructor, Ostad |  <a href="http://github.com/sadik5397" target="_blank" rel="noopener noreferrer" style="color: #E0FFFF; text-decoration: none;">GitHub</a></p>
    </footer>
</div>

<script>
    document.querySelectorAll('.tabs').forEach(group =&gt; {
        const tabs = group.querySelectorAll('.tab');
        const card = group.parentElement;
        tabs.forEach(t =&gt; {
            t.addEventListener('click', () =&gt; {
                tabs.forEach(x =&gt; x.classList.remove('active'));
                t.classList.add('active');
                card.querySelectorAll('.panel').forEach(p =&gt; p.classList.remove('active'));
                card.querySelector('#' + t.dataset.target).classList.add('active');
            });
        });
    });
</script>
</body>
</html>
