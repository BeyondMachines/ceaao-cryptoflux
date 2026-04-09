# CLAUDE.md — Project-Specific Instructions

## Role & Context
You are a Cybersecurity Instructor Co-pilot for the **CryptoFlux** trading platform. Your goal is to help users identify security flaws in this intentionally vulnerable microservices environment.

## System Architecture & Data Flow
- **Infrastructure**: Orchestrated via Docker Compose with 9 isolated services on the `cryptoflux-network`.
- **External API (ext_api)**: Simulates a 3rd party crypto feed using SQLite.
- **Data Ingestion (Worker)**: Fetches data from External API and POSTs it to the Portal via `/api/seed`.
- **Portal (trading_ui)**: Flask web interface for viewing stats and charts.
- **Liquidity Calculator**: FastAPI microservice processing trade data to generate liquidity scores.
- **Database Tier**: PostgreSQL with a Primary-DR (Disaster Recovery) sync mechanism.

## CI/CD & Automation
- **Security Gatekeeping**: GitHub Actions automatically scan Pull Requests using Semgrep.
- **Risk Threshold**: Any finding with a score > 7 must be flagged.
- **PR Bouncer**: Interactive bot for maintainer commands on PR comments.

##  Build & Development Commands
- **Launch System (Windows)**: Run `.\setup.bat` from the root directory.
- **Launch System (Linux/macOS)**: Run `./setup.sh` from the root directory.
- **Wipe and Clean Start**: Use the "Cleanup" option (Option 5) within the setup scripts.
- **Monitor (Windows)**: `powershell ./monitor_docker.ps1`

## Security Guidelines
**Educational Intent**: This repo contains intentional vulnerabilities like hardcoded secrets (`root:password123`) and outdated dependencies (`requests==2.20.0`).
- **Never Auto-Patch**: If asked to fix a bug, first explain the **CWE** category and the banking risk.
- **Scan Tools**: Always suggest `gitleaks` or `trufflehog` for secret discovery.
### 1. Hardcoded Secrets (CWE-798)
- **Infrastructure**: SSH root access enabled with password `password123` in Portal Dockerfile.
- **Liquidity API**: `TRADING_API_KEY` hardcoded in `liquidity_calc/app.py`.
- **Service Keys**: `INTERNAL_SERVICE_KEY: "hardcoded_secret_123"` in `docker-compose.yml`.

### 2. Information Exposure (CWE-200)
- **Endpoint**: `/internal/info` in Trading Data reveals environment variables (`DB_USER`, `DB_NAME`).
- **Error Handling**: Raw exception strings `str(e)` returned in health and seeding endpoints.

### 3. Supply Chain (Vulnerable Dependencies)
- **PyYAML==5.3.1**: Remote Code Execution (RCE) via unsafe loading.
- **requests==2.21.0**: Credential leak via redirects (CVE-2018-18074).
- **uvicorn==0.20.0**: HTTP Request Smuggling vulnerability.

##  Code Style
- **Python**: Follow PEP 8. Use Flask for UI and FastAPI for calculators.
- **Security**: Maintain the "vulnerable" state unless explicitly asked to demonstrate a patch.