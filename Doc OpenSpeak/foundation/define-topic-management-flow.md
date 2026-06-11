
## **Estado**

Propuesto

---

# **Objetivo**

Definir cómo el usuario crea, organiza y mantiene sus temarios y temas dentro de OpoSpeak.

Este documento describe el flujo de gestión de temas desde una perspectiva de producto y dominio.

No define diseño visual ni implementación técnica.

---

# **Principio fundamental**

OpoSpeak organiza temas.

No proporciona temarios.

No vende contenido.

No sustituye a una academia ni a un preparador.

---

# **Resultado esperado**

El usuario debe poder crear una estructura básica de estudio y empezar a practicar sin una configuración pesada.

---

# **Conceptos principales**

## **Oposición**

Raíz del dominio: el proceso selectivo que el opositor prepara.

Ejemplos:

- Judicatura
- Notarías
- Inspección de Hacienda

Judicatura NO es un temario. Es una oposición.

---

## **Temario**

Agrupación lógica de temas dentro de una oposición.

Ejemplos:

- Civil
- Penal
- Procesal
- Bloque 1
- Segundo ejercicio

---

## **Tema**

Unidad concreta que puede ser practicada oralmente.

Ejemplos:

- Tema 1
- Tema 42
- Tema 178
- Responsabilidad patrimonial
- Impuesto sobre Sociedades

---

# **Flujo inicial recomendado**

```txt
Crear oposición
      ↓
Crear temario
      ↓
Añadir temas
      ↓
Seleccionar tema
      ↓
Practicar
```

La oposición se crea una vez (normalmente en el primer arranque) y la aplicación trabaja sobre ella.

---

# **Creación de temario**

## **Información mínima**

- Nombre del temario

---

## **Información opcional**

- Descripción
- Oposición
- Número estimado de temas
- Orden personalizado

---

## **Regla**

La creación debe ser rápida.

El usuario no debe tener que completar una ficha compleja para empezar.

---

# **Creación de temas**

## **Información mínima**

- Número o identificador
- Título opcional

---

## **Información opcional**

- Bloque
- Notas internas
- Estado
- Objetivo de duración

---

## **Regla importante**

El título del tema puede estar vacío.

Muchos opositores pueden querer trabajar solo con:

- Tema 1
- Tema 2
- Tema 3

sin introducir el título completo.

---

# **Alta rápida de temas**

OpoSpeak debe permitir crear muchos temas de forma rápida.

Ejemplo:

```txt
Crear temas del 1 al 325
```

Resultado:

```txt
Tema 1
Tema 2
Tema 3
...
Tema 325
```

---

# **Importación futura**

El modelo debe permitir importar temas desde:

- texto pegado
- CSV
- archivo estructurado
- paquete de respaldo de OpoSpeak

---

# **Organización**

El usuario debe poder:

- reordenar temas
- agrupar por bloques
- activar o desactivar temas
- buscar temas
- filtrar temas

---

# **Estados de tema**

## **Estado inicial recomendado**

- Activo
- Archivado

---

## **Estados futuros posibles**

- Pendiente
- En estudio
- En repaso
- Dominado
- Problemático

---

## **Decisión inicial**

No introducir estados complejos en el MVP.

El progreso debe deducirse primero de la práctica real, no de etiquetas manuales.

---

# **Tema archivado**

Un tema archivado:

- no aparece en las listas principales
- mantiene su historial
- puede restaurarse
- no borra intentos ni grabaciones

---

# **Edición de tema**

El usuario puede editar:

- número
- título
- bloque
- notas
- objetivo de duración

---

# **Eliminación de tema**

## **Riesgo**

Eliminar un tema puede afectar a:

- intentos
- grabaciones
- métricas
- estadísticas históricas

---

## **Decisión recomendada**

En MVP, priorizar archivo sobre borrado.

---

## **Borrado definitivo**

Debe existir, pero con confirmación clara.

Al borrar un tema, el usuario debe entender si se eliminan también:

- intentos
- grabaciones
- notas
- métricas

---

# **Búsqueda**

La búsqueda debe permitir localizar rápidamente un tema por:

- número
- título
- bloque

---

# **Ordenación**

Opciones iniciales:

- orden natural del temario
- más practicados
- menos practicados
- últimos practicados
- pendientes de práctica

---

# **Información visible en listado**

Cada tema debería mostrar, como mínimo:

- número o identificador
- título si existe
- último intento
- número de intentos

---

# **Información visible en detalle**

El detalle de tema debe mostrar:

- información básica
- historial de intentos
- evolución temporal
- acceso rápido a practicar

---

# **Acción principal**

La acción principal de un tema es:

```txt
Practicar
```

No:

```txt
Editar
```

No:

```txt
Leer
```

No:

```txt
Estudiar
```

---

# **Restricciones estratégicas**

OpoSpeak no debe almacenar el contenido completo de los temas como funcionalidad principal.

Puede permitir títulos, notas o referencias, pero no debe convertirse en gestor de temarios jurídicos.

---

# **Casos futuros**

El flujo debe permitir más adelante:

## **Extracción aleatoria**

Seleccionar uno o varios temas aleatorios para practicar.

---

## **Simulacros**

Agrupar varios temas en una práctica compuesta.

---

## **Plantillas**

Crear estructuras predefinidas de bloques sin incluir contenido legal protegido.

---

## **Importación desde texto**

Pegar una lista de temas y convertirla en estructura.

---

# **Métrica de éxito**

Un usuario debe poder crear su primer temario y empezar a practicar en menos de dos minutos.

---

# **Resultado esperado**

OpoSpeak debe dar al opositor una sensación inmediata de orden.

No porque le dé contenido.

Sino porque transforma una lista caótica de temas y audios en un sistema de práctica organizado.