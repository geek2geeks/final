FROM node:18-alpine

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json ./
COPY pnpm-lock.yaml ./

# Copy workspace configuration
COPY pnpm-workspace.yaml ./

# Copy packages directory for shared dependencies
COPY packages ./packages

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy application source
COPY apps/web ./

# Expose port
EXPOSE 3000

# Start command
CMD ["pnpm", "run", "dev"]