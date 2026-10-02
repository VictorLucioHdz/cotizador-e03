defmodule SinMutacion do
  @moduledoc """
  Martes 29 · Taller: quitar la mutacion.

  Cada funcion es la traduccion de una funcion imperativa de TypeScript que esta en
  `../imperativo.ts`. Alla mutan. Aqui no se puede. Reemplaza cada `raise` y corre:

      mix test test/sin_mutacion_test.exs
  """

  def total_pesos(embarques), do: total_pesos(embarques, 0)

  defp total_pesos([], total), do: total
  defp total_pesos([%{peso_kg: peso} | cola], total), do: total_pesos(cola, total + peso)

  def marcar_urgentes(embarques), do: marcar_urgentes(embarques, [])

  defp marcar_urgentes([], acumulado), do: invertir(acumulado)
  defp marcar_urgentes([%{distancia_km: distancia} = embarque | cola], acumulado) do
    marcado = Map.put(embarque, :urgente, distancia > 500)
    marcar_urgentes(cola, [marcado | acumulado])
  end

  def aplicar_descuento(precios, pct), do: aplicar_descuento(precios, pct, [])

  defp aplicar_descuento([], _pct, acumulado), do: invertir(acumulado)
  defp aplicar_descuento([precio | cola], pct, acumulado) do
    descuento = div(precio * pct + 50, 100)
    aplicar_descuento(cola, pct, [precio - descuento | acumulado])
  end

  def contar_por_tipo(embarques), do: contar_por_tipo(embarques, %{})

  defp contar_por_tipo([], conteo), do: conteo
  defp contar_por_tipo([%{tipo: tipo} | cola], conteo) do
    conteo_actualizado = Map.update(conteo, tipo, 1, fn cantidad -> cantidad + 1 end)
    contar_por_tipo(cola, conteo_actualizado)
  end

  def sin_duplicados(ids), do: sin_duplicados(ids, %{}, [])

  defp sin_duplicados([], _vistos, acumulado), do: invertir(acumulado)
  defp sin_duplicados([id | cola], vistos, acumulado) do
    if Map.has_key?(vistos, id) do
      sin_duplicados(cola, vistos, acumulado)
    else
      sin_duplicados(cola, Map.put(vistos, id, true), [id | acumulado])
    end
  end

  defp invertir(lista), do: invertir(lista, [])
  defp invertir([], acumulado), do: acumulado
  defp invertir([cabeza | cola], acumulado), do: invertir(cola, [cabeza | acumulado])
end
