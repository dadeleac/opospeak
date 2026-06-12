# Design — add-live-audio-presence

## La matemática del nivel (pura)

`AudioLevelMeter` (Logic/AudioLevelMeter.swift), struct con estado mínimo:

- `normalize(power:)`: `averagePower` llega en dB (−160…0). Suelo de habla en −50 dB: por debajo es silencio (0); 0 dB es 1. Mapeo lineal en dB fijado a [0, 1] — para presencia visual basta y es predecible; nada de curvas exponenciales que amplifiquen el ruido de fondo.
- `smooth(_:)`: EMA asimétrica — ataque rápido (α≈0,5: el halo responde a la voz en ~2 muestras) y caída lenta (α≈0,12: el halo se relaja, no parpadea). El parpadeo era el riesgo señalado al diferir esta opción; la asimetría es la respuesta.

El recorder solo alimenta muestras; toda la calibración vive en constantes testeadas.

## El recorder

- `isMeteringEnabled = true` antes de `record()` (no altera el archivo: solo activa la medición).
- Timer de medición propio a ~15 Hz (1/15 s), separado del de elapsed (0,5 s): el reloj no necesita 15 Hz y el halo no puede vivir con 2 Hz. Solo corre en `.recording`; `pause()`/`stopRecorder()` lo invalidan y asientan `level = 0`.
- `private(set) var level: Double` observable — la vista no toca AVFoundation, como siempre.

## El halo

`AudioPresenceHalo(level:)` (Views): círculo con gradiente radial Sage que respira —
`scaleEffect(0.78 + 0.34·level)`, opacidad central `0.18 + 0.42·level`, sostenida hasta 2/3 del radio antes de desvanecerse (cuerpo, no tinte) — detrás del reloj, dentro del anillo en cuenta atrás y como única presencia en cronómetro. El nivel pasa por una curva perceptual (^0,7) antes de dibujar: a volumen conversacional el nivel medio ronda 0,4–0,5 y en lineal el halo era invisible sobre Paper (calibración corregida tras prueba en dispositivo). Animación `easeOut(0.1)` por muestra: el suavizado real ya lo hizo la EMA; la animación solo cose los fotogramas.

Con Reduce Motion (`@Environment(\.accessibilityReduceMotion)`): halo fijo en estado suave (nivel constante 0,3), sin seguir la voz.

Accesibilidad: `accessibilityHidden(true)` — es presencia, no información; el estado de grabación ya lo cuentan la línea de estado y VoiceOver.

## El punto que late

El punto rojo de "Grabando" escala suavemente (1 + 0,35·level) con el mismo nivel: la confirmación psicológica de "me está recogiendo" vive donde el ojo comprueba que graba. Decisión deliberada tras revisión: el aro NO reacciona a la voz — es el instrumento del tiempo (cada elemento, un trabajo) — y no hay texto "voz detectada" (telemetría en streaming que parpadea con las pausas naturales del discurso). Con Reduce Motion el punto queda fijo.

## Calibración

Objetivo: presencia, no vúmetro. A volumen conversacional el halo debe insinuarse, no dominar; en silencio, calma total (opacidad mínima visible solo grabando). La verificación es manual en dispositivo: hablar, callar, susurrar, y comprobar que nunca distrae del reloj.

## Qué NO entra

- Forma de onda histórica (scrubbing visual): otra feature, otro coste.
- Nivel persistido o métricas de volumen: el nivel es efímero, muere con la pantalla.
