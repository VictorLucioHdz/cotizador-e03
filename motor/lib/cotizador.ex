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

  # Etapa 2 · El flete (meta: viernes 16)

  # Ahora `calcular/2`. En esta etapa: flete bruto, descuento, flete y cuota del puente. El recargo y el
  # mínimo todavía en 0 (la prueba "por debajo del umbral" es carga general: su recargo **es** 0).

  # **El redondeo,** que va a usar todo lo que tenga porcentaje. Viene en el enunciado; escríbanlo una vez:

  # ```elixir
  # # un porcentaje, redondeado al centavo, las mitades hacia arriba
  # defp pct(monto, p), do: div(monto * p + 50, 100)
  # ```

  # **El descuento** depende del criterio de su variante, y ahí está la prueba "EXACTAMENTE en el
  # umbral". Tracen esa prueba a mano antes de escribir: con su criterio, ¿el peso exacto lleva
  # descuento o no?

  # <details><summary>Pista · el criterio, sin if</summary>

  # Una función con dos cláusulas que reciba el peso y `reglas.descuento`, y decida con el patrón del
  # criterio (`%{criterio: :a_partir_de, umbral_kg: u}` contra `%{criterio: :mas_de, umbral_kg: u}`) y
  # una guarda con `>=` o `>`. Las reglas traen las dos llaves; ustedes no escriben ningún número.
  # </details>

  # <details><summary>Pista · la cuota del puente</summary>

  # `Map.fetch!(reglas.cuota_puente, embarque.puente)`. El `!` es a propósito: si el puente no existiera,
  # truena. Pero ya no puede pasar, porque `validar` lo rechazó antes.
  # </details>

  # **Listo cuando:** pasan las 7 de "rechaza" y las 4 de esta etapa (16 pruebas, 5 fallas).

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

  defp pct(monto, p), do: div(monto * p + 50, 100)

  defp calcular_descuento(peso, flete_bruto, %{criterio: :a_partir_de, umbral_kg: u, pct: p})
       when peso >= u do
    pct(flete_bruto, p)
  end

  defp calcular_descuento(peso, flete_bruto, %{criterio: :mas_de, umbral_kg: u, pct: p})
       when peso > u do
    pct(flete_bruto, p)
  end

  defp calcular_descuento(_peso, _flete_bruto, _descuento_cfg), do: 0

  # Etapa 3 · Recargos y mínimo (meta: miércoles 21)

  # - `Map.fetch!(reglas.recargo, embarque.tipo)` les da `%{pct: _, fija: _}`.
  # - **La base** del porcentaje depende de `reglas.base_recargo`: `:flete` o `:subtotal` (flete más
  #   cuota). Igual que el criterio: **dos cláusulas**, no un `if`.
  # - El total nunca baja de `reglas.minimo`; `ajuste_minimo` es lo que se sumó para llegar (casi
  #   siempre 0). `max/2` existe.

  # Antes de escribir, hagan a mano la prueba "refrigerada paga su recargo" de su variante (lo hicieron
  # en el arranque): si su cuenta a mano no da, el código tampoco va a dar.
  # Ajuste mínimo cuando no alcanza la tarifa mínima
  defp calcular_ajuste_minimo(subtotal, minimo) when subtotal < minimo do
    {minimo - subtotal, minimo}
  end

  # Ajuste mínimo cuando iguala o supera la tarifa mínima
  defp calcular_ajuste_minimo(subtotal, _minimo) do
    {0, subtotal}
  end
end
