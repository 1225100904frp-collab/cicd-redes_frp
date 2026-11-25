# CI/CD para automatización de redes — Fabian Reyes Peralta

Python + GitHub Actions + Cisco DevNet Sandbox (IOS XE, On-Demand privado).

## Qué hace este proyecto

- `configuracion.py`: genera la configuración de la Loopback99 (`192.0.2.99/32`, descripción `LAB_CICD_PYTHON`) y los comandos de verificación, sin conectarse al router.
- `tests/test_configuracion.py`: 2 pruebas pytest que validan esa configuración antes de cualquier despliegue.
- `desplegar.py`: despliegue controlado con Netmiko por SSH. Pide escribir `SI`, muestra `show version`, aplica la Loopback99 y verifica con `show running-config interface Loopback99`.
- `.github/workflows/ci.yml`: pipeline CI en Python 3.11 — instala dependencias, valida sintaxis con `compileall` y ejecuta `pytest -v`. No se conecta al router.

## Todo lo que hay que hacer, en orden

### A. Entorno local (Windows PowerShell)
1. Copia esta carpeta como `cicd-redes`, entra en ella.
2. `py -m venv .venv` y luego `.venv\Scripts\Activate.ps1`
3. `python --version` y `python -m pip install --upgrade pip`
4. `python -m pip install -r requirements.txt`
5. Comprueba: `python -m pip show netmiko` y `python -m pip show pytest`
6. Captura: estructura de carpetas y archivos, con tu usuario visible.

### B. Sandbox nuevo (el anterior venció)
7. Reserva en DevNet un **IOS XE On-Demand, privado y con acceso administrativo**. No uses un Always-On compartido para modificarlo.
8. Anota en privado host, puerto SSH (22), usuario, contraseña y si requiere VPN. No subas credenciales al repositorio.
9. Si requiere VPN, conéctala antes de probar. Comprueba: `Test-NetConnection HOST_SANDBOX -Port 22`
10. Un ping fallido no siempre significa que el sandbox esté caído; algunos entornos bloquean ICMP.

### C. Lógica y pruebas
11. `python configuracion.py` — debe imprimir las 4 líneas de la Loopback99.
12. `python -m pytest -v` — resultado esperado: **2 passed**. Captura.

### D. CI en GitHub
13. Crea el repositorio `cicd-redes` en GitHub, sin archivos iniciales.
14. Desde la carpeta del proyecto:
    ```
    git init
    git add .
    git commit -m "Primer proyecto CI CD de redes"
    git branch -M main
    git remote add origin https://github.com/TU_USUARIO/cicd-redes.git
    git push -u origin main
    ```
15. En GitHub → Actions, abre la ejecución de `CI - Automatizacion de redes` y verifica los 5 pasos en verde. **Evidencia 1.**

### E. Despliegue controlado
16. En la misma ventana de PowerShell, define las variables (con tus datos reales, no los de ejemplo):
    ```
    $env:NET_DEVICE_HOST="HOST_O_IP_DEL_SANDBOX"
    $env:NET_DEVICE_USER="USUARIO_DEL_SANDBOX"
    $env:NET_DEVICE_PASSWORD="CONTRASEÑA_DEL_SANDBOX"
    $env:NET_DEVICE_TYPE="cisco_xe"
    $env:NET_DEVICE_PORT="22"
    ```
    No guardes estos comandos con la contraseña real en capturas ni en archivos.
17. `python desplegar.py`, lee el `show version`, escribe exactamente `SI` solo si confirmas que es tu sandbox privado.
18. Verifica que la salida muestre Loopback99 con `192.0.2.99/32`.
19. En la consola del dispositivo: `show ip interface brief` y `show running-config interface Loopback99`. Captura sin credenciales ni datos de VPN.
20. Limpieza **solo cuando el docente lo indique** y solo en tu sandbox privado:
    ```
    configure terminal
    no interface Loopback99
    end
    show ip interface brief
    ```
    No la ejecutes en un equipo compartido ni si Loopback99 ya existía antes.

### F. Error controlado (Paso 16)
21. En `tests/test_configuracion.py`, cambia temporalmente `Loopback99` por `Loopback100` en una aserción.
22. `git add .`, `git commit -m "Prueba de deteccion de error"`, `git push`. En Actions debe fallar el paso de pruebas. Captura.
23. Restaura `Loopback99`, ejecuta `pytest -v` en local, luego `git add .`, `git commit -m "Corrige prueba de Loopback"`, `git push`. En Actions debe volver a verde. **Evidencia 2:** captura fallida + captura aprobada.

## Entregables
- URL del repositorio GitHub con todos los archivos.
- Captura de la estructura de carpetas.
- Captura de pytest local con 2 pruebas aprobadas.
- Captura de GitHub Actions con pipeline aprobado.
- Capturas de la ejecución fallida y la corregida del Paso 16.
- Capturas del despliegue y de los `show` que verifican Loopback99.
- Conclusión individual (abajo, 150–200 palabras).

## Conclusión (borrador, adáptalo con tus palabras)

<!-- CONCLUSION START -->
La integración continua evita que un error pequeño, como escribir mal una interfaz o una dirección IP, llegue sin revisión a la red y cause una interrupción que después es difícil de rastrear. Al ejecutar las pruebas automáticamente en cada cambio, el pipeline detecta el problema antes del despliegue, avisa qué prueba falló y permite corregirlo con un cambio controlado en el repositorio. Por eso el despliegue debe controlarse: aplicar una configuración directamente al equipo, sin confirmar que es el sandbox privado correcto ni verificar el resultado, puede afectar a otros usuarios o dejar el dispositivo en un estado incorrecto. La confirmación explícita, las variables de entorno y la verificación con comandos show reducen ese riesgo y dejan evidencia de lo que realmente cambió. Para automatizar la aprobación, añadiría una revisión obligatoria en el pull request, secretos protegidos en GitHub, una prueba de conectividad de solo lectura y un despliegue que solo se ejecute después de esa aprobación, para mantener la velocidad sin perder el control.
<!-- CONCLUSION END -->

## Preguntas de reflexión (respuestas cortas para guiarte)
1. **¿CI vs CD?** CI revisa y prueba cada cambio automáticamente. CD deja ese cambio validado listo para entregarse o lo aplica de forma controlada a un entorno.
2. **¿Por qué probar antes de conectarse?** Para detectar errores de lógica sin tocar el router ni arriesgar la red.
3. **¿Ventaja de las variables de entorno?** Las credenciales no quedan en el código ni en el repositorio; se cambian por entorno sin modificar el programa.
4. **¿Por qué no modificar un Always-On compartido?** Porque otros estudiantes lo usan al mismo tiempo y un cambio tuyo puede romper su práctica.
5. **¿Qué pasa si se despliega sin revisión?** Se puede aplicar una configuración errónea, interrumpir servicios o dejar el equipo en un estado difícil de revertir.
6. **¿Qué agregarías para una red real?** Aprobaciones, secretos, inventario, pruebas de conectividad, respaldo de la configuración antes del cambio y plan de reversión.
