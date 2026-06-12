# Tasks — refine-attempt-curation

## 1. Modelo y export

- [x] 1.1 `Attempt.isHighlighted: Bool = false` (aditivo, CloudKit-compatible)
- [x] 1.2 `destacado` en AttemptDTO (clave española, aditiva al contrato v2); actualizar el test de claves del contrato

## 2. Destacado en la UI

- [x] 2.1 Toggle de estrella en la toolbar de `AttemptDetailView`
- [x] 2.2 Estrella (`star.fill`, Amber) en `AttemptRow` junto a los indicadores existentes

## 3. Notas: editar y borrar

- [x] 3.1 Edición en línea en `AttemptDetailView` (tocar la nota → TextField + guardar); `createdAt` intacto
- [x] 3.2 Borrado por swipe sin alerta

## 4. Notas recientes como contenido

- [x] 4.1 Fecha + hora en el timestamp; el texto manda, el timestamp es caption
- [x] 4.2 Presentación de contenido (no fila de navegación), conservando el toque → intento

## 5. Verificación y docs

- [x] 5.1 Tests: round-trip del destacado, editar/borrar nota persiste, export incluye `destacado`
- [x] 5.2 Suite completa en verde; `Current Context.md`
