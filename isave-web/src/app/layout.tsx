import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "iSave | Debt Payoff Command Center",
  description:
    "iSave is a finance command center for tracking credit cards, budgeting spending, and planning smarter debt payoff strategies.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="h-full antialiased">
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
