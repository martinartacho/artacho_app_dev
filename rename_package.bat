@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   RENOMBRAR PACKAGE ANDROID FLUTTER
echo ========================================
set "PROJECT_DIR=%cd%"
echo Proyecto: %PROJECT_DIR%

:: === PEDIR VALORES ===
set /p OLD_PACKAGE="Introduce el package actual (ej: com.artacho.app): "
set /p NEW_PACKAGE="Introduce el package nuevo (ej: com.artacho.appdev): "

if "%OLD_PACKAGE%"=="" (
    echo ❌ Package actual vacío. Abortando.
    exit /b 1
)
if "%NEW_PACKAGE%"=="" (
    echo ❌ Package nuevo vacío. Abortando.
    exit /b 1
)

:: === MODO SIMULACIÓN ===
set /p SIMULATE="¿Quieres ejecutar en modo simulación? (s/n): "
if /i "%SIMULATE%"=="s" (
    set "DRY_RUN=1"
) else (
    set "DRY_RUN=0"
)

:: === RESUMEN ===
echo.
echo Cambiar:
echo    %OLD_PACKAGE%
echo por:
echo    %NEW_PACKAGE%
set /p CONFIRM="¿Seguro que quieres continuar? (s/n): "
if /i not "%CONFIRM%"=="s" exit /b 0

:: === BACKUP (solo si NO es simulación) ===
if "%DRY_RUN%"=="0" (
    set "BACKUP_DIR=%PROJECT_DIR%\package_backup_%date:~6,4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%"
    mkdir "%BACKUP_DIR%" >nul 2>&1
    echo Creando backup en: %BACKUP_DIR%
    for %%F in (
        android\app\build.gradle.kts
        android\app\src\main\AndroidManifest.xml
    ) do (
        if exist "%%F" copy "%%F" "%BACKUP_DIR%" >nul
    )
)

:: === REEMPLAZO DE TEXTO ===
echo.
echo Buscando y reemplazando en archivos...
for /r "%PROJECT_DIR%" %%F in (*.kt *.kts *.xml) do (
    if "%DRY_RUN%"=="1" (
        findstr /c:"%OLD_PACKAGE%" "%%F" >nul && echo [SIMULACION] Cambiaria: %%F
    ) else (
        powershell -Command "(Get-Content '%%F') -replace '\b%OLD_PACKAGE%\b', '%NEW_PACKAGE%' | Set-Content '%%F'"
    )
)

:: === RENOMBRAR CARPETAS KOTLIN ===
echo.
echo Renombrando carpetas de código...
set "OLD_PATH=%OLD_PACKAGE:.=\%"
set "NEW_PATH=%NEW_PACKAGE:.=\%"
set "SRC_DIR=android\app\src\main\kotlin"
set "OLD_DIR=%SRC_DIR%\%OLD_PATH%"
set "NEW_DIR=%SRC_DIR%\%NEW_PATH%"

if exist "%OLD_DIR%" (
    if "%DRY_RUN%"=="1" (
        echo [SIMULACION] Renombraría "%OLD_DIR%" a "%NEW_DIR%"
    ) else (
        mkdir "%NEW_DIR%" >nul 2>&1
        xcopy "%OLD_DIR%" "%NEW_DIR%" /E /I /Y >nul
        rmdir /S /Q "%OLD_DIR%"
    )
) else (
    echo ⚠ No se encontró la carpeta Kotlin para %OLD_PACKAGE%.
)

:: === FINAL ===
echo.
echo ========================================
if "%DRY_RUN%"=="1" (
    echo   SIMULACIÓN COMPLETADA - No se hicieron cambios
) else (
    echo   PROCESO COMPLETADO
    echo - Backup en: %BACKUP_DIR%
    echo - Ahora debes:
    echo   1. Reemplazar android/app/google-services.json por el de Firebase para %NEW_PACKAGE%
    echo   2. Revisar assets/.env si aplica.
    echo   3. Ejecutar:
    echo        flutter clean
    echo        flutter pub get
    echo   4. Probar compilación antes de generar el .aab
)
echo ========================================
pause
