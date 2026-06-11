## 1. Recorder

- [x] 1.1 Estado `paused` + `pause()`/`resume()` en `PracticeRecorder` (mismo archivo, cronómetro congelado, re-aserción de la sesión de audio al reanudar con fallback a `.failed`)
- [x] 1.2 `finish()` válido desde `.recording` y `.paused`
- [x] 1.3 Observer de `AVAudioSession.interruptionNotification`: `.began` → auto-pausa; `.ended` → permanece en pausa (reanudación manual); observer retirado al parar

## 2. Persistencia

- [x] 2.1 `PracticeService.finish` recibe `duration` explícita (tiempo grabado del recorder) en lugar de derivarla de fechas
- [x] 2.2 `PracticeView` pasa `recorder.elapsed` como duración

## 3. UI

- [x] 3.1 Fase de grabación con dos temperaturas: Grabando (MutedRed) ⇄ En pausa (Amber, icono y texto — nunca solo color); control primario Pausar/Reanudar; Finalizar y descarte siempre disponibles
- [x] 3.2 Idle timer deshabilitado solo en `.recording` (en pausa la pantalla puede dormirse); `interactiveDismissDisabled` en ambos estados

## 4. Tests

- [x] 4.1 Test clave: `finish` persiste la duración pasada, no `endedAt − startedAt` (valores deliberadamente divergentes, como una práctica con pausa)
- [x] 4.2 Actualizar llamadas existentes de los tests de `PracticeService` a la nueva firma
- [x] 4.3 Suite completa en verde

## 5. Documentación

- [x] 5.1 Enmendar la sección "Pausa" de `define-practice-session-flow`: decisión revertida deliberadamente, motivos originales desmentidos, semántica de la duración
- [x] 5.2 Actualizar `Current Context.md`
- [x] 5.3 Nota de verificación manual en dispositivo: pausa/reanudación real y llamada entrante
