## 1. Lógica de sesiones

- [x] 1.1 Implementar `SesionPolicy`: decisión pura de reutilizar sesión (última actividad dentro de ventana de 30 min) o crear nueva
- [x] 1.2 Tests de `SesionPolicy`: dentro de ventana, fuera, exactamente en el límite, sin sesiones previas

## 2. Audio

- [x] 2.1 Implementar `PracticeRecorder` (@Observable, MainActor): sesión de audio `.playAndRecord` + `.spokenAudio`, permiso en contexto, AVAudioRecorder a la URL final de `RecordingStore`, cronómetro, estados idle/recording/finished/denied/failed
- [x] 2.2 Constantes de grabación: AAC, 44.1 kHz, mono, ~64 kbps
- [x] 2.3 Implementar `PlaybackController` (@Observable): AVAudioPlayer, play/pausa, progreso, stop al desaparecer
- [x] 2.4 Añadir `INFOPLIST_KEY_NSMicrophoneUsageDescription` a los build settings (Debug y Release)

## 3. Persistencia del intento

- [x] 3.1 Implementar `PracticeService.finish(...)`: aplica `SesionPolicy`, crea Intento + Grabación + Métrica duración total, actualiza fechaFin de la sesión, guarda una vez
- [x] 3.2 Implementar descarte: borrar archivo parcial vía `RecordingStore`, sin persistir nada
- [x] 3.3 Tests de `PracticeService` con contenedor en memoria y archivo de audio falso: persistencia completa, reutilización de sesión, sesión nueva fuera de ventana, descarte sin restos

## 4. Pantalla de práctica

- [x] 4.1 Implementar `PracticeView` (fullScreenCover): fase grabando con cronómetro, indicador de grabación, Finalizar y descarte discreto; `interactiveDismissDisabled`; pantalla despierta solo durante grabación
- [x] 4.2 Fase resumen: tema, duración, fecha, grabación disponible, botón Hecho
- [x] 4.3 Estado de permiso denegado: explicación y enlace a Ajustes del sistema, sin persistir nada
- [x] 4.4 Activar el botón Practicar en `TemaDetailView` → fullScreenCover con `PracticeView`

## 5. Reproducción

- [x] 5.1 Sección de reproducción en `IntentoDetailView`: play/pausa y progreso (transcurrido / total) cuando el archivo existe
- [x] 5.2 Estado "grabación no disponible" cuando los metadatos existen pero el archivo no

## 6. Verificación

- [x] 6.1 Compilar y ejecutar la suite completa en el simulador
- [x] 6.2 Actualizar `Doc OpenSpeak/Current Context.md`
