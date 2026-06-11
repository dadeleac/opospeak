
## **Estado**

Propuesto

---

# **Objetivo**

Definir la experiencia de primer arranque de OpoSpeak.

Este documento describe qué ocurre desde que el usuario abre la aplicación por primera vez hasta que realiza su primera práctica.

No define diseño visual ni implementación técnica.

---

# **Principio fundamental**

El onboarding no enseña la aplicación.

El onboarding lleva al usuario a su primera práctica cuanto antes.

La mejor explicación de OpoSpeak es practicar un tema.

---

# **Resultado esperado**

Al terminar el primer arranque, el usuario debe haber conseguido:

- una estructura mínima de estudio
- al menos un tema disponible
- comprender que la acción central es practicar

Idealmente, haber grabado ya su primer intento.

---

# **Lo que el onboarding NO es**

No es un tutorial de varias pantallas.

No es una secuencia de permisos al inicio.

No es una recogida de datos personales.

No es una cuenta obligatoria.

---

# **Filosofía de fricción**

```txt
Abrir
   ↓
Oposición
   ↓
Temario
   ↓
Temas
   ↓
Practicar
```

Cada pantalla añadida entre abrir y practicar debe justificarse.

---

# **Primer arranque**

## **Estado inicial**

La aplicación arranca sin temarios ni temas.

No hay datos de ejemplo permanentes.

---

## **Pantalla de bienvenida**

Una única pantalla breve.

Comunica, en pocas palabras:

- qué es OpoSpeak
- que el usuario va a empezar creando su primer temario
- que sus datos son privados y locales

Acción única:

```txt
Empezar
```

---

## **Regla**

La bienvenida es opcional de leer y rápida de pasar.

No bloquea, no obliga a leer, no encadena pantallas.

---

# **Creación de la oposición**

Es el primer paso real.

---

## **Información solicitada**

Solo:

- nombre de la oposición

---

## **Ayuda contextual**

Se ofrecen ejemplos como sugerencia, no como obligación:

```txt
Judicatura
Notarías
Inspección de Hacienda
```

El usuario puede escribir la suya libremente.

---

# **Creación del primer temario**

Tras la oposición, su primer temario.

---

## **Información solicitada**

Solo:

- nombre del temario

Todo lo demás es opcional y puede completarse después.

---

## **Ayuda contextual**

Ejemplos a nivel de temario, nunca nombres de oposición:

```txt
Civil
Penal
Procesal
```

El nombre de la oposición permanece visible como contexto.

---

# **Creación de los primeros temas**

## **Decisión**

Tras crear el temario, se ofrece de inmediato el alta rápida de temas.

---

## **Alta rápida**

El camino recomendado en el primer arranque.

```txt
¿Cuántos temas tiene tu temario?
   ↓
Crear temas del 1 al N
```

Resultado:

```txt
Tema 1
Tema 2
Tema 3
...
Tema N
```

Esto evita la creación manual tema a tema, que sería tediosa con temarios largos.

El comportamiento detallado del alta rápida se define en `define-topic-management-flow`.

---

## **Alternativa**

El usuario que lo prefiera puede crear un único tema y empezar.

No se le obliga a definir el temario completo.

---

# **Permisos**

## **Principio**

Los permisos se piden en el momento en que se necesitan.

No al inicio.

---

## **Micrófono**

Se solicita al iniciar la primera práctica, no antes.

El contexto explica por qué:

```txt
OpoSpeak necesita el micrófono para grabar tu práctica oral.
```

---

## **iCloud**

No se solicita nada explícito en el onboarding.

La continuidad mediante iCloud sigue la cuenta del sistema, como define `define-local-first-data-strategy`.

El estado de sincronización se consulta y gestiona desde Ajustes.

---

# **Invitación a la primera práctica**

Tras crear los temas, el usuario llega a la lista de temas.

El estado de esa lista invita de forma evidente a practicar el primer tema.

```txt
Tema 1
   ↓
Practicar
```

---

## **Objetivo**

Cerrar el círculo del primer arranque con una acción, no con una explicación.

El primer intento es la mejor demostración del producto.

---

# **Estados vacíos como onboarding continuo**

El onboarding no termina en la primera sesión.

Los estados vacíos siguen guiando:

```txt
Sin intentos en un tema → invitar a practicar
Sin progreso todavía    → explicar que aparece al practicar
Sin notas en un intento → invitar a añadir una observación
```

Cada estado vacío enseña el siguiente paso natural.

---

# **Lo que se difiere**

No se solicita en el primer arranque:

- configuración de objetivos de duración
- organización por bloques
- estados de tema
- ajustes de exportación
- preferencias avanzadas

Todo ello se descubre cuando el usuario lo necesita.

---

# **Reanudación**

Si el usuario abandona el onboarding a mitad:

- los datos creados se conservan
- al volver, continúa donde lo dejó
- nunca se pierde un temario o tema ya creado

El onboarding no es una transacción de todo o nada.

---

# **Restricciones estratégicas**

No introducir una cuenta obligatoria.

No introducir una secuencia larga de pantallas explicativas.

No pedir permisos por adelantado.

No bloquear el uso hasta completar una configuración.

No mostrar datos de ejemplo que el usuario deba borrar luego.

---

# **Métrica de éxito**

Un usuario nuevo debe poder:

1. Abrir la aplicación.
2. Crear su primer temario.
3. Generar sus temas.
4. Practicar el primero.

en menos de dos minutos y sin leer documentación.

---

# **Resultado esperado**

El primer arranque debe dar una sensación inmediata de orden y de control.

El usuario no debe sentir que está configurando una herramienta.

Debe sentir que ya ha empezado a entrenar.

---

Una tentación habitual sería añadir un carrusel de bienvenida explicando las virtudes del producto: local-first, privacidad, historial a largo plazo.

Lo evitaría.

El opositor no necesita que le convenzan con pantallas. Necesita cantar un tema y ver que ha quedado guardado. Esa primera grabación, recuperable y suya, comunica la propuesta de valor mejor que cualquier texto.

El onboarding ideal de OpoSpeak es casi invisible: el usuario cree que simplemente ha empezado a usar la aplicación, cuando en realidad ya ha creado su estructura de estudio y su primer intento.
