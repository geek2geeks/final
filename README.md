# QuizzTok - TikTok Quiz Game Platform

A modern monorepo-based platform for creating interactive quiz games from TikTok content, built with Next.js 14, NestJS 10, and Turborepo.

## 🏗️ Architecture

This project follows a monorepo architecture with:

- **Frontend**: Next.js 14 with TypeScript, Tailwind CSS, and Mantine UI
- **Backend**: NestJS 10 with TypeScript, Prisma, and Redis
- **Shared Packages**: Reusable components, types, and utilities
- **Infrastructure**: Docker, Kubernetes, and Terraform configurations

## 📁 Project Structure

```
quizztok/
├── apps/
│   ├── web/                     # Next.js 14 frontend (port 3000)
│   └── api/                     # NestJS 10 backend (port 3001)
├── packages/
│   ├── shared-types/            # TypeScript interfaces
│   ├── game-engine/             # Core game logic
│   ├── tiktok-connector/        # TikTok API wrapper
│   ├── ui-components/           # Shared React components
│   └── redis-client/            # Redis utilities
├── infrastructure/              # Deployment configurations
├── tools/                       # Development tools
└── docs/                        # Documentation
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- pnpm 8+
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd quizztok
   ```

2. **Install dependencies**
   ```bash
   pnpm install
   ```

3. **Start development servers**
   ```bash
   # Start all applications
   pnpm dev

   # Or start individual apps
   pnpm --filter web dev        # Frontend only
   pnpm --filter api dev        # Backend only
   ```

4. **Access the applications**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:3001

## 📜 Available Scripts

### Root Level Commands

```bash
# Development
pnpm dev              # Start all apps in development mode
pnpm build            # Build all packages and apps
pnpm lint             # Run ESLint across all packages
pnpm type-check       # Run TypeScript checks
pnpm test             # Run tests across all packages

# Formatting
pnpm format           # Format all files with Prettier

# Individual package commands
pnpm --filter web dev                    # Run web app only
pnpm --filter api dev                    # Run API only
pnpm --filter @quizztok/shared-types build  # Build shared types
```

### Package-Specific Commands

```bash
# Web App (Next.js)
cd apps/web
pnpm dev              # Development server
pnpm build            # Production build
pnpm start            # Start production server
pnpm lint             # Lint web app
pnpm type-check       # TypeScript check

# API (NestJS)
cd apps/api
pnpm dev              # Development server with hot reload
pnpm build            # Production build
pnpm start            # Start production server
pnpm test             # Run unit tests
pnpm test:e2e         # Run e2e tests
```

## 🛠️ Development Workflow

### Git Worktrees for Parallel Development

This project includes scripts for Git worktree management, perfect for BMAD agent development:

```bash
# Create a new worktree for feature development
./tools/worktree-setup/setup-worktree.sh create feature/epic-1-auth "Epic 1: Authentication"

# List existing worktrees
./tools/worktree-setup/setup-worktree.sh list

# Remove a worktree when done
./tools/worktree-setup/setup-worktree.sh remove ../quizztok-feature-epic-1-auth
```

For Windows users, use the `.bat` equivalent scripts in the same directory.

### Code Quality

The project enforces strict code quality standards:

- **TypeScript**: Strict mode enabled with comprehensive type checking
- **ESLint**: Consistent code style and best practices
- **Prettier**: Automatic code formatting
- **Husky**: Pre-commit hooks prevent bad code from being committed
- **Lint-staged**: Only lints changed files for faster commits

### Pre-commit Hooks

Every commit automatically:
1. Runs ESLint with auto-fix on staged files
2. Formats code with Prettier
3. Runs TypeScript type checking
4. Prevents commit if any checks fail

## 🏗️ Building and Deploying

### Local Build

```bash
# Build all packages and applications
pnpm build

# Build specific package
pnpm --filter @quizztok/shared-types build
pnpm --filter web build
pnpm --filter api build
```

### Production Deployment

The monorepo is configured for deployment on:
- **Frontend**: Vercel (recommended for Next.js)
- **Backend**: Heroku or any Node.js hosting platform
- **Database**: PostgreSQL 15
- **Cache**: Redis 7

## 🧪 Testing

```bash
# Run all tests
pnpm test

# Run tests for specific package
pnpm --filter api test
pnpm --filter @quizztok/game-engine test

# Run tests with coverage
pnpm --filter api test:cov

# Run e2e tests
pnpm --filter api test:e2e
```

## 📋 Technology Stack

### Frontend
- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript 5.0+
- **Styling**: Tailwind CSS + Mantine UI
- **State Management**: Zustand
- **Animations**: Framer Motion

### Backend
- **Framework**: NestJS 10
- **Language**: TypeScript 5.0+
- **Database**: PostgreSQL 15 + Prisma ORM
- **Cache**: Redis 7
- **Validation**: class-validator

### Development Tools
- **Monorepo**: Turborepo
- **Package Manager**: pnpm
- **Linting**: ESLint + Prettier
- **Git Hooks**: Husky
- **CI/CD**: GitHub Actions

## 🤝 Contributing

1. **Clone and setup**
   ```bash
   git clone <repo-url>
   cd quizztok
   pnpm install
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the existing code style
   - Add tests for new functionality
   - Update documentation as needed

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat(scope): your commit message"
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

### Commit Message Format

We follow [Conventional Commits](https://conventionalcommits.org/):

```
type(scope): description

feat(auth): add OAuth2 login
fix(game): resolve scoring calculation bug
docs(api): update endpoint documentation
```

## 📚 Documentation

- [Architecture Documentation](docs/architecture/)
- [API Documentation](docs/api/)
- [Development Guidelines](docs/development/)
- [Deployment Guide](docs/deployment/)

## 🔧 Troubleshooting

### Common Issues

1. **pnpm install fails**
   ```bash
   # Clear cache and reinstall
   pnpm store prune
   rm -rf node_modules pnpm-lock.yaml
   pnpm install
   ```

2. **TypeScript errors after updating**
   ```bash
   # Clean build artifacts
   pnpm clean
   pnpm build
   ```

3. **Husky hooks not working**
   ```bash
   # Reinstall husky
   npx husky install
   ```

### Getting Help

- Check the [documentation](docs/)
- Create an issue for bugs or feature requests
- Review existing issues and discussions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎯 Project Status

This is an active development project. Current focus:

- ✅ **Epic 1**: Foundation & Core Infrastructure
- 🚧 **Epic 2**: TikTok Integration & Real-time Pipeline
- 📋 **Epic 3**: Quiz Game Engine
- 📋 **Epic 4**: User Interface & Animations
- 📋 **Epic 5**: Monetization & Analytics

---

Built with ❤️ by the QuizzTok Team# QuizzTok Live - Production Ready
# 🚀 QuizzTok Live - Production Deployment Ready
