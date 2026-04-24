# iSave

A SwiftUI credit-card payoff and budgeting app, backed by a Node.js/Express
API on Neon (serverless Postgres) with Plaid integration for real bank data.

## Architecture

```
┌─────────────────┐      HTTPS + JWT     ┌──────────────────┐      SQL      ┌────────┐
│  iOS (SwiftUI)  │ ───────────────────▶ │  Node.js / Express│ ───────────▶ │  Neon  │
└─────────────────┘                      └──────────────────┘              └────────┘
                                                  │
                                                  │ Plaid API
                                                  ▼
                                         ┌────────────────┐
                                         │  Bank accounts │
                                         └────────────────┘
```

## Features

- 🔐 Email/password auth with JWT (stored in iOS Keychain)
- 💳 Credit card CRUD with utilisation tracking
- 📊 Transaction CRUD with category tagging
- 🎯 Budget categories with progress bars
- 📈 Payoff calculator (Avalanche / Snowball + extra-payment strategies)
- 🏦 Plaid Link integration for automatic bank-account import
- 🔄 Pull-to-refresh and optimistic updates throughout

## Repo layout

```
iSave/
├── backend/                # Node.js + Express API
│   ├── index.js
│   ├── package.json
│   └── .env.example        # Copy → .env, fill in your keys
└── iSave/                  # Xcode project (SwiftUI app)
    ├── iSave.xcodeproj/
    └── iSave/              # Swift sources
```

## Quick start

### 1. Backend

```bash
cd backend
npm install
cp .env.example .env
# edit .env: set DATABASE_URL (Neon), JWT_SECRET, PLAID_CLIENT_ID, PLAID_SECRET
npm start
```

The API listens on `http://localhost:3000`. The schema is created
automatically on first launch.

### 2. iOS app

```bash
open iSave/iSave.xcodeproj
```

In Xcode:
- Select the **iSave** scheme + any iPhone Simulator
- ⌘R to run
- Register an account → start adding cards / transactions

If your backend is on a different host, edit `iSave/Services/APIService.swift`
(`baseURL`) **or** set the `API_BASE_URL` environment variable in your Xcode
scheme.

### 3. Enable real Plaid bank linking (optional)

The project compiles without the Plaid SDK so it can be opened immediately.
To enable the Link UI:

1. Xcode → **File → Add Package Dependencies…**
2. URL: `https://github.com/plaid/plaid-link-ios`
3. Add `LinkKit` to the **iSave** target
4. Open `iSave/Plaid/PlaidManager.swift`
5. Uncomment `// import LinkKit` and the real implementation block at the
   bottom of the file (replace the stub `startLink()` and `linkView()`)

Sandbox login (Plaid):
- Username: `user_good`
- Password: `pass_good`

## API reference

| Method | Path                          | Auth | Purpose                       |
|--------|-------------------------------|------|-------------------------------|
| POST   | `/auth/register`              |      | Create account, returns JWT   |
| POST   | `/auth/login`                 |      | Sign in, returns JWT          |
| GET    | `/auth/me`                    | ✓    | Current user                  |
| GET    | `/cards`                      | ✓    | List credit cards             |
| POST   | `/cards`                      | ✓    | Add credit card               |
| PUT    | `/cards/:id`                  | ✓    | Update card                   |
| DELETE | `/cards/:id`                  | ✓    | Delete card                   |
| GET    | `/transactions`               | ✓    | List transactions             |
| POST   | `/transactions`               | ✓    | Add transaction               |
| PUT    | `/transactions/:id`           | ✓    | Update transaction            |
| DELETE | `/transactions/:id`           | ✓    | Delete transaction            |
| GET    | `/categories`                 | ✓    | List budget categories        |
| POST   | `/categories`                 | ✓    | Add category                  |
| PUT    | `/categories/:id`             | ✓    | Update category               |
| DELETE | `/categories/:id`             | ✓    | Delete category               |
| GET    | `/preferences`                | ✓    | Read user preferences         |
| PUT    | `/preferences`                | ✓    | Update preferences            |
| POST   | `/plaid/create-link-token`    | ✓    | Plaid Link token              |
| POST   | `/plaid/exchange-token`       | ✓    | Exchange public token, sync   |
| POST   | `/plaid/sync`                 | ✓    | Re-sync linked accounts       |

## Deploy the backend to Vercel

The backend is set up as a Vercel serverless function
(`backend/api/index.js` + `backend/vercel.json`).

### Via the Vercel dashboard (recommended)

1. Push this repo to GitHub
2. Go to https://vercel.com/new → **Import** the repo
3. **Root Directory:** `backend` ← important
4. Framework Preset: **Other**
5. Add environment variables (Settings → Environment Variables):
   - `DATABASE_URL` — Neon connection string
   - `JWT_SECRET` — any long random string
   - `PLAID_CLIENT_ID`
   - `PLAID_SECRET`
   - `PLAID_ENV` = `sandbox`
6. Click **Deploy**

Vercel returns a URL like `https://isave-api.vercel.app`. Point the iOS app
at it by editing `iSave/Services/APIService.swift` `baseURL` (or set the
`API_BASE_URL` env var in the Xcode scheme).

### Via CLI

```bash
npm i -g vercel
cd backend
vercel                # first time: prompts + links project
vercel env add DATABASE_URL
vercel env add JWT_SECRET
vercel env add PLAID_CLIENT_ID
vercel env add PLAID_SECRET
vercel env add PLAID_ENV
vercel --prod         # promote to production
```

### Other hosts

Standard Express app — also runs on Railway, Render, Fly.io, Heroku, etc.
Set the env vars and run `npm start`.

## License

MIT
