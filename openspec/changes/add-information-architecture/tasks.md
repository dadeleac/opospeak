## 1. Modelo y lógica pura

- [x] 1.1 Añadir `activo: Bool = true` a `Temario` (aditivo, sin migración)
- [x] 1.2 Implementar `TemaBulkCreator.plan(existingNumbers:range:)` — números a crear, salta existentes, valida límites (inicio ≥ 1, fin ≥ inicio, total ≤ 1000)
- [x] 1.3 Implementar `TemaSortOrder` (natural, más practicados, menos practicados, últimos practicados, pendientes) con función pura de ordenación
- [x] 1.4 Implementar `ProgressSummary` — volumen, consistencia, cobertura y distribución derivados de intentos y temas

## 2. Shell de navegación

- [x] 2.1 Sustituir `ContentView` por `TabView` con tres pestañas (Temarios, Progreso, Ajustes), cada una con su `NavigationStack`, Temarios seleccionada al inicio
- [x] 2.2 Crear `AjustesView`: versión de la app, declaración de privacidad, filas placeholder de exportación e iCloud

## 3. Gestión de temarios

- [x] 3.1 `TemariosListView`: lista de temarios activos (nombre, nº de temas, actividad reciente) con estado vacío que invita a crear el primero
- [x] 3.2 Hoja de creación de temario (nombre obligatorio, descripción opcional; confirmar deshabilitado con nombre vacío)
- [x] 3.3 Archivar temario por swipe (oculta de la lista, conserva todo)

## 4. Gestión de temas

- [x] 4.1 `TemarioDetailView`: lista de temas activos (número, título, último intento, nº intentos; "Tema N" si no hay título)
- [x] 4.2 Búsqueda por número y título
- [x] 4.3 Selector de ordenación con los cinco órdenes
- [x] 4.4 Hoja de creación de tema individual (número sugerido = siguiente libre, título opcional)
- [x] 4.5 Hoja de alta rápida ("crear temas del 1 al N") usando `TemaBulkCreator`
- [x] 4.6 Archivar tema por swipe
- [x] 4.7 Estado vacío del temario con ambas vías de creación

## 5. Detalle de tema e intento

- [x] 5.1 `TemaDetailView`: info básica, botón Practicar prominente deshabilitado ("próximamente"), historial de intentos descendente con estado vacío
- [x] 5.2 Filas de intento: fecha, duración, indicadores de grabación y notas
- [x] 5.3 `IntentoDetailView`: fecha, duración, completado, lista de notas y añadir nota

## 6. Progreso

- [x] 6.1 `ProgresoView`: vista editorial con los cuatro grupos de indicadores desde `ProgressSummary`
- [x] 6.2 Estado vacío de Progreso (el progreso aparece al practicar)

## 7. Accesibilidad

- [x] 7.1 Etiquetas de accesibilidad en todos los controles y filas combinadas legibles por VoiceOver
- [x] 7.2 Solo text styles dinámicos (sin tamaños fijos); el color nunca es la única señal

## 8. Tests y verificación

- [x] 8.1 Tests de `TemaBulkCreator`: rango completo, salto de existentes, validación de límites
- [x] 8.2 Tests de `TemaSortOrder`: los cinco órdenes con datos representativos
- [x] 8.3 Tests de `ProgressSummary`: valores correctos con y sin intentos
- [x] 8.4 Compilar y ejecutar la suite completa en el simulador
- [x] 8.5 Actualizar `Doc OpenSpeak/Current Context.md`
