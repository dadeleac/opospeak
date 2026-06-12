## 1. Modelo

- [x] 1.1 Honestidad de referencia en `evaluate`: filtrar intentos posteriores a la fecha de referencia antes de calcular estados, conteos, ciclo y cadencia
- [x] 1.2 Test: un intento futuro respecto a la referencia no existe para la evaluación (sin practicar, cadencia intacta)

## 2. Fundación

- [x] 2.1 Sección "Niveles de agregación" en `define-topic-insights-model`: tema → temario → oposición, mismo cálculo, distinto alcance; cadencia siempre de oposición (el ritmo es de la persona); honestidad de referencia como costura de la futura Evolución

## 3. Pantalla Estado

- [x] 3.1 Mapa por bloques cuando hay >1 temario activo: nombre del temario + desglose compacto del bloque + su rejilla; con 1 temario, pantalla idéntica a hoy
- [x] 3.2 Filas cualificadas (solo multi-temario): Siguiente, grupos y "Ver todos" muestran el temario como texto secundario ("Tema 1 — Civil"); sin códigos inventados
- [x] 3.3 Resumen global y Siguiente siguen siendo de oposición

## 4. Ficha

- [x] 4.1 Subtítulo de navegación con el nombre del temario

## 5. Verificación y cierre

- [x] 5.1 Suite completa en verde
- [x] 5.2 Actualizar `Current Context.md`

## 6. Refinado tras revisión en dispositivo

- [x] 6.1 Listas "Ver todos" por estado: búsqueda siempre visible (número, título y temario) y filtro por temario en la toolbar (Menu+Picker, solo con >1 temario); estado vacío de búsqueda
- [x] 6.2 Buscador de la lista de temas del temario siempre visible (navigationBarDrawer .always)
- [x] 6.3 El número nunca desaparece: `numberedDisplayName` ("4 · Título") en Siguiente, grupos y "Ver todos"; subtítulo de la Ficha con "Tema N — Temario" cuando hay título
- [x] 6.4 Mantener pulsado una celda del mapa revela su identidad — peek sin abandonar el mapa
- [x] 6.5 Corrección del peek: el contextMenu dentro de una fila de List se registraba una sola vez (siempre mostraba la primera celda) → gestos por celda + popover anclado con tarjeta propia (banda de estado tintada, título numerado, intentos, última práctica, Abrir ficha)
- [x] 6.6 Singular corregido en etiquetas temporales: "Hace 1 día" (helper daysAgoLabel compartido)
