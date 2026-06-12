# Design — add-attempt-deletion

- Borrado siempre vía `PracticeRepository.delete(attempt:)` (punto único: el archivo muere con los modelos). Jamás `modelContext.delete` directo.
- Confirmación con alerta centrada en ambos caminos — audio irreversible; mismo criterio que Descartar práctica. Las notas (swipe sin alerta) marcan el contraste deliberado: el coste dicta la fricción.
- Historial: `swipeActions` con botón destructivo que abre la alerta (no `onDelete` directo, que ejecutaría sin confirmar).
- Detalle: menú "···" en la toolbar con "Eliminar intento" (destructivo); confirmar borra y hace `dismiss()` — la pantalla se queda sin sujeto.
- Consecuencia aceptada y documentada: los insights recalculan sin ese intento.
- Diferido: borrar solo el audio conservando el intento (gestión de almacenamiento) — cambio futuro propio.
