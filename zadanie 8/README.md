# Zadanie 8 — Selenium / Playwright Test Suite

Automated tests for the React shop from `zadanie 5`.

## Prerequisites

- `zadanie 5` frontend running at `http://localhost:5173`
- `zadanie 5` backend running at `http://localhost:8080`

From `zadanie 5/`:

```bash
docker compose up --build
```

Or run backend and frontend separately:

```bash
cd backend && go run .
cd frontend && npm run dev
```

The frontend uses `/api` as a relative base URL (proxied to the backend by Vite) so session and CSRF cookies work correctly in the browser.

## Setup

```bash
cd "zadanie 8"
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
playwright install chromium
```

## Running tests

```bash
source .venv/bin/activate
pytest tests/ -v
```

Run a single file:

```bash
pytest tests/test_csrf.py -v
```

## Test files

| File | Tool | Purpose |
|------|------|---------|
| `test_user_form.py` | Selenium | Registration form validation |
| `test_xss.py` | Selenium | XSS payload immunity |
| `test_cart_parallel.py` | Selenium | Multi-tab cart isolation |
| `test_csrf.py` | Selenium | CSRF attack blocking |
| `test_e2e.py` | Playwright | Full user journey (50+ assertions) |
