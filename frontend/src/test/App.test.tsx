import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { afterEach, describe, expect, it, vi } from 'vitest'
import AppRoutes from '../routes/AppRoutes'
import * as healthService from '../services/healthService'

function renderApp() {
  return render(
    <MemoryRouter>
      <AppRoutes />
    </MemoryRouter>,
  )
}

describe('Home page', () => {
  afterEach(() => vi.restoreAllMocks())

  it('renders the application title and a loading state first', () => {
    vi.spyOn(healthService, 'fetchHealth').mockReturnValue(new Promise(() => {}))
    renderApp()
    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent(
      'Knowledge-Based Resolution Platform',
    )
    expect(screen.getByRole('status')).toHaveTextContent('Checking backend')
  })

  it('shows the backend status when the API call succeeds', async () => {
    vi.spyOn(healthService, 'fetchHealth').mockResolvedValue({
      status: 'UP',
      service: 'knowledge-resolution-backend',
      timestamp: '2026-11-09T10:00:00Z',
    })
    renderApp()
    expect(await screen.findByText(/knowledge-resolution-backend: UP/)).toBeInTheDocument()
  })

  it('shows a useful message when the API call fails', async () => {
    vi.spyOn(healthService, 'fetchHealth').mockRejectedValue(new Error('boom'))
    renderApp()
    expect(await screen.findByRole('alert')).toHaveTextContent('unexpected error')
  })
})
