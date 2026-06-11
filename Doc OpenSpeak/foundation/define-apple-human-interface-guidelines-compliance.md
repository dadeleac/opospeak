
## **Estado**

Propuesto

---

# **Objetivo**

Definir los principios de cumplimiento con las Apple Human Interface Guidelines (HIG) que deben aplicarse a OpoSpeak.

Este documento actúa como referencia de diseño, interacción y experiencia de usuario para todas las funcionalidades presentes y futuras.

No define pantallas concretas.

No sustituye la documentación oficial de Apple.

---

# **Principio fundamental**

OpoSpeak es una aplicación Apple-first.

La experiencia debe sentirse nativa.

El usuario no debe percibir que está utilizando una aplicación multiplataforma adaptada a iPhone.

---

# **Filosofía**

La mejor interfaz es la que desaparece durante la práctica.

El foco del usuario debe estar en:

- cantar
- escuchar
- revisar

No en aprender a usar la aplicación.

---

# **Regla general**

Ante dos soluciones equivalentes:

- una nativa de Apple
- una personalizada

debe preferirse la solución nativa.

---

# **Experiencia nativa**

## **Objetivo**

Todo comportamiento debe resultar familiar para un usuario habitual de iPhone.

---

## **Ejemplos**

Preferir:

- NavigationStack
- Tab Bar nativa
- Search nativo
- Sheets nativos
- Menús contextuales nativos
- Compartir mediante Share Sheet

Evitar:

- componentes personalizados innecesarios
- navegación inventada
- patrones propios de Android
- controles difíciles de reconocer

---

# **Claridad**

## **Principio**

El usuario debe entender qué ocurre en cada momento.

---

## **Aplicación**

Los elementos interactivos deben:

- tener propósito claro
- utilizar lenguaje sencillo
- evitar ambigüedad

---

## **Evitar**

- jerga técnica
- términos internos
- conceptos de implementación

---

# **Simplicidad**

## **Principio**

Cada pantalla debe centrarse en una tarea principal.

---

## **Ejemplos**

### **Tema**

Acción principal:

Practicar.

---

### **Intento**

Acción principal:

Escuchar.

---

### **Historial**

Acción principal:

Explorar evolución.

---

# **Jerarquía visual**

## **Principio**

La información importante debe ser evidente.

---

## **Prioridades**

### **Nivel 1**

Información principal.

---

### **Nivel 2**

Contexto relevante.

---

### **Nivel 3**

Información secundaria.

---

## **Evitar**

Pantallas saturadas.

---

# **Consistencia**

## **Principio**

La misma acción debe comportarse siempre igual.

---

## **Ejemplos**

Si archivar utiliza swipe:

- debe funcionar igual en toda la aplicación.

Si eliminar requiere confirmación:

- debe requerirla siempre.

---

# **Accesibilidad**

## **Principio**

Toda funcionalidad debe ser accesible desde el primer día.

No como una mejora futura.

---

# **VoiceOver**

Todos los controles deben disponer de:

- etiquetas adecuadas
- descripciones comprensibles
- navegación lógica

---

# **Dynamic Type**

La aplicación debe funcionar correctamente con todos los tamaños de texto soportados por iOS.

---

# **Contraste**

Todos los textos deben mantener niveles adecuados de contraste.

---

# **Navegación por teclado**

Las futuras versiones para iPad y macOS deben considerar navegación mediante teclado.

---

# **Objetivos táctiles**

## **Requisito**

Los elementos interactivos deben respetar las recomendaciones de Apple.

---

## **Objetivo**

Evitar pulsaciones accidentales.

---

# **Animaciones**

## **Principio**

Las animaciones deben aportar contexto.

No decoración.

---

## **Deben**

- explicar transiciones
- reforzar jerarquías
- mejorar comprensión

---

## **No deben**

- ralentizar tareas
- distraer durante la práctica

---

# **Estados vacíos**

## **Principio**

Las pantallas vacías deben orientar.

No confundir.

---

## **Ejemplo**

Si no existen temas:

La aplicación explica el siguiente paso.

---

# **Feedback**

## **Principio**

Las acciones importantes deben proporcionar respuesta inmediata.

---

## **Ejemplos**

- práctica iniciada
- grabación detenida
- exportación completada
- eliminación realizada

---

# **Errores**

## **Principio**

Los errores deben ayudar.

No culpar al usuario.

---

## **Requisitos**

Explicar:

- qué ocurrió
- qué consecuencias tiene
- qué puede hacer ahora

---

# **Privacidad visible**

## **Principio**

La privacidad debe percibirse.

No únicamente existir.

---

## **Aplicación**

La interfaz debe comunicar claramente:

- funcionamiento sin cuenta
- almacenamiento local
- sincronización mediante iCloud
- exportación disponible

---

# **Diseño de la práctica**

## **Principio**

Durante la práctica la interfaz debe desaparecer.

---

## **Mostrar únicamente**

- estado de grabación
- tiempo transcurrido
- acciones esenciales

---

## **Evitar**

- métricas complejas
- estadísticas
- configuraciones

---

# **Diseño del historial**

## **Principio**

El historial debe priorizar comprensión.

No cantidad de información.

---

## **Objetivo**

Permitir responder rápidamente:

- qué practiqué
- cuándo practiqué
- cuánto practiqué

---

# **Diseño de métricas**

## **Principio**

Las métricas deben informar.

No juzgar.

---

## **Evitar**

- puntuaciones arbitrarias
- rankings
- gamificación agresiva
- evaluaciones artificiales

---

# **Apple Ecosystem**

## **Principio**

Aprovechar primero capacidades nativas.

---

## **Ejemplos**

- CloudKit
- Share Sheet
- Archivos
- VoiceOver
- Dynamic Type
- Shortcuts (futuro)

---

# **Auditorías obligatorias**

Antes de cada versión relevante se debe verificar:

- VoiceOver
- Dynamic Type
- Contraste
- Estados vacíos
- Flujo completo de grabación
- Flujo completo de reproducción
- Flujo completo de exportación

---

# **Criterio de aceptación**

Una funcionalidad no se considera terminada hasta que:

- cumple las HIG relevantes
- funciona con VoiceOver
- funciona con Dynamic Type
- mantiene consistencia con el resto de la aplicación

---

# **Resultado esperado**

Un opositor que utilice habitualmente aplicaciones de Apple debe sentir que OpoSpeak pertenece naturalmente al ecosistema.

La experiencia debe parecer diseñada para iPhone desde el primer día.

No adaptada posteriormente.

De hecho, para OpoSpeak yo añadiría otro spec complementario muy pronto:

```txt
define-design-principles
```

Porque las HIG te dicen **cómo comportarte como una app Apple**, pero no te dicen **qué personalidad debe tener OpoSpeak**. Ahí es donde definiríamos conceptos como:

- calma
- concentración
- progreso a largo plazo
- ausencia de gamificación
- sensación de herramienta seria de estudio

que son rasgos propios de la marca OpoSpeak y no de Apple.