## **Estado**

Propuesto

---

# **Objetivo**

Definir los requisitos de accesibilidad de OpoSpeak basados en las Web Content Accessibility Guidelines (WCAG) y en las capacidades de accesibilidad del ecosistema Apple.

Este documento establece los criterios mínimos que deben cumplir todas las funcionalidades presentes y futuras.

---

# **Principio fundamental**

La accesibilidad no es una funcionalidad adicional.

Es una característica básica de calidad del producto.

---

# **Objetivo de cumplimiento**

OpoSpeak debe aspirar a un nivel equivalente a WCAG 2.2 AA en todas las experiencias razonablemente aplicables al entorno iOS.

---

# **Filosofía**

La aplicación debe poder utilizarse independientemente de:

- limitaciones visuales
- limitaciones auditivas
- limitaciones motoras
- limitaciones cognitivas
- edad del usuario

---

# **Principios WCAG**

---

# **Perceptible**

## **Objetivo**

La información debe poder percibirse de múltiples formas.

---

## **Texto legible**

Todo texto debe:

- ser escalable
- mantener contraste suficiente
- permanecer legible en cualquier tamaño soportado

---

## **Dynamic Type**

Toda la aplicación debe funcionar correctamente con Dynamic Type.

---

## **Requisitos**

No debe existir:

- texto truncado crítico
- contenido inaccesible
- controles inutilizables

cuando se utilizan tamaños de texto grandes.

---

## **Contraste**

Todo contenido textual debe mantener contraste adecuado respecto al fondo.

---

## **Aplicación**

Incluye:

- títulos
- subtítulos
- métricas
- estados
- botones
- mensajes de error

---

## **Información no dependiente del color**

El color nunca debe ser el único mecanismo para comunicar significado.

---

## **Ejemplos**

Incorrecto:

- verde = correcto
- rojo = incorrecto

sin contexto adicional.

---

## **Correcto**

Combinar:

- color
- icono
- texto

---

# **Operable**

## **Objetivo**

Toda funcionalidad debe poder utilizarse mediante tecnologías de asistencia.

---

# **VoiceOver**

Todos los elementos interactivos deben tener:

- etiqueta accesible
- descripción comprensible
- orden lógico de navegación

---

# **Navegación**

La navegación debe ser coherente y predecible.

---

## **Requisitos**

El usuario debe comprender:

- dónde está
- qué puede hacer
- cómo volver atrás

---

# **Objetivos táctiles**

Todos los controles deben respetar tamaños mínimos recomendados.

---

## **Objetivo**

Reducir errores de interacción.

---

# **Gestos**

Las acciones críticas no deben depender exclusivamente de gestos complejos.

---

## **Ejemplos**

Si existe un swipe:

Debe existir una alternativa accesible.

---

# **Comprensible**

## **Objetivo**

La aplicación debe resultar fácil de entender.

---

# **Lenguaje**

El contenido debe utilizar lenguaje claro y directo.

---

## **Evitar**

- tecnicismos innecesarios
- mensajes ambiguos
- terminología interna

---

# **Consistencia**

Los mismos elementos deben comportarse siempre igual.

---

## **Ejemplos**

Si una acción requiere confirmación:

Debe requerirla siempre.

---

# **Errores**

Los mensajes de error deben explicar:

- qué ocurrió
- qué impacto tiene
- qué puede hacer el usuario

---

# **Robusto**

## **Objetivo**

La aplicación debe funcionar correctamente con tecnologías de asistencia actuales y futuras.

---

# **Compatibilidad**

Debe verificarse compatibilidad con:

- VoiceOver
- Dynamic Type
- Ajustes de contraste
- Reducción de movimiento
- Bold Text

---

# **Flujos críticos**

Los siguientes flujos deben ser completamente accesibles.

---

## **Gestión de temas**

- crear tema
- editar tema
- archivar tema

---

## **Práctica oral**

- iniciar grabación
- detener grabación
- guardar intento

---

## **Reproducción**

- reproducir audio
- pausar audio
- navegar por historial

---

## **Exportación**

- iniciar exportación
- compartir archivo
- confirmar resultado

---

# **Accesibilidad de métricas**

## **Principio**

Las métricas deben ser comprensibles mediante lectura secuencial.

---

## **Evitar**

Representaciones exclusivamente visuales.

---

## **Requisito**

Toda visualización debe disponer de alternativa textual equivalente.

---

# **Accesibilidad de gráficos futuros**

Si se incorporan:

- tendencias
- distribuciones
- estadísticas

deben incluir:

- resumen textual
- descripción accesible
- información equivalente

---

# **Reducción de movimiento**

La aplicación debe respetar la configuración del sistema.

---

## **Requisito**

Si el usuario activa “Reducir movimiento”:

las animaciones deben minimizarse.

---

# **Modo oscuro**

Toda la aplicación debe funcionar correctamente en:

- modo claro
- modo oscuro

---

# **Estados vacíos**

Los estados vacíos deben ser comprensibles para:

- usuarios visuales
- usuarios de VoiceOver

---

# **Auditorías obligatorias**

Antes de cada versión relevante debe verificarse:

---

## **VoiceOver**

Flujos completos.

---

## **Dynamic Type**

Todos los tamaños soportados.

---

## **Contraste**

Pantallas principales.

---

## **Modo oscuro**

Flujos completos.

---

## **Reducción de movimiento**

Pantallas críticas.

---

# **Definición de terminado**

Una funcionalidad no se considera terminada hasta que:

- cumple los criterios WCAG aplicables
- funciona con VoiceOver
- funciona con Dynamic Type
- funciona en modo oscuro
- mantiene contraste adecuado

---

# **Resultado esperado**

Cualquier opositor debe poder utilizar OpoSpeak independientemente de sus necesidades de accesibilidad.

La accesibilidad debe estar integrada en el diseño desde el principio y no añadirse posteriormente como corrección.

Además, después de las auditorías que hiciste en Liroa, añadiría una regla organizativa que no estaba en aquella app:

Ninguna versión puede considerarse lista para TestFlight externo sin una pasada manual completa de VoiceOver y Dynamic Type.

Porque precisamente ese fue el hallazgo repetido en prácticamente todas las auditorías. O sea, no basta con decir “cumplimos WCAG”; hay que institucionalizar la comprobación manual dentro del proyecto.