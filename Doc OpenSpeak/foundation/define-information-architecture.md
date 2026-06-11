
## **Estado**

Propuesto

---

# **Objetivo**

Definir la arquitectura de información del MVP de OpoSpeak.

Este documento describe qué pantallas existen, cómo se navega entre ellas y dónde vive cada concepto del dominio.

No define diseño visual ni implementación técnica.

---

# **Principio fundamental**

La acción central del producto es practicar un tema.

Toda la arquitectura debe acercar al usuario a esa acción y, después, devolverle su historial.

Cualquier pantalla que aleje del par **practicar / revisar** debe justificarse.

---

# **Resultado esperado**

El usuario debe entender la aplicación sin instrucciones.

Debe saber en todo momento:

- dónde están sus temas
- cómo practicar
- dónde está su historial
- dónde están sus ajustes

---

# **Modelo de navegación**

## **Decisión**

Navegación por pestañas en la base.

Profundización mediante `NavigationStack` dentro de cada pestaña.

---

## **Motivo**

Las pestañas son el patrón nativo de Apple para separar áreas estables y persistentes.

OpoSpeak tiene áreas claramente estables: estudiar, ver progreso y ajustar.

---

# **Pestañas del MVP**

```txt
[ Temarios ]   [ Progreso ]   [ Ajustes ]
```

Tres pestañas.

Ni una más en el MVP.

---

## **Por qué solo tres**

La práctica no es una pestaña.

La práctica es una acción que se lanza desde un tema.

El historial no es una pestaña.

El historial vive dentro de cada tema y se resume en Progreso.

---

# **Pestaña 1 — Temarios**

Es la pestaña principal y la que se muestra al abrir la aplicación.

---

## **Jerarquía**

```txt
Temarios
   └── Detalle de temario (lista de temas)
          └── Detalle de tema
                 └── Práctica
                 └── Detalle de intento
```

---

## **Pantalla: Lista de temarios**

Muestra los temarios del usuario.

Información mínima por temario:

- nombre
- número de temas
- actividad reciente

Acción principal:

```txt
Abrir temario
```

Acción secundaria:

```txt
Crear temario
```

---

## **Pantalla: Detalle de temario**

Es la lista de temas de ese temario.

Información mínima por tema:

- número o identificador
- título si existe
- último intento
- número de intentos

Controles disponibles:

- buscar
- ordenar
- filtrar
- crear tema
- alta rápida de temas

---

## **Pantalla: Detalle de tema**

Es el centro de gravedad de la aplicación.

Debe mostrar:

- información básica del tema
- historial de intentos
- evolución temporal sencilla
- acceso inmediato a practicar

---

### **Acción principal**

```txt
Practicar
```

Debe ser el elemento más visible y accesible de la pantalla.

---

## **Pantalla: Práctica**

Se lanza desde el detalle de tema.

Se presenta de forma modal y a pantalla completa.

La interfaz desaparece.

Solo se muestra:

- cronómetro
- estado de grabación
- finalizar

Al finalizar, se muestra la pantalla de cierre con el resumen del intento.

El flujo completo está definido en `define-practice-session-flow`.

---

## **Pantalla: Detalle de intento**

Se accede desde el historial del tema.

Permite:

- escuchar la grabación
- consultar duración y fecha
- leer y añadir notas
- compartir o exportar el intento

---

# **Pestaña 2 — Progreso**

## **Propósito**

Responder a la pregunta central del producto:

```txt
¿Estoy mejorando?
```

---

## **Contenido**

Es una vista editorial, no un panel de control.

Muestra los indicadores definidos en `define-progress-and-history-model`:

- volumen
- consistencia
- cobertura
- distribución

---

## **Alcance**

Progreso es una proyección global.

El detalle por tema siempre vive en el propio tema.

Progreso resume.

El tema profundiza.

---

# **Pestaña 3 — Ajustes**

## **Contenido del MVP**

- estado de sincronización iCloud
- exportación de datos
- privacidad
- información de la aplicación
- gestión de almacenamiento

---

## **Principio**

Ajustes no es un cajón de funcionalidades.

Solo contiene lo que no pertenece al flujo de práctica.

---

# **Dónde vive cada entidad**

```txt
Oposición    → Título de la pestaña Temarios + Ajustes (renombrar)
Temario      → Pestaña Temarios (lista, filtrada por la oposición activa)
Tema         → Detalle de temario
Sesión       → Invisible (gestión automática)
Intento      → Detalle de tema (historial)
Grabación    → Detalle de intento
Métricas     → Detalle de intento + Progreso
Notas        → Detalle de intento
Historial    → Detalle de tema + Progreso
```

---

# **El estado del temario**

## **Decisión**

El estado del temario vive en la pestaña Temarios, no en Progreso.

El criterio: Temarios responde "¿qué voy a practicar?"; Progreso responde "¿cómo voy?". El estado del temario responde a la primera pregunta.

---

## **Estructura**

```txt
Temarios (cabecera)
   └── Tarjeta "Estado del temario": salud
       (al día · necesitan repaso · sin practicar)
            └── Detalle: salud + posición de vuelta (secundaria),
                Siguiente (factual), mapa del temario,
                grupos capados con "Ver todos"
                     └── Cada tema → su Ficha
```

La pantalla de inicio deja de ser espacio vacío: comunica el estado real de la preparación antes de listar dónde ir.

---

## **Reglas**

- La tarjeta muestra salud, nunca rotación ni prescripción. "Vuelta" es vocabulario interno, visible solo en el detalle.
- "Siguiente" es la cabeza de la ordenación canónica con su razón factual — un tema, un hecho, un toque. Nada más se recomienda.
- Progreso permanece reflexivo e intacto.
- Toda la semántica (estados visibles, salud, vuelta, cobertura) proviene de `define-topic-insights-model`.

---

# **La oposición no es una pantalla**

## **Decisión**

La oposición activa da título a la pestaña Temarios (Judicatura arriba, sus temarios debajo) y se renombra desde Ajustes.

No existe selector de oposición en el MVP: la aplicación opera sobre una única oposición activa, aunque el dominio soporta varias.

---

# **La sesión no es una pantalla**

## **Decisión**

La entidad Sesión existe en el dominio.

No existe como pantalla en el MVP.

---

## **Motivo**

El usuario no quiere gestionar sesiones.

El usuario quiere cantar un tema.

La sesión se crea y se cierra automáticamente, como define `define-practice-session-flow`.

---

# **Un tema por intento en el MVP**

## **Decisión**

En el MVP, una práctica corresponde a un único tema.

La extracción de varios temas en un mismo intento queda fuera.

---

## **Motivo**

La extracción múltiple exige una entidad intermedia y una navegación más compleja.

Introducirla antes de validar el flujo básico añade riesgo sin validar nada.

El modelo de dominio ya queda preparado para incorporarla más adelante, como anota `define-core-domain-model`.

---

# **Punto de entrada de cada acción**

```txt
Crear temario   → Lista de temarios
Crear tema      → Detalle de temario
Practicar       → Detalle de tema
Revisar intento → Detalle de tema → Historial
Ver progreso    → Pestaña Progreso
Exportar        → Ajustes (global) o Detalle de intento (puntual)
```

Cada acción tiene un único punto de entrada principal.

No se duplican acciones en pantallas distintas sin motivo.

---

# **Estados vacíos**

Cada pantalla principal debe definir su estado vacío.

```txt
Sin temarios   → invitar a crear el primero
Sin temas      → invitar a añadir temas o usar alta rápida
Sin intentos   → invitar a practicar
Sin progreso   → explicar que el progreso aparece al practicar
```

Los estados vacíos son parte del producto, no un caso excepcional.

El flujo de primer arranque se define en `define-onboarding-flow`.

---

# **Restricciones estratégicas**

No añadir una pestaña de práctica.

No añadir una pestaña de historial separada del tema.

No convertir Progreso en un panel de control con métricas agresivas.

No esconder la acción Practicar bajo menús.

---

# **Métrica de éxito**

Un usuario nuevo debe poder, sin instrucciones:

1. Encontrar sus temas.
2. Abrir un tema.
3. Pulsar Practicar.
4. Volver y encontrar su historial.

---

# **Resultado esperado**

OpoSpeak debe sentirse como un cuaderno de entrenamiento.

Tres áreas estables.

Una acción central evidente.

Y un historial que siempre está a un toque de distancia.

---

Hay una tentación que evitaría desde el principio:

**No crear una pestaña “Practicar”.**

Parece intuitivo poner la acción más importante como pestaña fija. Pero practicar no existe en abstracto: siempre se practica *un tema concreto*. Si separamos la acción del tema, obligamos al usuario a elegir el tema dos veces y rompemos la conexión natural entre tema, intento e historial.

La acción Practicar debe nacer siempre desde el tema. Eso mantiene el modelo limpio y refuerza que el producto no es grabar, sino construir el historial de cada tema a lo largo de los años.
