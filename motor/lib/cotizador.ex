defmodule Cotizador do
  @tipos [:general, :refrigerada, :peligrosa, :sobredimensionada]

  def cotizar(embarque, reglas) do
    with :ok <- validar(embarque, reglas) do
      {:ok, calcular(embarque, reglas)}
    end
  end

  # 1. Rechaza peso menor o igual a cero
  defp validar(%{peso_kg: p}, _reglas) when p <= 0, do: {:error, :peso_invalido}

  # 2. Rechaza distancia menor o igual a cero
  defp validar(%{distancia_km: d}, _reglas) when d <= 0, do: {:error, :distancia_invalida}

  # 3. Rechaza tipo desconocido
  defp validar(%{tipo: t}, _reglas) when t not in @tipos, do: {:error, :tipo_desconocido}

  # 4. Rechaza puente no registrado en las reglas
  defp validar(%{puente: p}, %{cuota_puente: cuotas}) when not is_map_key(cuotas, p) do
    {:error, :puente_desconocido}
  end

  # 5. Rechaza peligrosa sin número UN
  defp validar(%{tipo: :peligrosa, numero_un: nil}, _reglas), do: {:error, :falta_numero_un}

  # 6. Rechaza sobredimensionada sin permiso
  defp validar(%{tipo: :sobredimensionada, permiso: nil}, _reglas), do: {:error, :falta_permiso}

  # 7. Sobredimensionada con permiso y exenta de límite de peso
  defp validar(%{tipo: :sobredimensionada, permiso: _}, _reglas), do: :ok

  # 8. Rechaza exceso de peso para los demás tipos
  defp validar(%{peso_kg: p}, %{peso_maximo_kg: max}) when p > max,
    do: {:error, :excede_peso_maximo}

  # 9. Caso base exitoso
  defp validar(_embarque, _reglas), do: :ok

  # Función provisional para calcular
  defp calcular(_embarque, _reglas), do: %{}
end
