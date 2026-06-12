# Design — refine-recording-screen

## El anillo (B)

`CountdownRing` es una vista tonta; toda la aritmética vive en `CountdownRingGeometry` (Logic/PracticeTimer.swift), pura y testeada:

- `remainingFraction(target:elapsed:)` → 1 al empezar, 0 al agotarse, fijado a [0, 1] (el exceso no "des-vacía" el anillo).
- `markFractions(target:marks:)` → posición de cada marca como fracción restante (`mark / target`), filtrando marcas fuera de (0, target).

Dibujo: `Circle().trim(from: 0, to: fraction)` rotado −90° (el arco restante nace arriba y se vacía en sentido horario, como el Temporizador del sistema). Pista de fondo en `.quaternary`; arco en Ink; en exceso, pista en MutedRed con opacidad suave. Ticks como círculos pequeños posicionados por ángulo (−90° + 360°·fracción); un tick se atenúa cuando `fraction > remainingFraction` (su aviso ya sonó). Animación implícita suave sobre la fracción (el tick de cada segundo fluye).

El anillo corre sobre tiempo grabado (elapsed del recorder): la pausa lo congela gratis, igual que las marcas. Tamaño fijo (~240 pt) — esta pantalla es un reloj, no un layout adaptable complejo.

En "Listo" (countdown) el anillo se muestra lleno y estático con sus ticks: anticipa la práctica y hace comprensibles los avisos antes de empezar.

## El momento del aviso (C)

`flashingMark` ya existe y dura 4 s; cambia su presentación, no su mecánica:

- Cápsula `.regularMaterial` (campana Amber + etiqueta) bajo el reloj, `transition(.scale.combined(with: .opacity))` con `.spring`. Espacio reservado de altura fija para que el reloj no salte.
- Pulso del reloj: estado `clockPulse` que escala 1.0 → 1.04 → 1.0 con un muelle corto al cruzar cualquier marca (también el cero).
- Hápticas: marcas intermedias `.warning`; cero `.error` (más contundente). `UINotificationFeedbackGenerator`, sin CoreHaptics: dos niveles bastan y no añadimos un motor háptico propio.

La línea de estado (Grabando / En pausa / Tiempo agotado) deja de hacer doble servicio: ya no muestra avisos.

## Los controles (D)

- `HStack`: Pausar/Reanudar `.borderedProminent` + Finalizar `.bordered`, ambos `.large`, mitades iguales. Un solo gesto prominente: el que no destruye nada.
- Descartar va a un menú `ellipsis.circle` en la toolbar (solo grabando/en pausa) con `confirmationDialog`: borra el audio irreversiblemente y HIG pide confirmación para lo destructivo no recuperable. Cancelar pre-grabación sigue libre: no hay nada que perder.
- Caption "objetivo N min" en `.footnote` `.tertiary` bajo el reloj (countdown): el "11:58" por fin dice de cuánto es.

## Qué NO entra

- Medición de nivel de micrófono (presencia de audio en vivo): cambio propio futuro — toca el recorder y exige calibración fina.
- Sonidos: jamás; micrófono abierto.
