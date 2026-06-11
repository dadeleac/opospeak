## 1. Modelo

- [x] 1.1 `SyllabusHealth` (alDía = recent+current, necesitaRepaso = forgotten, sinPracticar = pending) como agregado del modelo: `TopicInsightsModel.health(_:)`
- [x] 1.2 Tests de salud: conteos correctos, decaimiento (un tema cruza el umbral y cambia de grupo), temario vacío

## 2. Presentación de estados

- [x] 2.1 `TopicStateStyle`: tres etiquetas visibles (Sin practicar / Al día / Necesita repaso); reciente = "Al día" con matiz (icono relleno, tinte Sage más intenso); explicaciones de una frase conservadas por estado interno

## 3. Tarjeta

- [x] 3.1 Retitular a "Estado del temario": barra de al día / total + desglose "X al día · Y necesitan repaso · Z sin practicar" (grupos a cero omitidos); sin vuelta, sin sugerencias

## 4. Detalle

- [x] 4.1 Sección de salud (barra + desglose) con la posición de rotación como línea secundaria ("Vuelta N · M de T practicados en esta vuelta")
- [x] 4.2 Fila "Siguiente": cabeza de la ordenación canónica + razón factual ("Hace N días sin práctica" / "Todavía no lo has cantado") → Ficha
- [x] 4.3 Grupos capados a 5 con "Ver todos (N)" → lista completa por estado (`StateGroupDestination` + navigationDestination)
- [x] 4.4 Leyenda del mapa con tres entradas; matiz de reciente en celdas

## 5. Documentación y cierre

- [x] 5.1 Enmendar `define-topic-insights-model`: salud del temario, estados visibles (con la nota del matiz "necesita"), vuelta como concepto interno, Siguiente
- [x] 5.2 Actualizar la sección de la Vuelta en `define-information-architecture`
- [x] 5.3 Suite completa en verde; actualizar `Current Context.md`
