# OTP Verification App

## Descripción

Aplicación móvil desarrollada en Flutter que simula un flujo completo de autenticación mediante código OTP (One-Time Password). El usuario ingresa su correo electrónico, recibe un código de 6 dígitos y lo verifica antes de acceder. Todo el proceso es una simulación sin backend real, orientada a demostrar la implementación de los mecanismos de seguridad y la experiencia de usuario de un sistema de verificación moderno.

---

## Tema seleccionado

**Tema 15.3 — OTP y Verificación**

---

## Objetivo

Implementar un flujo de autenticación de dos factores mediante OTP en Flutter, aplicando buenas prácticas de arquitectura (Provider), validaciones de seguridad (expiración, bloqueo por intentos) y una experiencia de usuario fluida con retroalimentación visual en cada paso.

---

## Integrantes

| Nombre | 
|--------|
| José Francisco Rodríguez Arias |
| Cipriano Rivera |

---

## Tecnologías

| Tecnología | Versión | Uso |
|---|---|---|
| Flutter | 3.x | Framework principal |
| Dart | 3.x | Lenguaje |
| Provider | ^6.1.2 | Gestión de estado |
| sms_autofill | ^2.4.0 | Simulación de detección de SMS |
| intl | ^0.20.2 | Formato de fechas |

---

## Ejecución

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Correr en dispositivo/emulador conectado
flutter run

# 3. Análisis estático
flutter analyze

# 4. Pruebas
flutter test

# 5. Generar APK
flutter build apk
```

> **Requisito:** tener Flutter instalado y un dispositivo Android conectado o emulador activo.

---

## Capturas

| Pantalla de Login | Pantalla OTP | Verificación Exitosa |
|:---:|:---:|:---:|
| Ingreso de correo electrónico | Cajas de 6 dígitos con countdown | Checkmark animado con info de sesión |

---

## Funcionalidades

- **Pantalla de Login:** validación de formato de correo electrónico antes de generar el OTP.
- **Generación de OTP:** código de 6 dígitos aleatorio, expira en **2 minutos**.
- **Ingreso de código:** 6 cajas individuales con auto-foco, retroceso automático y teclado numérico.
- **Detección automática de SMS:** simulación con `sms_autofill` que rellena las cajas a los 3 segundos (demo).
- **Countdown en tiempo real:** temporizador visible que cambia a rojo en los últimos 20 segundos.
- **Validación con bloqueo:** máximo **3 intentos fallidos**, tras los cuales el input se deshabilita y se muestra un diálogo de bloqueo.
- **Reenvío de OTP:** disponible una vez expirado o fallido el código, genera una nueva sesión.
- **Pantalla de éxito:** animación de escala con información de la sesión verificada (correo, fecha/hora).
- **Arquitectura limpia:** `OtpService` stateless, estado centralizado en `OtpProvider` con `ChangeNotifier`.

---

## Dificultades

- **Compatibilidad de paquetes:** `flutter_boot_receiver 1.3.0` usa APIs de Flutter deprecadas (`ShimPluginRegistry`, `FlutterNativeView`) que impiden compilar en versiones modernas del SDK. Se resolvió eliminando la dependencia y simplificando el punto de entrada.
- **Overflow en pantallas pequeñas:** las 6 cajas OTP con ancho fijo desbordaban en dispositivos de 360 dp o menos. Se resolvió usando `LayoutBuilder` para calcular el ancho de cada caja dinámicamente.
- **Gestión del Timer:** garantizar que el `Timer` se cancele correctamente al hacer `dispose` del provider para evitar llamadas sobre widgets desmontados.
- **Auto-focus y retroceso:** manejar el evento `Backspace` en cajas vacías para mover el foco a la caja anterior requirió un `KeyboardListener` envolviendo cada `TextField`.

---

## Mejoras futuras

- Integración con un backend real (Firebase Auth, API REST) para envío de OTP por correo o SMS.
- Soporte para autenticación biométrica (huella/Face ID) como segundo factor adicional.
- Internacionalización (i18n) para soporte multilenguaje.
- Pruebas unitarias y de widget con cobertura completa de `OtpService` y `OtpProvider`.
- Animación de error en las cajas OTP al ingresar un código incorrecto (shake animation).
- Modo oscuro completo con tema dinámico según preferencias del sistema.
