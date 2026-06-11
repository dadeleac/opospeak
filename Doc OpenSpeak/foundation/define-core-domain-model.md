## **Estado**

Propuesto

---

## **Objetivo**

Definir el modelo de dominio principal de OpoSpeak.

Este documento describe las entidades, relaciones y responsabilidades del sistema desde una perspectiva de negocio.

No define persistencia, UI ni implementación técnica.

---

# **Principio fundamental**

OpoSpeak no gestiona audios.

OpoSpeak gestiona entrenamiento oral.

Las grabaciones son únicamente evidencia de ese entrenamiento.

---

# **Visión conceptual**

```txt
Temario
 └── Tema
      └── Sesión
            └── Intento
                   ├── Grabación
                   ├── Métricas
                   └── Notas
```

---

# **Lenguaje ubicuo**

Todos los documentos, código y especificaciones futuras deben utilizar la terminología definida aquí.

---

# **Temario**

## **Definición**

Conjunto organizado de temas pertenecientes a una oposición.

---

## **Ejemplos**

- Judicatura
- Fiscalía
- Notarías
- Inspección de Hacienda

---

## **Responsabilidades**

- Agrupar temas
- Mantener orden lógico
- Servir como contexto de trabajo

---

## **No almacena**

- Grabaciones
- Métricas
- Resultados

---

## **Atributos mínimos**

```txt
Id
Nombre
Descripción opcional
FechaCreación
FechaActualización
```

---

# **Tema**

## **Definición**

Unidad de estudio individual que puede ser cantada.

---

## **Ejemplos**

- Tema 1
- Tema 25
- Tema 178

---

## **Responsabilidades**

- Representar contenido entrenable
- Agrupar intentos históricos
- Permitir análisis longitudinal

---

## **Atributos mínimos**

```txt
Id
TemarioId
Número
Título
Activo
FechaCreación
FechaActualización
```

---

# **Sesión**

## **Definición**

Bloque de entrenamiento realizado por el opositor.

Una sesión representa un momento concreto de práctica.

---

## **Ejemplos**

- Sesión del lunes por la mañana
- Simulacro con preparador
- Repaso rápido de tarde

---

## **Principio**

Una sesión puede contener varios intentos.

---

## **Atributos mínimos**

```txt
Id
FechaInicio
FechaFin
Duración
Tipo
Observaciones
```

---

# **Tipo de sesión**

Inicialmente:

```txt
Práctica individual
Preparador
Simulacro
```

La lista debe ser extensible.

---

# **Intento**

## **Definición**

Ejecución concreta de un tema dentro de una sesión.

Es la entidad central del producto.

---

## **Ejemplo**

```txt
Sesión:
  12 mayo

Intento:
  Tema 42
  11m 48s
  Grabado
```

---

## **Principio**

Todo análisis histórico se construye alrededor de los intentos.

No alrededor de las sesiones.

---

## **Responsabilidades**

- Vincular tema y sesión
- Registrar duración
- Asociar grabación
- Asociar métricas
- Asociar notas

---

## **Atributos mínimos**

```txt
Id
TemaId
SesiónId

FechaInicio
FechaFin

DuraciónReal

Completado
```

---

# **Grabación**

## **Definición**

Archivo de audio asociado a un intento.

---

## **Principios**

Una grabación pertenece a un único intento.

Un intento puede existir sin grabación.

---

## **Responsabilidades**

- Conservar evidencia del intento
- Permitir escucha posterior
- Permitir exportación

---

## **Atributos mínimos**

```txt
Id
IntentoId

Duración
Tamaño
Formato

FechaCreación
```

---

# **Métricas**

## **Definición**

Información cuantitativa obtenida durante un intento.

---

## **Objetivo**

Permitir visualizar evolución.

No evaluar conocimientos jurídicos.

---

## **Ejemplos iniciales**

```txt
Duración total

Diferencia frente al objetivo

Fecha de realización
```

---

## **Futuras métricas posibles**

```txt
Velocidad de habla

Pausas

Muletillas

Tiempo por bloque

Silencios
```

---

# **Nota**

## **Definición**

Observación asociada a un intento.

Puede provenir del opositor o del preparador.

---

## **Ejemplos**

```txt
Demasiado rápido al inicio

Olvidé la clasificación final

Mucho mejor que la semana pasada
```

---

## **Principio**

Las notas son contexto.

No sustituyen al audio.

---

## **Atributos mínimos**

```txt
Id
IntentoId

Contenido
FechaCreación
```

---

# **Relaciones**

## **Temario → Tema**

```txt
1:N
```

Un temario contiene muchos temas.

---

## **Tema → Intento**

```txt
1:N
```

Un tema puede haberse cantado cientos de veces.

---

## **Sesión → Intento**

```txt
1:N
```

Una sesión puede incluir múltiples temas.

---

## **Intento → Grabación**

```txt
1:0..1
```

---

## **Intento → Métricas**

```txt
1:N
```

---

## **Intento → Notas**

```txt
1:N
```

---

# **Historial**

El historial no es una entidad propia.

Es una proyección construida a partir de:

```txt
Intentos
+
Grabaciones
+
Métricas
+
Notas
```

---

# **Estadísticas**

Las estadísticas no son entidades persistentes.

Son vistas derivadas del historial.

Ejemplos:

- Temas más practicados
- Temas olvidados
- Tiempo acumulado
- Evolución mensual
- Distribución por temario

---

# **Futuras extensiones**

El modelo debe permitir incorporar más adelante:

## **Transcripción**

```txt
Intento
 └── Transcripción
```

---

## **Análisis de voz**

```txt
Intento
 └── VoiceAnalysis
```

---

## **Informes**

```txt
Periodo
 └── Informe
```

---

## **IA local**

```txt
Intento
 └── Insights
```

---

# **Restricciones estratégicas**

No almacenar contenido completo de los temas.

No modelar legislación.

No modelar preguntas tipo test.

No modelar exámenes escritos.

No modelar preparación teórica.

El dominio siempre gira alrededor del entrenamiento oral.

---

Hay una decisión que todavía no cerraría aquí porque merece un spec propio:

**¿El opositor canta “un tema” o “una extracción de varios temas”?**

Por ejemplo:

- Judicatura → 5 temas seguidos.
- Notarías → configuraciones distintas.
- Algunas oposiciones → exposiciones de varios bloques.

Sospecho que acabaremos necesitando una entidad intermedia tipo:

```txt
Attempt
 └── Performance
       ├── Tema 12
       ├── Tema 48
       └── Tema 102
```

pero para el primer dominio yo no la introduciría todavía. La dejaría como decisión abierta para no complicar el modelo antes de validar el MVP.