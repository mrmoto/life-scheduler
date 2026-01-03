# Life Scheduler

Personal deadline and task management for life administration (property taxes, insurance renewals, recurring obligations).

## Prerequisites

**Required**:
- Docker Desktop or OrbStack (macOS)
- VSCode or Cursor IDE
- Dev Containers extension for VSCode/Cursor
- Git

**NOT Required**:
- ❌ Local Python installation (development happens inside containers)
- ❌ Local PostgreSQL (runs in Docker container)
- ❌ Python virtual environment (venv)

## Development Setup

### First Time Setup

1. **Clone repository**:
   ```bash
   git clone <repo-url>
   cd life-scheduler
   ```

2. **Create environment file**:
   ```bash
   cp .env.example .env
   # Edit .env with your values (or use generated secure defaults)
   ```

3. **Start containers** (optional helper script):
   ```bash
   ./dev-session-start.sh
   ```
   
   Or manually:
   ```bash
   docker compose up -d
   ```

4. **Open in Cursor**:
   ```bash
   cursor Life-Scheduler.code-workspace
   ```

5. **Attach to container**:
   - Cursor will prompt: "Reopen in Container?"
   - Click "Yes"
   - First time: Builds container (2-3 minutes)
   - Subsequent times: Fast startup (<30 seconds)

6. **You're now inside the container!**
   - Terminal prompt shows container environment
   - All commands run inside container automatically

### Development Commands (Inside Container)

```bash
# Run tests
pytest

# Run tests with coverage
pytest --cov=app --cov-report=term

# Start Flask development server
flask run

# Apply database migrations
alembic upgrade head

# Create new migration
alembic revision --autogenerate -m "description"

# Check Python version (should be 3.12)
python --version

# Run linters
mypy app/
black app/
flake8 app/
```

### Stopping Development Session

```bash
# From your Mac (outside container):
./dev-session-stop.sh

# Or manually:
docker compose down
```

**Note**: Database data persists in Docker volume `postgres_data`. Your source files sync automatically via volume mount.

## Why Dev Containers?

Development happens inside the same container that runs in production:
- ✅ Your Python = Production Python (same image)
- ✅ Your packages = Production packages (same requirements.txt)
- ✅ Zero "works on my machine" issues
- ✅ Perfect environment parity

See [ADR-011](mnt/project/docs/agent-training-(link)/DECISIONS.md) for full rationale.

