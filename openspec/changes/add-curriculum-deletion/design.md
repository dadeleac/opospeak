# Design — add-curriculum-deletion

## El repositorio cubre toda la jerarquía

`PracticeRepository` gana `delete(topic:)` y `delete(syllabus:)`: recogen las grabaciones de todos los intentos por debajo, borran sus archivos y después borran el modelo (la cascada hace el resto). La regla "jamás `modelContext.delete` directo" sube de los intentos a temas y temarios — un borrado crudo dejaría huérfano cada audio.

## UI

- Swipes: "Eliminar" (destructivo, rojo) junto a "Archivar" (Amber) en la lista de temas y en la de temarios. Archivar conserva el historial; eliminar lo destruye — las dos opciones visibles, con fricción distinta (archivar directo, eliminar con alerta).
- Hojas de edición: fila roja al final ("Eliminar tema" / "Eliminar temario") — el patrón HIG de acción destructiva sobre el objeto editado. `EditSyllabusSheet` nuevo, espejo de `EditTopicSheet` (campo nombre, validación de no-vacío).
- Borrar el tema desde su hoja cierra también la Ficha (callback `onDelete` → dismiss): la pantalla se queda sin sujeto, como el detalle de intento.
- Alertas con escala real: el tema cuenta sus intentos; el temario, sus temas e intentos. El usuario confirma sabiendo qué pierde.

## Tests

Espejo del test de intentos: borrar tema/temario vía repositorio elimina los archivos de audio de debajo; los modelos caen por cascada.
