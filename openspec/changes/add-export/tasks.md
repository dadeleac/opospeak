## 1. DTOs y CSV

- [x] 1.1 Implementar `ExportModels.swift`: structs Codable (Manifest, TemarioExport, TemaExport, SesionExport, IntentoExport con GrabacionExport embebida, MetricaExport, NotaExport) con mapeo desde los modelos SwiftData
- [x] 1.2 Encoder compartido: fechas ISO 8601, prettyPrinted + sortedKeys
- [x] 1.3 Builder de `intentos.csv` con cabecera de define-export-format y escapado RFC 4180

## 2. Servicio de exportación

- [x] 2.1 Implementar `ExportService.buildFullPackage()`: directorio `opospeak-export/` con manifest.json, data/*.json, intentos.csv y recordings/ (solo archivos existentes; counts del manifest reflejan lo copiado)
- [x] 2.2 Implementar `ExportService.buildIntentoPackage(intento:)`: intento.json (con contexto de tema/temario), notas.json y audio si existe
- [x] 2.3 Implementar `ExportArchiver`: zip nativo vía NSFileCoordinator (.forUploading) copiado a URL estable `opospeak-export.zip`

## 3. UI

- [x] 3.1 `AjustesView`: fila "Exportar mis datos" funcional con progreso, botón deshabilitado durante generación y share sheet con el zip
- [x] 3.2 `IntentoDetailView`: acción de compartir en la toolbar que genera el paquete reducido y abre el share sheet
- [x] 3.3 Wrapper `ShareSheet` (UIActivityViewController) compartido por ambos puntos de entrada
- [x] 3.4 Limpieza best-effort del directorio temporal tras compartir

## 4. Tests

- [x] 4.1 Test: paquete completo contiene manifest, los 6 JSON, el CSV y recordings/ con los archivos copiados
- [x] 4.2 Test: counts del manifest coinciden con el contenido (incluido el caso de grabación con archivo ausente)
- [x] 4.3 Test: los JSON son decodificables y las relaciones por id se reconstruyen (intento → tema → temario)
- [x] 4.4 Test: el audio exportado es byte a byte idéntico al original
- [x] 4.5 Test: CSV con cabecera correcta, una fila por intento y escapado de comas/comillas en nombres
- [x] 4.6 Test: paquete de intento único con y sin grabación
- [x] 4.7 Test: `ExportArchiver` produce un zip real a partir de un directorio
- [x] 4.8 Ejecutar la suite completa

## 5. Cierre

- [x] 5.1 Actualizar `Doc OpenSpeak/Current Context.md`
