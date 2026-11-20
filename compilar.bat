@echo off
setlocal
rem ------------------------------------------------------------
rem Compila o servidor (ninja, MSYS2 UCRT64) e troca o exe da raiz.
rem Uso:  compilar.bat            compila e troca o exe
rem       compilar.bat semtroca  so compila (exe novo fica em build\)
rem       compilar.bat nopause   nao espera tecla no final
rem ------------------------------------------------------------

set "ROOT=%~dp0"
set "MSYS=E:\msys64"
set "EXE=theforgottenserver.exe"
set "SWAP=1"
set "PAUSE=1"
for %%A in (%*) do (
    if /i "%%A"=="semtroca" set "SWAP=0"
    if /i "%%A"=="nopause" set "PAUSE=0"
)

if not exist "%MSYS%\usr\bin\bash.exe" (
    echo [ERRO] MSYS2 nao encontrado em %MSYS%
    set "RC=1" & goto :fim
)
if not exist "%ROOT%build" (
    echo [ERRO] Pasta build nao existe em %ROOT%
    set "RC=1" & goto :fim
)

cd /d "%ROOT%build"

for /f %%T in ('powershell -nop -c "[DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set "T0=%%T"

if not exist build.ninja (
    echo [cmake] build.ninja ausente, configurando...
    "%MSYS%\usr\bin\env.exe" MSYSTEM=UCRT64 CHERE_INVOKING=1 "%MSYS%\usr\bin\bash.exe" -lc "cmake -G Ninja -DCMAKE_BUILD_TYPE=Release .."
    if errorlevel 1 ( echo [ERRO] cmake falhou. & set "RC=1" & goto :fim )
)

echo [ninja] compilando...
"%MSYS%\usr\bin\env.exe" MSYSTEM=UCRT64 CHERE_INVOKING=1 "%MSYS%\usr\bin\bash.exe" -lc "ninja"
if errorlevel 1 ( echo. & echo [ERRO] A compilacao falhou. O exe da raiz NAO foi alterado. & set "RC=1" & goto :fim )

for /f %%T in ('powershell -nop -c "[DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set "T1=%%T"
set /a DT=T1-T0
echo [OK] Compilado em %DT% s.

if "%SWAP%"=="0" ( echo Troca do exe ignorada ^(semtroca^). Exe novo: %ROOT%build\%EXE% & set "RC=0" & goto :fim )

tasklist /FI "IMAGENAME eq %EXE%" 2>nul | find /I "%EXE%" >nul
if not errorlevel 1 (
    echo.
    echo [AVISO] O servidor esta aberto: exe NAO foi trocado.
    echo         Feche o servidor e rode este .bat de novo.
    set "RC=2" & goto :fim
)

if exist "%ROOT%%EXE%" (
    fc /b "%ROOT%build\%EXE%" "%ROOT%%EXE%" >nul 2>&1
    if not errorlevel 1 ( echo [OK] O exe da raiz ja e igual ao novo. Nada a trocar. & set "RC=0" & goto :fim )
    copy /Y "%ROOT%%EXE%" "%ROOT%%EXE%.bak" >nul
    if errorlevel 1 ( echo [ERRO] Nao consegui criar o backup .bak. & set "RC=1" & goto :fim )
    echo [OK] Exe anterior salvo em %EXE%.bak
)
copy /Y "%ROOT%build\%EXE%" "%ROOT%%EXE%" >nul
if errorlevel 1 ( echo [ERRO] Nao consegui copiar o exe novo. & set "RC=1" & goto :fim )
echo [OK] Exe novo copiado para %ROOT%%EXE%
set "RC=0"

:fim
echo.
if "%PAUSE%"=="1" pause
exit /b %RC%
