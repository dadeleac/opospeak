## 1. Dominio

- [x] 1.1 Implementar `Oposicion.swift` (@Model: id, nombre, descripcion opcional, activo, fechas, relación `temarios` cascade con inverso)
- [x] 1.2 `Temario`: añadir `oposicion: Oposicion?` e inicializador que exige la oposición
- [x] 1.3 Registrar `Oposicion` en el esquema de la app y en los esquemas de tests/previews
- [x] 1.4 Implementar `OposicionBackfill.run(context:)`: adopta temarios huérfanos bajo "Mi oposición", idempotente, síncrono en el arranque
- [x] 1.5 Resolución de oposición activa (`@AppStorage("oposicionActivaId")` → primera → nil) en un único helper

## 2. Onboarding

- [x] 2.1 Nueva fase oposición (ejemplos: Judicatura, Notarías, Inspección de Hacienda) antes de la fase temario (ejemplos: Civil, Penal, Procesal; contexto de la oposición visible)
- [x] 2.2 Persistencia por transición: oposición al salir de su fase, temario al salir de la suya
- [x] 2.3 `OnboardingDecision`: condición `tieneDatos` (oposiciones u huérfanos) en lugar de `tieneTemarios`

## 3. UX

- [x] 3.1 `TemariosListView`: filtrar por oposición activa; título de navegación = nombre de la oposición; estado vacío con ejemplos de temario
- [x] 3.2 `NuevoTemarioSheet`: contexto de la oposición y ejemplos corregidos (Civil, Penal, Bloque I); creación bajo la oposición activa
- [x] 3.3 `AjustesView`: fila "Oposición" editable (solo renombrar)
- [x] 3.4 `TemaDetailView`: hoja de edición de tema (número con unicidad excluyéndose a sí mismo, título vacío permitido → nil)
- [x] 3.5 `ProgresoView`: indicadores calculados sobre la oposición activa
- [x] 3.6 Revisar copys y previews: Judicatura siempre como oposición; Civil/Penal como temarios

## 4. Export v2

- [x] 4.1 `OposicionExport` + `oposicionId` en `TemarioExport`; `oposiciones.json` en el paquete
- [x] 4.2 Manifest `version: 2` + `counts.oposiciones`; CSV con columna `oposicion`
- [x] 4.3 Exportar TODAS las oposiciones (no solo la activa)

## 5. Documentación

- [x] 5.1 `define-core-domain-model`: Oposición como raíz, ejemplos corregidos, relaciones
- [x] 5.2 `define-product-foundation`: cadena de dominio y ejemplos
- [x] 5.3 `define-topic-management-flow`: flujo oposición → temario → temas, ejemplos por nivel
- [x] 5.4 `define-onboarding-flow`: nueva fase oposición
- [x] 5.5 `define-information-architecture`: mapa de entidades y título de navegación
- [x] 5.6 `define-export-format`: formato v2
- [x] 5.7 `Current Context.md`

## 6. Tests y verificación

- [x] 6.1 Actualizar suites existentes al nuevo árbol (Oposicion("Judicatura") → Temario("Civil"))
- [x] 6.2 Tests nuevos: relación y cascade de Oposición, backfill idempotente, export v2, decisión de onboarding, unicidad al editar número de tema
- [x] 6.3 Suite completa en verde
