# Design — add-weighted-extraction

**Estado: especificada, no programada.** Ver criterio de activación al final.

## La lógica pura

`WeightedExtraction` (Logic/WeightedExtraction.swift):

- `draw(insights: [TopicInsight], using generator: inout some RandomNumberGenerator) -> UUID?`
- Pesos por estado, constantes con nombre (provisionales, a calibrar):
  - pending: 4 — nunca cantado, lo que más conviene sacar
  - forgotten: 3 — posible refinamiento: +peso con los días sin cantar
  - current: 2
  - recent: 1
- Generador inyectable: tests deterministas con semilla fija; distribución verificable por conteo sobre miles de extracciones.
- Excluye archivados (los insights ya llegan filtrados a temas activos, como en el resto de superficies).
- Casos borde: un solo tema (sale siempre), temario vacío (nil), todos recientes (≈ uniforme).

Los pesos consumen `TopicState`, no umbrales propios: si el modelo de insights evoluciona, la bola hereda el cambio. Cuarta superficie del mismo motor — Ficha, Estado, Progreso, Bola.

## El momento

```text
        🎱  (o equivalente sobrio de la casa)

        Tema 27
        Responsabilidad civil contractual

        [ Cantar este tema ]   (prominente)
        [ Sacar otra bola ]    (secundario)
```

- El resultado se muestra siempre; jamás se salta a grabar. "Cantar este tema" abre el flujo de práctica estándar (preparación → listo → Grabar), que ya está a la altura del ritual.
- Línea de transparencia bajo el resultado: "Salen más los temas que llevas más tiempo sin cantar."
- Sacar otra reemplaza la bola con una transición breve. Sin contador, sin lista, sin registro.

## Dónde vive (decisión diferida a la implementación)

Dos candidatas, a resolver con lo aprendido en TestFlight:

1. Junto a "Siguiente" en Estado del temario: las dos respuestas a "¿qué canto hoy?" lado a lado — la racional (recomendación factual) y la ritual (el sorteo).
2. La evolución "Hoy" de la home: "¿Qué quieres cantar? — Tema recomendado · Sacar bola". Más carácter, pero es un cambio de arquitectura de información que merece su propia conversación.

El bombo es por temario en ambos casos (los ritmos de Civil/Penal/Procesal son distintos; los exámenes sortean por bloques). La extracción global queda para simulacros (V2), que en esencia son N bolas con reloj global.

## Qué NO es

- No gamificación: sin rachas, sin culpa, sin historial de rechazos (vetado por fundación).
- No "la app decide": el usuario siempre puede elegir cualquier tema por las vías de siempre.
- No conocimiento nuevo: la bola consume el motor de insights; no crea semántica propia.

## Criterio de activación

No es "cuando haya hueco". Es: **cuando TestFlight dé evidencia de que "Siguiente" se usa de forma recurrente.** Bola y Siguiente responden a la misma pregunta con el mismo motor; si los opositores reales ignoran la recomendación determinista, lo que hay que repensar es la decisión, no ritualizarla. Si la señal llega, esta spec se implementa tal cual.
