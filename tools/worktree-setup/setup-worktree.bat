@echo off
REM QuizzTok Worktree Setup Script for Windows
REM This script sets up Git worktrees for parallel BMAD agent development

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR%..\..\"

REM Check if Git is available
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git is not installed or not in PATH
    exit /b 1
)

REM Function to display help
:show_help
echo QuizzTok Worktree Setup Script for Windows
echo.
echo Usage: %0 [COMMAND] [OPTIONS]
echo.
echo Commands:
echo   create ^<branch-name^> ^<description^>  Create a new worktree
echo   list                                 List existing worktrees
echo   remove ^<path^>                        Remove a worktree
echo   help                                 Show this help message
echo.
echo Examples:
echo   %0 create feature/epic-1-auth "Epic 1: Authentication System"
echo   %0 list
echo   %0 remove ..\quizztok-feature-epic-1-auth
goto :eof

REM Function to create worktree
:create_worktree
set "branch_name=%~1"
set "feature_description=%~2"
set "worktree_path=..\quizztok-%branch_name%"

echo [INFO] Creating worktree for feature: %feature_description%

REM Create branch if it doesn't exist
git show-ref --verify --quiet refs/heads/%branch_name% >nul 2>&1
if errorlevel 1 (
    echo [INFO] Creating new branch: %branch_name%
    git branch %branch_name%
)

REM Check if worktree directory exists
if exist "%worktree_path%" (
    echo [WARNING] Worktree directory already exists: %worktree_path%
    set /p "remove_existing=Do you want to remove it and recreate? (y/N): "
    if /i "!remove_existing!"=="y" (
        rmdir /s /q "%worktree_path%"
    ) else (
        echo [ERROR] Aborted.
        goto :eof
    )
)

REM Create worktree
git worktree add "%worktree_path%" %branch_name%

REM Copy BMAD configuration if it exists
if exist ".bmad-core" (
    echo [INFO] Copying BMAD configuration to worktree...
    xcopy /e /i /q ".bmad-core" "%worktree_path%\.bmad-core"
)

echo [INFO] Worktree created successfully!
echo [INFO] Path: %worktree_path%
echo [INFO] Branch: %branch_name%
echo.
echo [INFO] Next steps:
echo   1. cd %worktree_path%
echo   2. Start your BMAD agent development
echo   3. Use 'git add && git commit' to save progress
echo   4. Use 'git push -u origin %branch_name%' to push changes
goto :eof

REM Function to list worktrees
:list_worktrees
echo [INFO] Existing worktrees:
git worktree list
goto :eof

REM Function to remove worktree
:remove_worktree
set "worktree_path=%~1"
if "%worktree_path%"=="" (
    echo [ERROR] Please specify the worktree path to remove
    goto :eof
)

echo [WARNING] Removing worktree: %worktree_path%
git worktree remove "%worktree_path%"
echo [INFO] Worktree removed successfully!
goto :eof

REM Main script logic
cd /d "%ROOT_DIR%"

set "command=%~1"
if "%command%"=="" set "command=help"

if "%command%"=="create" (
    if "%~2"=="" (
        echo [ERROR] Usage: %0 create ^<branch-name^> ^<description^>
        exit /b 1
    )
    call :create_worktree "%~2" "%~3"
) else if "%command%"=="list" (
    call :list_worktrees
) else if "%command%"=="remove" (
    if "%~2"=="" (
        echo [ERROR] Usage: %0 remove ^<worktree-path^>
        exit /b 1
    )
    call :remove_worktree "%~2"
) else (
    call :show_help
)