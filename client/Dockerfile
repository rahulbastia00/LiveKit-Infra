
# ==========================================
# Base image
# ==========================================
FROM node:20-alpine AS base

# Enable pnpm through Corepack
RUN corepack enable


# ==========================================
# Stage 1: Install dependencies
# ==========================================
FROM base AS deps

RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy dependency manifests
COPY package.json pnpm-lock.yaml ./

# Install exact dependencies from the lockfile
RUN pnpm install --frozen-lockfile


# ==========================================
# Stage 2: Build Next.js application
# ==========================================
FROM base AS builder

WORKDIR /app

# Frontend environment variable supplied by Docker Compose
ARG NEXT_PUBLIC_SHOW_SETTINGS_MENU=true
ENV NEXT_PUBLIC_SHOW_SETTINGS_MENU=${NEXT_PUBLIC_SHOW_SETTINGS_MENU}

ENV NEXT_TELEMETRY_DISABLED=1

# Copy installed dependencies
COPY --from=deps /app/node_modules ./node_modules

# Copy application source
COPY . .

# Build the production application
RUN pnpm build


# ==========================================
# Stage 3: Production runner
# ==========================================
FROM base AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV NEXT_PUBLIC_SHOW_SETTINGS_MENU=true
ENV PORT=3000

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy production application
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Run as non-root user
USER nextjs

EXPOSE 3000

# Start Next.js production server
CMD ["npm", "start"]
