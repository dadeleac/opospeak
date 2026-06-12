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

## 5. Refinamiento del flujo (decidir → colocar → cantar)

- [x] 5.1 Preparación comprimida: chip de resumen de una línea pulsable que despliega el formulario solo a demanda; acción "Continuar" (no graba nada)
- [x] 5.2 Pantalla "Listo": invitación a colocar el móvil, reloj en reposo (objetivo o 0:00) y "Grabar" como único botón que enciende el micrófono
- [x] 5.3 Permiso de micrófono en Continuar (`PracticeRecorder.requestPermission()`), para que el diálogo no interrumpa tras colocar el móvil
- [x] 5.4 Vocabulario auditado: Continuar / Grabar / Pausar / Reanudar / Finalizar / Hecho; "Empezar" queda solo en el onboarding
- [x] 5.5 Cancelar libre también en "Listo"; spec y fundación enmendadas
- [x] 5.6 Editor de configuración como hoja del sistema desde abajo (altura completa, HIG) al tocar el chip de resumen; la práctica permanece a pantalla completa (inmersiva)

## 6. Aviso "A mitad de tiempo" (marca relativa)

- [x] 6.1 `PracticeTimerConfig.halfTimeWarning` (Bool, por defecto desactivado) con decodificación tolerante: configs guardadas sin la clave caen a sus valores por defecto en vez de invalidarse
- [x] 6.2 `effectiveWarningMarks()`: marcas absolutas + mitad del objetivo si está activada, deduplicadas (la mitad puede coincidir con un preset) y filtradas por debajo del objetivo
- [x] 6.3 `handleWarnings` consume las marcas efectivas; la marca de mitad se etiqueta como hito ("Mitad de tiempo", no cifra redondeada) en flash y anuncio de VoiceOver
- [x] 6.4 Toggle "A mitad de tiempo" en la sección Avisos con detalle dinámico ("Con este objetivo, cuando queden 7 min 30 s"); chip de resumen incluye "mitad"
- [x] 6.5 Tests: round-trip con la nueva clave, payload legado sin la clave, escala con el objetivo, deduplicación y filtrado; configurabilidad total diferida a demanda real
- [x] 6.6 Chip de resumen rediseñado en dos líneas deliberadas (titular "Cuenta atrás · 10 min" + caption "Avisos a mitad y al quedar 5, 2 y 1 min"): sin primas (′), lista española real y sin saltos de línea accidentales
