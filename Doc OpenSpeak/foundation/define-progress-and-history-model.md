## **Estado**

Propuesto

---

# **Objetivo**

Definir cómo OpoSpeak registra, conserva y presenta la evolución del opositor a lo largo del tiempo.

Este documento establece los principios para el historial, el seguimiento del progreso y las métricas derivadas.

No define pantallas concretas ni visualizaciones específicas.

---

# **Principio fundamental**

El verdadero producto de OpoSpeak no es la grabación.

El verdadero producto es el historial acumulado de entrenamiento oral.

---

# **La frontera Estado / Evolución**

Dos preguntas distintas, dos lugares distintos:

```txt
Temarios  → Fotografía → "¿Qué hago ahora?"
Progreso  → Película   → "¿Qué ha cambiado?"
```

Todo lo que responde al presente (estados, cobertura, mapa, Siguiente) vive en el Estado del temario, dentro de Temarios.

Progreso muestra exclusivamente cambio a lo largo del tiempo: actividad del periodo y deltas de estado ("Al día: 18 → 43").

Si esta frontera se difumina, Progreso degenera en un panel de contadores que nadie abre. Cualquier contenido nuevo debe responder primero: ¿es fotografía o es película?

---

## **La evolución es derivada, no grabada**

Gracias a la honestidad de referencia de `define-topic-insights-model`, el estado de cualquier fecha pasada se calcula con exactitud evaluando en esa fecha.

La película sale del mismo cálculo que la fotografía: sin snapshots persistidos, retroactiva desde el primer día de datos.

---

# **Problema**

Después de meses o años de preparación, los opositores suelen tener:

- cientos de grabaciones
- decenas o cientos de temas
- múltiples etapas de preparación

Sin una estructura clara resulta difícil responder preguntas básicas:

- ¿Qué he practicado más?
- ¿Qué llevo semanas sin cantar?
- ¿Estoy mejorando?
- ¿Practico con suficiente regularidad?
- ¿Qué temas requieren atención?

---

# **Resultado esperado**

OpoSpeak debe permitir comprender la evolución del entrenamiento oral sin necesidad de revisar manualmente cientos de grabaciones.

---

# **Historial**

## **Definición**

El historial es la representación cronológica de toda la actividad realizada dentro de OpoSpeak.

---

## **Construcción**

El historial se genera a partir de:

- intentos
- grabaciones
- métricas
- notas

---

## **Principio**

El historial no es una entidad independiente.

Es una vista derivada del dominio.

---

# **Unidad básica de análisis**

## **Decisión**

La unidad principal de análisis es el intento.

No:

- la grabación
- la sesión
- el tema

---

## **Motivo**

El intento representa un acto real de práctica.

Cada intento contiene:

- contexto
- duración
- fecha
- resultado

---

# **Evolución temporal**

## **Objetivo**

Permitir al usuario observar cambios a lo largo del tiempo.

---

## **Periodos mínimos**

- Últimos 7 días
- Últimos 30 días
- Últimos 90 días
- Todo el histórico

---

## **Periodos personalizados**

Se podrán incorporar posteriormente.

---

# **Indicadores fundamentales**

## **Volumen de práctica**

Responde a:

“¿Cuánto he practicado?”

---

### **Métricas**

- Número de intentos
- Tiempo acumulado
- Temas trabajados
- Días con actividad

---

## **Consistencia**

Responde a:

“¿Estoy manteniendo una rutina?”

---

### **Métricas**

- Días consecutivos
- Frecuencia semanal
- Frecuencia mensual

---

## **Cobertura**

Responde a:

“¿Qué parte del temario practico realmente?”

---

### **Métricas**

- Temas practicados
- Temas nunca practicados
- Temas olvidados
- Temas recientemente trabajados

---

## **Distribución**

Responde a:

“¿Dónde estoy concentrando mi esfuerzo?”

La distribución actual (más/menos practicado) es fotografía: vive en el mapa del Estado del temario, no en Progreso. Aquí solo cabe su evolución, si algún día aporta.

---

### **Métricas**

- Temas más practicados
- Temas menos practicados
- Bloques más trabajados
- Bloques menos trabajados

---

# **Información por tema**

Cada tema debe poder mostrar:

- número de intentos
- tiempo acumulado
- último intento
- primer intento
- evolución histórica

---

# **Información por intento**

Cada intento debe conservar:

- fecha
- duración
- grabación asociada
- notas
- métricas disponibles

---

# **Información por sesión**

Las sesiones permiten aportar contexto.

Ejemplos:

- cuántos temas se trabajaron
- duración total de la sesión
- fecha

---

## **Restricción**

Las sesiones no deben convertirse en el eje principal de análisis.

---

# **Línea temporal**

## **Objetivo**

Permitir revisar el entrenamiento como una historia continua.

---

## **Eventos posibles**

- Intento realizado
- Nota añadida
- Grabación disponible
- Tema archivado
- Tema recuperado

---

# **Temas olvidados**

## **Definición**

La definición exacta de "olvidado" — relativa al ritmo de revisita del propio usuario, con suelo absoluto — vive en `define-topic-insights-model`, junto al resto de estados temporales del tema (pendiente, reciente, al día).

Este documento la consume; no la posee.

---

## **Objetivo**

Ayudar al opositor a detectar lagunas.

---

## **Relación entre modelos**

`define-topic-insights-model` define la capa de tema (hechos, estados, cadencia, vuelta, cobertura).

Las proyecciones globales de este documento (volumen, consistencia, cobertura, distribución) se derivan de esa capa.

---

# **Temas frecuentes**

## **Definición**

Temas practicados de forma recurrente.

---

## **Objetivo**

Mostrar sesgos de entrenamiento.

---

# **Métricas derivadas**

## **Principio**

Las métricas deben derivarse automáticamente de la actividad.

---

## **Evitar**

Indicadores manuales del tipo:

- Dominado
- Suspendido
- Aprobado
- Nivel experto

---

## **Motivo**

La práctica real es más fiable que la autoevaluación.

---

# **Comparación histórica**

El usuario debe poder comparar:

- hoy frente a hace semanas
- hoy frente a hace meses
- un intento frente a otro intento

---

# **Futuras extensiones**

El modelo debe permitir incorporar posteriormente:

---

## **Velocidad de habla**

Palabras por minuto.

---

## **Muletillas**

Frecuencia de uso.

---

## **Silencios**

Duración y distribución.

---

## **Transcripción**

Análisis de contenido.

---

## **IA local**

Generación de observaciones automáticas.

---

# **Restricciones estratégicas**

No convertir el progreso en una competición.

No introducir rankings.

No introducir comparaciones con otros opositores.

No gamificar agresivamente.

No sustituir el criterio del preparador.

---

# **Filosofía de producto**

OpoSpeak no pretende decir:

“Vas bien.”

O:

“Vas mal.”

OpoSpeak pretende mostrar:

“Esto es lo que has hecho.”

Y permitir que el opositor y su preparador extraigan conclusiones.

---

# **Métrica de éxito**

Después de varios meses de uso, un opositor debe poder abrir OpoSpeak y responder rápidamente:

- ¿Qué practico más?
- ¿Qué practico menos?
- ¿Qué llevo tiempo sin cantar?
- ¿Cuánto estoy entrenando realmente?
- ¿Cómo ha evolucionado mi actividad?

---

# **Resultado esperado**

Cuando el usuario acumule cientos o miles de intentos, OpoSpeak debe transformar ese volumen de información en una visión clara y comprensible de su evolución.

La grabación conserva el pasado.

El historial explica el progreso.

Una observación estratégica: aquí todavía no estamos hablando de **calidad de los cantos**, solo de **actividad y evolución**.

Me parece correcto para el MVP.

Las métricas de calidad (ritmo, muletillas, duración objetivo, estructura, etc.) deberían vivir en un spec posterior, probablemente algo como:

```txt
define-performance-analysis-model
```

porque son una capa distinta al historial puro.