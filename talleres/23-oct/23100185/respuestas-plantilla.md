# Taller 4 · De condicionales a despacho

Nombre: Diego Alonso Molina Gaytan  
Número de control: 23100185
Equipo: e03

Copia este archivo a `talleres/23-oct/<tu número de control>/respuestas.md` en el repositorio de tu
equipo, junto con tu `despacho.ts`. Entrega: viernes 23 de octubre, 23:59.

## Paso 1 · La versión con switch

**a)** Antes de tocar nada: ¿cuántos lugares de `condicionales.ts` hay que cambiar para agregar
`perecedera`?
Según lo que veo debemos de modificar 4 lugares como en la definición del tipo `Tipo`, y en los switch de las funciones `recargo`, `documentoRequerido`y `etiqueta` solo en caso de que se quiera agregar cada uno de ellos si no pues depende si se quiere agregar solo una o dos cosas también se puede.

**b)** Después de agregar `'perecedera'` solo al tipo: ¿qué dijo `tsc`, y qué imprimió la
demostración para perecedera?
`tsc` no arrojó ningún error ni advertencia y la demostración imprimió `perecedera  0  null  General`

**c)** ¿Por qué el compilador no te avisó? (una línea)
Porque los tres `switch` tienen una `default` que hace que no marque error.

## Paso 3 · La versión con tabla

**d)** Después de agregar `'perecedera'` al tipo: ¿qué dijo `tsc`? Copia el mensaje.
Property 'perecedera' is missing in type '{ general: { pct: number; fija: number; documento: null; etiqueta: string; }; refrigerada: { pct: number; fija: number; documento: null; etiqueta: string; }; peligrosa: { pct: number; fija: number; documento: "numeroUn"; etiqueta: string; }; sobredimensionada: { ...; }; }' but required in type 'Record<Tipo, Politica>'

**e)** ¿Cuántos lugares cambiaste en `despacho.ts` para agregar perecedera?
Solo 2 lugares que es agregar `'perecedera'` al `Tipo` y agregar su entrada dentro del objeto `POLITICAS`.

## Los dos lenguajes

**f)** En su motor de Elixir, ¿qué pasa si llega un tipo de carga para el que no hay cláusula? ¿Y en
`despacho.ts`, si a la tabla le falta un tipo? ¿Cuál de los dos te avisa antes, y cuándo? (dos líneas)
En Elixir arroja `FunctionClauseError` al ejecutar, mientras que en `despacho.ts` falla al compilar.
TypeScript avisa antes en tiempo de compilación y elixir al ejecutar.
