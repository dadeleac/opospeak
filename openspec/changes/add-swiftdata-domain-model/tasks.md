## 1. Estructura de modelos

- [x] 1.1 Crear el grupo `Models/` en el target `opospeak` del proyecto Xcode
- [x] 1.2 Implementar `Temario.swift` (@Model: id UUID con default, nombre, descripcion opcional, fechaCreacion, fechaActualizacion, relación `temas` cascade con inverso)
- [x] 1.3 Implementar `Tema.swift` (@Model: id, numero, titulo opcional, activo con default true, fechas, relación opcional a `Temario`, relación `intentos` cascade con inverso)
- [x] 1.4 Implementar `Sesion.swift` (@Model: id, fechaInicio, fechaFin opcional, tipo como String raw + enum `TipoSesion`, observaciones opcional, relación `intentos` nullify con inverso)
- [x] 1.5 Implementar `Intento.swift` (@Model: id, fechaInicio, fechaFin opcional, duracionReal con default 0, completado con default false, relaciones opcionales a `Tema` y `Sesion`, relación to-one `grabacion` cascade, relaciones `metricas` y `notas` cascade con inversos)
- [x] 1.6 Implementar `Grabacion.swift` (@Model: id, duracion, tamano, formato con default "m4a", fechaCreacion, relación opcional inversa a `Intento`; sin path absoluto)
- [x] 1.7 Implementar `Metrica.swift` (@Model: id, tipo como String raw + enum `TipoMetrica`, valor Double, fecha, relación opcional inversa a `Intento`)
- [x] 1.8 Implementar `Nota.swift` (@Model: id, contenido, fechaCreacion, relación opcional inversa a `Intento`)
- [x] 1.9 Añadir inicializadores que exijan el padre como parámetro requerido (Tema requiere Temario; Intento requiere Tema y Sesion; Grabacion/Metrica/Nota requieren Intento)

## 2. Almacenamiento de grabaciones

- [x] 2.1 Implementar `RecordingStore.swift`: resolución de URL `Application Support/Recordings/<id>.m4a` a partir del id de la grabación, creación del directorio si no existe
- [x] 2.2 Añadir a `RecordingStore` la eliminación del archivo de audio dado un id de grabación
- [x] 2.3 Implementar `PracticeRepository.delete(intento:)` que borra el archivo de audio antes de eliminar el modelo (punto único de borrado de intentos)

## 3. Integración en la aplicación

- [x] 3.1 Actualizar `opospeakApp.swift` para registrar el esquema con los siete modelos
- [x] 3.2 Sustituir el CRUD de `ContentView.swift` por una vista placeholder mínima que compile
- [x] 3.3 Eliminar `Item.swift` del proyecto
- [x] 3.4 Compilar el proyecto y verificar que el `ModelContainer` se inicializa sin errores en el simulador

## 4. Tests

- [x] 4.1 Crear helper de tests con `ModelContainer` en memoria (`isStoredInMemoryOnly: true`)
- [x] 4.2 Test: creación de temario con información mínima (solo nombre)
- [x] 4.3 Test: tema sin título se persiste y pertenece a su temario (relación en ambas direcciones)
- [x] 4.4 Test: intento completo vincula tema y sesión, registra duración y completado
- [x] 4.5 Test: intento sin grabación es válido (`grabacion == nil`)
- [x] 4.6 Test: borrar un intento elimina grabación, métricas y notas (cascade) y su archivo de audio vía `PracticeRepository`
- [x] 4.7 Test: borrar una sesión NO elimina sus intentos (nullify)
- [x] 4.8 Test: archivar un tema (activo = false) conserva intentos y satélites
- [x] 4.9 Test: `RecordingStore` resuelve URLs por id y elimina archivos correctamente
- [x] 4.10 Ejecutar la suite completa y verificar que pasa

## 5. Cierre

- [x] 5.1 Revisar que todas las relaciones declaran inverso y que no hay `#Unique` ni reglas `.deny` (compatibilidad CloudKit)
- [x] 5.2 Actualizar `Doc OpenSpeak/Current Context.md`: el modelo de dominio está implementado en SwiftData
