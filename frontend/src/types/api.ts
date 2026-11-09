/** Shape returned by GET /api/v1/health on the Spring Boot backend. */
export interface HealthResponse {
  status: string
  service: string
  timestamp: string
}

/** Consistent error body the backend will return (finalised in M3). */
export interface ApiError {
  message: string
  status?: number
}
