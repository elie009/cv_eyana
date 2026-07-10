# syntax=docker/dockerfile:1.7
ARG NODE_VERSION=24
FROM node:${NODE_VERSION}-slim AS runtime

WORKDIR /app
ENV NODE_ENV="production" \
    PORT=3000 \
    LOCAL_STORAGE_PATH=/app/data

RUN mkdir -p /app/apps/server /app/apps/web /app/data && chown node:node /app/data

# Accept the workspace files directly from the runner environment
COPY --chown=node:node . .

USER node
EXPOSE 3000/tcp

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ["node", "-e", "fetch(`http://127.0.0.1:${process.env.PORT ?? 3000}/api/health`).then((r) => { if (!r.ok) process.exit(1); }).catch(() => process.exit(1));"]

CMD ["node", "apps/server/dist/index.mjs"]
