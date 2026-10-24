defmodule Cotizador do
  @tipos [:general, :refrigerada, :peligrosa, :sobredimensionada]

  def cotizar(embarque, reglas) do
    with :ok <- validar(embarque, reglas) do
      {:ok, calcular(embarque, reglas)}
    end
  end

  def resumen(lote, reglas) do
    acumulador_inicial = %{
      cotizados: 0,
      rechazados: [],
      total: 0,
      por_puente: %{}
    }

    lote
    |> Enum.reduce(acumulador_inicial, fn embarque, acc ->
      acumular(cotizar(embarque, reglas), acc, embarque)
    end)
    |> Map.update!(:rechazados, &Enum.reverse/1)
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

  defp calcular(embarque, reglas) do
    flete_bruto = embarque.distancia_km * reglas.tarifa_km
    descuento = calcular_descuento(embarque.peso_kg, flete_bruto, reglas.descuento)
    flete = flete_bruto - descuento
    cuota_puente = Map.fetch!(reglas.cuota_puente, embarque.puente)

    base_recargo = flete
    recargo_cfg = Map.fetch!(reglas.recargo, embarque.tipo)
    recargo = pct(base_recargo, recargo_cfg.pct) + recargo_cfg.fija

    subtotal = flete + cuota_puente + recargo
    {ajuste_minimo, total} = calcular_ajuste_minimo(subtotal, reglas.minimo)

    %{
      flete_bruto: flete_bruto,
      descuento: descuento,
      flete: flete,
      cuota_puente: cuota_puente,
      recargo: recargo,
      ajuste_minimo: ajuste_minimo,
      total: total
    }
  end

  defp acumular({:ok, cotizacion}, acc, embarque) do
    nuevo_desglose =
      Map.update(acc.por_puente, embarque.puente, cotizacion.total, &(&1 + cotizacion.total))

    %{
      acc
      | cotizados: acc.cotizados + 1,
        total: acc.total + cotizacion.total,
        por_puente: nuevo_desglose
    }
  end

  defp acumular({:error, motivo}, acc, embarque) do
    %{
      acc
      | rechazados: [{embarque.id, motivo} | acc.rechazados]
    }
  end

  # Redondeo bancario
  defp pct(monto, p), do: div(monto * p + 50, 100)

  # Descuento por volumen
  defp calcular_descuento(peso, flete_bruto, %{criterio: :a_partir_de, umbral_kg: u, pct: p})
       when peso >= u do
    pct(flete_bruto, p)
  end

  defp calcular_descuento(peso, flete_bruto, %{criterio: :mas_de, umbral_kg: u, pct: p})
       when peso > u do
    pct(flete_bruto, p)
  end

  defp calcular_descuento(_peso, _flete_bruto, _descuento_cfg), do: 0

  # Ajuste mínimo
  defp calcular_ajuste_minimo(subtotal, minimo) when subtotal < minimo do
    {minimo - subtotal, minimo}
  end

  defp calcular_ajuste_minimo(subtotal, _minimo) do
    {0, subtotal}
  end
end
