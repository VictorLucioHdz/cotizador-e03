# Taller 5 · Composición o herencia

Nombre: Victor Armando Lucio Hernandez
Número de control: 21100233
Equipo: 03

Copia este archivo a `talleres/27-oct/<tu número de control>/respuestas.md` en el repositorio de tu
equipo, junto con tu `composicion.ts`. Entrega: martes 27 de octubre, 23:59.

## Paso 1 · La herencia

**a)** ¿En qué dos clases está escrito el cálculo del seguro? ¿Por qué no se pudo escribir una sola
vez?

Está escrito en ConSeguro y en RefrigeradaConSeguro. No se pudo escribir una sola vez porque TypeScript no soporta herencia múltiple y RefrigeradaConSeguro ya hereda de Refrigerada para obtener el extra de frío, por lo que no puede heredar al mismo tiempo de ConSeguro, obligando a duplicar el cálculo del seguro.

**b)** Con un tercer extra (express), ¿cuántas clases hacen falta para todas las combinaciones?
¿Cuántas son nuevas? Muestra la cuenta.

Hacen falta 8 clases en total y 4 son nuevas, cada extra puede estar presente o ausente y con 3 extras son 2 x 2 x 2 = 8 combinaciones posibles. Como ya teníamos 4 clases hechas en el código, quedan 8 - 4 = 4 clases nuevas

## Paso 2 · La composición

**c)** Para agregar express a `composicion.ts`, ¿qué agregaste? ¿Cambió `cotizar`?

Solo tuve que agregar la función para express en una línea: export const express: Ajuste = (monto) => monto + 50000; La función cotizar no cambió en nada, porque como usa reduce, le da igual cuántos extras le mandes en la lista, simplemente los recorre y los va aplicando uno por uno.

## Paso 3 · El orden

| Llamada                                 | Predigo | Salió  |
| --------------------------------------- | ------- | ------ |
| `cotizar(100, 1000, [express, seguro])` | 153000  | 153000 |
| `cotizar(100, 1000, [seguro, express])` | 152000  | 152000 |

**d)** ¿Por qué salen distintos? (dos líneas)

Porque si va express primero, suma los $500 antes y el seguro del 2% se cobra sobre el total ya inflado. En cambio si va seguro primero, el 2% solo se le aplica al flete base y los $500 de express se suman tal cual al final.

## Paso 4 · Sostén la decisión

**e)** En su modelo del proyecto, ¿cómo están escritos los pasos del cálculo: con herencia o con
composición? Cita el archivo y la función.

**f)** Da **un** caso, en su proyecto o fuera de él, donde sí usarías herencia, y di por qué ahí no
hay explosión de combinaciones. (tres líneas)
