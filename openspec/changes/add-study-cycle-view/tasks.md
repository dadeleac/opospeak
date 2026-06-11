## 1. Estilo compartido

- [x] 1.1 Extraer `TopicStateStyle` (etiqueta, icono, color, explicación por estado) a `Views/TopicStateStyle.swift`; la Ficha pasa a consumirlo

## 2. Tarjeta de Vuelta

- [x] 2.1 Tarjeta en la cabecera de `SyllabusListView`: vuelta actual, "N de M temas practicados" con barra sobria, "X temas olvidados" (oculto a cero), Ver detalle; toda la tarjeta navega al detalle
- [x] 2.2 Auto-ocultar sin temas (los estados vacíos siguen guiando); sin sugerencias ni copy prescriptivo

## 3. Detalle de la Vuelta

- [x] 3.1 `StudyCycleView` en el stack de Temarios: resumen de cobertura (vuelta + barra + N/M)
- [x] 3.2 Mapa del temario: LazyVGrid de celdas teñidas por estado con número de tema, leyenda icono+texto+color, etiqueta de accesibilidad por celda ("Tema 47, olvidado"), celda → Ficha
- [x] 3.3 Grupos factuales: Olvidados (práctica más antigua primero), Pendientes (por número), Recientes (más reciente primero); cada fila → Ficha
- [x] 3.4 Todo derivado de `TopicInsightsModel` — nada reimplementado, nada persistido

## 4. Documentación y verificación

- [x] 4.1 Actualizar `define-information-architecture`: dónde vive la Vuelta (cabecera de Temarios + drill-in), Progreso intacto, sugerencia diferida a Fase 3
- [x] 4.2 Suite completa en verde
- [x] 4.3 Actualizar `Current Context.md`

## 5. Corrección tras prueba en simulador

- [x] 5.1 Mapa: celdas como Button + destino programático único (`navigationDestination(item:)`) — varias NavigationLink en una misma fila de List duplicaban chevrons y un toque empujaba varias pantallas (volver del 20 recorría 19, 18, 17…)
