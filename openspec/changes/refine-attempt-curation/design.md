# Design — refine-attempt-curation

## El destacado

- `Attempt.isHighlighted: Bool = false` — aditivo con default: CloudKit-compatible, sin migración. Sincroniza como cualquier campo del intento.
- Toggle en `AttemptDetailView` como botón de toolbar (estrella junto a compartir): el gesto vive donde el usuario escucha y decide "esta es la buena".
- Estrella en `AttemptRow` (Historial de la Ficha) junto a los indicadores existentes (waveform, nota). `star.fill` en Amber — aquí el Amber es legítimo: es el acento de "esto importa", elegido por el usuario, no por la app.
- Export: clave española `destacado` en AttemptDTO. Aditiva — el contrato v2 se mantiene (los lectores existentes ignoran claves nuevas); el test de claves del contrato se actualiza para incluirla.
- Alcance mínimo deliberado: sin filtros, sin agregados, sin superficie en home. La fundación de la decisión: curación del usuario = hecho; cualquier lógica derivada del destacado sería juicio.

## Notas: editar y borrar

- Editar: tocar la nota en `AttemptDetailView` abre edición en línea (la fila se vuelve TextField con guardar). `createdAt` no cambia: la nota registra cuándo se hizo la observación, no cuándo se corrigió la errata. Sin `updatedAt`: no rendimos cuentas de las correcciones.
- Borrar: swipe (`onDelete`), sin alerta — la pérdida es una nota, proporcional al gesto. Contraste deliberado con descartar una grabación (alerta): el coste de cada destrucción dicta su fricción.

## Notas recientes en la Ficha

- El texto manda: `Text(note.content)` con 2–3 líneas, timestamp `abbreviated + shortened` como caption.
- Sigue navegando al intento al tocar, pero pierde el disfraz de lista de navegación: la sección es contenido para releer antes de volver a cantar — el post-it del banco de trabajo. Historial (debajo) sigue siendo el archivo cronológico; la redundancia de caminos es deliberada: dos preguntas distintas ("¿qué me dije?" vs "¿qué he hecho?").

## Qué NO entra

- Filtrar historial por destacados, destacados en home/Estado: a demanda real.
- Editar notas desde la Ficha (solo desde el intento, su casa).
- Marcadores temporales en la escucha: V2 (el destacado es su primo simple).
