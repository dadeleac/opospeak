## 1. Fundación

- [x] 1.1 Escribir `foundation/define-topic-insights-model.md`: hechos por tema, estados temporales con fórmulas exactas (cadencia, suelo absoluto, arranque en frío), vuelta y cobertura derivadas, ordenación de sugerencia, frontera sin juicios, relación con progress-and-history
- [x] 1.2 Realinear `foundation/define-progress-and-history-model.md`: la definición de "temas olvidados" pasa a referenciar el nuevo modelo; las proyecciones globales se documentan como derivaciones de la capa de tema

## 2. Lógica pura

- [x] 2.1 `Logic/TopicInsights.swift`: `TopicFacts` (proyección de entrada), `TopicState` (pendiente/reciente/alDia/olvidado), `StudyCycle` (vuelta, cobertura, cadencia), `TopicInsightsModel.evaluate` como calculador único con constantes nombradas
- [x] 2.2 Ordenación canónica de sugerencia (pendientes → olvidados más antiguos → al día → recientes) expuesta por el modelo

## 3. Tests

- [x] 3.1 Estados: fronteras exactas (7 días, suelo de 14, 2× cadencia), arranque en frío (cadencia por defecto), tema único, temario vacío
- [x] 3.2 Cadencia: mediana de intervalos agrupados, resistencia a outliers
- [x] 3.3 Vuelta y cobertura: posición intermedia, vuelta completada, tema nuevo a mitad de vuelta
- [x] 3.4 Ordenación de sugerencia: los cuatro grupos en orden, olvidados por antigüedad
- [x] 3.5 Suite completa en verde (sin cambios de comportamiento en lo existente)

## 4. Cierre

- [x] 4.1 Actualizar `Current Context.md` (V1 en marcha: modelo de insights aprobado e implementado)
