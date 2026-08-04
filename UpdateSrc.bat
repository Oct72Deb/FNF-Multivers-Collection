@echo off
setlocal enabledelayedexpansion

REM ==== Configuration ====
set REPO_OWNER=Oct72Deb
set REPO_NAME=FNF-Multivers-Collection
set BRANCH=main
set VERSION_FILE=.local_version.txt
set TMP_ZIP=%TEMP%\%REPO_NAME%_update.zip
set TMP_DIR=%TEMP%\%REPO_NAME%_update_extract

echo === Verification des mises a jour disponibles ===

REM Recupere le hash du dernier commit distant (pas besoin de .git local)
for /f "tokens=1" %%H in ('git ls-remote https://github.com/%REPO_OWNER%/%REPO_NAME%.git %BRANCH% 2^>nul') do set REMOTE_HASH=%%H

if "!REMOTE_HASH!"=="" (
    echo [ERREUR] Impossible de contacter GitHub. Verifie ta connexion.
    echo.
    pause
    exit /b 1
)

REM Lit le hash enregistre localement (si existant)
set LOCAL_HASH=
if exist "%VERSION_FILE%" (
    for /f "delims=" %%L in (%VERSION_FILE%) do set LOCAL_HASH=%%L
)

if "!LOCAL_HASH!"=="!REMOTE_HASH!" (
    echo Ton code source est deja a jour.
    echo.
    pause
    exit /b 0
)

REM Recupere le message du dernier commit via l'API GitHub, pour affichage
set UPDATE_NAME=!REMOTE_HASH!
for /f "delims=" %%M in ('powershell -NoProfile -Command "try { (Invoke-RestMethod -Uri 'https://api.github.com/repos/%REPO_OWNER%/%REPO_NAME%/commits/%BRANCH%').commit.message.Split([Environment]::NewLine)[0] } catch { '' }"') do set UPDATE_NAME=%%M

echo.
echo === Mise a jour disponible ! ===
echo   "!UPDATE_NAME!"
echo.
set /p CONFIRM="Voulez-vous mettre a jour vers cette version ? (O/N) : "
if /i not "!CONFIRM!"=="O" (
    echo Mise a jour annulee.
    echo.
    pause
    exit /b 0
)

echo.
echo === Telechargement de la mise a jour ===
if exist "%TMP_ZIP%" del /q "%TMP_ZIP%"
curl -L -o "%TMP_ZIP%" "https://github.com/%REPO_OWNER%/%REPO_NAME%/archive/refs/heads/%BRANCH%.zip"
if errorlevel 1 (
    echo [ERREUR] Le telechargement a echoue.
    echo.
    pause
    exit /b 1
)

echo === Extraction ===
if exist "%TMP_DIR%" rmdir /s /q "%TMP_DIR%"
mkdir "%TMP_DIR%"
tar -xf "%TMP_ZIP%" -C "%TMP_DIR%"

REM Le zip GitHub extrait dans un sous-dossier du type REPO_NAME-BRANCH
for /d %%D in ("%TMP_DIR%\*") do set EXTRACTED_DIR=%%D

echo === Copie des fichiers modifies (les fichiers locaux non touches sont conserves) ===
robocopy "!EXTRACTED_DIR!" "." /E /XO /NFL /NDL /NJH /NJS
REM /XO = n'ecrase que si le fichier source est plus recent (evite d'ecraser des fichiers identiques)
REM Rien n'est supprime localement : les fichiers absents de la mise a jour restent intacts

echo !REMOTE_HASH!>"%VERSION_FILE%"

echo === Nettoyage ===
del /q "%TMP_ZIP%" >nul 2>&1
rmdir /s /q "%TMP_DIR%" >nul 2>&1

echo.
echo === Mise a jour terminee ! ===
echo.
pause
