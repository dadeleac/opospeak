
## **Estado**

Propuesto

---

# **Objetivo**

Definir el formato del paquete de exportación y respaldo de OpoSpeak.

Este documento describe la estructura del paquete, el esquema de los datos y las reglas de portabilidad.

No define la interfaz de exportación ni la implementación técnica.

---

# **Principio fundamental**

La exportación es un derecho, no una funcionalidad.

El usuario debe poder llevarse todo lo suyo, en formatos abiertos, sin pérdida y sin depender de OpoSpeak.

Este documento desarrolla lo establecido en `define-privacy-and-export-strategy`.

---

# **Resultado esperado**

Un paquete exportado debe permitir:

- conservar un respaldo completo
- migrar a otro dispositivo
- abandonar OpoSpeak sin perder nada
- reimportar la información en el futuro

---

# **Qué incluye la exportación**

```txt
Todos los temarios
Todos los temas
Todas las sesiones
Todos los intentos
Todas las grabaciones
Todas las métricas
Todas las notas
```

Nada queda fuera.

El historial completo es exportable.

---

# **Formato del paquete**

## **Decisión**

La exportación produce un paquete: una carpeta comprimida.

```txt
opospeak-export.zip
```

---

## **Motivo**

Los metadatos son datos estructurados.

Las grabaciones son archivos de audio independientes.

Un único paquete mantiene unidos ambos sin mezclar su naturaleza.

---

# **Estructura del paquete**

```txt
opospeak-export/
│
├── manifest.json
├── data/
│     ├── temarios.json
│     ├── temas.json
│     ├── sesiones.json
│     ├── intentos.json
│     ├── metricas.json
│     ├── notas.json
│     └── intentos.csv
│
└── recordings/
      ├── <intentoId>.m4a
      ├── <intentoId>.m4a
      └── ...
```

---

## **Principio**

```txt
data/        → verdad estructurada (JSON)
intentos.csv → conveniencia para hojas de cálculo
recordings/  → evidencia de audio
```

JSON es la fuente de verdad.

CSV es una comodidad, no el formato principal.

---

# **manifest.json**

Describe el paquete y permite validarlo al reimportar.

```json
{
  "format": "opospeak-export",
  "version": 1,
  "exportedAt": "2026-06-11T10:00:00Z",
  "appVersion": "1.0.0",
  "counts": {
    "temarios": 1,
    "temas": 325,
    "sesiones": 84,
    "intentos": 612,
    "grabaciones": 598,
    "notas": 140
  },
  "recordingFormat": "m4a"
}
```

---

## **Reglas del manifest**

- `format` identifica el tipo de paquete.
- `version` permite evolucionar el esquema sin romper paquetes antiguos.
- `counts` permite verificar integridad al importar.

---

# **Esquema de datos**

El esquema sigue el modelo de `define-core-domain-model`.

Todos los identificadores son estables y permiten reconstruir las relaciones.

Todas las fechas se expresan en ISO 8601 con zona horaria.

---

## **temarios.json**

```json
[
  {
    "id": "TEM-001",
    "nombre": "Judicatura",
    "descripcion": null,
    "fechaCreacion": "2025-09-01T08:00:00Z",
    "fechaActualizacion": "2026-05-20T19:30:00Z"
  }
]
```

---

## **temas.json**

```json
[
  {
    "id": "T-0042",
    "temarioId": "TEM-001",
    "numero": 42,
    "titulo": "Responsabilidad patrimonial",
    "activo": true,
    "fechaCreacion": "2025-09-01T08:05:00Z",
    "fechaActualizacion": "2025-09-01T08:05:00Z"
  }
]
```

`titulo` puede ser `null`, como permite `define-topic-management-flow`.

---

## **sesiones.json**

```json
[
  {
    "id": "S-0084",
    "fechaInicio": "2026-05-12T09:00:00Z",
    "fechaFin": "2026-05-12T09:45:00Z",
    "duracion": 2700,
    "tipo": "practica_individual",
    "observaciones": null
  }
]
```

`duracion` se expresa en segundos.

---

## **intentos.json**

```json
[
  {
    "id": "I-0612",
    "temaId": "T-0042",
    "sesionId": "S-0084",
    "fechaInicio": "2026-05-12T09:10:00Z",
    "fechaFin": "2026-05-12T09:21:48Z",
    "duracionReal": 708,
    "completado": true,
    "grabacionId": "I-0612"
  }
]
```

---

## **grabaciones**

Las grabaciones no llevan archivo JSON propio separado.

Sus metadatos viajan dentro del intento o en una sección del propio archivo de intentos, y el audio vive en `recordings/`.

```json
{
  "grabacionId": "I-0612",
  "archivo": "recordings/I-0612.m4a",
  "duracion": 708,
  "tamano": 5734400,
  "formato": "m4a",
  "fechaCreacion": "2026-05-12T09:21:48Z"
}
```

El nombre del archivo de audio coincide con el identificador del intento.

Esto hace la relación evidente sin necesidad de un índice adicional.

---

## **metricas.json**

```json
[
  {
    "id": "M-1001",
    "intentoId": "I-0612",
    "tipo": "duracion_total",
    "valor": 708,
    "fecha": "2026-05-12T09:21:48Z"
  }
]
```

El campo `tipo` es extensible para métricas futuras, como anota `define-core-domain-model`.

---

## **notas.json**

```json
[
  {
    "id": "N-0140",
    "intentoId": "I-0612",
    "contenido": "Demasiado rápido al inicio.",
    "fechaCreacion": "2026-05-12T09:25:00Z"
  }
]
```

---

## **intentos.csv**

Vista plana y legible del historial para hojas de cálculo.

```txt
intentoId,temario,tema,numero,fecha,duracionSegundos,completado,tieneGrabacion,tieneNotas
I-0612,Judicatura,Responsabilidad patrimonial,42,2026-05-12,708,true,true,true
```

El CSV es una proyección.

No contiene nada que no esté ya en los JSON.

---

# **Formato de las grabaciones**

## **Decisión**

Las grabaciones se exportan en su formato original.

```txt
m4a
```

---

## **Principio**

No se recodifica el audio al exportar.

El usuario se lleva exactamente el archivo que se grabó.

---

# **Identificadores**

## **Regla**

Los identificadores son estables y únicos dentro del paquete.

Permiten reconstruir todas las relaciones:

```txt
temario → tema → intento → grabación / métricas / notas
```

Un paquete debe ser autosuficiente: ninguna relación depende de información externa.

---

# **Exportación puntual**

Además del paquete completo, debe poder exportarse un único intento.

```txt
intento-I-0612/
├── intento.json
├── notas.json
└── I-0612.m4a
```

Sigue el mismo esquema, reducido a un solo intento.

Útil para compartir una práctica concreta, por ejemplo con un preparador.

---

# **Reimportación**

## **Principio**

Todo lo que OpoSpeak exporta, OpoSpeak debe poder reimportarlo.

El paquete es a la vez exportación y respaldo.

---

## **Validación**

Al importar, se usa `manifest.json` para:

- comprobar el formato
- comprobar la versión
- verificar los conteos
- detectar grabaciones ausentes

---

## **Versionado**

El campo `version` del manifest permite que versiones futuras lean paquetes antiguos.

Nunca se rompe la lectura de un paquete anterior sin una ruta de migración.

---

# **Restricciones estratégicas**

No usar formatos propietarios.

No cifrar el paquete de forma que el usuario no pueda abrirlo.

No recodificar ni degradar el audio.

No omitir datos del usuario en la exportación.

No exigir conexión ni cuenta para exportar.

---

# **Métrica de éxito**

Un usuario debe poder:

1. Exportar todo su historial.
2. Abrir el paquete fuera de OpoSpeak.
3. Entender su contenido sin la aplicación.
4. Reimportarlo sin pérdida.

---

# **Resultado esperado**

El paquete de exportación debe transmitir una idea clara:

Los datos son del usuario.

OpoSpeak solo los organiza.

Si algún día el usuario decide marcharse, debe poder hacerlo llevándose años de entrenamiento intactos, legibles y reutilizables.

---

Hay una decisión de esquema que dejaría anotada para resolver al implementar:

**Si los metadatos de la grabación viven dentro de `intentos.json` o en un `grabaciones.json` propio.**

En el modelo de dominio, Grabación es una entidad independiente con relación `1:0..1` respecto al intento. Lo más coherente sería un `grabaciones.json` separado. Pero en la práctica, como cada intento tiene como máximo una grabación y comparten identificador, incrustar los metadatos en el intento simplifica mucho el paquete.

Me inclino por incrustarlos en el MVP y separarlos solo si en el futuro un intento pudiera tener varias grabaciones. Lo dejo como decisión abierta para no sobrediseñar el formato antes de validar el MVP.
