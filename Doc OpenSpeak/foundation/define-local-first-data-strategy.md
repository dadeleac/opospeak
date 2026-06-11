
## **Estado**

Propuesto

---

# **Objetivo**

Definir cómo se almacenan, sincronizan, exportan y conservan los datos en OpoSpeak.

Este documento establece los principios de propiedad, privacidad y continuidad de los datos del usuario.

No define tecnologías concretas de persistencia.

---

# **Principio fundamental**

Los datos pertenecen al opositor.

OpoSpeak existe para ayudar a organizarlos, visualizarlos y conservarlos.

No para poseerlos.

---

# **Principios estratégicos**

## **1. Local First**

La aplicación debe funcionar completamente sin conexión.

El usuario debe poder:

- Crear sesiones
- Registrar intentos
- Grabar audio
- Escuchar grabaciones
- Consultar histórico
- Ver estadísticas

sin necesidad de conexión a Internet.

---

## **2. Sin cuenta obligatoria**

El uso de la aplicación no requiere:

- registro
- email
- contraseña
- cuenta propia de OpoSpeak

La aplicación debe aprovechar las capacidades nativas del ecosistema Apple.

---

## **3. Privacidad por defecto**

Las grabaciones y notas forman parte de un proceso de preparación altamente personal.

La aplicación debe tratar toda esta información como privada por defecto.

---

## **4. El desarrollador no accede a los datos**

La arquitectura inicial debe diseñarse para que el desarrollador no tenga acceso a:

- grabaciones
- notas
- métricas
- transcripciones

del usuario.

---

## **5. El usuario conserva el control**

El usuario debe poder:

- cambiar de dispositivo
- exportar sus datos
- realizar copias de seguridad
- abandonar la plataforma

sin perder acceso a su información.

---

# **Modelo de propiedad**

## **Usuario**

Propietario único de:

- grabaciones
- sesiones
- intentos
- métricas
- notas
- configuraciones

---

## **OpoSpeak**

Responsable únicamente de:

- almacenar
- organizar
- visualizar
- sincronizar cuando corresponda

---

# **Continuidad entre dispositivos**

## **Principio**

Local-first no significa que los datos vivan únicamente en un dispositivo físico.

Local-first significa que la aplicación funciona localmente y no depende de servidores propios.

---

## **Experiencia objetivo**

Un usuario debe poder:

- cambiar de iPhone
- restaurar un dispositivo
- utilizar un iPad en el futuro
- utilizar un Mac en el futuro

sin perder años de entrenamiento oral.

---

## **Fuente de verdad**

### **Fuente de verdad operativa**

Los datos se leen y escriben localmente en cada dispositivo.

La aplicación debe funcionar incluso sin conexión.

---

### **Fuente de verdad de continuidad**

La cuenta iCloud del usuario actúa como mecanismo de sincronización y recuperación.

La experiencia esperada es:

“Mis datos están conmigo, en mis dispositivos Apple.”

No:

“Mis datos están únicamente en este móvil.”

---

# **Estrategia de sincronización**

## **Decisión inicial**

La sincronización se realizará mediante iCloud y CloudKit.

---

## **Objetivos**

Permitir:

- continuidad entre dispositivos
- restauración tras cambio de móvil
- recuperación ante pérdida del dispositivo

sin necesidad de backend propio.

---

## **Requisitos**

La sincronización nunca debe:

- bloquear el uso de la aplicación
- impedir grabar
- impedir consultar datos
- impedir exportar datos

---

## **Fallos de sincronización**

Si iCloud no está disponible:

- la aplicación continúa funcionando
- los datos locales siguen siendo accesibles
- las operaciones pendientes podrán sincronizarse posteriormente

---

# **Estrategia de almacenamiento**

## **Metadatos**

La aplicación almacena:

- temarios
- temas
- sesiones
- intentos
- métricas
- notas
- configuraciones

como datos estructurados.

---

## **Grabaciones**

Las grabaciones se almacenan como archivos independientes.

No deben almacenarse como blobs dentro de la base de datos.

---

## **Referencias**

Los metadatos mantienen referencias estables a los archivos de audio asociados.

---

# **Cambio de dispositivo**

## **Escenario esperado**

Un usuario compra un nuevo iPhone.

Tras instalar OpoSpeak:

- recupera sus temarios
- recupera sus sesiones
- recupera sus métricas
- recupera sus notas
- recupera sus grabaciones

a través de su cuenta iCloud.

---

## **Resultado esperado**

El historial completo debe mantenerse entre dispositivos sin intervención manual.

---

# **Uso multidispositivo**

El modelo debe permitir en el futuro:

- grabar en iPhone
- revisar métricas en iPad
- consultar histórico en macOS

utilizando la misma cuenta iCloud.

---

# **Nubes de terceros**

## **Decisión inicial**

OpoSpeak no integrará inicialmente:

- Google Drive
- Dropbox
- OneDrive
- otros proveedores externos

---

## **Motivo**

Mantener:

- simplicidad
- privacidad
- integración nativa con Apple
- menor complejidad de soporte

---

## **Libertad del usuario**

La ausencia de integración directa no debe limitar al usuario.

La exportación abierta permite almacenar copias donde desee.

---

# **Exportación**

## **Principio**

Todo dato generado debe poder recuperarse.

---

## **Formato**

La aplicación debe poder generar un paquete de respaldo completo.

Ejemplo:

OpoSpeak Backup

- metadata.json
- recordings/
- manifest.json

---

## **Contenido mínimo**

### **Datos estructurados**

- temarios
- temas
- sesiones
- intentos
- métricas
- notas

### **Archivos**

- grabaciones originales

---

## **Objetivo**

Garantizar que el usuario nunca quede cautivo de la plataforma.

---

# **Eliminación de datos**

## **Eliminación individual**

El usuario puede eliminar:

- una grabación
- un intento
- una sesión

---

## **Eliminación completa**

El usuario puede eliminar toda la información almacenada.

---

## **Resultado esperado**

Tras la eliminación:

- no quedan datos accesibles en la aplicación
- no existen copias en servidores propios
- los datos sincronizados se eliminan también de la cuenta iCloud del usuario

---

# **Ausencia de backend propio**

## **Decisión inicial**

La primera versión de OpoSpeak no incorpora backend propietario.

---

## **Motivos**

Reduce:

- complejidad
- costes
- riesgos legales
- superficie de ataque
- dependencia operativa

---

## **Beneficios**

Permite centrar el producto en:

- entrenamiento oral
- experiencia de usuario
- análisis local
- privacidad

---

# **IA y privacidad**

## **Principio**

La IA no debe obligar a enviar grabaciones a terceros.

---

## **Estrategia preferida**

Procesamiento local siempre que sea viable.

---

## **Restricción**

Las funcionalidades futuras de IA no deben romper los principios definidos en este documento.

---

# **Decisiones explícitas**

## **Sí**

- Local First
- Offline completo
- Sin cuenta propia
- iCloud como mecanismo principal de continuidad
- CloudKit para sincronización
- Exportación abierta
- Eliminación total de datos
- Audio almacenado como archivos independientes

---

## **No**

- Backend obligatorio
- Dependencia permanente de Internet
- Publicidad
- Venta de datos
- Analítica invasiva
- Bloqueo de exportaciones
- Dependencia de proveedores cloud externos

---

# **Resultado esperado**

Un opositor debe poder utilizar OpoSpeak durante años sabiendo que:

- sus datos siguen siendo suyos
- la aplicación funciona sin conexión
- puede cambiar de dispositivo sin perder historial
- puede exportar toda su información
- nadie necesita acceder a sus grabaciones para que el producto funcione
- sus datos viven en su ecosistema Apple, no en servidores de OpoSpeak

Además, esto deja una propuesta de valor muy potente para la web y App Store:

“Tus grabaciones y tu progreso permanecen en tu ecosistema Apple. OpoSpeak no necesita servidores propios ni cuentas para funcionar.”

Eso encaja perfectamente con la filosofía que ya has definido para OpoSpeak.