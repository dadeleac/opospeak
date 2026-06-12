# Tasks — refine-recording-screen

## 1. Geometría pura

- [x] 1.1 `CountdownRingGeometry` en Logic/PracticeTimer.swift: `remainingFraction(target:elapsed:)` fijada a [0, 1] y `markFractions(target:marks:)` (fracción restante `mark/target`, filtrando fuera de (0, target))
- [x] 1.2 Tests: fracción al empezar/mitad/agotado/exceso; marcas dentro y fuera de rango; objetivo no positivo

## 2. Anillo de cuenta atrás (B)

- [x] 2.1 `Views/CountdownRing.swift`: pista, arco restante desde arriba en sentido horario, ticks por ángulo, atenuación de ticks cruzados, estado de exceso en MutedRed, animación suave de la fracción
- [x] 2.2 Integrar en `recordingView` (countdown): anillo alrededor del reloj + caption "objetivo N min"; count-up intacto
- [x] 2.3 Anillo lleno y estático con ticks en la pantalla "Listo" (countdown)
- [x] 2.4 Afinado tras revisión: trazo a 6 pt (proporción del Temporizador del sistema) y ticks monocromos (Paper con borde Ink, muesca en la correa) — el Amber queda reservado para el momento del aviso

## 3. Momento del aviso (C)

- [x] 3.1 Cápsula de material (campana + etiqueta) bajo el reloj con transición de muelle y espacio reservado; la línea de estado deja de mostrar avisos
- [x] 3.2 Pulso único del reloj al cruzar cualquier marca (incluido el cero)
- [x] 3.3 Hápticas diferenciadas: `.warning` en marcas intermedias, `.error` en el agotamiento

## 4. Jerarquía de controles (D)

- [x] 4.1 Pausar (prominente) + Finalizar (bordered) en fila, mitades iguales
- [x] 4.2 Descartar práctica a menú "···" en la toolbar (solo grabando/en pausa) con alerta centrada de confirmación (el action sheet desde menú de toolbar se ancla como popover flotante); cancelar pre-grabación sigue libre
- [x] 4.3 Plantearse descartar pausa la grabación antes de la alerta; cancelar la deja en pausa hasta Reanudar explícito (coherente con las interrupciones: reanudación solo manual)

## 5. Verificación y docs

- [x] 5.1 Suite completa en verde
- [x] 5.2 Enmendar `define-practice-session-flow` (Avisos, Información visible) y `Current Context.md`
- [ ] 5.3 Verificación manual en dispositivo: hápticas diferenciadas, fluidez del anillo, pulso

## 6. Transición Listo → Grabando sin saltos

- [x] 6.1 Esqueleto único `sessionView` para reposo y grabación: el reloj (anillo + cifra + caption) ocupa el mismo sitio en ambos momentos; ranuras de altura fija para estado (48 pt) y cápsula de aviso (44 pt)
- [x] 6.2 Solo cambia el contenido de las ranuras (instrucción ↔ estado de grabación, Grabar ↔ Pausar/Finalizar) con fundido `.snappy` sobre el estado del recorder

## 7. Coherencia del cronómetro ascendente

- [x] 7.1 Escenario de tamaño fijo (240×240) en ambos modos y todos los estados: el halo entra y sale sin redistribuir la pantalla
- [x] 7.2 En cronómetro, solo la pista del anillo como escenario común (fracción 0, sin marcas): coherencia visual sin inventar semántica — la cuenta atrás añade la información real
