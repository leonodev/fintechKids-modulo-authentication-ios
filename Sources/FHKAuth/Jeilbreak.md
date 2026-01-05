# 🛡️ Seguridad Avanzada: Detección de Compromiso de Sistema (Jailbreak)

Este módulo no es una simple validación de archivos; es un sistema de **Integridad de Entorno** diseñado para proteger los datos sensibles de la aplicación frente a dispositivos vulnerados.

---

## 🐦 El Concepto: Rompiendo el Sandbox
iOS está diseñado bajo una arquitectura de **Sandbox**. Cada app es un "pájaro" en su propia "jaula". El **Jailbreak** (usando herramientas como **Dopamine, Palera1n o Unc0ver**) consiste en explotar el Kernel para abrir esa jaula y obtener privilegios de **Root**.



---

## 🧠 Glosario de Ingeniería Inversa y Bajo Nivel

Para esta implementación, se utilizaron técnicas que evaden el análisis estático y detectan la presencia de herramientas como **Cydia** y **Sileo**:

### 1. Introspección Dinámica con `dlsym`
En lugar de llamar a funciones de sistema de forma directa (lo cual es fácil de detectar y bloquear para un atacante), usamos `dlsym` (*Dynamic Link Symbol*).
* **Propósito:** Busca la dirección de memoria de una función (como `fork`) mientras la app se está ejecutando. 
* **Nivel Senior:** Esto oculta nuestras intenciones de los escáneres automáticos de código.

### 2. El Test del `fork()`
`fork()` es una función de Unix que clona el proceso actual para crear uno nuevo.
* **Por qué importa:** En un iPhone original, el Sandbox prohíbe terminantemente que una app haga un `fork()`.
* **Resultado:** Si `fork()` tiene éxito (devuelve un PID > 0), sabemos con 100% de certeza que el Sandbox ha sido destruido.

### 3. Puentes de Memoria: `@convention(c)` y `unsafeBitCast`
Swift es un lenguaje seguro, pero para hablar con el Kernel necesitamos ser "inseguros":
* **`@convention(c)`**: Le dice a Swift que una variable debe comportarse como una función pura de C.
* **`unsafeBitCast`**: Fuerza al compilador a tratar un puntero de memoria como si fuera una función ejecutable. Es la técnica más potente para interactuar con librerías de sistema (`Darwin`).

---

## 🛠️ Capas de Protección Implementadas

| Técnica | Objetivo | Concepto Clave |
| :--- | :--- | :--- |
| **Detección de Binarios** | Busca archivos de **Cydia, Sileo, Zebra o Filza**. | Comprueba rutas como `/Applications/Cydia.app`. |
| **Protocolos de URL** | Verifica si el sistema responde a `cydia://`. | Requiere configuración en **Info.plist** (`LSApplicationQueriesSchemes`). |
| **Prueba de Escritura** | Intenta escribir en `/private/`. | Si el sistema lo permite, el **RootFS** (sistema de archivos) está desbloqueado. |
| **Análisis de Procesos** | Ejecuta `fork()` mediante `dlsym`. | Detecta si el aislamiento del Kernel ha sido vulnerado. |

---

## ⚙️ Configuración del Proyecto (Info.plist)

Para que la detección por esquemas de URL sea efectiva, se debe declarar la lista de aplicaciones sospechosas en el archivo de configuración del proyecto. Sin esto, iOS siempre devolverá `false` por motivos de privacidad:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>cydia</string>
    <string>sileo</string>
    <string>zbra</string>
    <string>undecimus</string>
</array>