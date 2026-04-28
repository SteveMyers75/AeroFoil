FROM python:3.11-slim

ARG AEROFOIL_VERSION

ENV AEROFOIL_VERSION="${AEROFOIL_VERSION}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Runtime and build dependencies for Python packages with native extensions
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        git \
        sudo \
        build-essential \
        gcc \
        libc6-dev \
        libjpeg62-turbo \
        zlib1g \
        libffi8 \
        libcairo2 \
        libpango-1.0-0 \
        libgdk-pixbuf-2.0-0 \
        libjpeg62-turbo-dev \
        zlib1g-dev \
        libffi-dev \
        libcairo2-dev \
        libpango1.0-dev \
        libgdk-pixbuf-2.0-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies first for better layer caching
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip \
    && pip install --requirement /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt \
    && apt-get purge -y --auto-remove \
        build-essential \
        gcc \
        libc6-dev \
        libjpeg62-turbo-dev \
        zlib1g-dev \
        libffi-dev \
        libcairo2-dev \
        libpango1.0-dev \
        libgdk-pixbuf-2.0-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy app code after dependencies
COPY ./app /app
COPY ./docker/run.sh /app/run.sh

# Normalize line endings and make entrypoint executable
RUN sed -i 's/\r$//' /app/run.sh \
    && chmod +x /app/run.sh \
    && mkdir -p /app/data

ENTRYPOINT ["/app/run.sh"]
