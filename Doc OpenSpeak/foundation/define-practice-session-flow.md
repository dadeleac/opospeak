
## **Estado**

Propuesto

---

# **Objetivo**

Definir el flujo principal mediante el cual un opositor realiza una práctica oral dentro de OpoSpeak.

Este flujo constituye la experiencia central del producto.

---

# **Principio fundamental**

El usuario no viene a grabar audios.

El usuario viene a practicar temas.

La grabación es una consecuencia de la práctica.

---

# **Resultado esperado**

Al finalizar una práctica el usuario debe haber conseguido:

- registrar un intento
- almacenar la grabación
- conservar el contexto del ejercicio
- disponer de información para futuras revisiones

---

# **Flujo conceptual**

```txt
Seleccionar tema
        ↓
Preparar práctica
        ↓
Iniciar intento
        ↓
Exposición oral
        ↓
Finalizar intento
        ↓
Guardar resultado
        ↓
Revisión posterior
```

---

# **Inicio de práctica**

## **Punto de entrada principal**

El usuario selecciona un tema que desea practicar.

---

## **Información visible**

Como mínimo:

- número de tema
- nombre del tema
- historial reciente
- fecha del último intento

---

# **Preparación**

Antes de comenzar la práctica el usuario puede:

- revisar información del tema
- prepararse mentalmente
- configurar el cronómetro

---

## **Configuración del cronómetro**

Dos modos:

- Cronómetro ascendente.
- Cuenta atrás con duración objetivo, como el reloj del examen oral.

En cuenta atrás, el usuario elige en qué marcas restantes recibir aviso.

---

## **Filosofía**

La preparación debe ser rápida.

La configuración se recuerda y se muestra como un resumen de una línea: la decisión habitual no paga el coste de la decisión excepcional.

El objetivo es empezar a cantar cuanto antes.

---

## **Tres momentos**

```txt
Decidir   → Preparación (resumen del cronómetro + Continuar)
Colocar   → Listo (sitúa el móvil en su soporte; nada se graba aún)
Cantar    → Grabar
```

El permiso de micrófono se pide en Continuar, para que el diálogo del sistema no interrumpa después de colocar el móvil.

Grabar es el único control que enciende el micrófono. Así las grabaciones no empiezan con los roces del móvil contra el atril.

---

# **Inicio de intento**

La grabación nunca arranca sola: comienza con la acción explícita del usuario (Grabar).

Cuando el usuario inicia un intento:

- comienza la medición temporal
- comienza la grabación de audio
- se crea un nuevo intento

---

## **Requisitos**

La aplicación debe minimizar la fricción.

Idealmente:

```txt
Tema
↓
Botón Practicar
↓
Grabando
```

---

# **Exposición oral**

Durante la exposición:

- el audio se registra continuamente
- el tiempo transcurrido es visible
- la aplicación evita distracciones

---

## **Prioridad**

La exposición oral es el foco principal.

La interfaz debe desaparecer.

---

# **Información visible durante la práctica**

Versión inicial:

- cronómetro (ascendente o restante, según el modo elegido)
- estado de grabación

---

## **Avisos en cuenta atrás**

Al cruzar cada marca elegida: vibración, señal visual y anuncio de VoiceOver.

Nunca sonido: el micrófono está abierto y un pitido quedaría en la grabación.

Al llegar a cero la grabación continúa, mostrando el exceso. Saber cuánto te pasas es dato; nada lo juzga.

La métrica diferencia objetivo (duración real − objetivo) permite responder con los años: ¿me ajusto al tiempo de examen?

---

## **No necesario inicialmente**

- métricas avanzadas
- análisis en tiempo real
- IA
- evaluaciones automáticas

---

# **Pausa**

## **Decisión inicial (revertida)**

La primera versión excluyó la pausa por tres temores técnicos: inconsistencias temporales, fragmentación de audio y dudas en métricas.

La implementación real los desmintió: la grabación nativa continúa en el mismo archivo sin cortes, el cronómetro mide solo tiempo grabado, y el hueco de la pausa no existe en el audio (las métricas futuras salen más limpias, no más sucias).

---

## **Decisión vigente**

La práctica puede pausarse y reanudarse.

La vida real interrumpe: llaman a la puerta, entra una llamada. Una grabación de veinte minutos descartada por una interrupción es peor que una pausa honesta.

---

## **Reglas**

- El audio continúa en el mismo archivo, sin hueco ni fragmento.
- La duración del intento es el tiempo realmente grabado, nunca el tiempo de pared transcurrido.
- Las interrupciones del sistema (llamadas, Siri) pausan automáticamente; la reanudación es siempre manual.
- Pausar no conlleva juicio: ninguna métrica lo penaliza. Es una herramienta personal de entrenamiento.

---

# **Finalización**

El usuario decide cuándo termina el intento.

---

## **Al finalizar**

La aplicación:

- detiene la grabación
- detiene el cronómetro
- guarda el audio
- guarda la duración
- persiste el intento

---

# **Pantalla de cierre**

Tras finalizar debe mostrarse un resumen sencillo.

---

## **Información mínima**

- tema
- duración
- fecha
- grabación disponible

---

# **Revisión posterior**

Cada intento debe poder revisarse posteriormente.

---

## **Acciones disponibles**

### **Escuchar grabación**

Objetivo principal.

---

### **Consultar duración**

Comparación con otros intentos.

---

### **Añadir notas**

Observaciones personales.

---

### **Compartir o exportar**

Cuando corresponda.

---

# **Sesiones**

## **Definición**

Una sesión agrupa uno o varios intentos realizados en un mismo bloque de entrenamiento.

---

## **Creación**

La sesión se crea automáticamente al iniciar la primera práctica.

---

## **Cierre**

La sesión finaliza automáticamente tras un periodo razonable de inactividad.

---

## **Objetivo**

Evitar que el usuario tenga que gestionar sesiones manualmente.

---

# **Casos futuros**

El flujo debe permitir añadir posteriormente:

---

## **Extracción aleatoria**

```txt
Práctica
↓
Tema aleatorio
↓
Intento
```

---

## **Varios temas consecutivos**

```txt
Tema 12
↓
Tema 48
↓
Tema 97
↓
Intento compuesto
```

---

## **Simulacro completo**

```txt
Selección
↓
Preparación
↓
Exposición
↓
Evaluación
```

---

## **Preparador**

```txt
Intento
↓
Notas externas
↓
Revisión conjunta
```

---

# **Restricciones estratégicas**

No convertir la práctica en una herramienta compleja de grabación.

No añadir controles propios de un editor de audio profesional.

No introducir análisis avanzados antes de validar el flujo principal.

---

# **Métrica de éxito**

Un usuario nuevo debe poder:

1. Elegir un tema.
2. Empezar a cantar.
3. Finalizar.
4. Revisar el resultado.

sin necesidad de leer instrucciones.

---

# **Resultado esperado**

Tras cientos de prácticas, el opositor debe percibir que OpoSpeak ha construido automáticamente su historial completo de entrenamiento oral.

La grabación es una funcionalidad.

El historial acumulado es el producto.

Hay una decisión de producto que yo resolvería antes de escribir el siguiente spec:

**¿El usuario entra en “Tema → Practicar” o entra en “Nueva sesión” y dentro añade temas?**

Para OpoSpeak, por lo que sabemos de Judicatura y similares, me inclino claramente por:

```txt
Tema
↓
Practicar
↓
Grabar
```

porque es mucho más natural para alguien que va a cantar un tema concreto. La entidad “Sesión” puede existir en el dominio sin convertirse en una pantalla visible para el usuario. Eso suele simplificar muchísimo la UX.