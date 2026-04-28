# iSave Web

Marketing and launch website for iSave, built with Next.js 16 and deployed on Vercel.

## What it includes

- Product-focused homepage for the iSave finance app
- Dashboard-inspired sections for cards, transactions, budgets, payoff strategy, and settings
- Production-safe build configuration for local and Vercel deploys
- Default CTA wiring to the main iSave app deployment, with optional override through `NEXT_PUBLIC_LIVE_APP_URL`

## Local development

```bash
npm ci
npm run dev
```

Open `http://127.0.0.1:3000` or the port shown by Next.js.

## Verification

```bash
npm run lint
npm run build
```

## Deployment

This app is designed to deploy directly on Vercel from the `isave-web/` directory.

By default, the primary CTA buttons open:

```bash
https://i-save-git-main-reyghim1093-5928s-projects.vercel.app/
```

If that destination ever changes, override it with:

```bash
NEXT_PUBLIC_LIVE_APP_URL=https://your-production-url.example
```
