
# ==========================================
# Base image
# ==========================================
ARG NODE_IMAGE=node:20-alpine
FROM ${NODE_IMAGE} AS base

# Enable pnpm through Corepack
RUN apk upgrade --no-cache \
	&& corepack enable


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
# Stage 3: Production dependencies
# ==========================================
FROM base AS prod-deps

WORKDIR /app

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile --prod


# ==========================================
# Stage 4: Production runner
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
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx

# Copy production application
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=prod-deps --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json

# Run as non-root user
USER nextjs

EXPOSE 3000

# Start Next.js production server
CMD ["node_modules/.bin/next", "start"]
