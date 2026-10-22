# Taller 3 · La mutación escondida

Nombre: Diego Alonso Molina Gaytan
Número de control: 23100185
Equipo: 3

Copia este archivo a `talleres/16-oct/<tu número de control>/respuestas.md` en el repositorio de tu
equipo, junto con tu `escondida.ex`. Entrega: viernes 16 de octubre, 23:59.

## 1 · Antes y después de ejecutar

Llena "Predigo" **antes** de correr `npx tsx escondida.ts`. No borres las predicciones que fallaron.

| Línea | Predigo               | Salió             |
|---    |---                    |---                |
| 1 ·   | `1 · B,A true`        | `1 · B,A true`    |
| 2 ·   | `2 · 10 true`         | `2 · 10 true`     |
| 3 ·   | `3 · 1 false`         | `3 · 2 true`      |
| 4 ·   | `4 · undefined false` | `4 · SCT-77 false`|
| 5 ·   | `5 · 15 15`           | `5 · 15 15`       |

## 2 · Qué se muta y quién se entera

| # | Función           | ¿Qué línea muta, y qué cambia? | ¿Quién más se entera del cambio? |
|---|---                |---|---|
| 1 | ordenarPorPeso    | embarques.sort cambia el orden de la lista original.| Cualquier otra parte del programa que use la variable lote |
| 2 | conDescuento      | reglas.descuentoPct = pct le cambia el porcentaje al objeto recibido| Todos los clientes que usen las reglas base|
| 3 | registrar         | vistos.push(id) agrega el id al arreglo que está afuera| Quien sea que consulte la lista compartida vistos|
| 4 | conPermiso        | copia.documentos.permiso = permiso modifica el permiso dentro de documentos| El objeto original, porque ambos comparten el mismo mapa de documentos|
| 5 | fechaDeEntrega    | salida.setDate adelanta los días de la fecha original | Cualquier lugar donde se use la fecha de salida original|

## 3 · Tres preguntas cortas

**a)** En la línea 4 salió `false` en `original === conP`, y aun así el original cambió. ¿Cómo es
posible? 
Porque { ...e } solo clonó lo de afuera pero documentos sigue siendo lo mismo para los dos

**b)** ¿Por qué `registrar` no es una función pura?
Porque modifica una variable externa en vez de solo regresar un cálculo basado en sus argumentos

**c)** En tus pruebas de Elixir, la última aserción de cada una revisa que el original sigue igual.
¿Por qué en Elixir esa aserción no puede fallar?
Porque en Elixir todas las variables y datos son inmutables y pues no existe forma de modificar lo que ya se creó en memoria
