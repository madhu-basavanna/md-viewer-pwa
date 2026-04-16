# ── Stage 1: deps ────────────────────────────────────────────────────────────
FROM node:22-alpine AS deps
LABEL org.opencontainers.image.source="https://github.com/madhu-basavanna/md-viewer-pwa"
WORKDIR /app

# Copy only the manifest first so this layer is cached unless deps change
COPY .npmrc package.json package-lock.json ./
RUN npm ci --frozen-lockfile

# ── Stage 2: builder ─────────────────────────────────────────────────────────
FROM node:22-alpine AS builder
WORKDIR /app

# Bring in installed node_modules from the deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy the rest of the source and build
COPY . .
RUN npm run build

# ── Stage 3: runner (nginx static server) ────────────────────────────────────
FROM nginx:1.27-alpine AS runner

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built assets
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx config (SPA routing + PWA headers)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
