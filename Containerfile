# Stage 1: Builder (Downloads and extracts the binary)
FROM debian:trixie-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates tar
# Download the generic Linux binary directly from Ookla
RUN curl -L -o speedtest.tgz https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz \
    && tar xzvf speedtest.tgz -C /usr/local/bin speedtest

# Stage 2: Final Image (Minimal and Secure)
FROM debian:trixie-slim

# Install only the required runtime dependency
RUN apt-get update && apt-get install -y --no-install-recommends tzdata ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy only the compiled binary from the builder stage
COPY --from=builder /usr/local/bin/speedtest /usr/local/bin/speedtest

# Create a non-root user and prepare directories
RUN useradd -m -s /bin/bash speedtestuser \
    && mkdir -p /usr/local/speedtest-data \
    && chown -R speedtestuser:speedtestuser /usr/local/speedtest-data

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown speedtestuser:speedtestuser /entrypoint.sh

# Switch to the non-root user
USER speedtestuser

ENV TZ="Europe/Prague"
# Replaced cron syntax with seconds (10 minutes = 600 seconds)
ENV SPEEDTEST_INTERVAL="600"
ENV SPEEDTEST_ARGS=""

ENTRYPOINT ["/entrypoint.sh"]