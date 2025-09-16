# Worktree Setup Scripts

These scripts help set up Git worktrees for parallel BMAD agent development in the QuizzTok project.

## What are Git Worktrees?

Git worktrees allow you to have multiple working directories from the same repository, each with different branches checked out. This is perfect for BMAD agent development where you might want to work on multiple features simultaneously.

## Usage

### Linux/macOS
```bash
# Make script executable
chmod +x tools/worktree-setup/setup-worktree.sh

# Create a new worktree
./tools/worktree-setup/setup-worktree.sh create feature/epic-1-auth "Epic 1: Authentication System"

# List existing worktrees
./tools/worktree-setup/setup-worktree.sh list

# Remove a worktree
./tools/worktree-setup/setup-worktree.sh remove ../quizztok-feature-epic-1-auth
```

### Windows
```cmd
REM Create a new worktree
tools\worktree-setup\setup-worktree.bat create feature/epic-1-auth "Epic 1: Authentication System"

REM List existing worktrees
tools\worktree-setup\setup-worktree.bat list

REM Remove a worktree
tools\worktree-setup\setup-worktree.bat remove ..\quizztok-feature-epic-1-auth
```

## Benefits for BMAD Development

1. **Parallel Development**: Work on multiple stories/epics simultaneously
2. **Isolation**: Each worktree has its own working directory and branch
3. **BMAD Integration**: Scripts automatically copy `.bmad-core` configuration
4. **Easy Switching**: No need to stash/commit changes when switching contexts

## Example Workflow

1. Create a worktree for Epic 1:
   ```bash
   ./tools/worktree-setup/setup-worktree.sh create feature/epic-1-foundation "Epic 1: Foundation Setup"
   ```

2. Navigate to the new worktree:
   ```bash
   cd ../quizztok-feature-epic-1-foundation
   ```

3. Start BMAD agent development:
   ```bash
   # Your BMAD commands here
   /BMad:agents:dev
   ```

4. Commit and push when ready:
   ```bash
   git add .
   git commit -m "feat(foundation): implement initial monorepo structure"
   git push -u origin feature/epic-1-foundation
   ```

## Clean Up

When you're done with a feature branch:

1. Remove the worktree:
   ```bash
   ./tools/worktree-setup/setup-worktree.sh remove ../quizztok-feature-epic-1-foundation
   ```

2. Delete the remote branch (if needed):
   ```bash
   git push origin --delete feature/epic-1-foundation
   git branch -d feature/epic-1-foundation
   ```