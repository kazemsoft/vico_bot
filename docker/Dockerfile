# ────────────────────────────────────────────────
# Builder stage
FROM thevlang/vlang:alpine AS builder

WORKDIR /build
COPY v.mod v.sum* ./
RUN v install
COPY src/ ./src/
COPY *.v *.vv ./
RUN v -prod -cflags "-Os -flto -s" -o /build/vicobot .

# Ensure the binary is executable
RUN chmod +x /build/vicobot

# ────────────────────────────────────────────────
# Final stage - Alpine with minimal setup
FROM alpine

# Install CA certificates, create user, and add su-exec for permission fixing
RUN apk add --no-cache ca-certificates bash curl coreutils su-exec
RUN addgroup -S vicobot && adduser -S vicobot -G vicobot

# Copy necessary files from builder
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /build/vicobot /vicobot

# Set up environment
ENV USER=vicobot
ENV HOME=/home/vicobot
ENV VICOBOT_HOME=/home/vicobot/.vicobot

# Set workdir and create home directory
WORKDIR /home/vicobot
RUN mkdir -p /home/vicobot/.vicobot && chown -R vicobot:vicobot /home/vicobot

# Run onboard to create default config and workspace
USER vicobot
RUN /vicobot onboard

# Switch back to root for entrypoint setup
USER root

# Copy entrypoint script for runtime environment variable substitution
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Start as root to fix mounted volume permissions, entrypoint drops to vicobot
ENTRYPOINT ["/entrypoint.sh"]
CMD ["gateway"]
