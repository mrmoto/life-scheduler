# =============================================================================
# Life Scheduler - Multi-Stage Dockerfile
# =============================================================================
# Three-stage build for proper dev/prod separation (ADR-013)
# - Stage 1 (base): Runtime dependencies only
# - Stage 2 (development): Base + complete dev toolchain
# - Stage 3 (production): Base + production optimizations

# =============================================================================
# Stage 1: Base (Runtime Dependencies)
# =============================================================================
FROM python:3.12-slim AS base

WORKDIR /app

# Install runtime system dependencies (minimal)
RUN apt-get update && apt-get install -y \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python runtime dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# =============================================================================
# Stage 2: Development (Base + COMPLETE Dev Toolchain)
# =============================================================================
FROM base AS development

# Install COMPREHENSIVE development toolchain (ADR-005, ADR-011, ADR-013)
# NO GAPS. Every tool needed for Python/Flask/PostgreSQL/Docker development.
RUN apt-get update && apt-get install -y \
    # Version Control
    git \
    # Build Tools & Compilation
    build-essential \
    pkg-config \
    libpq-dev \
    libffi-dev \
    libssl-dev \
    python3-dev \
    # Network Diagnostics
    net-tools \
    iproute2 \
    dnsutils \
    iputils-ping \
    traceroute \
    telnet \
    netcat-openbsd \
    # Process & System Monitoring
    procps \
    htop \
    lsof \
    strace \
    # HTTP/API Testing
    curl \
    wget \
    httpie \
    # Database Tools
    postgresql-client \
    postgresql-contrib \
    # Text Editors
    vim \
    nano \
    # Data Processing
    jq \
    less \
    # File Management
    tree \
    file \
    zip \
    unzip \
    # Security & SSL
    openssl \
    ca-certificates \
    # General Utilities
    man-db \
    bash-completion \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install dev-only Python packages
COPY requirements-dev.txt .
RUN pip install --no-cache-dir -r requirements-dev.txt

# Copy application code (volume mount will override in dev)
COPY . .

EXPOSE 5000
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]

# =============================================================================
# Stage 3: Production (Base + Prod Optimizations)
# =============================================================================
FROM base AS production

# Install production WSGI server
RUN pip install --no-cache-dir gunicorn==21.2.0

# Copy application code
COPY . .

# Create non-root user for security
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:create_app()"]
