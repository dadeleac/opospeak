# Análisis de oportunidades post-MVP

## Estado

Documento estratégico vivo. No es una auditoría: orienta decisiones futuras y se revisa cuando el contexto cambia.

**Última revisión: 11 de junio de 2026** (segunda iteración, tras revisión crítica del análisis inicial).

---

# 1. Revisión crítica del análisis anterior

El primer análisis acertó en el mapa (las diez oportunidades eran las correctas) y falló en tres cosas que importan más que el mapa.

## Error 1: ordené por coste de implementación, no por valor

Recomendé "Evolución por tema primero porque los datos ya existen". Eso es instinto de ingeniero, no de fundador. La prueba correcta es la de la desaparición:

**Si OpoSpeak desapareciera mañana, ¿qué echaría más de menos un opositor?**

No una gráfica de duraciones de un tema. Echaría de menos **saber dónde está**: qué temas tiene olvidados, cuánto temario lleva cubierto en esta vuelta, qué le falta por trabajar. Esa visión es la que hoy fabrica a mano con Excel, colores en un índice impreso y memoria — y la que peor envejece a medida que pasan los meses. Una gráfica es un lujo; el mapa de la vuelta es el cuaderno mismo.

**Corrección**: la vuelta al temario no era la apuesta "estratégica a medio plazo". Es la funcionalidad nº 1 a secas, también en secuencia.

## Error 2: pensé en intentos cuando el opositor piensa en temas

El análisis anterior giró alrededor de `Intento → métricas` porque el modelo de dominio declara el intento como "unidad central de análisis". Eso sigue siendo cierto **para el análisis** — pero la unidad de **trabajo** del opositor es el Tema:

- "Hoy me toca el 47."
- "El 112 lo tengo abandonado."
- "El 15 ya lo canto en tiempo."

El intento es el átomo; el tema es la molécula con la que el usuario razona. Hoy el detalle de tema es un botón de Practicar y una lista de intentos — un índice, no una ficha. La **Ficha de tema** (¿cuándo lo canté por última vez? ¿cuántas veces? ¿cómo evoluciona? ¿qué notas tengo? ¿qué me conviene hacer ahora?) no es una funcionalidad más de la lista: es la pieza que da sentido a casi todas las demás. La "evolución por tema" que propuse como funcionalidad independiente es, en realidad, **una sección de la ficha**. Los marcadores y las notas desembocan en ella. La vuelta al temario es el agregado de todas las fichas.

**Corrección**: no hay "evolución por tema" como feature suelta. Hay una Ficha de tema, y la evolución vive dentro.

## Error 3: iba a improvisar la semántica feature a feature

"Olvidado", "reciente", "cobertura", "vuelta", "pendiente" — propuse tres funcionalidades que usan estos conceptos sin definirlos una sola vez. Si cada feature improvisa su definición, en seis meses "olvidado" significa una cosa en la ficha, otra en la extracción ponderada y otra en Progreso. Esa deriva semántica es exactamente el tipo de deuda que el flujo spec-first de este proyecto existe para evitar.

**Corrección**: antes de construir ficha, vuelta o extracción ponderada, hace falta un modelo conceptual que las tres consuman. Ver §3.

---

# 2. Qué agrupo bajo un mismo modelo conceptual

Las que antes eran cinco entradas separadas del ranking son en realidad **un solo arco de producto** sobre una sola base semántica:

```txt
                define-topic-insights-model
                 (la semántica, una vez)
                          │
        ┌─────────────────┼─────────────────────┐
        ▼                 ▼                     ▼
  Ficha de tema    La vuelta al temario   Extracción ponderada
  (un tema en      (todas las fichas      (la bola, sesgada
   profundidad)     en agregado)           hacia lo olvidado)
                          │
                          ▼
                 Progreso (ya existente)
            se realinea sobre el mismo modelo
```

Llamo a este arco **el Ciclo de estudio**. Es la respuesta de producto a la pregunta diaria del opositor ("¿qué canto hoy y cómo voy?"), y es lo que convierte OpoSpeak de archivo en herramienta de decisión — sin tocar la frontera de la IA ni la de la productividad.

---

# 3. La pieza nueva: `define-topic-insights-model`

## ¿Debe existir antes que las funcionalidades? Sí.

Es el mismo patrón que ya funcionó en este proyecto: el esquema fue CloudKit-compatible un mes antes de activar CloudKit, y `targetDelta` existió en el modelo meses antes del cronómetro. Definir la semántica una vez, consumirla N veces.

## Qué debe responder

- **Qué sabe OpoSpeak de un tema** (hechos derivables): nº de intentos, fechas primera/última práctica, tiempo acumulado, serie de duraciones, serie de targetDelta, notas asociadas.
- **Estados derivados y sus definiciones exactas**: qué significa *reciente*, *olvidado*, *pendiente* (nunca practicado), *frecuente*. Decisión clave a tomar en la spec: ¿"olvidado" es un umbral fijo (>N días) o relativo al ritmo del propio usuario (p. ej., percentil de su distancia media entre prácticas)? Mi inclinación: relativo con mínimo absoluto — un opositor en vuelta rápida y otro en vuelta lenta no comparten umbral.
- **Qué es una vuelta y qué es cobertura**: cuándo empieza, cuándo se completa, cómo se cuenta un tema dentro de la vuelta actual.
- **La frontera ética del modelo**: solo hechos y estados temporales — jamás juicios de calidad ("dominado", "flojo"), que la fundación veta explícitamente. *Olvidado* habla de tiempo, no de mérito.
- **Relación con `define-progress-and-history-model`**: ese documento define las proyecciones globales (volumen/consistencia/cobertura/distribución); el nuevo define el conocimiento a nivel de tema del que aquellas se derivan. Complementarios, no solapados — y la definición de "temas olvidados" que hoy vive embrionaria en el doc de progreso debe migrar/referenciarse aquí.

## Nombre

`define-topic-insights-model` es correcto y lo mantengo. Alternativas consideradas: `define-study-cycle-model` (describe la vuelta pero no la ficha) y `define-topic-knowledge-model` ("knowledge" sugiere contenido jurídico, que es justo lo que no almacenamos). "Insights" captura lo que es: lo que OpoSpeak puede decir de un tema a partir de hechos.

---

# 4. Nuevo Top 10 priorizado

| # | Qué | Por qué aquí | Complejidad | Riesgo |
|---|---|---|---|---|
| 0 | **`define-topic-insights-model`** | Prerrequisito semántico del arco completo. No es una feature: es la spec que evita tres definiciones divergentes de "olvidado" | Baja (es pensar, no construir) | Sobre-modelar: limitarlo a lo que #1-#3 necesitan |
| 1 | **La vuelta al temario** | Gana la prueba de la desaparición. Cambia el comportamiento diario (decidir qué cantar). El moat real frente a Voice Memos + Excel | Media | Deriva a planificador/productividad: sugiere, nunca programa |
| 2 | **Ficha de tema** | La unidad de trabajo del opositor, con la evolución (duraciones, targetDelta), las notas y el estado dentro. Absorbe la antigua "evolución por tema" | Media | Convertirla en dashboard: debe ser editorial, no panel de control |
| 3 | **Extracción aleatoria (la bola)** | Realismo del examen, barata, y la ponderación hacia olvidados/pendientes sale gratis del modelo de insights | Baja | Mínimo |
| 4 | **Simulacro multi-tema** | El formato real del examen (N temas, reloj global). Requiere la entidad intermedia ya anotada en la fundación. Candidato natural a valor premium | Media-alta | Tocar el modelo de dominio: spec cuidadosa |
| 5 | **Marcadores en la escucha** | Convierte la escucha en revisión activa; el artefacto perfecto para la sesión con preparador | Media | Bajo |
| 6 | **Import/restore del paquete** | Completa la promesa de propiedad de datos; el manifest ya lo soporta | Media | Bajo |
| 7 | **Objetivo de tiempo por oposición/tema** | Ya previsto en fundación; completa el cronómetro de examen | Baja | Bajo |
| 8 | **Compartir con preparador (ligero)** | Mejorar el export por intento (varios intentos, con marcadores). Sin cuentas, sin backend | Baja | **Alto si crece**: la versión con colaboración rompe local-first |
| 9 | **Métricas de voz locales** (velocidad, silencios) | Previstas en fundación; solo DSP local, sin IA | Media-alta | Deriva a juicio: presentar como hechos, nunca puntuación |
| 10 | **UI multi-oposición** | La costura existe; la demanda real llegará con usuarios que cambien de oposición | Baja | Bajo |

**Lo que sigue fuera, y por qué** (sin cambios respecto al análisis anterior, reafirmado):

- **Evaluación automática / nota IA** → rompe "datos > interpretación" y nos convierte en la grabadora-con-IA. Alternativa permanente: hechos longitudinales (#2) que humano y preparador interpretan.
- **Gamificación / rachas** → vetada por fundación. La constancia se muestra como hecho, no como cadena que romper.
- **Colaboración con cuentas** → arrastra backend e identidad. La alternativa es #8 ligero.
- **Contenido / temarios incluidos** → deriva academia. La alternativa es el import de listas propias.
- **Transcripción en la nube** → rompe privacidad. Si algún día: on-device, opt-in, y después de que el Ciclo de estudio exista.

---

# 5. Roadmap recomendado

## MVP — hecho
Temarios · Temas · Grabación · Historial · Notas · Indicadores básicos · Export · iCloud.

## MVP+ — hecho (refinamiento pre-release)
Pausa con auto-pausa en interrupciones · Cronómetro de examen con avisos silenciosos · `targetDelta` · Flujo decidir→colocar→cantar · Edición de tema.

## V1 — el Ciclo de estudio (la release que demuestra la tesis) — hecho 1–3
1. `define-topic-insights-model` (fundación, primero) ✓
2. **Ficha de tema** ✓ (consume el modelo; el detalle de tema se convierte en el centro de gravedad real)
3. **La vuelta al temario** ✓ (Estado del temario + Progreso como Evolución, sobre el mismo motor)

*Nota de secuencia*: por valor, la vuelta es nº 1; por construcción, la ficha va antes — la vuelta es un mapa cuyas celdas son fichas, y un mapa que lleva a un detalle pobre defrauda. El modelo de insights desbloquea ambas; la inversión orden-valor/orden-construcción es deliberada y barata porque comparten la misma base.

## Release / TestFlight — el foco actual
El cuello de botella ya no es técnico ni de producto: faltan opositores reales usando la app para descubrir qué genera hábito. Camino: QA manual en dispositivo · icono · CloudKit a producción (hubo renombres de entidades) · TestFlight. La validación clave: **¿se usa "Siguiente" de forma recurrente?** — ¿abren la app pensando "qué me toca hoy" o "quiero grabar lo que estoy estudiando"?

## V1.5 — la Extracción ponderada ("la bola") — **especificada, no programada**
4. **Extracción ponderada por insights** — spec completa en `openspec/changes/add-weighted-extraction` (2026-06-12), decisiones tomadas: bombo por temario · reextracción sin historial ni culpa · resultado visible antes de practicar · pesos derivados de los estados del modelo · transparencia en una línea. **Criterio de activación: evidencia de TestFlight de que "Siguiente" se usa de forma recurrente** — bola y Siguiente responden a "¿qué canto hoy?" con el mismo motor; si nadie usa la recomendación, hay que repensar la decisión antes de ritualizarla. Estratégicamente: una de las funcionalidades con más personalidad del producto — "un bombo inteligente que te saca lo que te conviene cantar sin que parezca una recomendación". Cierra la narrativa Ficha (un tema) → Vuelta (el conjunto) → Bola (la decisión). Idea anotada para entonces: la evolución "Hoy" de la home (¿Qué quieres cantar? — Tema recomendado · Sacar bola), las dos respuestas del mismo motor lado a lado.

## V2 — el Modo examen + profundidad
5. **Simulacro multi-tema** (con la entidad intermedia; el cronómetro global — en esencia, N bolas con reloj global: consume la extracción)
6. **Objetivos por oposición/tema**
7. **Marcadores en la escucha**
8. **Import/restore**

## Más adelante (con señal de usuarios, no antes)
Compartir con preparador ligero · Métricas de voz locales · UI multi-oposición · Exploración de transcripción on-device.

---

# 6. Recomendación final

**Siguiente paso único: escribir `define-topic-insights-model`.** Es deliberadamente poco glamuroso — y es la decisión correcta por tercera vez en este proyecto (CloudKit-compat antes de CloudKit, targetDelta antes del cronómetro): la semántica primero, las pantallas después. Con ese documento aprobado, Ficha → Vuelta → Extracción salen en cadena sobre una base que no se contradice.

La prueba de fuego no cambia: *¿ayuda a construir el historial completo del entrenamiento oral?* El Ciclo de estudio es la primera vez que el producto no solo guarda ese historial, sino que **lo devuelve convertido en decisión diaria**.

---

# 7. Documentos a actualizar si se aprueba este análisis

(Propuesta — no modificados todavía.)

| Documento | Cambio |
|---|---|
| `foundation/define-topic-insights-model.md` | **Crear** (la pieza nueva, vía change OpenSpec) |
| `foundation/define-progress-and-history-model.md` | Referenciar el nuevo modelo; migrar allí la definición embrionaria de "temas olvidados" |
| `foundation/define-information-architecture.md` | El detalle de tema pasa a ser la Ficha (el doc ya lo llama "centro de gravedad" — se refuerza); decidir dónde vive la Vuelta (¿pestaña Progreso evolucionada? ¿cabecera de Temarios?) — decisión de IA pendiente |
| `foundation/define-topic-management-flow.md` | La ordenación/filtrado de temas gana los estados del modelo de insights |
| `Current Context.md` | Dirección post-MVP: el Ciclo de estudio como V1 |
