# Use a minimal but compatible base image
FROM node:23.3.0-slim AS builder

# Install necessary build tools
RUN apt-get update && apt-get install -y \
    git python3 make g++ \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install PNPM globally
RUN npm install -g pnpm@9.4.0

# Copy package-related files first
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc turbo.json ./

# Copy the full source code
COPY agent ./agent
COPY client ./client
COPY packages ./packages
COPY scripts ./scripts
COPY characters ./characters

# Install dependencies **only for root and client**
RUN pnpm install -r --frozen-lockfile

# Build the project and prune unnecessary files
RUN pnpm build-docker \
    && pnpm prune --prod


# Final runtime image
FROM node:23.3.0-slim

# Install only necessary runtime dependencies
RUN apt-get update && apt-get install -y git python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for security
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Set working directory
WORKDIR /app

# Copy production files
COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-workspace.yaml ./
COPY --from=builder /app/.npmrc ./
COPY --from=builder /app/turbo.json ./
COPY --from=builder /app/node_modules ./node_modules

# Copy only necessary built application files
COPY --from=builder /app/agent ./agent
COPY --from=builder /app/client ./client
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/characters ./characters

# Switch to non-root user
USER appuser

# Expose necessary ports
EXPOSE 8080 5173

# Start the application
CMD ["pnpm", "start"]
