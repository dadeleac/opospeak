
## **Estado**

Propuesto

---

# **Objetivo**

Definir qué sabe OpoSpeak sobre un tema y qué significan exactamente los conceptos derivados de esa información: pendiente, reciente, al día, olvidado, vuelta y cobertura.

Este documento es la semántica única que consumen la Ficha de tema, la Vuelta al temario, la extracción ponderada y Progreso.

No define pantallas ni implementación técnica.

---

# **Principio fundamental**

El intento es la unidad de análisis.

El tema es la unidad de trabajo.

El opositor no piensa "mi intento 412 duró 14:48". Piensa "el tema 47 lo tengo abandonado".

Este modelo traduce los intentos (átomos) al lenguaje del tema (la molécula con la que el usuario razona).

---

# **Regla de oro**

Los estados hablan de tiempo.

Nunca de calidad.

"Olvidado" significa que ha pasado demasiado tiempo, no que se cante mal.

Quedan prohibidos en este modelo y en cualquier consumidor: dominado, flojo, suspenso, puntuaciones y cualquier juicio de mérito.

La práctica real es más fiable que cualquier etiqueta.

---

# **Hechos por tema**

Todo lo que el modelo sabe se deriva de entidades existentes. Nada se persiste: mismas entradas, mismas salidas.

```txt
Número de intentos
Fecha del primer intento
Fecha del último intento
Tiempo acumulado de práctica
Serie de duraciones
Serie de diferencias frente al objetivo (targetDelta)
Número de notas
```

---

# **Cadencia de revisita**

## **Definición**

Mediana de los intervalos entre intentos consecutivos del mismo tema, agrupando todos los temas practicados de la oposición activa.

---

## **Por qué la mediana**

Resiste valores extremos: unas vacaciones de tres semanas no deben redefinir el ritmo del opositor.

---

## **Arranque en frío**

Con menos de 5 intervalos disponibles, la cadencia por defecto es **21 días**.

Los estados quedan bien definidos desde el primer día.

---

# **Estados temporales**

Cada tema activo está exactamente en uno de cuatro estados:

## **Pendiente**

Nunca practicado.

```txt
intentos == 0
```

---

## **Reciente**

Practicado esta semana.

```txt
días desde el último intento ≤ 7
```

Fijo y universal: "esta semana" no necesita explicación.

---

## **Olvidado**

Más del doble de tu propio ritmo sin cantarlo.

```txt
días desde el último intento > max(14, 2 × cadencia)
```

El umbral es relativo al usuario: para quien rota cada 10 días, 25 días es olvido; para quien rota cada 30, es normalidad.

El suelo absoluto de 14 días evita umbrales absurdos en rachas de práctica intensiva.

---

## **Al día**

Practicado, ni reciente ni olvidado.

---

## **Explicabilidad**

Cada estado debe poder explicarse al usuario en una frase:

```txt
Pendiente  → "Todavía no lo has cantado."
Reciente   → "Lo cantaste esta semana."
Al día     → "Dentro de tu ritmo habitual."
Olvidado   → "Llevas más del doble de tu ritmo sin cantarlo."
```

---

## **Estados visibles**

Los cuatro estados internos se presentan al usuario como tres:

```txt
Interno              Visible
──────────────────────────────────
Pendiente            Sin practicar
Reciente             Al día (con matiz visual)
Al día               Al día
Olvidado             Necesita repaso
```

"Al día" y "Reciente" se pisaban para el usuario; reciente sobrevive como matiz (icono relleno, tinte más intenso) y sigue alimentando la ordenación interna.

Sobre "Necesita repaso": *necesita* habla de tiempo transcurrido relativo al ritmo propio — necesidad temporal, jamás mérito. Es más amable que "Olvidado", que roza la acusación. Todo consumidor debe mantener ese matiz.

---

## **El estado del temario**

La métrica de cobertura principal: cuántos temas hay en cada grupo visible.

```txt
2 al día
0 necesitan repaso
24 sin practicar
```

Se calcula sobre estados, así que **decae sola con el tiempo**: no se puede "completar" cantando cada tema una vez y parando cuatro meses. Es la respuesta honesta a "¿cómo llevo el temario?".

Deliberadamente NO se llama "salud": ese vocabulario (salud financiera, health score) pertenece al SaaS, no al opositor. El opositor pregunta "¿cómo llevo el temario?", "¿qué tengo abandonado?" — y la pantalla responde con sus palabras.

Los tres grupos se muestran siempre, incluidos los que están a cero: ver "0 necesitan repaso" enseña el vocabulario de estados antes de que haga falta.

La cobertura por vuelta es otra cosa: posición de rotación, secundaria.

---

# **La vuelta**

## **Definición**

Una vuelta es una pasada completa sobre los temas activos de la oposición activa.

```txt
Vuelta actual = mínimo de intentos entre los temas activos + 1
```

Una vuelta solo se completa cuando TODOS los temas activos se han cantado ese número de veces.

---

## **Cobertura de la vuelta**

```txt
Proporción de temas activos ya practicados en la vuelta actual
(intentos ≥ vuelta actual)
```

Ejemplo: 187 de 325 temas con al menos 3 intentos y el resto con 2 → vuelta 3, cobertura 187/325.

---

## **Temas nuevos a mitad de vuelta**

Añadir un tema sin practicar devuelve la vuelta a 1.

Es deliberado y honesto: la vuelta no está completa hasta que ese tema se cante. La cobertura muestra exactamente dónde está el hueco.

---

## **Visibilidad**

La vuelta es un concepto interno.

Aparece únicamente dentro del detalle del estado del temario — para las oposiciones cuya cultura piensa en vueltas (Judicatura) — y nunca como titular de la tarjeta de entrada. Quien prepara Hacienda no tropieza con el término.

---

## **Sin gestión**

La vuelta se deriva; nunca se gestiona.

No hay botón "empezar vuelta" ni fechas que mantener — la misma filosofía que las sesiones.

---

# **Ordenación de sugerencia**

## **Definición**

El orden canónico de "qué practicar ahora":

```txt
1. Pendientes
2. Olvidados (el de práctica más antigua primero)
3. Al día
4. Recientes
```

---

## **Qué es y qué no es**

Es una ordenación sobre hechos, consumida igual por la Ficha ("qué hacer ahora"), el estado del temario y la extracción ponderada.

Su cabeza puede mostrarse como **"Siguiente"**: un tema, su razón factual ("Hace 42 días sin práctica" / "Todavía no lo has cantado"), un toque a su Ficha. Sin puntuaciones ni teatro de urgencia.

No es un planificador: el modelo no produce horarios, fechas límite, planes ni listas clasificadas más allá de esa única cabeza. OpoSpeak no es una herramienta de productividad.

---

# **Relación con el modelo de progreso**

`define-progress-and-history-model` define las proyecciones globales (volumen, consistencia, cobertura, distribución).

Este documento define la capa de tema de la que aquellas se derivan.

La definición de "temas olvidados" vive aquí; el modelo de progreso la referencia.

---

# **Restricciones estratégicas**

No persistir estados ni estadísticas (son vistas derivadas).

No introducir juicios de calidad ni etiquetas de mérito.

No producir planificación: sugerir, jamás programar.

No configurar umbrales por tema en la primera versión: un modelo, explicable, con constantes nombradas en un único lugar.

---

# **Casos futuros**

El modelo debe permitir incorporar más adelante:

- cadencia por tema (si el uso real lo pide)
- pesos de extracción más finos
- señales adicionales como hechos (nunca como juicios)

---

# **Criterio de aceptación**

Una funcionalidad cumple este documento cuando:

- toda semántica temporal que muestra proviene de este modelo
- ningún texto juzga calidad
- el usuario puede entender cada estado en una frase

---

# **Resultado esperado**

Que "olvidado" signifique exactamente lo mismo en la Ficha de tema, en la Vuelta al temario, en la extracción y en Progreso.

Y que cuando el opositor pregunte "¿por qué este tema sale como olvidado?", la respuesta quepa en una línea y hable de su propio ritmo — nunca de un número mágico ni de un juicio.
