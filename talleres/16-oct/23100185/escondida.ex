defmodule Escondida do
  # Taller 3 · La mutación escondida, en Elixir.
  # Las mismas cinco funciones de escondida.ts, pero aquí no hay nada que esconder:
  # cada una regresa un valor NUEVO y no puede tocar lo que recibió.
  # Reemplaza cada raise("por implementar").

  # 1 · Del más ligero al más pesado. Pista: Enum.sort_by/2.
  def ordenar_por_peso(embarques) do
    Enum.sort_by(embarques, fn e -> e.peso end)
  end
  # 2 · Las mismas reglas con otro descuento_pct. Pista: %{mapa | llave: valor}.
  def con_descuento(reglas, pct) do
    %{reglas | descuento_pct: pct}
  end
  # 3 · En TypeScript la lista de vistos era una variable global que todos compartían.
  #     Aquí la lista ENTRA como argumento y sale una lista nueva con el id al final.
  def registrar(vistos, id) do
    vistos ++ [id]
  end

  # 4 · El embarque con su permiso dentro de documentos. Ojo: documentos es un mapa
  #     dentro de otro mapa. Hay que hacer uno nuevo en los dos niveles.
  def con_permiso(embarque, permiso) do
    %{embarque | permiso: permiso}
  end

  # 5 · La fecha de salida más unos días. Pista: Date.add/2.
  def fecha_de_entrega(salida, dias) do
    Date.add(salida, dias)
  end
end
