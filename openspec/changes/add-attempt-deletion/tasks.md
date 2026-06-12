# Tasks — add-attempt-deletion

## 1. UI

- [x] 1.1 Swipe en las filas del Historial (Ficha) → alerta → `PracticeRepository.delete`
- [x] 1.2 Menú "···" en el detalle del intento con "Eliminar intento" (destructivo) → misma alerta → borrar + volver

## 2. Verificación y docs

- [x] 2.1 Suite en verde (el camino de borrado ya está testeado en DomainModelTests)
- [ ] 2.2 `Current Context.md`; verificación manual: borrar desde swipe y desde detalle, cancelar no borra
