# Tasks — add-live-audio-presence

## 1. Matemática pura del nivel

- [x] 1.1 `Logic/AudioLevelMeter.swift`: `normalize(power:)` (suelo −50 dB → 0, 0 dB → 1, fijado a [0, 1]) y `smooth(_:)` (EMA asimétrica: ataque rápido, caída lenta)
- [x] 1.2 Tests: fijación a los extremos, suelo de silencio, el ataque alcanza la voz más rápido de lo que la caída la suelta, el silencio asienta a cero

## 2. Medición en el recorder

- [x] 2.1 `isMeteringEnabled` antes de grabar; timer de medición ~15 Hz separado del de elapsed, solo en `.recording`
- [x] 2.2 `level: Double` observable alimentado por `AudioLevelMeter`; pausa, finalizar y descartar asientan el nivel a cero y paran el timer

## 3. El halo

- [x] 3.1 `Views/AudioPresenceHalo.swift`: gradiente radial Sage, escala y opacidad por nivel, oculto a accesibilidad
- [x] 3.2 Integrar detrás del reloj en `sessionView` (dentro del anillo en cuenta atrás); en reposo no aparece
- [x] 3.3 Reduce Motion: halo fijo en estado suave, sin seguir la voz
- [x] 3.4 Calibración tras dispositivo: gradiente con cuerpo (sostenido a 2/3 del radio), techo de opacidad 0,60 y curva perceptual ^0,7
- [x] 3.5 El punto rojo de "Grabando" late con el nivel (decisión: el aro no reacciona a la voz; sin texto "voz detectada")

## 4. Verificación y docs

- [x] 4.1 Suite completa en verde
- [x] 4.2 Enmendar `define-practice-session-flow` (Información visible) y `Current Context.md`
- [ ] 4.3 Verificación manual en dispositivo: hablar/callar/susurrar — presencia, no vúmetro; pausa visiblemente quieta; Reduce Motion
