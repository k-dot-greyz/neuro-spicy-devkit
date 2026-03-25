# Hardened OpenClaw Container
# Multi-stage build — minimal attack surface, non-root, read-only rootfs

# ============================================================
# Stage 1: Install dependencies in a throwaway build layer
# ============================================================
FROM node:22-alpine AS builder

RUN npm install -g openclaw@latest && \
    npm cache clean --force

# ============================================================
# Stage 2: Production image — hardened
# ============================================================
FROM node:22-alpine

LABEL maintainer="Neuro-Spicy DevKit <https://github.com/k-dot-greyz/neuro-spicy-devkit>"
LABEL description="Hardened OpenClaw AI coding assistant container"

# --- System hardening ---
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        tini \
        curl \
        git \
        dumb-init && \
    # Remove apk cache and package manager to reduce attack surface
    rm -rf /var/cache/apk/* /tmp/* /root/.npm

# --- Non-root user ---
RUN addgroup -g 1001 -S openclaw && \
    adduser -u 1001 -S -G openclaw -h /home/openclaw -s /bin/sh openclaw

# --- Copy openclaw from builder ---
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=builder /usr/local/bin/openclaw /usr/local/bin/openclaw

# --- Create required directories with correct ownership ---
RUN mkdir -p /home/openclaw/.openclaw/workspace \
             /home/openclaw/.openclaw/logs \
             /home/openclaw/.openclaw/data \
             /home/openclaw/.openclaw/plugins && \
    chown -R openclaw:openclaw /home/openclaw

# --- Copy default config templates (overridden by volume mounts) ---
COPY openclaw.json /home/openclaw/.openclaw/openclaw.json.default
COPY workspace/ /home/openclaw/.openclaw/workspace.default/
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown -R openclaw:openclaw /home/openclaw/.openclaw

# --- Security: drop all capabilities, prevent escalation ---
# (enforced at compose level, but document intent here)

# --- Switch to non-root user ---
USER openclaw
WORKDIR /home/openclaw

# --- Environment ---
ENV NODE_ENV=production
ENV OPENCLAW_HOME=/home/openclaw/.openclaw
ENV OPENCLAW_GATEWAY_HOST=0.0.0.0
ENV OPENCLAW_GATEWAY_PORT=18789

# --- Health check ---
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -sf http://localhost:${OPENCLAW_GATEWAY_PORT}/health || exit 1

# --- Expose gateway port ---
EXPOSE ${OPENCLAW_GATEWAY_PORT}

# --- Use tini as init system (proper signal handling + zombie reaping) ---
ENTRYPOINT ["tini", "--", "docker-entrypoint.sh"]
CMD ["openclaw", "gateway", "--port", "18789"]
