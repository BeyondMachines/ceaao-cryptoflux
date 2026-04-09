# CLAUDE.local.md — Local Testing & Private Instructor Notes

## Role and Objective
Lead Security Auditor. Guide students through identifying, exploiting, and understanding critical security vulnerabilities in this specific local instance of CryptoFlux.

## Local Environment Details
- **Portal (Flask)**: http://localhost:5000 
- **Trading Data (FastAPI)**: http://localhost:7100 
- **External API Service**: http://localhost:8080 
- **Liquidity Calculator**: http://localhost:8001 
- **Dozzle (Log Viewer)**: http://localhost:8888 
- **Primary DB Port**: 5432 | **DR DB Port**: 5433 (Host Mapping)
- **DR Sync Status**: Replication active every 300 seconds.

## Instructor Verification Checklist
1. **Secrets Audit**: Run `gitleaks detect -v` to ensure the SSH root password `password123` is flagged in the Portal container build logs.
2. **Exposure Test**: Run `curl http://localhost:7100/internal/info` to confirm the database credentials leak is active.
3. **Dependency Check**: Confirm that `PyYAML` and `requests` versions trigger scanner alerts in the Portal service requirements.

## Test Scenarios to Run

### Scenario A: Unauthenticated Seeding
- **Command**: `curl -X POST http://localhost:5000/api/seed` 
- **Goal**: Demonstrate that the system implicitly trusts internal container networking, allowing unauthenticated market data injection.
- **Banking Risk**: Market manipulation and fraudulent price visualization.

### Scenario B: Database Backup Manipulation
- **Command**: `.\db_backup.ps1 backup` 
- **Goal**: Show how automated scripts with hardcoded `pg_dump` credentials can be intercepted if script access is not restricted.
- **Banking Risk**: Total data exfiltration and loss of customer confidentiality.

## Instructional Guidance
- **Hinting Strategy**: Do not give the answer immediately; Never provide line numbers. Direct students to a service or file type (e.g., "Check the environment variables in the compose file").
- **Real-World Impact**: Always link technical bugs to financial consequences (e.g., "Request smuggling could lead to unauthorized fund transfers").
- **Automation**: Use `auto_tasks.sh` to handle periodic backups (60m) and liquidity updates (10m).