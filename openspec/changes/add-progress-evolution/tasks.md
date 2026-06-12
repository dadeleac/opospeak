## 1. Modelo

- [x] 1.1 `TopicInsightsModel.statusSeries(topics:from:to:samples:)`: serie (fecha, estado) muestreada en la ventana, cada punto una evaluación completa en esa referencia
- [x] 1.2 Tests: extremos de la serie (el último punto = hoy), nº de muestras, historial vacío (todo sin practicar)

## 2. Fundación

- [x] 2.1 Revisar `define-progress-and-history-model`: frontera Estado/Evolución (Temarios = fotografía "¿qué hago ahora?"; Progreso = película "¿qué ha cambiado?"), indicadores reencuadrados como evolución en ventanas, traspaso explícito de la distribución al Estado del temario
- [x] 2.2 Actualizar la sección Progreso de `define-information-architecture` (su pregunta pasa a "¿qué ha cambiado?")

## 3. Pantalla Progreso

- [x] 3.1 Selector de ventana (30 días / 90 días / Todo; "Todo" desde el primer intento)
- [x] 3.2 Sección "En este periodo": prácticas, tiempo total, días con práctica (ProgressSummary sobre los intentos de la ventana)
- [x] 3.3 Sección "Evolución del temario": deltas "entonces → ahora" por estado visible con su estilo, y una única gráfica sobria (temas al día en la ventana, 12 muestras)
- [x] 3.4 Retirar distribución (vive en el mapa del Estado) y los contadores de consistencia (la ventana los reemplaza); estado vacío intacto; alcance: oposición activa

## 4. Verificación y cierre

- [x] 4.1 Suite completa en verde
- [x] 4.2 Actualizar `Current Context.md`

## 5. Rediseño de la Evolución tras revisión en dispositivo

- [x] 5.1 Sustituir filas de deltas + gráfica de línea por dos barras de composición ("antes" / "Hoy") con los colores de estado del mapa — el temario cambiando de color, mismo lenguaje visual ya aprendido
- [x] 5.2 Anclas temporales reales ("Hace 30 días" / "Hace 90 días" / "Al empezar" → "Hoy") en lugar de notación de flechas
- [x] 5.3 Frase narrativa como pie y como resumen de accesibilidad ("Hace 30 días tenías 0 temas al día; hoy tienes 2…")
- [x] 5.4 Compuerta de suficiencia: con menos de 14 días de historia, explicación tranquila en lugar de ruido; la gráfica de línea retirada (podrá volver como área apilada cuando meses de datos la justifiquen)
