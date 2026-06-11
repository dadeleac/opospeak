## 1. Configuración

- [x] 1.1 Completar `opospeak.entitlements`: container CloudKit `iCloud.com.daviddeleonacosta.opospeak`, servicio CloudDocuments y `ubiquity-container-identifiers`
- [x] 1.2 Añadir `INFOPLIST_KEY_UIBackgroundModes = remote-notification` a los build settings

## 2. Ubicación y migración de grabaciones

- [x] 2.1 Implementar `RecordingLocation.resolve()`: contenedor ubicuo `Documents/Recordings` si está disponible (consultado fuera del hilo principal), local en caso contrario
- [x] 2.2 Implementar `RecordingMigrator.migrate(from:to:)`: copia-y-borra idempotente de `*.m4a`, fallos por archivo no destructivos
- [x] 2.3 Añadir `RecordingStore.availability(forGrabacionId:)`: disponible / descargando (placeholder `.icloud` + startDownloading) / ausente
- [x] 2.4 Centralizar la construcción del store (`AppEnvironment`) e inyectarlo en PracticeView, IntentoDetailView, AjustesView y ExportService

## 3. Contenedor CloudKit y estado

- [x] 3.1 `opospeakApp`: cadena de fallback CloudKit privado → local → fatalError, registrando el modo elegido
- [x] 3.2 Implementar `SyncStatus` (@Observable): modo del store + `CKContainer.accountStatus()` → activa / sin cuenta / no disponible
- [x] 3.3 Resolución async del contenedor ubicuo al arrancar + pase de migración idempotente en cada lanzamiento

## 4. UI

- [x] 4.1 `AjustesView`: fila de iCloud con el estado real (sin nagging)
- [x] 4.2 `IntentoDetailView`: estado "Descargando de iCloud…" con sondeo corto mientras la grabación se descarga, distinto de "no disponible"

## 5. Tests

- [x] 5.1 Test: `RecordingMigrator` mueve archivos, es idempotente y no destruye ante fallo por archivo
- [x] 5.2 Test: `RecordingLocation` resuelve local cuando no hay URL ubicua
- [x] 5.3 Test: detección de placeholder `.icloud` en `availability`
- [x] 5.4 Ejecutar la suite completa

## 6. Cierre

- [x] 6.1 Actualizar `Doc OpenSpeak/Current Context.md`
