# Tasks — add-weighted-extraction

> **Especificada, no programada.** No empezar la sección 1 hasta cumplir la 0.

## 0. Criterio de activación

- [ ] 0.1 Evidencia de TestFlight: opositores reales usan "Siguiente" de forma recurrente (señal cualitativa suficiente; si no la hay, repensar la decisión antes de ritualizarla)
- [ ] 0.2 Decidir la superficie con lo aprendido: junto a Siguiente en Estado, o evolución "Hoy" de la home (conversación de IA propia)

## 1. Lógica pura

- [ ] 1.1 `Logic/WeightedExtraction.swift`: pesos por estado (pending 4 / forgotten 3 / current 2 / recent 1, provisionales), generador inyectable, exclusión de archivados
- [ ] 1.2 Tests: determinismo con semilla, distribución por conteo, un solo tema, temario vacío, todos recientes ≈ uniforme

## 2. El momento de la bola

- [ ] 2.1 Pantalla del resultado: número + título como bola, "Cantar este tema" (prominente) → flujo de práctica estándar, "Sacar otra bola" (secundario, reemplaza sin registro)
- [ ] 2.2 Línea de transparencia ("Salen más los temas que llevas más tiempo sin cantar")
- [ ] 2.3 Bombo por temario; selector si la oposición tiene varios

## 3. Verificación y docs

- [ ] 3.1 Suite completa en verde
- [ ] 3.2 Enmendar fundación (define-topic-insights-model: semántica de extracción) y Current Context
- [ ] 3.3 Verificación manual: el ritual completo bola → cantar en dispositivo
