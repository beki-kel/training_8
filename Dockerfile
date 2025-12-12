# ══════════════════════════════════════════════════════════
# Current - Production Dockerfile
# ══════════════════════════════════════════════════════════
# Multi-stage build for optimized production image
#
# Build: docker build -t current .
# Run:   docker run -p 5000:5000 --env-file .env current
# ══════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────
# Stage 1: Dependencies
# ─────────────────────────────────────────────────────────
FROM node:20-alpine AS deps

# Install build dependencies for native modules (bcrypt)
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install all dependencies (including dev for build)
RUN npm ci

# ─────────────────────────────────────────────────────────
# Stage 2: Builder
# ─────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build the application
RUN npm run build

# ─────────────────────────────────────────────────────────
# Stage 3: Production
# ─────────────────────────────────────────────────────────
FROM node:20-alpine AS production

# Install runtime dependencies for native modules
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 current

# Copy package files
COPY package.json package-lock.json ./

# Install production dependencies only
RUN npm ci --omit=dev \
    && npm cache clean --force

# Remove build tools after native module compilation
RUN apk del python3 make g++

# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/client ./client

# Copy healthcheck script
COPY scripts/healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

# Set ownership
RUN chown -R current:nodejs /app

# Switch to non-root user
USER current

# Environment defaults
ENV NODE_ENV=production
ENV PORT=5000
ENV HOST=0.0.0.0

# Expose port
EXPOSE 5000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD /healthcheck.sh

# Start the application
CMD ["node", "dist/index.js"]
