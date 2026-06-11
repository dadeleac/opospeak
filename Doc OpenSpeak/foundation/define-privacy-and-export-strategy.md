
## **Estado**

Propuesto

---

# **Objetivo**

Definir cómo OpoSpeak protege la privacidad del usuario y garantiza la portabilidad de sus datos.

Este documento establece los principios de confianza sobre los que se construye el producto.

No define tecnologías concretas ni mecanismos de implementación.

---

# **Principio fundamental**

Los datos pertenecen al opositor.

No a OpoSpeak.

No al desarrollador.

No a terceros.

---

# **Problema**

La preparación oral de oposiciones genera información altamente personal.

Ejemplos:

- grabaciones de voz
- errores recurrentes
- comentarios del preparador
- métricas de evolución
- hábitos de estudio

Muchos opositores dedican años a construir este historial.

La aplicación debe tratarlo como un activo privado del usuario.

---

# **Resultado esperado**

El usuario debe sentir que:

- sus datos están protegidos
- mantiene el control
- puede abandonar la aplicación cuando quiera
- nunca queda cautivo de la plataforma

---

# **Principios de privacidad**

## **1. Privacidad por defecto**

Toda la información creada en OpoSpeak es privada por defecto.

---

## **2. Sin exposición pública**

La aplicación no incorpora:

- perfiles públicos
- rankings
- comunidad
- comparativas entre usuarios
- contenido compartido por defecto

---

## **3. Sin monetización basada en datos**

Los datos del usuario nunca se utilizarán para:

- publicidad
- segmentación comercial
- venta a terceros
- creación de perfiles de comportamiento

---

## **4. Minimización de datos**

La aplicación únicamente debe almacenar información necesaria para cumplir su propósito.

---

## **5. Transparencia**

El usuario debe entender claramente:

- qué datos se almacenan
- dónde se almacenan
- cómo se eliminan
- cómo se exportan

---

# **Propiedad de los datos**

## **Principio**

Toda información generada pertenece al usuario.

---

## **Incluye**

- grabaciones
- intentos
- sesiones
- métricas
- notas
- configuraciones
- futuras transcripciones

---

## **Consecuencia**

El usuario debe poder recuperar toda esta información en cualquier momento.

---

# **Ausencia de backend propio**

## **Decisión inicial**

OpoSpeak no incorpora un backend propietario.

---

## **Beneficios**

- menor superficie de ataque
- menor complejidad legal
- menor riesgo operativo
- mayor privacidad

---

## **Resultado**

El desarrollador no necesita acceder a los datos del usuario para que la aplicación funcione.

---

# **Sincronización**

## **Principio**

La sincronización existe para beneficiar al usuario.

No para centralizar datos.

---

## **Estrategia inicial**

Utilizar la infraestructura privada del usuario dentro del ecosistema Apple.

---

## **Consecuencia**

Las grabaciones y metadatos permanecen asociados a la cuenta iCloud del usuario.

---

# **Exportación**

## **Principio fundamental**

La exportación no es una funcionalidad avanzada.

Es un derecho básico del usuario.

---

# **Objetivos**

Permitir:

- conservar copias de seguridad
- migrar a otro dispositivo
- abandonar la plataforma
- compartir información con preparadores

---

# **Exportación completa**

La aplicación debe poder generar una exportación completa del historial.

---

## **Contenido mínimo**

### **Estructura**

- temarios
- temas
- sesiones
- intentos
- métricas
- notas

### **Archivos**

- grabaciones originales

---

# **Formato**

## **Requisito**

Los formatos utilizados deben ser abiertos y reutilizables.

---

## **Preferencias**

### **Datos**

- JSON
- CSV

### **Audio**

- formatos estándar del sistema

---

## **Restricción**

No utilizar formatos propietarios que dificulten la migración.

---

# **Importación futura**

## **Objetivo**

La estrategia de exportación debe permitir futuras capacidades de importación.

---

## **Casos posibles**

- restaurar una copia
- migrar entre dispositivos
- recuperar datos exportados previamente

---

# **Eliminación de datos**

## **Eliminación individual**

El usuario puede eliminar:

- grabaciones
- intentos
- sesiones
- notas

---

## **Eliminación completa**

El usuario puede eliminar todo su historial.

---

## **Resultado esperado**

Tras la eliminación:

- la información desaparece de la aplicación
- la información sincronizada deja de estar disponible
- no quedan copias en servidores propios

---

# **Acceso futuro de IA**

## **Principio**

La incorporación futura de IA no modifica la propiedad de los datos.

---

## **Restricción**

Ninguna funcionalidad de IA debe asumir automáticamente que las grabaciones pueden enviarse a servicios externos.

---

## **Consentimiento**

Si una funcionalidad futura requiere procesamiento externo:

- debe explicarse claramente
- debe ser opcional
- debe requerir consentimiento explícito

---

# **Preparadores y compartición**

## **Principio**

Compartir información siempre es una decisión del usuario.

---

## **Ejemplos futuros**

- compartir una grabación
- compartir un informe
- compartir métricas
- exportar una sesión

---

## **Restricción**

Nada se comparte automáticamente.

---

# **Política de observabilidad**

## **Principio**

Los sistemas de telemetría nunca deben registrar contenido personal.

---

## **Nunca registrar**

- audio
- transcripciones
- notas
- contenido del tema

---

## **Permitido**

- errores técnicos
- tiempos de carga
- fallos de sincronización
- eventos técnicos anonimizados

---

# **Restricciones estratégicas**

No crear dependencia artificial.

No dificultar exportaciones.

No bloquear datos detrás de suscripciones.

No exigir conexión permanente.

No exigir cuenta propia.

---

# **Filosofía de producto**

La confianza es una funcionalidad.

Un opositor debe sentir que OpoSpeak trabaja para él.

No que está entregando años de preparación a una plataforma.

---

# **Métrica de éxito**

Un usuario debe poder responder afirmativamente a estas preguntas:

- ¿Sé dónde están mis datos?
- ¿Puedo recuperarlos?
- ¿Puedo eliminarlos?
- ¿Puedo cambiar de dispositivo?
- ¿Puedo dejar de usar OpoSpeak sin perder mi trabajo?

---

# **Resultado esperado**

Después de años utilizando OpoSpeak, el usuario debe seguir sintiendo que conserva el control absoluto sobre su historial de entrenamiento oral.

La aplicación organiza los datos.

La propiedad sigue siendo del opositor.

De todos los specs que llevamos, este es uno de los que más valor de marca aporta. Porque si algún día la web de OpoSpeak tiene una sección “Principios”, prácticamente este documento puede publicarse casi sin modificaciones. Es exactamente el tipo de mensaje que diferencia a OpoSpeak de una futura app de suscripción que centraliza audios en servidores propios.