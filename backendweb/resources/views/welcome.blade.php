<!DOCTYPE html>
<html lang="zh-Hant">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="AsseTcash APP 系統 — Laravel 後端 API、管理後台與 Flutter 行動端整合之資產與定位風控平台。">

        <title>AsseTcash APP 系統 — {{ config('app.name', 'Laravel') }}</title>

        <link rel="icon" type="image/png" href="{{ asset('icons8.png') }}">

        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=instrument-sans:400,500,600,700" rel="stylesheet" />

        @if (file_exists(public_path('build/manifest.json')) || file_exists(public_path('hot')))
            @vite(['resources/css/app.css', 'resources/js/app.js'])
        @endif

        <style>
            :root {
                --navy-from: #1e3a5f;
                --navy-to: #2d5a87;
                --accent-from: #667eea;
                --accent-to: #764ba2;
                --text: #1b1b18;
                --text-muted: #5c5a56;
                --surface: #ffffff;
                --border: rgba(30, 58, 95, 0.12);
                --shadow: 0 4px 24px rgba(30, 58, 95, 0.08);
                --radius: 1rem;
                --font: 'Instrument Sans', ui-sans-serif, system-ui, sans-serif;
            }
            @media (prefers-color-scheme: dark) {
                :root {
                    --text: #ededec;
                    --text-muted: #a1a09a;
                    --surface: #161615;
                    --border: rgba(237, 237, 236, 0.12);
                    --shadow: 0 4px 28px rgba(0, 0, 0, 0.35);
                }
            }

            *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
            html { -webkit-text-size-adjust: 100%; }
            body {
                font-family: var(--font);
                color: var(--text);
                line-height: 1.5;
                min-height: 100vh;
                background: linear-gradient(145deg, #f0f4fa 0%, #e8ecf8 40%, #f5f0fb 100%);
            }
            @media (prefers-color-scheme: dark) {
                body {
                    background: linear-gradient(145deg, #0d1118 0%, #12161f 50%, #1a1520 100%);
                }
            }

            a { color: inherit; text-decoration: none; }
            a:hover { text-decoration: underline; }

            .shell {
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }

            .topbar {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 1rem 1.5rem;
                max-width: 72rem;
                margin: 0 auto;
                width: 100%;
            }
            .logo-mark {
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                font-weight: 700;
                font-size: 0.95rem;
                letter-spacing: -0.02em;
            }
            .logo-dot {
                width: 2rem;
                height: 2rem;
                border-radius: 0.5rem;
                background: linear-gradient(135deg, var(--navy-from), var(--navy-to));
                display: grid;
                place-items: center;
                font-size: 1rem;
                box-shadow: var(--shadow);
            }
            .nav-actions {
                display: flex;
                flex-wrap: wrap;
                gap: 0.5rem;
                align-items: center;
                justify-content: flex-end;
            }
            .btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 0.5rem 1rem;
                border-radius: 0.5rem;
                font-size: 0.875rem;
                font-weight: 600;
                border: 1px solid transparent;
                transition: transform 0.15s ease, box-shadow 0.15s ease, background 0.15s ease;
                text-decoration: none;
            }
            .btn:hover { text-decoration: none; transform: translateY(-1px); }
            .btn-ghost {
                background: transparent;
                border-color: var(--border);
                color: var(--text);
            }
            .btn-ghost:hover {
                background: rgba(30, 58, 95, 0.06);
            }
            @media (prefers-color-scheme: dark) {
                .btn-ghost:hover { background: rgba(237, 237, 236, 0.06); }
            }
            .btn-primary {
                background: linear-gradient(135deg, var(--navy-from), var(--navy-to));
                color: #fff;
                box-shadow: 0 2px 12px rgba(30, 58, 95, 0.35);
            }
            .btn-primary:hover {
                box-shadow: 0 4px 18px rgba(30, 58, 95, 0.45);
            }

            main {
                flex: 1;
                width: 100%;
                max-width: 72rem;
                margin: 0 auto;
                padding: 1.5rem 1.5rem 3rem;
            }

            .hero {
                background: var(--surface);
                border-radius: var(--radius);
                border: 1px solid var(--border);
                box-shadow: var(--shadow);
                overflow: hidden;
                display: grid;
                grid-template-columns: 1fr;
            }
            @media (min-width: 900px) {
                .hero { grid-template-columns: 1.15fr 1fr; min-height: 22rem; }
            }

            .hero-brand {
                background: linear-gradient(135deg, var(--navy-from) 0%, var(--navy-to) 100%);
                color: #fff;
                padding: 2.25rem 2rem;
                display: flex;
                flex-direction: column;
                justify-content: center;
                gap: 1rem;
            }
            .hero-eyebrow {
                font-size: 0.75rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.12em;
                opacity: 0.85;
            }
            .hero-title {
                font-size: clamp(1.75rem, 4vw, 2.5rem);
                font-weight: 700;
                line-height: 1.15;
                letter-spacing: -0.03em;
            }
            .hero-title span.accent {
                background: linear-gradient(90deg, #a8c4ff, #fff);
                -webkit-background-clip: text;
                background-clip: text;
                color: transparent;
            }
            .hero-sub {
                font-size: 0.95rem;
                opacity: 0.92;
                max-width: 28rem;
            }

            .hero-body {
                padding: 2rem;
                display: flex;
                flex-direction: column;
                justify-content: center;
                gap: 1.25rem;
            }
            .hero-body p {
                color: var(--text-muted);
                font-size: 0.9375rem;
            }
            .hero-cta {
                display: flex;
                flex-wrap: wrap;
                gap: 0.75rem;
            }

            footer {
                text-align: center;
                padding: 1.5rem;
                font-size: 0.8125rem;
                color: var(--text-muted);
                border-top: 1px solid var(--border);
                margin-top: auto;
            }
            footer code {
                font-size: 0.75rem;
                padding: 0.15rem 0.4rem;
                border-radius: 0.35rem;
                background: rgba(30, 58, 95, 0.08);
            }
            @media (prefers-color-scheme: dark) {
                footer code { background: rgba(237, 237, 236, 0.08); }
            }
            .footer-api {
                margin-top: 0.5rem;
                font-size: 0.8125rem;
            }
            .footer-api a {
                color: var(--text-muted);
            }
            .footer-api a:hover {
                color: var(--text);
            }
        </style>
    </head>
    <body>
        <div class="shell">
            <header class="topbar">
                <a href="{{ url('/') }}" class="logo-mark">
                    <span class="logo-dot" aria-hidden="true">📍</span>
                    <span>AsseTcash APP 系統</span>
                </a>
                <nav class="nav-actions" aria-label="主要導覽">
                    @auth
                        <a href="{{ url('/admin/dashboard') }}" class="btn btn-primary">管理後台</a>
                        <form method="POST" action="{{ route('admin.logout') }}" style="display: inline;">
                            @csrf
                            <button type="submit" class="btn btn-ghost">登出</button>
                        </form>
                    @else
                        <a href="{{ url('/admin/login') }}" class="btn btn-primary">管理後台登入</a>
                    @endauth
                </nav>
            </header>

            <main>
                <section class="hero" aria-labelledby="hero-title">
                    <div class="hero-brand">
                        <p class="hero-eyebrow">Backend · Admin · Mobile API</p>
                        <h1 id="hero-title" class="hero-title">
                            <span class="accent">AsseTcash APP 系統</span>
                        </h1>
                        <p class="hero-sub">
                            與本專案 Laravel 後端、Vue 管理後台及 Flutter 行動端同一套 RESTful API 架構，支援多租戶資料隔離與定位相關風控流程。
                        </p>
                    </div>
                    <div class="hero-body">
                        <p>
                            此站台為 <strong>{{ config('app.name', 'AssetCash APP') }}</strong> 的服務入口頁。管理者請由後台登入。
                        </p>
                        <div class="hero-cta">
                            @guest
                                <a href="{{ url('/admin/login') }}" class="btn btn-primary">進入管理後台</a>
                            @else
                                <a href="{{ url('/admin/dashboard') }}" class="btn btn-primary">開啟儀表板</a>
                            @endguest
                        </div>
                    </div>
                </section>
            </main>

            <footer>
                <p>
                    AsseTcash APP 系統 · {{ config('app.name', 'AssetCash APP') }}
                    @if (app()->environment('local'))
                        · 環境 <code>{{ app()->environment() }}</code>
                    @endif
                </p>
                <!-- <p class="footer-api">
                    <a href="{{ url('/api') }}">會員端 API 說明（GET /api）</a>
                </p> -->
            </footer>
        </div>
    </body>
</html>
