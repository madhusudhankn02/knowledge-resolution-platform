import { useEffect, useState } from 'react'
import { fetchHealth } from '../services/healthService'
import { toApiError } from '../services/apiClient'
import type { ApiError, HealthResponse } from '../types/api'

type State =
  | { phase: 'loading' }
  | { phase: 'success'; data: HealthResponse }
  | { phase: 'error'; error: ApiError }

/** Calls the real backend once on mount and exposes loading / success / error. */
export function useHealth(): State {
  const [state, setState] = useState<State>({ phase: 'loading' })

  useEffect(() => {
    let cancelled = false
    fetchHealth()
      .then((data) => !cancelled && setState({ phase: 'success', data }))
      .catch((e) => !cancelled && setState({ phase: 'error', error: toApiError(e) }))
    return () => {
      cancelled = true
    }
  }, [])

  return state
}
