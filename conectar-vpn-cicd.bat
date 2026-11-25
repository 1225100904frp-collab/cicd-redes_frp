@echo off
REM ============================================================
REM  Conectar a la VPN del sandbox DevNet con openconnect
REM  Practica 2 CI/CD - Catalyst 9000 Stack, Cat9k-Stack2a
REM  Host: 10.10.20.181 - vence ~21:28 CST del 2026-11-25
REM
REM  SERVER ya esta completo: devnetsandbox-usw1-reservation.cisco.com:20177
REM  (confirmado el 2026-11-25; distinto al :20123 de la reserva anterior).
REM
REM  1. SERVER ya esta completo, no lo cambies. Clic derecho > Ejecutar como administrador.
REM  3. Escribe tu vpn_password de Access Details cuando te la pida
REM     (no es la contrasena del router).
REM  4. No cierres la ventana de la VPN mientras haces la practica.
REM ============================================================
setlocal
set "SERVER=devnetsandbox-usw1-reservation.cisco.com:20177"
set "VPNUSER=fabianre"
set "HOST=10.10.20.181"

if "%SERVER%"=="TU-SERVIDOR-VPN-COMPLETO" goto :NOEDIT

set "OPENCONNECT="

REM --- Buscar openconnect.exe en el PATH ---
for /f "delims=" %%i in ('where openconnect.exe 2^>nul') do set "OPENCONNECT=%%i"

REM --- Si no esta en el PATH, buscarlo en la ruta de OpenConnect-GUI ---
if "%OPENCONNECT%"=="" if exist "C:\Program Files (x86)\OpenConnect-GUI\openconnect.exe" set "OPENCONNECT=C:\Program Files (x86)\OpenConnect-GUI\openconnect.exe"
if "%OPENCONNECT%"=="" if exist "C:\Program Files\OpenConnect-GUI\openconnect.exe" set "OPENCONNECT=C:\Program Files\OpenConnect-GUI\openconnect.exe"

if "%OPENCONNECT%"=="" goto :NOTFOUND

echo Cliente encontrado en:
echo   %OPENCONNECT%
echo.
echo Conectando a %SERVER% como %VPNUSER% ...
echo (la contrasena es tu vpn_password de Access Details)
echo.
start "OpenConnect VPN - Practica 2 CICD" "%OPENCONNECT%" --protocol=anyconnect %SERVER% --user=%VPNUSER%
echo Esperando 8 segundos a que la VPN suba...
timeout /t 8 /nobreak >nul
echo.
echo --- Comprobando conexion al equipo %HOST% ---
ping -n 3 %HOST%
echo.
echo Si el ping responde, ya puedes probar el puerto 22 y correr desplegar.py.
echo Si no responde, revisa que la ventana "OpenConnect VPN" siga
echo abierta y diga Connected, y vuelve a intentar el ping.
echo.
pause
exit /b 0

:NOEDIT
echo Edita primero este archivo y pon la direccion VPN COMPLETA:
echo   SERVER  = direccion VPN completa con puerto (Access Details)
echo   VPNUSER = fabianre (ya esta puesto)
echo   HOST    = 10.10.20.181 (ya esta puesto)
echo.
pause
exit /b 1

:NOTFOUND
echo NO se encontro openconnect.exe en tu PC.
echo.
echo Eso significa que OpenConnect-GUI se instalo solo con la GUI,
echo sin el cliente de consola. Reinstala eligiendo Full (no Standard)
echo y marcando el componente de consola + Add to PATH, luego vuelve
echo a ejecutar este archivo como administrador.
echo.
echo Atajo para no perder la ventana: conectate con la GUI ya instalada
echo (Server = %SERVER%, usuario %VPNUSER%) y haz la practica; la consola
echo queda para despues.
echo.
pause
exit /b 1
