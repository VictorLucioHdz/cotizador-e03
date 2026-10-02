# Taller · quitar la mutación

Nombre:
Número de control:
Equipo:

Copia este archivo a `talleres/01-oct/<tu número de control>/respuestas.md` en el repositorio de tu equipo,
junto con tu `sin_mutacion.ex`, y llena la tabla. Entrega: hoy antes de las 23:59.

| # | Función           | ¿Qué muta la versión de TypeScript?   | ¿Quién más se entera del cambio?  |
| 1 | total_pesos       |  El acumulador                        |  Local                            |
| 2 | marcar_urgentes   |  Los objetos prestados                |  Quien los tenga                  |
| 3 | aplicar_descuento |  El arreglo prestado                  |  Quien los mando                  |
| 4 | contar_por_tipo   |  Contador local                       |  Nadie                            |
| 5 | sin_duplicados    |  Set y el arreglo                     |  Nadie                            |

¿Cuál de las cinco era la más peligrosa en TypeScript, y por qué? (dos líneas)
La 2 porque modifica directamente un objetos y si en otra función se utiliza el objeto ese, pues no sabra que se modifico y tal vez esa función no la necesita modificada
