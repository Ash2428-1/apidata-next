import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen bg-zinc-50 flex flex-col">
      {/* Header */}
      <header className="bg-zinc-900 text-white py-4 px-6">
        <div className="max-w-6xl mx-auto flex items-center justify-between">
          <div>
            <p className="text-xs font-bold tracking-widest text-pink-500 uppercase">Xtend</p>
            <h1 className="text-xl font-bold">API Hub</h1>
          </div>
          <Link
            href="/api/health"
            className="text-sm text-zinc-400 hover:text-white transition-colors"
          >
            Health Check →
          </Link>
        </div>
      </header>

      {/* Main */}
      <main className="flex-1 flex items-center justify-center px-6 py-20">
        <div className="max-w-2xl w-full text-center">
          <h2 className="text-4xl font-bold text-zinc-900 mb-4">
            Eco System Sales Portal
          </h2>
          <p className="text-lg text-zinc-600 mb-8">
            API Hub staging environment. Manage connectors, contacts, deals, vehicles, and SIM data.
          </p>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-12">
            <div className="bg-white rounded-xl border border-zinc-200 p-6 text-left">
              <div className="w-10 h-10 bg-pink-100 rounded-lg flex items-center justify-center mb-3">
                <svg className="w-5 h-5 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <h3 className="font-semibold text-zinc-900 mb-1">Connectors</h3>
              <p className="text-sm text-zinc-500">CarTrack, Flickswitch, manual imports</p>
            </div>

            <div className="bg-white rounded-xl border border-zinc-200 p-6 text-left">
              <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center mb-3">
                <svg className="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <h3 className="font-semibold text-zinc-900 mb-1">Contacts</h3>
              <p className="text-sm text-zinc-500">Unified contact database</p>
            </div>

            <div className="bg-white rounded-xl border border-zinc-200 p-6 text-left">
              <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center mb-3">
                <svg className="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
              </div>
              <h3 className="font-semibold text-zinc-900 mb-1">Deals & Quotes</h3>
              <p className="text-sm text-zinc-500">Sales pipeline management</p>
            </div>
          </div>

          <div className="bg-zinc-900 text-white rounded-xl p-6 text-left">
            <h3 className="font-semibold mb-2">API Endpoints</h3>
            <div className="space-y-2 text-sm font-mono text-zinc-400">
              <div className="flex items-center gap-3">
                <span className="text-green-400">GET</span>
                <span>/api/health</span>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-blue-400">POST</span>
                <span>/api/auth/login</span>
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-zinc-200 py-6 px-6">
        <div className="max-w-6xl mx-auto text-center text-sm text-zinc-500">
          © {new Date().getFullYear()} Xtend. Staging environment.
        </div>
      </footer>
    </div>
  );
}
