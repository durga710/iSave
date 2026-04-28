'use strict';
require('dotenv').config();

const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const {
  Configuration,
  PlaidApi,
  PlaidEnvironments,
  Products,
  CountryCode,
} = require('plaid');

// ─── App & Middleware ────────────────────────────────────────────────────────

const app = express();
app.use(cors());
app.use(express.json());

// Lazy DB init — runs once per serverless cold start, cached thereafter.
let dbReadyPromise;
function ensureDB() {
  if (!dbReadyPromise) dbReadyPromise = initDB();
  return dbReadyPromise;
}
app.use(async (_req, _res, next) => {
  try { await ensureDB(); next(); }
  catch (err) { next(err); }
});

// ─── Database ────────────────────────────────────────────────────────────────

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
  max: 10,
});

// ─── Plaid Client ─────────────────────────────────────────────────────────────

const plaidConfig = new Configuration({
  basePath: PlaidEnvironments[process.env.PLAID_ENV || 'sandbox'],
  baseOptions: {
    headers: {
      'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
      'PLAID-SECRET': process.env.PLAID_SECRET,
    },
  },
});
const plaidClient = new PlaidApi(plaidConfig);

// ─── Schema Init ─────────────────────────────────────────────────────────────

async function initDB() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      email           TEXT UNIQUE NOT NULL,
      password_hash   TEXT NOT NULL,
      name            TEXT,
      created_at      TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS plaid_items (
      id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      item_id          TEXT UNIQUE NOT NULL,
      access_token     TEXT NOT NULL,
      institution_name TEXT,
      created_at       TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS credit_cards (
      id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      plaid_account_id  TEXT,
      name              TEXT NOT NULL,
      balance           NUMERIC(12,2) DEFAULT 0,
      credit_limit      NUMERIC(12,2) DEFAULT 0,
      apr               NUMERIC(5,2)  DEFAULT 0,
      minimum_payment   NUMERIC(12,2) DEFAULT 0,
      card_type         TEXT DEFAULT 'visa',
      color             TEXT DEFAULT '#007AFF',
      created_at        TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS transactions (
      id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id               UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      credit_card_id        UUID NOT NULL REFERENCES credit_cards(id) ON DELETE CASCADE,
      plaid_transaction_id  TEXT UNIQUE,
      amount                NUMERIC(12,2) NOT NULL,
      description           TEXT,
      category              TEXT,
      date                  DATE NOT NULL,
      is_pending            BOOLEAN DEFAULT false,
      created_at            TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS budget_categories (
      id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      name           TEXT NOT NULL,
      budget_amount  NUMERIC(12,2) DEFAULT 0,
      color          TEXT DEFAULT '#007AFF',
      icon           TEXT DEFAULT 'tag',
      created_at     TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS user_preferences (
      id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id                UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      monthly_income         NUMERIC(12,2) DEFAULT 0,
      extra_payment          NUMERIC(12,2) DEFAULT 0,
      payoff_strategy        TEXT DEFAULT 'avalanche',
      notifications_enabled  BOOLEAN DEFAULT true,
      updated_at             TIMESTAMPTZ DEFAULT NOW()
    );
  `);
  console.log('✅ Database schema ready');
}

// ─── Auth Middleware ──────────────────────────────────────────────────────────

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Authorization token required' });

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid or expired token' });
    req.user = user;
    next();
  });
}

function signToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
}

// ─── Landing Page + Health Check ─────────────────────────────────────────────

const LANDING_HTML = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>iSave API</title>
<style>
  :root { color-scheme: light dark; }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    font: 16px/1.5 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
    color: #e2e8f0;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 24px;
  }
  .card {
    max-width: 640px;
    width: 100%;
    background: rgba(15, 23, 42, 0.7);
    border: 1px solid rgba(148, 163, 184, 0.2);
    border-radius: 16px;
    padding: 40px;
    backdrop-filter: blur(10px);
  }
  .badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 6px 12px;
    background: rgba(34, 197, 94, 0.15);
    border: 1px solid rgba(34, 197, 94, 0.4);
    border-radius: 999px;
    font-size: 13px;
    color: #4ade80;
    font-weight: 500;
  }
  .dot {
    width: 8px; height: 8px; border-radius: 50%;
    background: #4ade80;
    box-shadow: 0 0 8px #4ade80;
    animation: pulse 2s ease-in-out infinite;
  }
  @keyframes pulse { 50% { opacity: 0.4; } }
  h1 { margin: 16px 0 8px; font-size: 32px; font-weight: 700; letter-spacing: -0.02em; }
  .sub { color: #94a3b8; margin: 0 0 32px; font-size: 15px; }
  h2 { font-size: 13px; text-transform: uppercase; letter-spacing: 0.08em; color: #94a3b8; margin: 24px 0 12px; font-weight: 600; }
  .endpoints {
    display: grid; gap: 6px;
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: 13px;
  }
  .endpoints div { display: flex; gap: 12px; padding: 8px 12px; background: rgba(30, 41, 59, 0.5); border-radius: 6px; }
  .method { color: #60a5fa; font-weight: 600; min-width: 56px; }
  .path { color: #e2e8f0; }
  .lock { color: #fbbf24; margin-left: auto; }
  .footer { margin-top: 32px; padding-top: 20px; border-top: 1px solid rgba(148, 163, 184, 0.15); color: #64748b; font-size: 13px; }
  a { color: #60a5fa; text-decoration: none; }
  a:hover { text-decoration: underline; }
</style>
</head>
<body>
<div class="card">
  <span class="badge"><span class="dot"></span> Online</span>
  <h1>iSave API</h1>
  <p class="sub">Backend for the iSave SwiftUI budgeting + payoff app. Built with Express on Vercel, backed by Neon Postgres and Plaid.</p>

  <h2>Auth</h2>
  <div class="endpoints">
    <div><span class="method">POST</span><span class="path">/auth/register</span></div>
    <div><span class="method">POST</span><span class="path">/auth/login</span></div>
    <div><span class="method">GET</span><span class="path">/auth/me</span><span class="lock">JWT</span></div>
  </div>

  <h2>Resources</h2>
  <div class="endpoints">
    <div><span class="method">CRUD</span><span class="path">/cards</span><span class="lock">JWT</span></div>
    <div><span class="method">CRUD</span><span class="path">/transactions</span><span class="lock">JWT</span></div>
    <div><span class="method">CRUD</span><span class="path">/categories</span><span class="lock">JWT</span></div>
    <div><span class="method">GET/PUT</span><span class="path">/preferences</span><span class="lock">JWT</span></div>
  </div>

  <h2>Plaid</h2>
  <div class="endpoints">
    <div><span class="method">POST</span><span class="path">/plaid/create-link-token</span><span class="lock">JWT</span></div>
    <div><span class="method">POST</span><span class="path">/plaid/exchange-token</span><span class="lock">JWT</span></div>
    <div><span class="method">POST</span><span class="path">/plaid/sync</span><span class="lock">JWT</span></div>
  </div>

  <p class="footer">Health check: <a href="/health">/health</a> &middot; iOS client connects via <code>APIService.baseURL</code></p>
</div>
</body>
</html>`;

app.get('/', (_req, res) => {
  res.set('Content-Type', 'text/html; charset=utf-8').send(LANDING_HTML);
});

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'iSave API', time: new Date().toISOString() });
});

// ─── Auth Routes ─────────────────────────────────────────────────────────────

app.post('/auth/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'email and password are required' });
    }
    const hash = await bcrypt.hash(password, 12);
    const result = await pool.query(
      'INSERT INTO users (email, password_hash, name) VALUES ($1, $2, $3) RETURNING id, email, name',
      [email.toLowerCase().trim(), hash, name || null]
    );
    const user = result.rows[0];
    res.status(201).json({ token: signToken(user), user });
  } catch (err) {
    if (err.code === '23505') return res.status(409).json({ error: 'Email already registered' });
    console.error('register error:', err);
    res.status(500).json({ error: 'Registration failed' });
  }
});

app.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email?.toLowerCase().trim()]
    );
    const user = result.rows[0];
    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    res.json({
      token: signToken(user),
      user: { id: user.id, email: user.email, name: user.name },
    });
  } catch (err) {
    console.error('login error:', err);
    res.status(500).json({ error: 'Login failed' });
  }
});

app.get('/auth/me', authenticateToken, async (req, res) => {
  const result = await pool.query(
    'SELECT id, email, name, created_at FROM users WHERE id = $1',
    [req.user.id]
  );
  if (!result.rows[0]) return res.status(404).json({ error: 'User not found' });
  res.json(result.rows[0]);
});

// ─── Credit Cards ─────────────────────────────────────────────────────────────

app.get('/cards', authenticateToken, async (req, res) => {
  const result = await pool.query(
    'SELECT * FROM credit_cards WHERE user_id = $1 ORDER BY created_at ASC',
    [req.user.id]
  );
  res.json(result.rows);
});

app.post('/cards', authenticateToken, async (req, res) => {
  const { name, balance, credit_limit, apr, minimum_payment, card_type, color } = req.body;
  const result = await pool.query(
    `INSERT INTO credit_cards (user_id, name, balance, credit_limit, apr, minimum_payment, card_type, color)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
    [req.user.id, name, balance ?? 0, credit_limit ?? 0, apr ?? 0,
     minimum_payment ?? 0, card_type ?? 'visa', color ?? '#007AFF']
  );
  res.status(201).json(result.rows[0]);
});

app.put('/cards/:id', authenticateToken, async (req, res) => {
  const { name, balance, credit_limit, apr, minimum_payment, card_type, color } = req.body;
  const result = await pool.query(
    `UPDATE credit_cards
     SET name=$1, balance=$2, credit_limit=$3, apr=$4, minimum_payment=$5, card_type=$6, color=$7
     WHERE id=$8 AND user_id=$9 RETURNING *`,
    [name, balance, credit_limit, apr, minimum_payment, card_type, color,
     req.params.id, req.user.id]
  );
  if (!result.rows[0]) return res.status(404).json({ error: 'Card not found' });
  res.json(result.rows[0]);
});

app.delete('/cards/:id', authenticateToken, async (req, res) => {
  await pool.query(
    'DELETE FROM credit_cards WHERE id=$1 AND user_id=$2',
    [req.params.id, req.user.id]
  );
  res.json({ success: true });
});

// ─── Transactions ─────────────────────────────────────────────────────────────

app.get('/transactions', authenticateToken, async (req, res) => {
  const { card_id, limit = 100, offset = 0 } = req.query;
  const params = [req.user.id];
  let where = 'user_id = $1';
  if (card_id) {
    params.push(card_id);
    where += ` AND credit_card_id = $${params.length}`;
  }
  params.push(parseInt(limit), parseInt(offset));
  const result = await pool.query(
    `SELECT * FROM transactions WHERE ${where}
     ORDER BY date DESC, created_at DESC
     LIMIT $${params.length - 1} OFFSET $${params.length}`,
    params
  );
  res.json(result.rows);
});

app.post('/transactions', authenticateToken, async (req, res) => {
  const { credit_card_id, amount, description, category, date, is_pending } = req.body;
  const result = await pool.query(
    `INSERT INTO transactions (user_id, credit_card_id, amount, description, category, date, is_pending)
     VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
    [req.user.id, credit_card_id, amount, description, category, date, is_pending ?? false]
  );
  res.status(201).json(result.rows[0]);
});

app.put('/transactions/:id', authenticateToken, async (req, res) => {
  const { amount, description, category, date, is_pending } = req.body;
  const result = await pool.query(
    `UPDATE transactions
     SET amount=$1, description=$2, category=$3, date=$4, is_pending=$5
     WHERE id=$6 AND user_id=$7 RETURNING *`,
    [amount, description, category, date, is_pending, req.params.id, req.user.id]
  );
  if (!result.rows[0]) return res.status(404).json({ error: 'Transaction not found' });
  res.json(result.rows[0]);
});

app.delete('/transactions/:id', authenticateToken, async (req, res) => {
  await pool.query(
    'DELETE FROM transactions WHERE id=$1 AND user_id=$2',
    [req.params.id, req.user.id]
  );
  res.json({ success: true });
});

// ─── Budget Categories ────────────────────────────────────────────────────────

app.get('/categories', authenticateToken, async (req, res) => {
  const result = await pool.query(
    'SELECT * FROM budget_categories WHERE user_id = $1 ORDER BY name ASC',
    [req.user.id]
  );
  res.json(result.rows);
});

app.post('/categories', authenticateToken, async (req, res) => {
  const { name, budget_amount, color, icon } = req.body;
  const result = await pool.query(
    `INSERT INTO budget_categories (user_id, name, budget_amount, color, icon)
     VALUES ($1,$2,$3,$4,$5) RETURNING *`,
    [req.user.id, name, budget_amount ?? 0, color ?? '#007AFF', icon ?? 'tag']
  );
  res.status(201).json(result.rows[0]);
});

app.put('/categories/:id', authenticateToken, async (req, res) => {
  const { name, budget_amount, color, icon } = req.body;
  const result = await pool.query(
    `UPDATE budget_categories SET name=$1, budget_amount=$2, color=$3, icon=$4
     WHERE id=$5 AND user_id=$6 RETURNING *`,
    [name, budget_amount, color, icon, req.params.id, req.user.id]
  );
  if (!result.rows[0]) return res.status(404).json({ error: 'Category not found' });
  res.json(result.rows[0]);
});

app.delete('/categories/:id', authenticateToken, async (req, res) => {
  await pool.query(
    'DELETE FROM budget_categories WHERE id=$1 AND user_id=$2',
    [req.params.id, req.user.id]
  );
  res.json({ success: true });
});

// ─── User Preferences ─────────────────────────────────────────────────────────

app.get('/preferences', authenticateToken, async (req, res) => {
  let result = await pool.query(
    'SELECT * FROM user_preferences WHERE user_id = $1',
    [req.user.id]
  );
  if (!result.rows[0]) {
    result = await pool.query(
      'INSERT INTO user_preferences (user_id) VALUES ($1) RETURNING *',
      [req.user.id]
    );
  }
  res.json(result.rows[0]);
});

app.put('/preferences', authenticateToken, async (req, res) => {
  const { monthly_income, extra_payment, payoff_strategy, notifications_enabled } = req.body;
  const result = await pool.query(
    `INSERT INTO user_preferences (user_id, monthly_income, extra_payment, payoff_strategy, notifications_enabled)
     VALUES ($1,$2,$3,$4,$5)
     ON CONFLICT (user_id) DO UPDATE SET
       monthly_income        = EXCLUDED.monthly_income,
       extra_payment         = EXCLUDED.extra_payment,
       payoff_strategy       = EXCLUDED.payoff_strategy,
       notifications_enabled = EXCLUDED.notifications_enabled,
       updated_at            = NOW()
     RETURNING *`,
    [req.user.id, monthly_income ?? 0, extra_payment ?? 0,
     payoff_strategy ?? 'avalanche', notifications_enabled ?? true]
  );
  res.json(result.rows[0]);
});

// ─── Plaid: Create Link Token ─────────────────────────────────────────────────

app.post('/plaid/create-link-token', authenticateToken, async (req, res) => {
  try {
    const response = await plaidClient.linkTokenCreate({
      user: { client_user_id: req.user.id },
      client_name: 'iSave',
      products: [Products.Transactions],
      country_codes: [CountryCode.Us],
      language: 'en',
      account_filters: {
        credit: { account_subtypes: ['credit card'] },
      },
    });
    res.json({ link_token: response.data.link_token });
  } catch (err) {
    console.error('Plaid link token error:', err?.response?.data || err.message);
    res.status(500).json({ error: 'Failed to create Plaid link token' });
  }
});

// ─── Plaid: Exchange Public Token ─────────────────────────────────────────────

app.post('/plaid/exchange-token', authenticateToken, async (req, res) => {
  try {
    const { public_token, institution_name } = req.body;

    const exchangeResponse = await plaidClient.itemPublicTokenExchange({ public_token });
    const { access_token, item_id } = exchangeResponse.data;

    await pool.query(
      `INSERT INTO plaid_items (user_id, item_id, access_token, institution_name)
       VALUES ($1,$2,$3,$4)
       ON CONFLICT (item_id) DO UPDATE SET access_token = EXCLUDED.access_token`,
      [req.user.id, item_id, access_token, institution_name || null]
    );

    // Pull credit accounts and seed credit_cards rows
    const accountsRes = await plaidClient.accountsGet({ access_token });
    const creditAccounts = accountsRes.data.accounts.filter(a => a.type === 'credit');

    for (const acct of creditAccounts) {
      await pool.query(
        `INSERT INTO credit_cards
           (user_id, plaid_account_id, name, balance, credit_limit, card_type)
         VALUES ($1,$2,$3,$4,$5,'credit')
         ON CONFLICT DO NOTHING`,
        [
          req.user.id,
          acct.account_id,
          acct.name,
          Math.abs(acct.balances.current || 0),
          acct.balances.limit || 0,
        ]
      );
    }

    // Sync the last 30 days of transactions
    const synced = await syncTransactions(req.user.id, access_token);

    res.json({
      success: true,
      accounts_linked: creditAccounts.length,
      transactions_synced: synced,
    });
  } catch (err) {
    console.error('Plaid exchange error:', err?.response?.data || err.message);
    res.status(500).json({ error: 'Failed to exchange Plaid token' });
  }
});

// ─── Plaid: Manual Sync ───────────────────────────────────────────────────────

app.post('/plaid/sync', authenticateToken, async (req, res) => {
  try {
    const items = await pool.query(
      'SELECT * FROM plaid_items WHERE user_id = $1',
      [req.user.id]
    );
    let total = 0;
    for (const item of items.rows) {
      total += await syncTransactions(req.user.id, item.access_token);
    }
    res.json({ success: true, transactions_synced: total });
  } catch (err) {
    console.error('Plaid sync error:', err?.response?.data || err.message);
    res.status(500).json({ error: 'Sync failed' });
  }
});

// ─── Plaid Helper: Sync Transactions ─────────────────────────────────────────

async function syncTransactions(userId, accessToken) {
  const endDate   = new Date().toISOString().slice(0, 10);
  const startDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);

  const txRes = await plaidClient.transactionsGet({
    access_token: accessToken,
    start_date: startDate,
    end_date: endDate,
    options: { count: 250, include_personal_finance_category: true },
  });

  let count = 0;
  for (const tx of txRes.data.transactions) {
    const cardRes = await pool.query(
      'SELECT id FROM credit_cards WHERE plaid_account_id = $1 AND user_id = $2',
      [tx.account_id, userId]
    );
    if (!cardRes.rows[0]) continue;

    await pool.query(
      `INSERT INTO transactions
         (user_id, credit_card_id, plaid_transaction_id, amount, description, category, date, is_pending)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
       ON CONFLICT (plaid_transaction_id) DO UPDATE SET
         amount     = EXCLUDED.amount,
         is_pending = EXCLUDED.is_pending`,
      [
        userId,
        cardRes.rows[0].id,
        tx.transaction_id,
        Math.abs(tx.amount),
        tx.name,
        tx.personal_finance_category?.primary ?? tx.category?.[0] ?? 'Other',
        tx.date,
        tx.pending,
      ]
    );
    count++;
  }
  return count;
}

// ─── Start (only when run directly; Vercel imports the app) ───────────────────

if (require.main === module) {
  const PORT = process.env.PORT || 3000;
  ensureDB()
    .then(() => app.listen(PORT, () => console.log(`🚀 iSave API on port ${PORT}`)))
    .catch(err => { console.error('DB init failed:', err); process.exit(1); });
}

module.exports = app;
