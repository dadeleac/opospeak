## 1. Sistema de color

- [x] 1.1 Crear colorsets con variantes claro/oscuro: Tinta, Pizarra, Arena, ArenaElevada, Salvia, Ambar, RojoApagado
- [x] 1.2 Actualizar AccentColor a Tinta (tinte global sin código)
- [x] 1.3 Implementar `Theme.swift`: tokens semánticos (`Color.tinta`, `.arena`, …) y modificador `.fondoEditorial()`

## 2. Aplicación

- [x] 2.1 Fondo editorial en las pantallas persistentes: TemariosListView, TemarioDetailView, TemaDetailView, IntentoDetailView, ProgresoView, AjustesView (las hojas de creación conservan fondo de sistema)
- [x] 2.2 Archivar: .orange → .ambar en los swipes de temario y tema
- [x] 2.3 Práctica: indicador de grabación y descarte .red → .rojoApagado; confirmación "Grabación guardada" .green → .salvia
- [x] 2.4 Onboarding: bienvenida con fondo Arena y acento Tinta

## 3. Verificación

- [x] 3.1 Test de resolución: cada color semántico existe en el catálogo
- [x] 3.2 Compilar y ejecutar la suite completa (sin cambios de comportamiento)
- [x] 3.3 Actualizar `Doc OpenSpeak/Current Context.md`
