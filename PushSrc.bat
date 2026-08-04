@echo off
setlocal enabledelayedexpansion

REM ==== Configuration par defaut ====
set DEFAULT_REPO_URL=https://github.com/Oct72Deb/FNF-Multivers-Collection.git

echo === Initialisation du depot Git (si necessaire) ===
if not exist ".git" (
    git init
)

echo === Verification de l'identite git ===
git config user.name >nul 2>&1
if errorlevel 1 (
    set /p GIT_NAME="Entrez votre nom pour git (ex: Octane): "
    git config --global user.name "!GIT_NAME!"
)
git config user.email >nul 2>&1
if errorlevel 1 (
    set /p GIT_EMAIL="Entrez votre email pour git (ex: vous@example.com): "
    git config --global user.email "!GIT_EMAIL!"
)

REM ==== Choix du repo distant ====
git remote get-url origin >nul 2>&1
if not errorlevel 1 (
    for /f "delims=" %%R in ('git remote get-url origin') do set CURRENT_REMOTE=%%R
    echo Remote "origin" actuel : !CURRENT_REMOTE!
) else (
    set CURRENT_REMOTE=
)

echo.
echo Repo par defaut : %DEFAULT_REPO_URL%
set /p REPO_URL="URL du repo distant (Entree = garder celui affiche ci-dessus / defaut) : "
if "!REPO_URL!"=="" (
    if not "!CURRENT_REMOTE!"=="" (
        set REPO_URL=!CURRENT_REMOTE!
    ) else (
        set REPO_URL=%DEFAULT_REPO_URL%
    )
)

echo === Configuration du remote "origin" ===
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    git remote add origin "!REPO_URL!"
) else (
    git remote set-url origin "!REPO_URL!"
)

REM ==== Choix de la branche ====
echo.
echo === Branches locales disponibles ===
git branch

for /f "delims=* " %%B in ('git branch --show-current 2^>nul') do set CURRENT_BRANCH=%%B
if "!CURRENT_BRANCH!"=="" set CURRENT_BRANCH=main

echo.
set /p BRANCH="Nom de la branche a utiliser (Entree = !CURRENT_BRANCH!) : "
if "!BRANCH!"=="" set BRANCH=!CURRENT_BRANCH!

REM Bascule sur la branche demandee si elle existe deja, sinon la cree
git rev-parse --verify "!BRANCH!" >nul 2>&1
if errorlevel 1 (
    echo La branche "!BRANCH!" n'existe pas encore, creation...
    git checkout -b "!BRANCH!"
) else (
    git checkout "!BRANCH!"
)

echo === Ajout des fichiers ===
git add .

echo === Commit ===
set /p COMMIT_MSG="Message de commit (Entree = 'Update') : "
if "!COMMIT_MSG!"=="" set COMMIT_MSG=Update
git commit -m "!COMMIT_MSG!"
if errorlevel 1 (
    echo.
    echo [INFO] Aucun nouveau changement a commit, ou erreur de commit.
)

REM ==== Synchronisation avec le distant (merge, pas d'ecrasement) ====
echo.
echo === Synchronisation avec origin/!BRANCH! ===
git fetch origin "!BRANCH!" >nul 2>&1
if not errorlevel 1 (
    git merge "origin/!BRANCH!" --no-edit
    if errorlevel 1 (
        echo.
        echo [ATTENTION] Conflit de fusion detecte.
        echo Resous les conflits manuellement, puis relance ce script pour finir le push.
        echo.
        pause
        exit /b 1
    ) else (
        echo Synchronisation OK : les fichiers non modifies localement ont ete conserves,
        echo seuls les fichiers changes ont ete mis a jour.
    )
) else (
    echo Pas de branche distante "!BRANCH!" existante, rien a synchroniser.
)

REM ==== Choix force ou non ====
echo.
echo Mode de push :
echo   1 = normal (git push)                     -- le plus sur, recommande apres synchronisation
echo   2 = force-with-lease                       -- ecrase, mais bloque si qqn a pousse entre-temps
echo   3 = force pur (--force)                    -- ecrase sans aucune verification, DANGEREUX
set /p PUSH_MODE="Choix (Entree = 1) : "
if "!PUSH_MODE!"=="" set PUSH_MODE=1

echo.
echo === Push vers !REPO_URL! (branche !BRANCH!) ===
if "!PUSH_MODE!"=="1" (
    git push -u origin "!BRANCH!"
) else if "!PUSH_MODE!"=="2" (
    git push -u origin "!BRANCH!" --force-with-lease
) else if "!PUSH_MODE!"=="3" (
    git push -u origin "!BRANCH!" --force
) else (
    echo Choix invalide, push normal utilise par defaut.
    git push -u origin "!BRANCH!"
)

if errorlevel 1 (
    echo.
    echo [ERREUR] Le push a echoue. Verifie le message d'erreur ci-dessus.
) else (
    echo.
    echo [OK] Push termine avec succes.
)

echo.
pause