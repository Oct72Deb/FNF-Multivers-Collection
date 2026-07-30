@echo off
setlocal

REM ==== Configuration ====
set REPO_URL=https://github.com/Oct72Deb/FNF-Multivers-Collection.git
set BRANCH=main

echo === Initialisation du depot Git (si necessaire) ===
if not exist ".git" (
    git init
)

echo === Verification de l'identite git ===
git config user.name >nul 2>&1
if errorlevel 1 (
    set /p GIT_NAME="Entrez votre nom pour git (ex: Octane): "
    git config --global user.name "%GIT_NAME%"
)
git config user.email >nul 2>&1
if errorlevel 1 (
    set /p GIT_EMAIL="Entrez votre email pour git (ex: vous@example.com): "
    git config --global user.email "%GIT_EMAIL%"
)

echo === Ajout des fichiers ===
git add .

echo === Commit ===
git commit -m "Initial commit"
if errorlevel 1 (
    echo.
    echo [INFO] Aucun nouveau changement a commit, ou erreur de commit.
    echo Verification si un commit existe deja...
)

echo === Renommage de la branche en %BRANCH% ===
git branch -M %BRANCH%

echo === Configuration du remote "origin" ===
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    git remote add origin %REPO_URL%
) else (
    git remote set-url origin %REPO_URL%
)

echo === Push vers GitHub (force) ===
git push -u origin %BRANCH% --force

if errorlevel 1 (
    echo.
    echo [ERREUR] Le push a echoue. Verifie le message d'erreur ci-dessus.
) else (
    echo.
    echo [OK] Push termine avec succes.
)

echo.
pause