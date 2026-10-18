# PRUEBAS DE ACEPTACION · Segundo parcial · Programacion Multiparadigma
# Equipo E03. Generado por el docente: NO se edita. Si una prueba te parece mal, abre un issue.
defmodule AceptacionTest do
  use ExUnit.Case, async: true

  @reglas %{
    tarifa_km: 3900,
    cuota_puente: %{comercio_mundial: 52000, colombia: 33500},
    descuento: %{umbral_kg: 12000, pct: 6, criterio: :a_partir_de},
    recargo: %{
      general: %{pct: 0, fija: 0},
      refrigerada: %{pct: 12, fija: 15000},
      peligrosa: %{pct: 25, fija: 50000},
      sobredimensionada: %{pct: 45, fija: 120_000}
    },
    base_recargo: :flete,
    minimo: 380_000,
    peso_maximo_kg: 30000
  }

  describe "cotizar/2" do
    test "carga general por debajo del umbral: flete mas cuota, sin descuento" do
      assert {:ok, c} =
               Cotizador.cotizar(
                 %{
                   id: "V01",
                   peso_kg: 6000,
                   distancia_km: 220,
                   tipo: :general,
                   puente: :comercio_mundial,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )

      assert c.flete_bruto == 858_000
      assert c.descuento == 0
      assert c.flete == 858_000
      assert c.cuota_puente == 52000
      assert c.recargo == 0
      assert c.ajuste_minimo == 0
      assert c.total == 910_000
    end

    test "peso EXACTAMENTE en el umbral (12000 kg): lee tu criterio" do
      assert {:ok, c} =
               Cotizador.cotizar(
                 %{
                   id: "V02",
                   peso_kg: 12000,
                   distancia_km: 220,
                   tipo: :general,
                   puente: :comercio_mundial,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )

      assert c.flete_bruto == 858_000
      assert c.descuento == 51480
      assert c.flete == 806_520
      assert c.cuota_puente == 52000
      assert c.recargo == 0
      assert c.ajuste_minimo == 0
      assert c.total == 858_520
    end

    test "un kilo arriba del umbral siempre lleva descuento" do
      assert {:ok, c} =
               Cotizador.cotizar(
                 %{
                   id: "V03",
                   peso_kg: 12001,
                   distancia_km: 220,
                   tipo: :general,
                   puente: :comercio_mundial,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )

      assert c.flete_bruto == 858_000
      assert c.descuento == 51480
      assert c.flete == 806_520
      assert c.cuota_puente == 52000
      assert c.recargo == 0
      assert c.ajuste_minimo == 0
      assert c.total == 858_520
    end

    test "refrigerada paga su recargo" do
      assert {:ok, c} =
               Cotizador.cotizar(
                 %{
                   id: "V04",
                   peso_kg: 5000,
                   distancia_km: 240,
                   tipo: :refrigerada,
                   puente: :comercio_mundial,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )

      assert c.flete_bruto == 936_000
      assert c.descuento == 0
      assert c.flete == 936_000
      assert c.cuota_puente == 52000
      assert c.recargo == 127_320
      assert c.ajuste_minimo == 0
      assert c.total == 1_115_320
    end

    test "peligrosa con numero UN paga recargo y cuota fija" do
      assert {:ok, c} =
               Cotizador.cotizar(
                 %{
                   id: "V05",
                   peso_kg: 12500,
                   distancia_km: 260,
                   tipo: :peligrosa,
                   puente: :comercio_mundial,
                   numero_un: "UN1203",
                   permiso: nil
                 },
                 @reglas
               )

      assert c.flete_bruto == 1_014_000
      assert c.descuento == 60840
      assert c.flete == 953_160
      assert c.cuota_puente == 52000
      assert c.recargo == 288_290
      assert c.ajuste_minimo == 0
      assert c.total == 1_293_450
    end

    test "sobredimensionada con permiso puede pasar del peso maximo" do
      assert {:ok, c} =
               Cotizador.cotizar(
                 %{
                   id: "V06",
                   peso_kg: 34000,
                   distancia_km: 190,
                   tipo: :sobredimensionada,
                   puente: :comercio_mundial,
                   numero_un: nil,
                   permiso: "SCT-4471"
                 },
                 @reglas
               )

      assert c.flete_bruto == 741_000
      assert c.descuento == 44460
      assert c.flete == 696_540
      assert c.cuota_puente == 52000
      assert c.recargo == 433_443
      assert c.ajuste_minimo == 0
      assert c.total == 1_181_983
    end

    test "el puente Colombia tiene su propia cuota" do
      assert {:ok, c} =
               Cotizador.cotizar(
                 %{
                   id: "V07",
                   peso_kg: 5000,
                   distancia_km: 200,
                   tipo: :general,
                   puente: :colombia,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )

      assert c.flete_bruto == 780_000
      assert c.descuento == 0
      assert c.flete == 780_000
      assert c.cuota_puente == 33500
      assert c.recargo == 0
      assert c.ajuste_minimo == 0
      assert c.total == 813_500
    end

    test "un viaje corto paga el minimo" do
      assert {:ok, c} =
               Cotizador.cotizar(
                 %{
                   id: "V08",
                   peso_kg: 900,
                   distancia_km: 15,
                   tipo: :general,
                   puente: :comercio_mundial,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )

      assert c.flete_bruto == 58500
      assert c.descuento == 0
      assert c.flete == 58500
      assert c.cuota_puente == 52000
      assert c.recargo == 0
      assert c.ajuste_minimo == 269_500
      assert c.total == 380_000
    end

    test "rechaza peso cero" do
      assert {:error, :peso_invalido} =
               Cotizador.cotizar(
                 %{
                   id: "X01",
                   peso_kg: 0,
                   distancia_km: 220,
                   tipo: :general,
                   puente: :comercio_mundial,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )
    end

    test "rechaza distancia negativa" do
      assert {:error, :distancia_invalida} =
               Cotizador.cotizar(
                 %{
                   id: "X02",
                   peso_kg: 5000,
                   distancia_km: -5,
                   tipo: :general,
                   puente: :comercio_mundial,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )
    end

    test "rechaza carga general arriba del peso maximo" do
      assert {:error, :excede_peso_maximo} =
               Cotizador.cotizar(
                 %{
                   id: "X03",
                   peso_kg: 30001,
                   distancia_km: 220,
                   tipo: :general,
                   puente: :comercio_mundial,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )
    end

    test "rechaza peligrosa sin numero UN" do
      assert {:error, :falta_numero_un} =
               Cotizador.cotizar(
                 %{
                   id: "X04",
                   peso_kg: 5000,
                   distancia_km: 220,
                   tipo: :peligrosa,
                   puente: :comercio_mundial,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )
    end

    test "rechaza sobredimensionada sin permiso" do
      assert {:error, :falta_permiso} =
               Cotizador.cotizar(
                 %{
                   id: "X05",
                   peso_kg: 5000,
                   distancia_km: 220,
                   tipo: :sobredimensionada,
                   puente: :comercio_mundial,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )
    end

    test "rechaza un tipo de carga que no existe" do
      assert {:error, :tipo_desconocido} =
               Cotizador.cotizar(
                 %{
                   id: "X06",
                   peso_kg: 5000,
                   distancia_km: 220,
                   tipo: :granel,
                   puente: :comercio_mundial,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )
    end

    test "rechaza un puente que no existe" do
      assert {:error, :puente_desconocido} =
               Cotizador.cotizar(
                 %{
                   id: "X07",
                   peso_kg: 5000,
                   distancia_km: 220,
                   tipo: :general,
                   puente: :laredo_iv,
                   numero_un: nil,
                   permiso: nil
                 },
                 @reglas
               )
    end
  end

  describe "resumen/2" do
    test "lote mixto: cuenta, suma y separa los rechazados" do
      lote = [
        %{
          id: "L1",
          peso_kg: 12010,
          distancia_km: 220,
          tipo: :general,
          puente: :comercio_mundial,
          numero_un: nil,
          permiso: nil
        },
        %{
          id: "L2",
          peso_kg: 5000,
          distancia_km: 220,
          tipo: :refrigerada,
          puente: :colombia,
          numero_un: nil,
          permiso: nil
        },
        %{
          id: "L3",
          peso_kg: 0,
          distancia_km: 220,
          tipo: :general,
          puente: :comercio_mundial,
          numero_un: nil,
          permiso: nil
        },
        %{
          id: "L4",
          peso_kg: 5000,
          distancia_km: 220,
          tipo: :peligrosa,
          puente: :comercio_mundial,
          numero_un: nil,
          permiso: nil
        },
        %{
          id: "L5",
          peso_kg: 5000,
          distancia_km: 30,
          tipo: :general,
          puente: :colombia,
          numero_un: nil,
          permiso: nil
        },
        %{
          id: "L6",
          peso_kg: 30100,
          distancia_km: 220,
          tipo: :sobredimensionada,
          puente: :comercio_mundial,
          numero_un: nil,
          permiso: "SCT-4471"
        }
      ]

      r = Cotizador.resumen(lote, @reglas)
      assert r.cotizados == 4
      assert r.rechazados == [{"L3", :peso_invalido}, {"L4", :falta_numero_un}]
      assert r.total == 3_589_434
      assert r.por_puente == %{comercio_mundial: 2_199_974, colombia: 1_389_460}
    end
  end
end
