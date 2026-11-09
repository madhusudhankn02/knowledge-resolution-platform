# Customer Service Knowledge-Based Resolution Platform

Status: **Phase 1, Milestone M1** (project setup). See `docs/` as it grows.

## Layout
- `backend/` Spring Boot 3 (Java 21, Maven)
- `frontend/` React + TypeScript + Vite + Tailwind
- `database/migrations` Flyway migrations, `database/seed` dev-only seed data
- `docs/`, `postman/`

## Run (local development)
```
cp .env.example .env            # then edit values
docker compose up -d postgres
cd backend && SPRING_PROFILES_ACTIVE=dev mvn spring-boot:run
cd frontend && npm install && npm run dev
```
Backend: http://localhost:8080/api/v1/health | Frontend: http://localhost:5173
