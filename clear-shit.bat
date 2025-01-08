@echo off
setlocal enabledelayedexpansion

REM Check if directory parameters are provided, and if not, use the current directory
if "%~1"=="" (
    set TARGET_DIR=.
) else (
    set TARGET_DIR=%~1
)

REM Use for loop to find and delete .DS_Store files
for /r "%TARGET_DIR%" %%f in (.DS_Store) do (
    del /f /q "%%f" 2>nul
)

REM Optionally, you can comment out or remove the following line to avoid any output
echo All shits have been deleted.
