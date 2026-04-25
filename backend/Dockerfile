# ── EduTailor Backend Dockerfile ──────────────────────────────
FROM python:3.11-slim

# System dependencies for Manim (Text() only — no LaTeX needed)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libcairo2-dev \
    libpango1.0-dev \
    pkg-config \
    python3-dev \
    gcc \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first (layer caching — only reinstalls if requirements change)
COPY requirements.txt .
RUN pip install --no-cache-dir --timeout=3000 -r requirements.txt

# Copy backend source code
COPY . .

# Create media directories
RUN mkdir -p media/animations media/audio media/diagrams media/lectures media/profiles

# Expose Flask port
EXPOSE 5000

# Run Flask
CMD ["python", "app.py"]
