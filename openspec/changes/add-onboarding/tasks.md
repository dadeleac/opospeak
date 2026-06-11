## 1. Lógica

- [x] 1.1 Implementar `OnboardingDecision.debeMostrarse(completado:tieneTemarios:)`: mostrar / omitir-y-marcar (caso de datos restaurados por iCloud)
- [x] 1.2 Tests de las cuatro combinaciones de la decisión

## 2. Vista de onboarding

- [x] 2.1 `OnboardingView` con tres fases: bienvenida (una pantalla, acción única "Empezar", privacidad visible), nombre del temario (solo nombre, ejemplos pulsables, confirmar deshabilitado vacío), temas ("¿Cuántos temas tiene tu temario?" con stepper y atajos, "Prefiero añadirlos después")
- [x] 2.2 Persistencia por transición de fase: el temario se inserta al salir de la fase 2; los temas (vía `TemaBulkCreator`) al finalizar la fase 3 — el abandono conserva lo completado
- [x] 2.3 Cierre interactivo permitido; `onDisappear` marca `onboardingCompletado` siempre

## 3. Integración

- [x] 3.1 `ContentView`: `NavigationPath` propio de la pestaña Temarios pasado al `NavigationStack` existente
- [x] 3.2 Mostrar el fullScreenCover según `OnboardingDecision` con `@AppStorage("onboardingCompletado")`; marcar en silencio si hay datos restaurados
- [x] 3.3 Al completar: append del temario creado al path → el usuario aterriza en la lista de temas

## 4. Verificación

- [x] 4.1 Compilar y ejecutar la suite completa
- [x] 4.2 Actualizar `Doc OpenSpeak/Current Context.md`
