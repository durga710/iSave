const heroStats = [
  { label: "Cards tracked", value: "12", detail: "Across personal and business accounts" },
  { label: "Interest saved", value: "$4.8k", detail: "Projected from strategy-led payoff" },
  { label: "Budget health", value: "86%", detail: "Spending aligned with monthly targets" },
];

const productPillars = [
  {
    title: "Debt payoff with a real strategy",
    description:
      "Switch between avalanche and snowball planning, compare outcomes, and see exactly where extra monthly payments make the biggest difference.",
  },
  {
    title: "Credit cards, budgets, and activity in one view",
    description:
      "iSave pulls the moving pieces together so balances, limits, spending, and budget drift all read like one system instead of six separate tasks.",
  },
  {
    title: "Built for everyday decisions",
    description:
      "Quick summaries, recent transactions, utilization signals, and monthly targets stay readable at a glance whether you are checking in for 20 seconds or 20 minutes.",
  },
];

const dashboardMetrics = [
  { label: "Total balance", value: "$18,420", tone: "text-[var(--danger)]" },
  { label: "Credit limit", value: "$42,000", tone: "text-[var(--success)]" },
  { label: "Min due", value: "$760", tone: "text-[var(--warning)]" },
  { label: "Spent this month", value: "$2,148", tone: "text-[var(--accent-strong)]" },
];

const cards = [
  { name: "Chase Sapphire", balance: "$7,420", apr: "22.9% APR", limit: "$14,000", utilization: 53 },
  { name: "Amex Gold", balance: "$4,860", apr: "19.4% APR", limit: "$10,000", utilization: 49 },
  { name: "Capital One Venture", balance: "$6,140", apr: "17.2% APR", limit: "$18,000", utilization: 34 },
];

const transactions = [
  { description: "Trader Joe's", category: "Groceries", amount: "-$118.24", date: "Apr 24" },
  { description: "Adobe", category: "Software", amount: "-$32.49", date: "Apr 22" },
  { description: "Payroll Deposit", category: "Income", amount: "+$3,900.00", date: "Apr 20" },
  { description: "Shell", category: "Transport", amount: "-$54.80", date: "Apr 19" },
];

const budgetCategories = [
  { name: "Groceries", spent: 782, budget: 900 },
  { name: "Dining", spent: 364, budget: 300 },
  { name: "Transport", spent: 192, budget: 260 },
  { name: "Subscriptions", spent: 86, budget: 120 },
];

const payoffPlan = [
  { month: "Month 5", card: "Amex Gold", note: "Highest APR cleared first" },
  { month: "Month 11", card: "Chase Sapphire", note: "Extra payment rolled forward" },
  { month: "Month 16", card: "Capital One Venture", note: "Debt-free projection reached" },
];

const settingsRows = [
  { label: "Monthly income", value: "$8,600" },
  { label: "Extra payment", value: "$450" },
  { label: "Strategy", value: "Avalanche" },
  { label: "Notifications", value: "Enabled" },
];

const DEFAULT_LIVE_APP_URL =
  "https://i-save-git-main-reyghim1093-5928s-projects.vercel.app/";

export default function Home() {
  const liveAppUrl = process.env.NEXT_PUBLIC_LIVE_APP_URL ?? DEFAULT_LIVE_APP_URL;
  const primaryLaunchHref = liveAppUrl;
  const primaryLaunchLabel = "Open live app";

  return (
    <main className="min-h-screen bg-[var(--background)] text-[var(--foreground)]">
      <div className="absolute inset-x-0 top-0 -z-10 h-[42rem] bg-[linear-gradient(180deg,rgba(11,59,52,0.12),rgba(245,241,232,0))]" />
      <div className="absolute inset-x-0 top-0 -z-10 h-[42rem] bg-[repeating-linear-gradient(90deg,transparent,transparent_0.95rem,rgba(11,59,52,0.05)_1rem)] opacity-40" />

      <div className="mx-auto flex w-full max-w-7xl flex-col px-5 pb-20 sm:px-8 lg:px-10">
        <header className="sticky top-0 z-20 -mx-5 border-b border-[var(--line)] bg-[color-mix(in_srgb,var(--background)_90%,white_10%)]/95 px-5 backdrop-blur sm:-mx-8 sm:px-8 lg:-mx-10 lg:px-10">
          <div className="mx-auto flex max-w-7xl items-center justify-between py-4">
            <a href="#top" className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-[var(--foreground)] text-sm font-semibold text-[var(--background)]">
                IS
              </div>
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.18em] text-[var(--accent-strong)]">
                  iSave
                </p>
                <p className="text-sm text-[var(--muted)]">Debt payoff command center</p>
              </div>
            </a>

            <nav className="hidden items-center gap-7 text-sm text-[var(--muted)] md:flex">
              <a href="#product" className="transition hover:text-[var(--foreground)]">
                Product
              </a>
              <a href="#modules" className="transition hover:text-[var(--foreground)]">
                Modules
              </a>
              <a href="#payoff" className="transition hover:text-[var(--foreground)]">
                Payoff
              </a>
              <a href="#launch" className="transition hover:text-[var(--foreground)]">
                Launch
              </a>
            </nav>

            <a
              href={primaryLaunchHref}
              className="rounded-full border border-[var(--foreground)] px-4 py-2 text-sm font-medium transition hover:bg-[var(--foreground)] hover:text-[var(--background)]"
              target={liveAppUrl ? "_blank" : undefined}
              rel={liveAppUrl ? "noreferrer" : undefined}
            >
              {primaryLaunchLabel}
            </a>
          </div>
        </header>

        <section
          id="top"
          className="scroll-mt-32 grid gap-12 border-b border-[var(--line)] py-14 lg:grid-cols-[minmax(0,1.05fr)_minmax(24rem,0.95fr)] lg:py-20"
        >
          <div className="flex flex-col justify-center">
            <div className="mb-6 inline-flex w-fit items-center gap-2 rounded-full border border-[var(--line)] bg-white/80 px-4 py-2 text-xs font-medium uppercase tracking-[0.16em] text-[var(--accent-strong)] shadow-[0_12px_30px_rgba(11,59,52,0.08)]">
              Vercel-ready finance product
            </div>
            <h1 className="max-w-3xl text-5xl leading-[1.02] font-semibold sm:text-6xl lg:text-7xl">
              A clearer way to track cards, budget spending, and pay debt down faster.
            </h1>
            <p className="mt-6 max-w-2xl text-lg leading-8 text-[var(--muted)] sm:text-xl">
              iSave turns credit utilization, recent activity, monthly budgets, and payoff strategy into one calm operating system for personal finance.
            </p>

            <div className="mt-9 flex flex-col gap-4 sm:flex-row">
              <a
                href={primaryLaunchHref}
                className="inline-flex items-center justify-center rounded-full bg-[var(--foreground)] px-6 py-3 text-sm font-semibold text-[var(--background)] transition hover:translate-y-[-1px]"
                target={liveAppUrl ? "_blank" : undefined}
                rel={liveAppUrl ? "noreferrer" : undefined}
              >
                {liveAppUrl ? "View live app" : "See launch section"}
              </a>
              <a
                href="#modules"
                className="inline-flex items-center justify-center rounded-full border border-[var(--line-strong)] px-6 py-3 text-sm font-semibold text-[var(--foreground)] transition hover:border-[var(--foreground)]"
              >
                Explore the product
              </a>
            </div>

            <div className="mt-10 grid gap-4 sm:grid-cols-3">
              {heroStats.map((stat) => (
                <article
                  key={stat.label}
                  className="rounded-[1.5rem] border border-[var(--line)] bg-white/80 p-5 shadow-[0_18px_40px_rgba(26,26,26,0.05)]"
                >
                  <p className="text-xs uppercase tracking-[0.16em] text-[var(--muted)]">{stat.label}</p>
                  <p className="mt-3 text-3xl font-semibold">{stat.value}</p>
                  <p className="mt-2 text-sm leading-6 text-[var(--muted)]">{stat.detail}</p>
                </article>
              ))}
            </div>
          </div>

          <div className="relative">
            <div className="rounded-[2rem] border border-[var(--line)] bg-[var(--panel)] p-4 shadow-[0_35px_80px_rgba(12,25,23,0.12)]">
              <div className="rounded-[1.6rem] border border-[var(--line)] bg-[var(--foreground)] p-5 text-[var(--panel)]">
                <div className="flex items-center justify-between border-b border-white/10 pb-4">
                  <div>
                    <p className="text-xs uppercase tracking-[0.18em] text-white/55">Dashboard</p>
                    <p className="mt-2 text-2xl font-semibold">Welcome back, Rey</p>
                  </div>
                  <div className="rounded-full border border-white/10 px-3 py-1 text-xs text-white/70">
                    Plaid synced 2h ago
                  </div>
                </div>

                <div className="mt-5 grid gap-3 sm:grid-cols-2">
                  {dashboardMetrics.map((metric) => (
                    <article key={metric.label} className="rounded-[1.25rem] bg-white/6 p-4">
                      <p className="text-xs uppercase tracking-[0.14em] text-white/55">{metric.label}</p>
                      <p className={`mt-2 text-3xl font-semibold ${metric.tone}`}>{metric.value}</p>
                    </article>
                  ))}
                </div>

                <div className="mt-5 grid gap-4 xl:grid-cols-[1.05fr_0.95fr]">
                  <article className="rounded-[1.35rem] bg-white/6 p-4">
                    <div className="flex items-center justify-between">
                      <p className="text-sm font-medium">Recent transactions</p>
                      <span className="text-xs text-white/55">4 items</span>
                    </div>
                    <div className="mt-4 space-y-3">
                      {transactions.map((transaction) => (
                        <div key={`${transaction.description}-${transaction.date}`} className="rounded-2xl border border-white/8 px-3 py-3">
                          <div className="flex items-start justify-between gap-3">
                            <div>
                              <p className="font-medium">{transaction.description}</p>
                              <p className="mt-1 text-sm text-white/55">{transaction.category}</p>
                            </div>
                            <div className="text-right">
                              <p className="font-medium">{transaction.amount}</p>
                              <p className="mt-1 text-xs text-white/65">{transaction.date}</p>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </article>

                  <article className="rounded-[1.35rem] bg-white/6 p-4">
                    <div className="flex items-center justify-between">
                      <p className="text-sm font-medium">Payoff runway</p>
                      <span className="rounded-full bg-[var(--accent-soft)] px-2.5 py-1 text-xs font-semibold text-[var(--accent-strong)]">
                        Avalanche
                      </span>
                    </div>
                    <div className="mt-4 space-y-3">
                      {payoffPlan.map((step) => (
                        <div key={step.card} className="rounded-2xl border border-white/8 px-3 py-3">
                          <div className="flex items-center justify-between">
                            <p className="font-medium">{step.card}</p>
                            <span className="text-sm text-[var(--success)]">{step.month}</span>
                          </div>
                          <p className="mt-1 text-sm text-white/55">{step.note}</p>
                        </div>
                      ))}
                    </div>
                  </article>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section
          id="product"
          className="scroll-mt-32 grid gap-6 border-b border-[var(--line)] py-14 lg:grid-cols-3"
        >
          {productPillars.map((pillar, index) => (
            <article
              key={pillar.title}
              className="rounded-[1.75rem] border border-[var(--line)] bg-[var(--panel)] p-6 shadow-[0_14px_30px_rgba(26,26,26,0.04)]"
            >
              <p className="text-xs uppercase tracking-[0.16em] text-[var(--accent-strong)]">0{index + 1}</p>
              <h2 className="mt-4 text-2xl font-semibold">{pillar.title}</h2>
              <p className="mt-4 text-base leading-7 text-[var(--muted)]">{pillar.description}</p>
            </article>
          ))}
        </section>

        <section id="modules" className="scroll-mt-32 py-14">
          <div className="max-w-2xl">
            <p className="text-sm font-semibold uppercase tracking-[0.18em] text-[var(--accent-strong)]">
              Product modules
            </p>
            <h2 className="mt-4 text-4xl font-semibold sm:text-5xl">
              The website now mirrors the actual app instead of a placeholder shell.
            </h2>
            <p className="mt-4 text-lg leading-8 text-[var(--muted)]">
              Every major surface from the Swift app is represented here so the web launch tells the same story as the product itself.
            </p>
          </div>

          <div className="mt-10 grid gap-6 xl:grid-cols-[1.15fr_0.85fr]">
            <article className="rounded-[2rem] border border-[var(--line)] bg-[var(--panel)] p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-semibold uppercase tracking-[0.16em] text-[var(--accent-strong)]">
                    Credit cards
                  </p>
                  <h3 className="mt-2 text-2xl font-semibold">Balances, APR, limits, utilization</h3>
                </div>
                <span className="rounded-full border border-[var(--line)] px-3 py-1 text-xs text-[var(--muted)]">
                  Cards module
                </span>
              </div>

              <div className="mt-6 space-y-4">
                {cards.map((card) => (
                  <div key={card.name} className="rounded-[1.4rem] border border-[var(--line)] bg-white p-4 shadow-[0_8px_20px_rgba(26,26,26,0.04)]">
                    <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                      <div>
                        <p className="text-lg font-semibold">{card.name}</p>
                        <p className="mt-1 text-sm text-[var(--muted)]">
                          {card.apr} · Limit {card.limit}
                        </p>
                      </div>
                      <div className="text-left sm:text-right">
                        <p className="text-2xl font-semibold">{card.balance}</p>
                        <p className="mt-1 text-sm text-[var(--muted)]">Current balance</p>
                      </div>
                    </div>
                    <div className="mt-4">
                      <div className="mb-2 flex items-center justify-between text-sm">
                        <span className="text-[var(--muted)]">Utilization</span>
                        <span className="font-medium text-[var(--foreground)]">{card.utilization}%</span>
                      </div>
                      <div className="h-2 rounded-full bg-[var(--line)]">
                        <div
                          className="h-2 rounded-full bg-[linear-gradient(90deg,var(--accent),var(--accent-strong))]"
                          style={{ width: `${card.utilization}%` }}
                        />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </article>

            <div className="grid gap-6">
              <article className="rounded-[2rem] border border-[var(--line)] bg-[var(--panel)] p-6">
                <p className="text-sm font-semibold uppercase tracking-[0.16em] text-[var(--accent-strong)]">
                  Budget
                </p>
                <h3 className="mt-2 text-2xl font-semibold">Category tracking with drift visibility</h3>
                <div className="mt-6 space-y-4">
                  {budgetCategories.map((category) => {
                    const progress = Math.round((category.spent / category.budget) * 100);
                    return (
                      <div key={category.name}>
                        <div className="flex items-center justify-between text-sm">
                          <p className="font-medium">{category.name}</p>
                          <p className="text-[var(--muted)]">
                            ${category.spent} / ${category.budget}
                          </p>
                        </div>
                        <div className="mt-2 h-2 rounded-full bg-[var(--line)]">
                          <div
                            className={`h-2 rounded-full ${
                              progress > 100 ? "bg-[var(--danger)]" : "bg-[var(--accent-strong)]"
                            }`}
                            style={{ width: `${Math.min(progress, 100)}%` }}
                          />
                        </div>
                      </div>
                    );
                  })}
                </div>
              </article>

              <article className="rounded-[2rem] border border-[var(--line)] bg-[var(--foreground)] p-6 text-[var(--panel)]">
                <p className="text-sm font-semibold uppercase tracking-[0.16em] text-white/60">Settings</p>
                <h3 className="mt-2 text-2xl font-semibold">Personalized payoff behavior</h3>
                <div className="mt-6 divide-y divide-white/10 rounded-[1.5rem] border border-white/10">
                  {settingsRows.map((row) => (
                    <div key={row.label} className="flex items-center justify-between px-4 py-4">
                      <span className="text-sm text-white/60">{row.label}</span>
                      <span className="text-sm font-medium">{row.value}</span>
                    </div>
                  ))}
                </div>
              </article>
            </div>
          </div>
        </section>

        <section
          id="payoff"
          className="scroll-mt-32 grid gap-8 border-y border-[var(--line)] py-14 lg:grid-cols-[0.9fr_1.1fr]"
        >
          <div>
            <p className="text-sm font-semibold uppercase tracking-[0.18em] text-[var(--accent-strong)]">
              Payoff engine
            </p>
            <h2 className="mt-4 text-4xl font-semibold sm:text-5xl">
              Avalanche and snowball plans, shown in plain language.
            </h2>
            <p className="mt-4 text-lg leading-8 text-[var(--muted)]">
              The same payoff logic from the iOS app becomes a web-friendly explainer here, so visitors understand how iSave helps before they ever sign in.
            </p>
          </div>

          <div className="grid gap-4 md:grid-cols-2">
            <article className="rounded-[1.8rem] border border-[var(--line)] bg-[var(--panel)] p-6">
              <p className="text-sm font-semibold uppercase tracking-[0.16em] text-[var(--accent-strong)]">
                Avalanche
              </p>
              <p className="mt-3 text-2xl font-semibold">$2,140 less interest</p>
              <p className="mt-3 text-base leading-7 text-[var(--muted)]">
                Highest APR balances are attacked first, which reduces long-run interest and usually produces the strongest mathematical outcome.
              </p>
            </article>

            <article className="rounded-[1.8rem] border border-[var(--line)] bg-[var(--panel)] p-6">
              <p className="text-sm font-semibold uppercase tracking-[0.16em] text-[var(--accent-strong)]">
                Snowball
              </p>
              <p className="mt-3 text-2xl font-semibold">3 early wins</p>
              <p className="mt-3 text-base leading-7 text-[var(--muted)]">
                Lowest balances disappear faster, which can be the right behavioral choice when momentum matters more than pure interest efficiency.
              </p>
            </article>

            <article className="rounded-[1.8rem] border border-[var(--line)] bg-[var(--foreground)] p-6 text-[var(--panel)] md:col-span-2">
              <div className="flex flex-col gap-5 sm:flex-row sm:items-end sm:justify-between">
                <div>
                  <p className="text-sm font-semibold uppercase tracking-[0.16em] text-white/60">Current projection</p>
                  <h3 className="mt-2 text-3xl font-semibold">Debt-free in 16 months with an extra $450/month</h3>
                </div>
                <div className="rounded-full border border-white/12 px-4 py-2 text-sm text-white/70">
                  Strategy tuned from settings
                </div>
              </div>
              <div className="mt-6 grid gap-3 sm:grid-cols-3">
                {payoffPlan.map((step) => (
                  <div key={step.card} className="rounded-[1.3rem] border border-white/10 bg-white/5 p-4">
                    <p className="text-sm text-white/55">{step.month}</p>
                    <p className="mt-2 text-lg font-semibold">{step.card}</p>
                    <p className="mt-2 text-sm leading-6 text-white/60">{step.note}</p>
                  </div>
                ))}
              </div>
            </article>
          </div>
        </section>

        <section className="grid gap-6 py-14 lg:grid-cols-[0.95fr_1.05fr]">
          <article className="rounded-[2rem] border border-[var(--line)] bg-[var(--panel)] p-6">
            <p className="text-sm font-semibold uppercase tracking-[0.16em] text-[var(--accent-strong)]">
              Security and sync
            </p>
            <h2 className="mt-3 text-3xl font-semibold">Plaid-linked, notification-aware, and designed for trust.</h2>
            <p className="mt-4 text-base leading-7 text-[var(--muted)]">
              iSave explains the connection model clearly: bank linking through Plaid, transaction sync controls, payment reminders, and profile settings all belong in one predictable place.
            </p>
          </article>

          <article className="rounded-[2rem] border border-[var(--line)] bg-[var(--panel)] p-6">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="rounded-[1.4rem] border border-[var(--line)] bg-white p-4">
                <p className="text-sm font-medium text-[var(--muted)]">Sync status</p>
                <p className="mt-2 text-2xl font-semibold">Connected</p>
                <p className="mt-2 text-sm leading-6 text-[var(--muted)]">2 institutions linked, 186 transactions categorized.</p>
              </div>
              <div className="rounded-[1.4rem] border border-[var(--line)] bg-white p-4">
                <p className="text-sm font-medium text-[var(--muted)]">Notifications</p>
                <p className="mt-2 text-2xl font-semibold">Smart reminders</p>
                <p className="mt-2 text-sm leading-6 text-[var(--muted)]">Payment nudges and budget overrun warnings stay easy to scan.</p>
              </div>
            </div>
          </article>
        </section>

        <section
          id="launch"
          className="scroll-mt-32 rounded-[2.4rem] border border-[var(--line)] bg-[var(--foreground)] px-6 py-10 text-[var(--panel)] sm:px-10"
        >
          <div className="flex flex-col gap-8 lg:flex-row lg:items-end lg:justify-between">
            <div className="max-w-2xl">
              <p className="text-sm font-semibold uppercase tracking-[0.18em] text-white/60">Launch ready</p>
              <h2 className="mt-3 text-4xl font-semibold sm:text-5xl">
                The iSave web presence is ready to replace the placeholder deployment with something real.
              </h2>
              <p className="mt-4 text-lg leading-8 text-white/65">
                This version gives you a proper homepage, product story, live product framing, and a clean path to keep expanding into authenticated dashboards later.
              </p>
              <p className="mt-3 text-sm leading-6 text-white/50">
                CTA buttons default to the main iSave app deployment and can be overridden with `NEXT_PUBLIC_LIVE_APP_URL` if that destination ever changes.
              </p>
            </div>

            <div className="flex flex-col gap-4 sm:flex-row">
              <a
                href={primaryLaunchHref}
                className="inline-flex items-center justify-center rounded-full bg-[var(--panel)] px-6 py-3 text-sm font-semibold text-[var(--foreground)] transition hover:translate-y-[-1px]"
                target={liveAppUrl ? "_blank" : undefined}
                rel={liveAppUrl ? "noreferrer" : undefined}
              >
                {liveAppUrl ? "Open production app" : "CTA wired for production"}
              </a>
              <a
                href="#top"
                className="inline-flex items-center justify-center rounded-full border border-white/15 px-6 py-3 text-sm font-semibold text-[var(--panel)] transition hover:border-white/40"
              >
                Back to top
              </a>
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}
