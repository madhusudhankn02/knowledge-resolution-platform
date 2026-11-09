import { useHealth } from '../hooks/useHealth'

export default function HomePage() {
  const health = useHealth()

  return (
    <main className="mx-auto max-w-2xl p-8">
      <h1 className="text-2xl font-semibold text-slate-900">
        Customer Service Knowledge-Based Resolution Platform
      </h1>
      <p className="mt-2 text-slate-600">Phase 1 foundation: M1 project setup.</p>

      <section aria-label="Backend status" className="mt-6 rounded-lg border border-slate-200 p-4">
        <h2 className="text-sm font-medium text-slate-500">Backend connection</h2>
        {health.phase === 'loading' && <p role="status">Checking backend…</p>}
        {health.phase === 'success' && (
          <p role="status" className="text-green-700">
            {health.data.service}: {health.data.status}
          </p>
        )}
        {health.phase === 'error' && (
          <p role="alert" className="text-red-700">
            {health.error.message}
          </p>
        )}
      </section>
    </main>
  )
}
