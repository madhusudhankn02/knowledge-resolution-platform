import axios, { AxiosError } from 'axios'
import type { ApiError } from '../types/api'

// Single, centralised Axios instance. The base URL comes from the environment
// (VITE_API_BASE_URL), never hard-coded in components.
export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080',
  timeout: 10_000,
  headers: { 'Content-Type': 'application/json' },
})

/** Turns any thrown error into a message that is safe to show to a user. */
export function toApiError(error: unknown): ApiError {
  if (error instanceof AxiosError) {
    if (error.response) {
      const data = error.response.data as { message?: string } | undefined
      return {
        status: error.response.status,
        message: data?.message ?? `Request failed with status ${error.response.status}`,
      }
    }
    return { message: 'Cannot reach the server. Check that the backend is running.' }
  }
  return { message: 'An unexpected error occurred.' }
}
