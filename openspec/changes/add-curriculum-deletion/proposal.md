## Why

Attempts became deletable; the levels above did not follow. A topic cannot be deleted (only archived), a syllabus cannot be renamed (a typo at creation is forever) nor deleted (only archived). Data ownership applies at every level. The dangerous detail: model cascades exist (Syllabus → Topics → Attempts → satellites), but a raw `modelContext.delete` on a topic or syllabus would orphan every audio file underneath — deletion MUST go through the repository, which deletes files first.

## What Changes

- **`PracticeRepository.delete(topic:)` and `delete(syllabus:)`**: collect all recordings underneath, delete their files, then delete the model (cascade removes the rest). The single-deletion-path rule now covers the whole hierarchy.
- **Delete a topic**: swipe "Eliminar" in the syllabus's topic list + red "Eliminar tema" row at the bottom of the edit sheet (the HIG pattern for destructive actions on the edited object). Confirmation alert states the scale (attempts + recordings + notes). Deleting from the edit sheet pops the Ficha too — its subject is gone.
- **Rename a syllabus**: new edit sheet (name field), reachable from the syllabus detail toolbar — mirroring EditTopicSheet.
- **Delete a syllabus**: swipe "Eliminar" in the syllabi list + red row in the edit sheet; alert states the scale (topics + attempts + recordings).
- **Archive remains the gentle option** in all swipes: archive preserves history, delete destroys it — both visible, differently colored, differently confirmed.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `tema-management`: topic deletion (swipe + edit sheet) behind confirmation, via repository.
- `temario-management`: syllabus rename; syllabus deletion (swipe + edit sheet) behind confirmation, via repository.

## Impact

- Modified: `Storage/PracticeRepository.swift`, `Views/SyllabusDetailView.swift`, `Views/SyllabusListView.swift`, `Views/TopicDetailView.swift` (EditTopicSheet + pop), new `EditSyllabusSheet`.
- Tests: repository topic/syllabus deletion removes audio files (mirroring the attempt test). No schema changes.
