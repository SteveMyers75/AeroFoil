FROM python:3.11-alpine

ARG AEROFOIL_VERSION

ENV AEROFOIL_VERSION="${AEROFOIL_VERSION}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Runtime packages
RUN apk add --no-cache \
    bash \
    git \
    sudo \
    jpeg \
    zlib \
    libffi \
    cairo \
    pango \
    gdk-pixbuf

# Build dependencies for Python packages with native extensions
RUN apk add --no-cache --virtual .build-deps \
    build-base \
    gcc \
    musl-dev \
    jpeg-dev \
    zlib-dev \
    libffi-dev \
    cairo-dev \
    pango-dev \
    gdk-pixbuf-dev

# Install Python dependencies first for better layer caching
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip \
    && pip install --requirement /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt

# Remove build dependencies after wheels/extensions are installed
RUN apk del .build-deps

# Copy app code after dependencies
COPY ./app /app
COPY ./docker/run.sh /app/run.sh

# Normalize line endings and make entrypoint executable
RUN sed -i 's/\r$//' /app/run.sh \
    && chmod +x /app/run.sh \
    && mkdir -p /app/data

ENTRYPOINT ["/app/run.sh"]