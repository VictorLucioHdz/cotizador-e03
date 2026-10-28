# Taller 4 · De condicionales a despacho

Nombre: Victor Armando Lucio Hernandez
Número de control: 21100233
Equipo: 03

## Paso 1 · La versión con switch

**a)** Antes de tocar nada: ¿cuántos lugares de `condicionales.ts` hay que cambiar para agregar
`perecedera`?

Hay que cambiar 4 lugares: el tipo Tipo y los tres switch dentro de
recargo, documentoRequerido y etiqueta.

**b)** Después de agregar `'perecedera'` solo al tipo: ¿qué dijo `tsc`, y qué imprimió la
demostración para perecedera?
tsc --noEmit no dijo nada. La demostración imprimió: perecedera 0 null General recargo 0, sin documento y etiqueta "General, porque los tres switch tienen default
y el tipo nuevo cayó ahí silenciosamente.

**c)** ¿Por qué el compilador no te avisó? (una línea)

Porque los switch tienen una cláusula default que absorbe cualquier caso no listado, así que
TypeScript no detecta que falta un caso para el tipo nuevo.

## Paso 3 · La versión con tabla

**d)** Después de agregar `'perecedera'` al tipo: ¿qué dijo `tsc`? Copia el mensaje.

```
error TS2322: Type '{ peligrosa: ...; general: ...; refrigerada: ...; sobredimensionada: ...; }'
is not assignable to type 'Record<Tipo, Politica>'.
Property 'perecedera' is missing in type '...' but required in type 'Record<Tipo, Politica>'.
```

TypeScript se quejó indicando exactamente qué llave faltaba en la tabla.

**e)** ¿Cuántos lugares cambiaste en `despacho.ts` para agregar perecedera?

Solo 1 agregar la entrada perecedera a la tabla POLITICAS. Las tres funciones no se tocaron.

## Los dos lenguajes

**f)** En su motor de Elixir, ¿qué pasa si llega un tipo de carga para el que no hay cláusula? ¿Y en
`despacho.ts`, si a la tabla le falta un tipo? ¿Cuál de los dos te avisa antes, y cuándo? (dos líneas)

En Elixir lanza un `FunctionClauseError` **en tiempo de ejecución**, cuando el mensaje llega y
ninguna cláusula encaja. En `despacho.ts` con `Record<Tipo, Politica>`, TypeScript lo detecta
**en tiempo de compilación**, antes de correr el programa; `despacho.ts` avisa antes.
