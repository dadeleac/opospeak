## 1. Lógica pura

- [x] 1.1 `PracticeTimer.swift`: `TimerMode` (countUp/countdown), `PracticeTimerConfig` Codable con carga/guardado en UserDefaults (`practiceTimerConfig`)
- [x] 1.2 `WarningSchedule.crossedMarks(target:marks:previousElapsed:elapsed:)`: marcas restantes cruzadas en el intervalo, cero (exceso) incluido como cruce
- [x] 1.3 Tests de cruce: marca exacta, varias en un tick, ninguna repetida, marcas fuera de rango ignoradas, cruce de cero

## 2. Persistencia

- [x] 2.1 `PracticeService.finish` con `targetDuration: TimeInterval? = nil` → métrica `targetDelta` (duración − objetivo) en el mismo save solo si hay objetivo
- [x] 2.2 Test: countdown persiste targetDelta (positivo y negativo); count-up no crea la métrica

## 3. PracticeView

- [x] 3.1 Fase de preparación (recorder == nil): tema, selector de modo, duración objetivo (stepper de minutos + atajos), marcas de aviso (toggles filtrados por debajo del objetivo), botón Empezar prominente; configuración precargada de la última usada
- [x] 3.2 Empezar crea el recorder y arranca (permiso de micrófono en el toque); cancelar/dismiss libre en preparación
- [x] 3.3 Display de cuenta atrás: restante mientras ≥ 0, después "+exceso" en MutedRed con signo (nunca solo color); count-up intacto; pausa congela ambos modos
- [x] 3.4 Avisos desde `onChange(of: elapsed)`: háptica warning + estado visual Amber breve (icono + texto) + anuncio de VoiceOver; cruce de cero con MutedRed y "Tiempo agotado"
- [x] 3.5 Guardar la configuración al empezar; pasar `targetDuration` a `finish` en modo countdown

## 4. Verificación y docs

- [x] 4.1 Suite completa en verde
- [x] 4.2 Enmendar `define-practice-session-flow`: Preparación (configuración del cronómetro, inicio explícito), Información visible (dos modos, avisos silenciosos, exceso)
- [x] 4.3 Actualizar `Current Context.md`; nota de verificación manual: háptica real y avisos en dispositivo
